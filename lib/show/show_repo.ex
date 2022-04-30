defmodule Show.Repo do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: ShowRepo)
  end

  def init(_) do
    :dets.open_file(:"show.db", type: :set)
  end

  def handle_call({:get_by_id, show_id}, _from, table) do
    result =
      case(:dets.lookup(table, show_id)) do
        [] -> nil
        [{_, show, updated}] -> %{show: show, updated: updated}
      end

    {:reply, result, table}
  end

  def handle_cast({:save, id, show, updated}, table) do
    :dets.insert(table, {id, show, updated})
    {:noreply, table}
  end

  def save(%{id: id} = show, updated) do
    GenServer.cast(ShowRepo, {:save, id, show, updated})
  end

  def get_by_id(show_id) do
    GenServer.call(ShowRepo, {:get_by_id, show_id})
  end
end
