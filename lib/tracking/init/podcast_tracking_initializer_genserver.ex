defmodule Podcast.Tracking.Initilizer.GenServer do
  use GenServer
  @delay 1 * 1_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Process.send_after(self(), :init, @delay)
    {:ok, state}
  end

  def handle_info(:init, state) do
    Podcast.Tracking.Initilizer.init_subscriptions_from_db()
    {:noreply, state}
  end
end
