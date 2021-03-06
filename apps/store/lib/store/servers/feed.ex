defmodule Store.Feed do
  @moduledoc false
  use GenServer
  import Ecto.Query, only: [where: 3, order_by: 2]
  alias Store.{Event, Users, Comments, Likes}
  alias Store.FeedRepo, as: Repo

  def start_link(_, opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:index_all, params}, _from, state) do
    params
    |> index_all()
    |> formatting()
    |> send_result(state)
  end

  def handle_call({:index_for, params}, _from, state) do
    params
    |> index_for()
    |> formatting()
    |> send_result(state)
  end

  defp send_result(result, state), do: {:reply, result, state}

  def index_for(params) do
    tenant_id = params["tenant_id"]
    options = cursor_options(params)

    Event
    |> where([e], e.tenant_id == ^tenant_id)
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(options)
  end

  def index_all(params) do
    options = cursor_options(params)

    Event
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(options)
  end

  defp cursor_options(%{"pagination" => options}) do
    [cursor_fields: [:inserted_at, :id], limit: 30, after: options]
  end

  defp cursor_options(_) do
    [cursor_fields: [:inserted_at, :id], limit: 30]
  end

  defp formatting(%{entries: [], metadata: metadata}), do: %{events: [], pagination: metadata}

  defp formatting(%{entries: events, metadata: metadata}) do
    events =
      events
      |> Enum.map(&render_event/1)

    %{
      events: events,
      pagination: metadata
    }
  end

  def render_event(event) do
    user = GenServer.call(Users, {:get, event.user_id})
    comments = GenServer.call(Comments, {:preview, event.id})
    likes = GenServer.call(Likes, {:preview, event.id, event.user_id})
    %{event: event, user: user, comments: comments, likes: likes}
  end
end
