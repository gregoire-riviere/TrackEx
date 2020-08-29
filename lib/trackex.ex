defmodule Trackex do
  require Logger
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: AppRouter, options: [port: 4001]},
      {IP.Filter, []},
      {Users, []},
      {Heart.Beat, []}
    ]
    Logger.info("Starting the app")

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
