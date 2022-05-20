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
          # images: [
          #   {
          #     url: String.t(),
          #     height: 300,
          #     width: 300
          #   }
          # ],
          is_externally_hosted: true,
          is_playable: true,
          language: String.t(),
          # languages: [
          #   fr,
          #   en
          # ],

          name: String.t(),
          release_date: String.t(),
          release_date_precision: String.t(),

          # resume_point: {
          #   fully_played: true,
          #   resume_position_ms: 0
          # },

          type: String.t(),
          uri: String.t(),

          # restrictions: {
          #   reason: string
          # },

          show: %{
            # available_markets: [
            #   string
            # ],
            # copyrights: [
            #   {
            #     text: string,
            #     type: string
            #   }
            # ],

            description: String.t(),
            html_description: String.t(),
            explicit: true,
            external_urls: %{
              spotify: String.t()
            },
            href: String.t(),
            id: String.t(),

            # images: [
            #   {
            #     url: https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228\n,
            #     height: 300,
            #     width: 300
            #   }
            # ],
            is_externally_hosted: true,
            # languages: [
            #   string
            # ],
            media_type: String.t(),
            name: String.t(),
            publisher: String.t(),
            type: String.t(),
            uri: String.t()
          }
        }
end
