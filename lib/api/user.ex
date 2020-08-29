defmodule PlugUser do
  require Logger
  use Plug.Router
  plug :match
  plug :dispatch

  get "/register" do
    Logger.info("A new user attempted to register!")
    send_resp(conn, 200, "")
  end

end
