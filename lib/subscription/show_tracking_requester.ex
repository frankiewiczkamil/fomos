defmodule Subscription.ShowTrackingRequester do
  use GenServer
  require Logger
  @delay 10 * 1_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Process.send_after(self(), :init, @delay)
    {:ok, state}
  end

  def handle_info(:init, state) do
    init_subscriptions_from_db()
    {:noreply, state}
  end

  defp init_subscriptions_from_db() do
    Logger.debug("Init subscriptions from DB: start")
    Subscription.Repo.first() |> init_subscriptions_from_db
  end

  defp init_subscriptions_from_db(sub_id) when sub_id == nil do
    Logger.debug("Init subscriptions from DB: done")
  end

  defp init_subscriptions_from_db(sub_id) do
    Logger.debug("Add #{sub_id}'s shows")
    [{_id, shows} | _] = Subscription.Repo.get(sub_id)
    Logger.debug("Found #{length(shows)} shows to be saved")
    next_sub_id = Subscription.Repo.next(sub_id)
    init_subscriptions_from_db(next_sub_id)
  end
end
