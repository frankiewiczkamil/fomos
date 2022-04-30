defmodule Show.Service do
  require Logger

  def sync(show_id, auth) do
    show = Show.SpotifyApiClient.get_show(auth, show_id)
    Show.Repo.save(show, :os.system_time(:millisecond))
    show
  end

  def sync_if_not_exist(show_id, auth) do
    show = Show.Repo.get_by_id(show_id)

    if(show == nil) do
      show = Show.SpotifyApiClient.get_show(auth, show_id)
      Show.Repo.save(show, :os.system_time(:millisecond))
    end

    show
  end
end
