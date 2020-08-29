defmodule Users do
  require Logger
  use GenServer

  def start_link(_)do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, :ets.new(:users, [:bag])}
  end

  def add_active_user(user), do: GenServer.cast(__MODULE__, {:active_user, user})
  def dead_user(user), do: GenServer.cast(__MODULE__, {:dead_user, user})
  def is_active_user?(user), do: GenServer.call(__MODULE__, {:is_active_user, user})

  def handle_cast({:active_user, user}, state) do
    Heart.Beat.register_user(user)
    :ets.insert(state, {user, %{}})
    Logger.info("User #{user} is active now")
    {:noreply, state}
  end

  def handle_cast({:dead_user, user}, state) do
    Logger.info("User #{user} is inactive now")
    :ets.delete(state, user)
    {:noreply, state}
  end

  def handle_call({:is_active_user, user}, _from, state) do
    {:reply, :ets.lookup(state, user) != [], state}
  end

end
