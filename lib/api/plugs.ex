defmodule AppRouter do
  require Logger
  use Plug.Router
  use Plug.Builder
  plug :ip_verification
  plug :match
  plug :dispatch

  def ip_verification(conn, _opts) do
    ip = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    if !IP.Filter.is_valid_ip?(ip) do
      conn |> send_resp(401, "Your IP adress isn't authorized") |> halt
    else conn end
  end

  forward "/user", to: PlugUser

end
