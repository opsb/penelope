defmodule Ermey do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Ermey.Bot, [System.get_env("SLACK_TOKEN"), []])
    ]

    opts = [strategy: :one_for_one, name: Ermey.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
