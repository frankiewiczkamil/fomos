defmodule Subscribtion.UserSpotifyApiClient do
  @user_url "#{Spotify_API.api_url()}/me"
  @user_shows_url "#{Spotify_API.api_url()}/me/shows"

  def get_user_info(authorization), do: Spotify_API.fetch(@user_url, authorization)

  def get_user_shows(authorization) do
    transformation = fn arg ->
      arg
      |> Enum.map(&Show.SpotifyApiClient.pick_show/1)
      |> Enum.map(&Show.SpotifyApiClient.pick_show_main_info/1)
    end

    Spotify_API.fetch_all(@user_shows_url, authorization, transformation)
  end
end
