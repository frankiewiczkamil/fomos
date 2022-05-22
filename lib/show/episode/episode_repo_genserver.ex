defmodule Episode.Repo.GenServer do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: EpisodeRepo)
  end

  def init(_) do
    :dets.open_file(:"episode.db", type: :bag)
  end

  def handle_call({:get_by_date, date}, _from, table) do
    {:reply, :dets.lookup(table, date), table}
  end

  def handle_call({:get_by_show_id, show_id}, _from, table) do
    query = [
      {
        {:_, %{show_id: show_id}},
        [],
        [{:element, 2, :"$_"}]
      }
    ]

    {:reply, :dets.select(table, query), table}
  end

  def handle_call(:get_all_keys, _from, table) do
    result = get_next(:dets.first(table), [], table)
    {:reply, result, table}
  end

  def handle_cast({:save, episode}, table) do
    :dets.insert(table, {episode[:release_date], episode})
    {:noreply, table}
  end

  defp get_next(:"$end_of_table", acc, _table) do
    acc
  end

  defp get_next(key, acc, table) do
    get_next(:dets.next(table, key), [key | acc], table)
  end
end
