use Mix.Config

config :store, Store.FeedRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "store_db_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :store, Store.SourceRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "store_source_db_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :store, :external_db_table_name, "tabla"
config :store, :external_db_full_name, :full_name
config :store, :external_db_user_id, :id
config :store, :external_db_profile_pic, :image_url
