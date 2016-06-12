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
    payload = %{type: "message", text: "please review blah", channel: "#pr_reviews", user: "jon_id"}
    slack = %{
      users: %{
        "jon_id": %{id: "jon_id", name: "jon", presence: "active", is_bot: false},
        "opsb_id": %{id: "opsb_id", name: "opsb", presence: "active", is_bot: false}
      },
      channels: %{
        "pr_reviews_id": %{id: "pr_reviews_id", name: "pr_reviews", is_channel: true}
      },
      socket: nil,
      client: FakeWebsocketClient
    }
    state_before = %{}

    state_after = Bot.handle_message(payload, slack, state_before)

    assert_received {:socket, %{
      "channel" => "pr_reviews_id",
      "text" => "@opsb kindly review that PR."
    }}

    assert state_after = %{ previous_reviewer_id: "opsb_id" }
  end
end
