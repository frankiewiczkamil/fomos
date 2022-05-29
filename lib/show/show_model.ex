defmodule Show.Model do
  @type mini :: %{
          id: String.t(),
          name: String.t(),
          total_episodes: number()
        }
  @type repo_response ::
          nil
          | %{
              show: mini,
              updated: integer()
            }
end
