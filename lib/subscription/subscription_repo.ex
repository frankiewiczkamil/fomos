defmodule Subscription.Repo do
  require Logger

  @spec store(String.t(), list) :: any
  def store(id, shows) do
    {:ok, table} = :dets.open_file(:"subscription.db", type: :set)
    :dets.insert(table, {id, shows})
    :ok
  end
end
