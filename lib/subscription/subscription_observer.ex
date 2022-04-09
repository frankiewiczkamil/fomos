defmodule Subscription.Observer do
  use GenServer
  require Logger
  @run_every 10 * 1_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_next()
    {:ok, state}
  end

  def handle_info(:check, state) do
    Logger.debug("Check subscriptions")
    Subscription.Repo.first() |> worker

    schedule_next()
    {:noreply, state}
  end

  defp schedule_next() do
    Process.send_after(self(), :check, @run_every)
  end

  defp worker(sub_id) when sub_id == nil do
    Logger.debug("nil subscription id provided, stop")
  end

  defp worker(sub_id) do
    Logger.debug("Add #{sub_id}'s shows")
    [{_id, shows} | _] = Subscription.Repo.get(sub_id)
    Logger.debug("Found #{length(shows)} shows to be saved")
    next_sub_id = Subscription.Repo.next(sub_id)
    worker(next_sub_id)
  end
end
