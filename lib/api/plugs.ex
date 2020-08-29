defmodule AppRouter do
  use Plug.Router
  plug :match
  plug :dispatch

  forward "/user", to: PlugUser

end
