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
    {number_of_subscribers, tracker_pid} =
      case el = Map.get(state, show_id) do
        nil -> {0, nil}
        _ -> el
      end

    Logger.debug(
      "currently show #{show_id} has #{number_of_subscribers} subscribers [#{inspect(tracker_pid)}]"
    )

    new_value =
      case number_of_subscribers do
        0 ->
          {:ok, pid} = Task.start_link(fn -> track(show_id) end)
          {1, pid}

        _ ->
          {number_of_subscribers + 1, tracker_pid}
      end

    # todo spin tracking impl
    Map.put(state, show_id, new_value)
  end

  defp track(show_id) do
    Logger.debug(" * track_worker #{show_id}")
    # user-read-playback-position grant is required o,o
    auth = Auth.get_dev_token()
    # r = Episode.SpotifyApiClient.get_episodes_by_show_id(auth, show_id)

    # r
    # |> Enum.map(fn %{name: name, release_date: release_date} ->
    #   Logger.debug("#{release_date} #{name}")
    # end)

    Process.sleep(3000_000)
    track(show_id)
  end
end
