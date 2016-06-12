ExUnit.start()

"test/support/**/*.exs" |> Path.wildcard |> Enum.each(&Code.require_file/1)
