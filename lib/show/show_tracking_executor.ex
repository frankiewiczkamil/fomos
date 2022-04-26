defmodule Show.Tracking.Executor do
  use GenServer
  require Logger
  @page_size 30

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: ShowTrackingExecutor)
  end

  def init(state) do
    {:ok, state}
  end

  def fetch_content(show_id, subscriber_id) do
    GenServer.cast(ShowTrackingExecutor, {show_id, subscriber_id})
  end

  def handle_cast({show_id, subscriber_id}, state) do
    Logger.debug("fetch content for show #{show_id} using #{subscriber_id}'s token")
    execute(show_id, subscriber_id)
    {:noreply, state}
  end

  defp execute(show_id, subscriber_id) do
    auth = get_auth(subscriber_id)
    fetched_show = Show.SpotifyApiClient.get_show(auth, show_id)
    %{show: saved_show} = Show.Repo.get_by_id(fetched_show[:id])

    saved_show_total_episodes =
      case saved_show do
        nil -> 0
        _ -> saved_show[:total_episodes]
      end

    fetched_show_total_episodes = fetched_show[:total_episodes]

    unless(saved_show_total_episodes === fetched_show_total_episodes) do
      Logger.debug("show's total_episodes changed - episodes fetch is required")
      diff = fetched_show_total_episodes - saved_show_total_episodes

      pages = Spotify_API.create_pagination_parameters(diff, min(diff, @page_size))
      fetch_and_store_episodes(pages, show_id, auth)

      Show.Repo.save(fetched_show, :os.system_time(:millisecond))
    end

    if(saved_show[:total_episodes] === fetched_show[:total_episodes]) do
      Logger.debug("show's total_episodes not changed")
    end
  end

  defp get_auth(subscriber_id) do
    case auth = Subscribtion.Token.Repo.get_auth(subscriber_id) do
      nil ->
        Process.sleep(10_000)
        # Logger.debug("missing token for subscriber #{subscriber_id}")
        get_auth(subscriber_id)

      _ ->
        auth
    end
  end

  defp fetch_and_store_episodes([%{limit: limit, offset: offset} | other_pages], show_id, auth) do
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
