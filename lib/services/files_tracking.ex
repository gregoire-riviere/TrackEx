defmodule Files.Tracking do
  require Logger
  use GenServer

  @file_path "data/file.db"

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    if File.exists?(@file_path) do
      :ets.file2tab('#{@file_path}')
    else {:ok, :ets.new(:files, [])} end
  end

  def add_files_seed(user, file_list) do

    invalid_files = file_list |> Enum.map(fn file ->
      case GenServer.call(__MODULE__, {:get_file, file.name}) do
        [{_, value}] ->
          if file.name == value.name && file.cksum == value.cksum && file.size == value.size do
            GenServer.cast(__MODULE__, {:add_file, %{
              name: file.name,
              cksum: file.cksum,
              size: file.size,
              users: value.users ++ [user]
            }})
            :ok
            else file.name end
        [] -> file.name
      end
    end) |> Enum.reject(& &1 == :ok)
    {:ok, %{status: "OK", rejected: invalid_files} |> Poison.encode!}
  end
  def remove_seeder(user), do: GenServer.cast(__MODULE__, {:remove_seeder, user})

  def add_file(%{name: _name, cksum: _cksum, size: _size} = f) do
    GenServer.cast(__MODULE__, {:add_file, f |> put_in([:users], [])})
    GenServer.cast(__MODULE__, :backup_file_base)
  end

  def remove_seeder_in_ets(ets, seeder, key) do
    [{key, val}] = :ets.lookup(ets, key)
    :ets.insert(ets, {key, val |> put_in([:users], val.users -- [seeder])})
    case :ets.next(ets, key) do
      :"$end_of_table" -> {:noreply, ets}
      key2 ->
        Logger.debug("#{inspect key2}")
        remove_seeder_in_ets(ets, seeder, key2)
    end
  end

  def get_file_info(file_name), do: GenServer.call(__MODULE__, {:get_file, file_name})

  # Genserver calls

  def handle_call({:get_file, file}, _from, state), do: {:reply, :ets.lookup(state, file), state}
  def handle_cast({:add_file, file}, state) do
    :ets.insert(state, {file.name, file})
    {:noreply, state}
  end
  def handle_cast(:backup_file_base, state) do
    :ets.tab2file(state, '#{@file_path}')
    {:noreply, state}
  end
  def handle_cast({:remove_seeder, user}, state) do #could be optimized w/ a user index
    case :ets.first(state) do
      :"$end_of_table" -> {:noreply, state}
      key -> remove_seeder_in_ets(state, user, key)
    end
  end

end
