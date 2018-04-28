use Mix.Config

config :ecto_cursor_pagination,
    per_page: 15,
    cursor_id: :id

import_config "#{Mix.env()}.exs"
