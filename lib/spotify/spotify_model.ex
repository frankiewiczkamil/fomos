defmodule Spotify.Model do
  @type image :: %{
          url: String.t(),
          height: number(),
          width: number()
        }

  @type copyrights :: %{
          text: String.t(),
          type: String.t()
        }

  @type external_urls :: %{
          spotify: String.t()
        }

  @type episode :: %{
          audio_preview_url: String.t(),
          description: String.t(),
          html_description: String.t(),
          duration_ms: number(),
          explicit: boolean(),
          external_urls: external_urls,
          href: String.t(),
          id: String.t(),
          images: list(image),
          is_externally_hosted: true,
          is_playable: true,
          language: String.t(),
          languages: list(String.t()),
          name: String.t(),
          release_date: String.t(),
          release_date_precision: String.t(),
          resume_point: %{
            fully_played: boolean(),
            resume_position_ms: number()
          },
          type: String.t(),
          uri: String.t(),
          restrictions: %{
            reason: String.t()
          },
          show: show_core
        }

  @type show_core :: %{
          available_markets: list(String.t()),
          copyrights: list(copyrights()),
          description: String.t(),
          html_description: String.t(),
          explicit: boolean(),
          external_urls: external_urls,
          href: String.t(),
          id: String.t(),
          images: list(image),
          is_externally_hosted: true,
          languages: list(String.t()),
          media_type: String.t(),
          name: String.t(),
          publisher: String.t(),
          type: String.t(),
          uri: String.t()
        }

  @type show ::
          Map.merge(
            show_core,
            %{
              episodes: %{
                href: String.t(),
                items: list(),
                limit: number(),
                next: String.t(),
                offset: number(),
                previous: String.t(),
                total: number()
              }
            }
          )
end
