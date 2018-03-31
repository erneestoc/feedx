defmodule Store.FeedBuilder do
  @moduledoc false
  use GenServer
  import Ecto.Query, only: [from: 2]
  alias Store.{FeedRepo, Event}

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

    case type do
      "create" -> create(map)
      "update" -> update(map)
      "delete" -> delete(map)
    end
  end

  defp create(map) do
    map
    |> validate()
    |> store()
    |> emit("create")
  end

  defp update(map) do
    map
    |> changeset()
    |> put()
    |> emit("update")
  end

  defp delete(map) do
    map
    |> remove()
    |> emit("delete")
  end

  defp validate(%{"event" => data}) do
    changeset = Event.changeset(%Event{}, data)

    if changeset.valid? do
      {:ok, changeset}
    else
      {:error, changeset.errors}
    end
  end

  defp changeset(%{"event" => data}) do
    external_id = data["external_id"] || data[:external_id]
    query = from(e in Event, where: e.external_id == ^external_id)
    event = FeedRepo.one!(query)
    changeset = Event.changeset(event, data)

    if changeset.valid? do
      {:ok, changeset}
    else
      {:error, changeset.errors}
    end
  end

  defp remove(%{"event" => data}) do
    external_id = data["external_id"] || data[:external_id]
    query = from(e in Event, where: e.external_id == ^external_id)
    event = FeedRepo.one!(query)
    Repo.delete(event)
  end

  defp store({:ok, event}), do: FeedRepo.insert(event)
  defp store(err), do: err

  defp put({:ok, event}), do: FeedRepo.update(event)
  defp put(err), do: err

  defp emit({:ok, event}, _event_type) do
    {:ok, event}
  end

  defp emit(err, _), do: err
end
