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

  defp init() do
    # todo change this module into genserver or sth like that
    {:ok, table} = :dets.open_file(:"episode.db", type: :bag)
    table
  end
end
