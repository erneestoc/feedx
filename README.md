# Feedx

Generic feed adding social features to current applications. 

---

RabbitMQ as event producer. This app consumes, stores, and serves. The goal is to create a plug-n-play social feed for existing applications. May be easy to consume events from other sources.

---

## Details

This is a OTP umbrella application. Containing other 3 OTP applications within the `apps` folder.

```
/apps/backbone
/apps/store
/apps/web
```

### Usage

An app should post events to RabbitMQ with a given format, in order for this app to consume and process events to build the feed.

We support 3 kind of events. `create`, `update`, `delete`. In order for us to handle an `update` or `delete` correctly, we should have already processed the create. `udpate` wont work once the event is deleted.

Our generic event looks like this.

```
{
	"event": {
		"type": "create",
		"tenant": 0,
		"user_id": 0,
		"content": "Main data content",
		"extra": {},
		"date": "ISOz date"
	}
}
```

### backbone

- Backbone contains the RabbitMQ `Consumer` generic server, which responsibility is to store events into the feed.
- `FeedBuilder` helps the consumer process events.
- `Feed` generic server interacts with the store to render needed json for the feed's events, comments, likes, and publish events to the web channels.

### store

- `FeedRepo` is the main data store for our feed. Can be backed by any [ecto's supported databases](https://github.com/elixir-ecto/ecto#usage).
- `SourceRepo` contains a connection to other app database, in which user's are stored. We should be able to get user name, id, and profile pic from one table. [ecto's supported databases](https://github.com/elixir-ecto/ecto#usage)
- `UserServer` retrieves and caches users given an id. Cache is backed by [con_cache](https://github.com/sasa1977/con_cache), which uses `ets` for fast querying. 

### web

- The web project is an [elixir phoenix](http://phoenixframework.org/) API.

__GET @ /api/v1/feed__

```
{
	data: [{
		"id": 1,
		"user": {
			"id": 1,
			"full_name": "Nombre",
			"profile_pic": "profile"
		},
		"type": "post",
		"content": "some content",
		"comments": {
			"total": 10,
			"preview": [{
				"user":...,
				"comment": "hello world!"
			}]
		}
	}]
}
```

__GET @ /api/v1/feed/:tenant_id__

```
{
	data: [{
		"id": 1,
		"user": {
			"id": 1,
			"full_name": "Nombre",
			"profile_pic": "profile"
		},
		"type": "post",
		"content": "some content",
		"comments": {
			"total": 10,
			"preview": [{
				"user":...,
				"comment": "hello world!",
				"id": 1
			}]
		}
	}]
}
```

__GET @ /api/v1/feed/:tenant_id/event/:event_id/comments__

```
{
	data: [{
		"user": ...,
		"comment": "Content",
		"id": 1
	}]
}
```

__POST @ /api/v1/feed/:tenant_id/event/:event_id/comments__

```
{
	content: "Hello world!"
}
```

__DELETE @ /api/v1/feed/:tenant_id/event/:event_id/comments/:comment_id__

__GET @ /api/v1/feed/:tenant_id/event/:event_id/like__

__GET @ /api/v1/feed/:tenant_id/event/:event_id/unlike__

### setup


Change RabbitMQ config on `apps/backbone/config/{dev, test, prod}.exs`.

```
config :backbone, :rabbitmq, "amqp://guest:guest@127.0.0.1"
```

Change feed data store settings on `apps/store/config/{dev, test, prod}.exs`

```
config :store, Store.FeedRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "store_db_dev",
  hostname: "localhost",
  pool_size: 10
```

Setup your app's database connection, and the name of the table and columns to pull the users parameters.

```
config :store, Store.SourceRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "store_db_dev",
  hostname: "localhost",
  pool_size: 10

config :store, :external_db_table_name, "tabla"
config :store, :external_db_full_name, :full_name
config :store, :external_db_user_id, :id
config :store, :external_db_profile_pic, :image_url
```

---

[Easy deploy using edeliver](https://github.com/edeliver/edeliver)

