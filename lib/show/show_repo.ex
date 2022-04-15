defmodule Show.Repo do
  require Logger

  def save(%{id: id} = show, updated) do
    table = init()
    :dets.insert(table, {id, show, updated})
  end

  def get_by_id(id) do
    table = init()

    case result = :dets.lookup(table, id) do
      [] -> %{show: nil, updated: nil}
      _ -> result
    end
  end

  defp init() do
    # todo change this module into genserver or sth like that
    {:ok, table} = :dets.open_file(:"show.db", type: :set)
    table
  end
end
