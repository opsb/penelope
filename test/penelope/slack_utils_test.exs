defmodule Penelope.SlackUtilsTest do
  use ExUnit.Case

  test "find_reviewers" do
    slack = %{
      users: %{
        "jon_id": %{id: "jon_id", name: "jon", presence: "active", is_bot: false},
        "opsb_id": %{id: "opsb_id", name: "opsb", presence: "active", is_bot: false},
        "hal_id": %{id: "hal_id", name: "hal", presence: "active", is_bot: true},
        "bob_id": %{id: "bob_id", name: "bob", presence: "active", is_bot: false},
        "away_id": %{id: "away_id", name: "away", presence: "away", is_bot: false},
        "mary_id": %{id: "mary_id", name: "mary", presence: "active", is_bot: false}
      }
    }
    state = %{previous_reviewer_id: "mary_id"}
    requester_id = "jon_id"

    reviewer_ids = Penelope.SlackUtils.find_reviewers(slack, state, requester_id) |> Enum.map(& &1[:id])

    assert EnumUtils.all_members?(reviewer_ids, ["opsb_id", "bob_id"]), "should include active users"
    assert !Enum.member?(reviewer_ids, "mary_id"), "should exclude previous requester"
    assert !Enum.member?(reviewer_ids, "jon_id"), "should exclude requester"
    assert !Enum.member?(reviewer_ids, "hal_id"), "should exclude bots"
    assert !Enum.member?(reviewer_ids, "away_id"), "should exclude away users"
  end

  test "find_reviewers when previous reviewer is only person available" do
    slack = %{
      users: %{
        "mary_id": %{id: "mary_id", name: "mary", presence: "active", is_bot: false}
      }
    }
    state = %{previous_reviewer_id: "mary_id"}
    requester_id = "jon_id"

    reviewer_ids = Penelope.SlackUtils.find_reviewers(slack, state, requester_id) |> Enum.map(& &1[:id])

    assert EnumUtils.all_members?(reviewer_ids, ["mary_id"]), "should include previous reviewer"
  end
end
