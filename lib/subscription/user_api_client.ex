defmodule Subscribtion.UserSpotifyApiClient do
  @spec get_user_info(String.t()) :: any
  def get_user_info(authorization) do
    url = "#{Spotify_API.api_url()}/me"

    HTTPoison.get!(url, Authorization: authorization)
    |> Spotify_API.pick_body()
    |> Jason.decode!()
  end

  @spec get_user_shows(String.t()) :: list
  def get_user_shows(authorization) do
    url = "#{Spotify_API.api_url()}/me/shows"

    transformation = fn arg ->
      arg
      |> Enum.map(&Show.SpotifyApiClient.pick_show/1)
      |> Enum.map(&Show.SpotifyApiClient.pick_show_main_info/1)
    end

    Spotify_API.fetch_all(url, authorization, transformation)
  end
end
