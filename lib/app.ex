defmodule Http.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Task.Supervisor, name: Http.TaskSupervisor},
      {Task, fn -> Http.accept(port) end}
    ]

    opts = [strategy: :one_for_one, name: Http.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
