defmodule EventTest do
  use Store.TestCase
  doctest Store.Event
  alias Store.Event

  test "valid parameters and ISO date" do
    datetime = DateTime.to_iso8601(DateTime.utc_now())
    params = Map.put(valid_parameters(), "date", datetime)

    changeset = Event.changeset(%Event{}, params)
    assert changeset.valid?
  end

  test "valid parameters and unix timestamp" do
    datetime = DateTime.to_unix(DateTime.utc_now())
    params = Map.put(valid_parameters(), "date", datetime)

    changeset = Event.changeset(%Event{}, params)
    assert changeset.valid?
  end

  defp valid_parameters do
    %{
      "type" => "a",
      "content" => "jaeiofje",
      "user_id" => 1,
      "tenant_id" => 1,
      "external_id" => 1
    }
  end
end
