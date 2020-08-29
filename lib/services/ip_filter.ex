defmodule IP.Filter do

  use Agent
  @file_path "data/ip_table"

  def start_link(_) do
    if File.exists?(@file_path) do
      Agent.start_link(fn -> File.read!(@file_path) |> :erlang.binary_to_term end, name: __MODULE__)
    else Agent.start_link(fn -> [] end, name: __MODULE__)end
  end

  def is_valid_ip?(ip) do
    Agent.get(__MODULE__, & &1) |> Enum.member?(ip)
  end

  def add_ip(ip) do
    Agent.update(__MODULE__, & &1 ++ [ip])
    File.write!(@file_path, Agent.get(__MODULE__, & &1) |> :erlang.term_to_binary)
  end

end
