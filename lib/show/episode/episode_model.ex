defmodule Episode.Model do
  @type episode :: %{
          release_date: String.t(),
          name: String.t(),
          show_id: String.t(),
          id: String.t(),
          uri: String.t(),
          duration: number()
        }

  @type spotify_episode :: %{
          audio_preview_url: String.t(),
          description: String.t(),
          html_description: String.t(),
          duration_ms: number(),
          explicit: boolean(),
          external_urls: %{
            spotify: String.t()
          },
          href: String.t(),
          id: String.t(),
          images: list(spotify_image),
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
          show: %{
            available_markets: list(String.t()),
            copyrights: list(spotify_copyrights()),
            description: String.t(),
            html_description: String.t(),
            explicit: true,
            external_urls: %{
              spotify: String.t()
            },
            href: String.t(),
            id: String.t(),
            images: list(spotify_image),
            is_externally_hosted: true,
            languages: list(String.t()),
            media_type: String.t(),
            name: String.t(),
            publisher: String.t(),
            type: String.t(),
            uri: String.t()
          }
        }

  @type spotify_image :: %{
          url: String.t(),
          height: number(),
          width: number()
        }

  @type spotify_copyrights :: %{
          text: String.t(),
          type: String.t()
        }
end
