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

config :store, :external_db_table_name, "users"
config :store, :external_db_full_name, :full_name
config :store, :external_db_user_id, :id
config :store, :external_db_profile_pic, :image_url

config :store, :user_cache,
  ttl: true,
  touch_on_read: true,
  global_ttl: 20,
  check_interval: 2

config :store, :interactions_cache,
  ttl: true,
  touch_on_read: true,
  global_ttl: 20,
  check_interval: 2
