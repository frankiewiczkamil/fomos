defmodule Subscription.Repo do
  require Logger

  @spec store(String.t(), list) :: any
  def store(id, shows) do
    table = init()
    :dets.insert(table, {id, shows, DateTime.utc_now()})
    :ok
  end

  def get(id) do
    table = init()
    :dets.lookup(table, id)
  end

  def first() do
    table = init()
    :dets.first(table)
  end

  def next(id) do
    table = init()
    :dets.lookup(table, id)
  end

  defp init() do
    # todo change this module into genserver or sth like that
    {:ok, table} = :dets.open_file(:"subscription.db", type: :set)
    table
  end
end
