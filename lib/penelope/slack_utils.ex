defmodule Penelope.SlackUtils do
  def find_reviewers(slack, state, requester_id) do
    slack
    |> Map.get(:users)
    |> Map.values
    |> Enum.filter(&(elligible?(slack, state, requester_id, &1)))
    |> remove_previous_reviewer(state)
  end

  defp elligible?(slack, state, requester_id, user) do
    Enum.all?([
      user.presence == "active",
      user.id != requester_id,
      !user.is_bot
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
end
