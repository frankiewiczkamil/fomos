defmodule Spotify_API do
  # dev mode only, tmp
  @headers [Authorization: "Bearer #{Auth.get_dev_token()}"]

  def get_my_shows_factory() do
    HTTPoison.get!("https://api.spotify.com/v1/me/shows", @headers)
  end
end
