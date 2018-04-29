defmodule Store.FeedBuilder do
  @moduledoc false
  use GenServer
  import Ecto.Query, only: [from: 2]
  alias Store.{FeedRepo, Feed, Event, Broadcast}
  require Logger

  def start_link(_, opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:build, map}, _from, _state) do
    map
    |> build
    |> send_result()
  end

  def build(%{"type" => type} = map) do
    type
    |> dispatch(map)
    |> publish_changes(type)
  end

  defp dispatch("create", map) do
    map
    |> new_changeset()
    |> save_changeset()
  end

  defp dispatch("update", map) do
    map
    |> validate_update()
    |> update_changeset()
  end

  defp dispatch("delete", map) do
    map
    |> delete_event()
  end

  defp dispatch(_, map) do
    _ = Logger.info(fn -> "[FeedBuilder] - Event not recognized" end)
    _ = Logger.info(fn -> "#{inspect(map)}" end)
  end

  defp new_changeset(%{"event" => data}) do
    Event.changeset(%Event{}, data)
  end

  defp validate_update(%{"event" => data}) do
    external_id = data["external_id"]
    query = from(e in Event, where: e.external_id == ^external_id)

    query
    |> FeedRepo.one!()
    |> Event.changeset(data)
  end

  defp delete_event(%{"event" => data}) do
    external_id = data["external_id"]
    query = from(e in Event, where: e.external_id == ^external_id)

    query
    |> FeedRepo.one!()
    |> FeedRepo.delete()
  end

  defp save_changeset(%Ecto.Changeset{valid?: true} = changeset), do: FeedRepo.insert(changeset)
  defp save_changeset(%Ecto.Changeset{valid?: false, errors: errors}), do: {:error, errors}

  defp update_changeset(%Ecto.Changeset{valid?: true} = changeset), do: FeedRepo.update(changeset)
  defp update_changeset(%Ecto.Changeset{valid?: false, errors: errors}), do: {:error, errors}

  defp publish_changes({:ok, event}, event_type) do
    event_payload = Feed.render_event(event)
    Broadcast.event(event_type, event.id, event_payload)
    {:ok, event}
  end

  defp publish_changes(err, _), do: err

  defp send_result(result), do: {:reply, result, %{}}
end
