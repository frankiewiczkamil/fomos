defmodule Subscription.Repo.GenServer do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: SubscriptionRepo)
  end

  def init(_) do
    :dets.open_file(:"subscription.db", type: :set)
  end

  def handle_call({:get_by_id, subscriber_id}, _from, table) do
    result =
      case(:dets.lookup(table, subscriber_id)) do
        [] -> nil
        [subscription] -> subscription
      end

    {:reply, result, table}
  end

  def handle_call(:get_first, _from, table) do
    result =
      case first_id = :dets.first(table) do
        :"$end_of_table" -> nil
        _ -> first_id
      end

    {:reply, result, table}
  end

  def handle_call({:get_next, previous_subscriber_id}, _from, table) do
    result =
      case next_id = :dets.next(table, previous_subscriber_id) do
        :"$end_of_table" -> nil
        _ -> next_id
      end

    {:reply, result, table}
  end

  def handle_cast({:save, subscriber_id, show_ids, updated}, table) do
    :dets.insert(table, {subscriber_id, show_ids, updated})
    {:noreply, table}
  end
end
