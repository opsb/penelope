defmodule Penelope.BotTest do
  use ExUnit.Case
  doctest Penelope
  alias Penelope.Bot

  defmodule FakeWebsocketClient do
    def send({:text, json}, _socket) do
      {:ok, decoded} = Poison.decode(json)
      Kernel.send self, {:socket, decoded}
    end
  end

  test "request review" do
    payload = %{type: "message", text: "please review blah", channel: "pr_reviews_id", user: "jon_id"}
    slack = %{
      users: %{
        "jon_id": %{id: "jon_id", name: "jon", presence: "active", is_bot: false},
        "opsb_id": %{id: "opsb_id", name: "opsb", presence: "active", is_bot: false}
      },
      channels: %{
        "pr_reviews_id" => %{id: "pr_reviews_id", name: "pr_reviews", is_channel: true, members: ["opsb_id", "jon_id"]}
      },
      groups: %{},
      socket: nil,
      client: FakeWebsocketClient
    }
    state_before = %{}

    {:ok, state_after} = Bot.handle_message(payload, slack, state_before)

    assert_received {:socket, %{
      "channel" => "pr_reviews_id",
      "text" => "@opsb kindly review that PR."
    }}

    assert state_after == %{ previous_reviewer_id: "opsb_id" }
  end

  test "request review when no one is available" do
    payload = %{type: "message", text: "please review blah", channel: "pr_reviews_id", user: "jon_id"}
    slack = %{
      users: %{},
      channels: %{
        "pr_reviews_id" => %{id: "pr_reviews_id", name: "pr_reviews", is_channel: true, members: ["opsb_id", "jon_id"]}
      },
      groups: %{},
      socket: nil,
      client: FakeWebsocketClient
    }
    state_before = %{}

    {:ok, state_after} = Bot.handle_message(payload, slack, state_before)

    assert_received {:socket, %{
      "channel" => "pr_reviews_id",
      "text" => "ahem, well this is embarrasing, there doesn't seem to be anyone available..."
    }}

    assert state_after == state_before
  end

  test "ignored message" do
    payload = %{type: "message", text: "please make some tea", channel: "pr_reviews_id", user: "jon_id"}
    state_before = %{}
    {:ok, state_after} = Bot.handle_message(payload, nil, state_before)

    assert state_before == state_after, "state should remain unchanged"
    assert {:message_queue_len, 0} = Process.info(self, :message_queue_len), "no messages should have been sent"
  end
end
