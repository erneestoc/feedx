# Feedx - WIP
---

[![Build Status](https://travis-ci.org/erneestoc/feedx.svg?branch=master)](https://travis-ci.org/erneestoc/feedx)
[![Coverage Status](https://coveralls.io/repos/github/erneestoc/feedx/badge.svg?branch=master)](https://coveralls.io/github/erneestoc/feedx?branch=master)

---

Generic feed adding social features to current applications.

---

* [Details](#details)
* [Design](#design)
* [Usage](#usage)
* [Setup](#setup)

---

## Details

RabbitMQ as event producer. This app consumes, stores, and serves. The goal is to create a plug-n-play social feed for existing applications. May be easy to consume events from other sources.

## Design

This is an OTP umbrella application, containing other 3 OTP applications within the `apps` folder.

```
/apps/bus
/apps/store
/apps/web
```

### bus

- `Bus` contains the RabbitMQ `Consumer` generic server, which responsibility is to store events into the feed.

### store

- `FeedRepo` is the main data store for our feed. Can be backed by any [ecto's supported databases](https://github.com/elixir-ecto/ecto#usage).
- `SourceRepo` contains a connection to other app database, in which user's are stored. We should be able to get user name, id, and profile pic from one table. The store app implements a simple caching using [con_cache](https://github.com/sasa1977/con_cache), so that we don't hit the `Source` database too much. The caching mecanisms and access to the database can be [configured](#setup), if we don't setup a TTL, each user will only be looked up once per app restart. (We can avoid apps restart using erlang's code hot swap 🙂)
- `Feed` gen_server is the main API for consuming the feed.
- `FeedBuilder` gen_server is an API for building up the feed.
- `Users` gen_server retrieves and caches users given an id. Mostly accessed by the feed server.
- `Comments` gen_server is an API for showing, creating, updating, and deleting comments.
- `Likes` gen_server is an API for liking and unliking feed events.

### web

- The web project contains a json API and websockets for consuming and updating the feed. Uses [phoenix framework](http://phoenixframework.org/)

## Usage

An app should post events to RabbitMQ with a given format, in order for this app to consume and process events to build the feed. We can always shutdown AMQP, and feed the `Store.FeedBuilder` using [distributed erlang](http://erlang.org/doc/reference_manual/distributed.html), the API, or building some other mecanism.

We support 3 kind of events. `create`, `update`, `delete`. In order for us to handle an `update` or `delete` correctly, we should have already processed the create. `udpate` wont work once the event is deleted.

### Our generic event looks like this.

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

### This app exposes an API endpoint.

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

### Websockets

We can also subscibe for updates using [phoenix channels](https://hexdocs.pm/phoenix/channels.html).

Websocket @ `/ws/v1/feed`

### Channel Subscriptions

Subscribe for company events @ `company:<id>`
```
// new event
{
	"type": "create",
	"data": {},
	"id": 0
}

// update event
{
	"type": "create",
	"data": {},
	"id": 0
}

// delete event
{
	"id": 0
}
```

Subscribe for event changes @ `event:<id>`

```
// new comment
{
	"type": "create_comment",
	"data": {},
	"id": 0
}

// update comment
{
	"type": "update_comment",
	"data": {},
	"id": 0
}

// delete comment
{
	"type": "delete_comment",
	"id": 0
}

// new like state
{
	"type": "update_likes",
	"data": {}
}

// someone is typing
{
	"type": "typing",
	"data": {}
}
```


## setup


Change RabbitMQ config on `apps/bus/config/{dev, test, prod}.exs`.

```
config :bus, :rabbitmq, "amqp://guest:guest@127.0.0.1"
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

Cache mecanism for users and other feed interactions can be customized. TTL is not active by default.

```
config :store, :user_cache,
  ttl: true,
  touch_on_read: true,
  global_ttl: 20,
  check_interval: 2

config :store, :interactions_cache,
  ttl: false
```

## TODO

- Better docs
- More tests
- Generic authentication and authorization mecanism
- Explore other ways of retrieving user's data.
- Explore other ways of storing data. [Cassandra](https://github.com/blitzstudios/triton), [Riak](http://basho.com/products/), [Mnesia](http://erlang.org/doc/man/mnesia.html) 🤔

---

[Easy deploy using edeliver](https://github.com/edeliver/edeliver)

