defmodule Ermey.BotTest do
  use ExUnit.Case
  doctest Ermey
  alias Ermey.Bot

  defmodule FakeWebsocketClient do
    def send({:text, json}, _socket) do
      {:ok, decoded} = Poison.decode(json)
      Kernel.send self, {:socket, decoded}
    end
  end

  test "something" do
    slack = %{
      client: FakeWebsocketClient,
      socket: nil,
      channels: %{
        channel1: %{ id: "channel1", name: "channelx" }
      }
    }
    state_before = []
    state_after = Bot.handle_message(%{type: "message", text: "hello", channel: "#channelx"}, slack, state_before)
    Apex.ap Process.info(self, :message_queue_len)

    assert state_after = ["blah"]
    assert_received {:socket, %{
      "channel" => "channel1",
      "text" => "Received 0 messages so far!",
      "type" => "message"}
    }
  end
end
