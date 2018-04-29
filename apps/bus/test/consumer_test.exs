defmodule ConsumerTest do
  use ExUnit.Case
  alias AMQP.{Connection, Channel, Basic}
  alias Faker.Lorem.Shakespeare
  doctest Bus

  test "it can consume events" do
    {:ok, conn} = Connection.open()
    {:ok, chan} = Channel.open(conn)
    Basic.publish(chan, "gen_server_test_exchange", "", event_string())
  end

  defp event_string do
    """
      {
        "type": "create",
        "event": {
          "tenant": 0,
          "user_id": 0,
          "content": "#{Shakespeare.hamlet()}",
          "extra": {},
          "date": "2015-01-23T23:50:07.123+02:30"
        }
      }
    """
  end
end
