defmodule Show.SpotifyApiClient do
  def pick_show(%{"show" => show}), do: show
  def pick_show_main_info(%{"id" => id, "name" => name}), do: %{id: id, name: name}
end
