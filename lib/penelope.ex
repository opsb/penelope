defmodule Penelope do
  use Application

  def start(_type, _args) do
    IO.puts "starting up"
    import Supervisor.Spec, warn: false

    children = [
      worker(Penelope.Bot, [slack_token, []])
    ]

    opts = [strategy: :one_for_one, name: Penelope.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp slack_token do
    System.get_env("SLACK_TOKEN") || raise ArgumentError, "SLACK_TOKEN env var must be set"
  end
end