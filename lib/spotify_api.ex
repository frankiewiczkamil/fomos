defmodule Spotify_API do
  # dev mode only, tmp
  @api "https://api.spotify.com/v1"
  @headers [Authorization: "Bearer #{Auth.get_dev_token()}"]

  def get_my_shows_factory() do
    HTTPoison.get!("#{@api}/me/shows", @headers)
  end

  def get_episodes_by_show_id(show_id) do
    HTTPoison.get!("#{@api}/shows/#{show_id}/episodes", @headers)
  end
end
