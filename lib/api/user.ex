defmodule PlugUser do
  require Logger
  use Plug.Router
  plug :match
  plug :dispatch

  get "/register" do
    Logger.info("A new user attempted to register!")
    ip = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    {:ok, data, _conn} = Plug.Conn.read_body(conn)
    data = data != "" && data |> Poison.decode!(keys: :atoms) || []
    {:ok, result} = Files.Tracking.add_files_seed(ip, data)
    Users.add_active_user(ip)
    send_resp(conn, 200, result)
  end

  get "/heart_beat" do
    ip = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    if Users.is_active_user?(ip) do
      Heart.Beat.receive_heart_beat(ip)
      send_resp(conn, 200, "")
    else send_resp(conn, 400, "You must register first") end
  end

end
