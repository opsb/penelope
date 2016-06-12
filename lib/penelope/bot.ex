defmodule Penelope.Bot do
  use Slack

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_message(message = %{type: "message"}, slack, state) do
    if Regex.match? ~r/review/, message.text do
      requester_id = message.user
      reviewer = find_reviewer(slack, state, requester_id)
      message_to_send = "@#{reviewer.name} kindly review that PR."
      send_message message_to_send, message.channel, slack

      {:ok, %{previous_reviewer_id: reviewer.id}}
    else
      {:ok, state}
    end
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  def find_reviewer(slack, state, requester_id) do
    Penelope.SlackUtils.find_reviewers(slack, state, requester_id) |> Enum.random
  end
end
