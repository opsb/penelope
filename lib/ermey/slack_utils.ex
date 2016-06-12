defmodule Ermey.SlackUtils do
  def find_reviewers(slack, state, requester_id) do
    slack
    |> Map.get(:users)
    |> Map.values
    |> Enum.filter fn (user) ->
      user.presence == "active" && user.id != requester_id && !user.is_bot
    end
  end
end
