defmodule EnumUtils do
  def all_members?(list, candidates) do
    Enum.all?(candidates, &(Enum.member?(list, &1)))
  end
end
