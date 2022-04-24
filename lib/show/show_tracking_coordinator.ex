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
    Logger.debug(" * track_worker #{show_id}")
    auth = get_auth(subscriber_id)
    fetched_show = Show.SpotifyApiClient.get_show(auth, show_id)
    %{show: saved_show} = Show.Repo.get_by_id(fetched_show[:id])
    Logger.debug("fetched show data:")
    IO.inspect(fetched_show)

    # todo move to repo or service
    saved_show_total_episodes =
      case saved_show do
        nil -> 0
        _ -> saved_show[:total_episodes]
      end

    fetched_show_total_episodes = fetched_show[:total_episodes]

    unless(saved_show_total_episodes === fetched_show_total_episodes) do
      Logger.debug("show's total_episodes changed - episodes fetch is required")
      diff = fetched_show_total_episodes - saved_show_total_episodes

      pages = Spotify_API.create_pagination_parameters(diff, 10)
      fetch_and_store_episodes(pages, show_id, auth)

      Show.Repo.save(fetched_show, :os.system_time(:millisecond))
    end

    # if(saved_show[:total_episodes] === fetched_show[:total_episodes]) do
    #   Logger.debug("show's total_episodes not changed")
    # end

    Process.sleep(3000_000)
    track(show_id, subscriber_id)
  end

  def get_auth(subscriber_id) do
    case auth = Subscribtion.Token.Repo.get_auth(subscriber_id) do
      nil ->
        Process.sleep(10_000)
        Logger.debug("missing token for subscriber #{subscriber_id}")
        get_auth(subscriber_id)

      _ ->
        auth
    end
  end

  def fetch_and_store_episodes([%{limit: limit, offset: offset} | other_pages], show_id, auth) do
    # todo [iterate backwards and] check total episodes each time, since it can increase during the process...

    # user-read-playback-position grant is required o,o
    Episode.SpotifyApiClient.get_episodes_by_show_id(auth, show_id, offset, limit)
    |> Enum.map(&Episode.Repo.save/1)

    case other_pages do
      [] -> :done
      _ -> fetch_and_store_episodes(other_pages, show_id, auth)
    end
  end
end
