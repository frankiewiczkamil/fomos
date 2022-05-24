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
    auth_callback = fn -> get_auth(subscriber_id) end

    fetched_show = Show.SpotifyApiClient.get_show(auth, show_id)
    Show.Repo.save(fetched_show, :os.system_time(:millisecond))

    saved_show_total_episodes = show_id |> Episode.Repo.get_by_show_id() |> length()
    fetched_show_total_episodes = fetched_show[:total_episodes]

    Logger.debug("saved show's total_episodes: #{saved_show_total_episodes}")
    Logger.debug("actual show's total_episodes: #{fetched_show_total_episodes})")

    diff = fetched_show_total_episodes - saved_show_total_episodes

    if(diff > 0) do
      Logger.debug("saved < current, sync #{diff} episodes")

      page_size = min(diff, @page_size)
      pages = Spotify_API.Paging.create_paging_parameters_desc(diff, page_size)

      result =
        fetch_and_store_episodes(pages, show_id, auth_callback, fetched_show_total_episodes)

      case result do
        :aborted ->
          Logger.debug("start over sync (show: #{show_id})")
          execute(show_id, subscriber_id)

        _ ->
          Logger.debug("sync done (show: #{show_id})")
          :done
      end
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

  defp fetch_and_store_episodes(
         [%{limit: limit, offset: offset} | other_pages],
         show_id,
         auth_callback,
         expected_total
       ) do
    auth = auth_callback.()

    %{episodes: episodes, total: total} =
      Episode.SpotifyApiClient.get_episodes_and_total_by_show_id(auth, show_id, offset, limit)

    other_pages =
      case total do
        ^expected_total ->
          episodes |> Enum.map(&Episode.Repo.save/1)
          other_pages

        _ ->
          Logger.debug("#{total - expected_total} new episodes arrived, abort")
          :abort
      end

    case other_pages do
      :abort -> :aborted
      [] -> :done
      _ -> fetch_and_store_episodes(other_pages, show_id, auth_callback, expected_total)
    end
  end
end
