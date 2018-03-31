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

  defp types, do: Application.get_env(:backbone, :event_types)

  def handle_call({:build, json}, _from, _state) do
    json
    |> build
    |> send_result()
  end

  def build(json) do
    type = json["type"] || json[:type]

    case type do
      "create" -> create(json)
      "update" -> update(json)
      "delete" -> delete(json)
    end
  end

  defp create(json) do
    json
    |> validate()
    |> store()
    |> emit("create")
  end

  defp update(json) do
    json
    |> changeset()
    |> put()
    |> emit("update")
  end

  defp delete(json) do
    json
    |> remove()
    |> emit("delete")
  end

  defp validate(%{"event" => data} = json) do
    changeset = Event.changeset(%Event{}, data)

    if changeset.valid? do
      {:ok, changeset}
    else
      {:error, changeset.errors}
    end
  end

  defp changeset(%{"event" => data} = json) do
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

  defp remove(%{"event" => data} = json) do
    external_id = data["external_id"] || data[:external_id]
    query = from(e in Event, where: e.external_id == ^external_id)
    event = FeedRepo.one!(query)
    Repo.delete(event)
  end

  defp store({:ok, event}), do: FeedRepo.insert(event)
  defp store(err), do: err

  defp put({:ok, event}), do: FeedRepo.update(event)
  defp put(err), do: err

  defp emit({:ok, event}, event_type) do
    IO.inspect("TODO: publish")
    {:ok, event}
  end

  defp emit(err, _), do: err
end
