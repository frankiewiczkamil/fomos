defmodule Show.TrackingCoordinator do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: ShowTrackingCoordinator)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:track, show_id}, _from, state) do
    Logger.debug("tracking show #{show_id} requested")
    new_state = track(state, show_id)
    {:reply, :ok, new_state}
  end

  defp track(state, show_id) do
    {number_of_subscribers, tracker_pid} =
      case el = Map.get(state, show_id) do
        nil -> {0, nil}
        _ -> el
      end

    Logger.debug("currently show #{show_id} has #{number_of_subscribers} subscribers")

    new_value =
      case number_of_subscribers do
        0 -> {1, "new pid"}
        _ -> {number_of_subscribers + 1, tracker_pid}
      end

    # todo spin tracking impl
    Map.put(state, show_id, new_value)
  end
end
