defmodule Heart.Beat do
  require Logger
  use GenServer

  @refresh_time 20

  def start_link(_)do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Process.send_after(self(), :check_dead_users, 1000*@refresh_time)
    {:ok, %{}}
  end

  def receive_heart_beat(user), do: GenServer.cast(__MODULE__, {:receive_heart_beat, user})
  def register_user(user), do: GenServer.cast(__MODULE__, {:register_user, user})

  def handle_cast({:register_user, user}, state) do
    {:noreply, state |> put_in([user], true)}
  end

  def handle_cast({:receive_heart_beat, user}, state) do
    Logger.info("Heart beat received for #{user}")
    {:noreply, state |> put_in([user], true)}
  end

  def handle_info(:check_dead_users, state) do
    Logger.info("Checking dead users...")
    deads = state |> Enum.into([]) |> Enum.filter(& elem(&1, 1) == false) |> Enum.map(fn {u, _} -> u end)
    if length(deads) > 0, do: Logger.warn("Users #{inspect deads} are inactive")
    deads |> Enum.each(& Users.dead_user(&1))
    Process.send_after(self(), :check_dead_users, 1000*@refresh_time)
    {:noreply, state |> Enum.into([]) |> Enum.reject(& elem(&1, 0) in deads) |> Enum.map(fn {u, _} -> {u, false} end) |> Enum.into(%{})}
  end

end
