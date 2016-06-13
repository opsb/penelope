defmodule Penelope do
  use Application

  def start(_type, _args) do
    IO.puts "starting up"
    import Supervisor.Spec, warn: false

    children = [
      worker(Penelope.Bot, [Application.get_env(:penelope, :slack_token), []])
    ]

    opts = [strategy: :one_for_one, name: Penelope.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
