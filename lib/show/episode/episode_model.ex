defmodule Episode.Model do
  @type episode :: %{
          release_date: String.t(),
          name: String.t(),
          show_id: String.t(),
          id: String.t(),
          uri: String.t(),
          duration: number()
        }

  @type episode_mini :: %{
          name: String.t(),
          uri: String.t(),
          duration: number()
        }
end
