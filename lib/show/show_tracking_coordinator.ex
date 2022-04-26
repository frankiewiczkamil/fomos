defmodule Show.TrackingCoordinator do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: ShowTrackingCoordinator)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:track, show_id, subscriber_id}, _from, state) do
    Logger.debug("tracking show #{show_id} requested")
    new_state = start_tracking(state, show_id, subscriber_id)
    {:reply, :ok, new_state}
  end

  defp start_tracking(state, show_id, subscriber_id) do
    %{number_of_subscribers: number_of_subscribers, tracker_pid: tracker_pid} =
      case el = Map.get(state, show_id) do
        nil -> %{number_of_subscribers: 0, tracker_pid: nil}
        _ -> el
      end

    Logger.debug(
      "currently show #{show_id} has #{number_of_subscribers} subscribers [#{inspect(tracker_pid)}]"
    )

    new_value =
      case number_of_subscribers do
        0 ->
          {:ok, fired_pid} = Task.start_link(fn -> track(show_id, subscriber_id) end)
          %{number_of_subscribers: 1, tracker_pid: fired_pid}

        _ ->
          %{number_of_subscribers: number_of_subscribers + 1, tracker_pid: tracker_pid}
      end

    Map.put(state, show_id, new_value)
  end

  defp track(show_id, subscriber_id) do
    Logger.debug("track show: #{show_id}")
    Show.Tracking.Executor.fetch_content(show_id, subscriber_id)
    Process.sleep(3000_000)
    track(show_id, subscriber_id)
  end
end
