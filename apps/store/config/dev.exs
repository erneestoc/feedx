use Mix.Config

config :store, Store.FeedRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "store_db_dev",
  hostname: "localhost",
  pool_size: 10

config :store, Store.SourceRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "store_source_db_dev",
  hostname: "localhost",
  pool_size: 10

config :store, :external_db_table_name, "tabla"
config :store, :external_db_full_name, :full_name
config :store, :external_db_user_id, :id
config :store, :external_db_profile_pic, :image_url

config :store, :user_cache,
  ttl: true,
  touch_on_read: true,
  global_ttl: 20,
  check_interval: 2
