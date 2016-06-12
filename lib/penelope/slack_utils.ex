defmodule Penelope.SlackUtils do
  def find_reviewers(message, slack, state) do
    slack
    |> Map.get(:users)
    |> Map.values
    |> Enum.filter(& elligible?(message, slack, state, &1))
    |> remove_previous_reviewer(state)
  end

  defp elligible?(message, slack, state, user) do
    channel = find_channel(slack, message.channel)

    Enum.all?([
      Map.get(user, :presence) == "active",
      user.id != message.user,
      !Map.get(user, :is_bot),
      channel |> Map.get(:members) |> Enum.member?(user.id)
    ])
  end

  defp remove_previous_reviewer(reviewers, state) do
    previous_reviewer_id = Map.get(state, :previous_reviewer_id)

    if previous_reviewer_id && Enum.count(reviewers) > 1 do
      Enum.filter(reviewers, & &1.id != previous_reviewer_id)
    else
      reviewers
    end
  end

  defp find_channel(slack, channel_id) do
    Map.get(slack.channels, channel_id) || Map.get(slack.groups, channel_id)
  end
end
