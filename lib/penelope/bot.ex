defmodule Penelope.Bot do
  use Slack

  def handle_connect(slack, _state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, %{}}
  end

  def handle_message(message = %{type: "message"}, slack, state) do
    if Regex.match? ~r/review/, message.text do
      reviewer = find_reviewer(message, slack, state)

      if reviewer do
        message_to_send = "@#{reviewer.name} kindly review that PR."
        send_message message_to_send, message.channel, slack

        {:ok, %{previous_reviewer_id: reviewer.id}}
      else
        message_to_send = "ahem, well this is embarrasing, there doesn't seem to be anyone available..."
        send_message message_to_send, message.channel, slack

        {:ok, state}
      end
    else
      {:ok, state}
    end
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  def find_reviewer(message, slack, state) do
    reviewers = Penelope.SlackUtils.find_reviewers(message, slack, state)
    if Enum.empty?(reviewers) do
      nil
    else
      reviewers |> Enum.random
    end
  end
end
