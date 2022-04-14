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
    new_state = start_tracking(state, show_id)
    {:reply, :ok, new_state}
  end

  defp start_tracking(state, show_id) do
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
          {:ok, fired_pid} = Task.start_link(fn -> track(show_id) end)
          %{number_of_subscribers: 1, tracker_pid: fired_pid}

        _ ->
          %{number_of_subscribers: number_of_subscribers + 1, tracker_pid: tracker_pid}
      end

    Map.put(state, show_id, new_value)
  end

  defp track(show_id) do
    Logger.debug(" * track_worker #{show_id}")
    auth = Auth.get_dev_token()
    res = Show.SpotifyApiClient.get_show(auth, show_id)
    IO.inspect("fetched show data:")
    IO.inspect(res)

    # user-read-playback-position grant is required o,o
    # r = Episode.SpotifyApiClient.get_episodes_by_show_id(auth, show_id)

    # r
    # |> Enum.map(fn %{name: name, release_date: release_date} ->
    #   Logger.debug("#{release_date} #{name}")
    # end)

    Process.sleep(3000_000)
    track(show_id)
  end
end
