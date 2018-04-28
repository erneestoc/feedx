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

  defp send_result(result), do: {:reply, result, %{}}

  def handle_call({:build, map}, _from, _state) do
    map
    |> build
    |> send_result()
  end

  def build(map) do
    type = map["type"] || map[:type]
    dispatch(type, map)
  end

  defp dispatch("create" = type, map) do
    map
    |> validate()
    |> store()
    |> emit(type)
  end

  defp dispatch("update" = type, map) do
    map
    |> changeset()
    |> put()
    |> emit(type)
  end

  defp dispatch("delete" = type, map) do
    map
    |> remove()
    |> emit(type)
  end

  defp dispatch(_, map) do
    _ = Logger.info(fn -> "[FeedBuilder] - Event not recognized" end)
    _ = Logger.info(fn -> "#{inspect(map)}" end)
  end

  defp validate(%{"event" => data}) do
    Event.changeset(%Event{}, data)
  end

  defp changeset(%{"event" => data}) do
    external_id = data["external_id"] || data[:external_id]
    query = from(e in Event, where: e.external_id == ^external_id)
    event = FeedRepo.one!(query)
    Event.changeset(event, data)
  end

  defp remove(%{"event" => data}) do
    external_id = data["external_id"] || data[:external_id]
    query = from(e in Event, where: e.external_id == ^external_id)
    event = FeedRepo.one!(query)
    FeedRepo.delete(event)
  end

  defp store(%Ecto.Changeset{valid?: true} = changeset), do: FeedRepo.insert(changeset)
  defp store(%Ecto.Changeset{valid?: false, errors: errors}), do: {:error, errors}

  defp put(%Ecto.Changeset{valid?: true} = changeset), do: FeedRepo.update(changeset)
  defp put(%Ecto.Changeset{valid?: false, errors: errors}), do: {:error, errors}

  defp emit({:ok, event}, event_type) do
    event_payload = Feed.render_event(event)
    Broadcast.event(event_type, event.id, event_payload)
    {:ok, event}
  end

  defp emit(err, _), do: err
end
