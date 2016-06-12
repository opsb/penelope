require IEx;

defmodule Ermey.Bot do
  use Slack

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_message(message = %{type: "message"}, slack, state) do
    requester_id = message.user
    reviewer = find_reviewer(slack, requester_id)
    message_to_send = "@#{reviewer.name} kindly review that PR."

    send_message message_to_send, message.channel, slack

    {:ok, state}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  defp find_reviewer(slack, requester_id) do
    slack
    |> Map.get(:users)
    |> Map.values
    |> Enum.find fn (user) ->
      user.presence == "active" && user.id != requester_id
    end
  end
end
