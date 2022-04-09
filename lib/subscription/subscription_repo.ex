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

    case first_id = :dets.first(table) do
      :"$end_of_table" -> nil
      _ -> first_id
    end
  end

  @spec next(String.t()) :: String.t() | nil
  def next(id) do
    table = init()

    case next_id = :dets.next(table, id) do
      :"$end_of_table" -> nil
      _ -> next_id
    end
  end

  defp init() do
    # todo change this module into genserver or sth like that
    {:ok, table} = :dets.open_file(:"subscription.db", type: :set)
    table
  end
end
