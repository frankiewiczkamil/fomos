defmodule Episode.Repo do
  require Logger

  @spec save(any) :: any
  def save(episode) do
    table = init()
    :dets.insert(table, {episode[:release_date], episode})
    :ok
  end

  def get_by_date(date) do
    table = init()
    :dets.lookup(table, date)
  end

  def get_all_keys() do
    # tmp for dev purposes
    table = init()
    get_next(:dets.first(table), []) |> Enum.sort()
  end

  defp get_next(:"$end_of_table", acc) do
    acc
  end

  defp get_next(key, acc) do
    table = init()
    get_next(:dets.next(table, key), [key | acc])
  end

  defp init() do
    # todo change this module into genserver or sth like that
    {:ok, table} = :dets.open_file(:"episode.db", type: :bag)
    table
  end
end
