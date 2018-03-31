defmodule Store.Feed do
  @moduledoc false
  use GenServer
  import Ecto.Query, only: [where: 3, limit: 3, order_by: 2]
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
    tenant_id = params["tenant_id"] || params[:tenant_id]

    Event
    |> where([e], e.tenant_id == ^tenant_id)
    |> add_time_constraints_for(params)
    |> order_by([desc: :inserted_at])
    |> limit([e], 20)
    |> Repo.all()
  end

  def index_all(params) do
    Event
    |> add_time_constraints_for(params)
    |> order_by([desc: :inserted_at])
    |> limit([e], 20)
    |> Repo.all()
  end

  defp add_time_constraints_for(query, %{"after" => date}) do
    add_time_constraints(query, date)
  end

  defp add_time_constraints_for(query, %{after: date}) do
    add_time_constraints(query, date)
  end

  defp add_time_constraints_for(query, _), do: query

  defp add_time_constraints(query, date) do
    date = DateTime.from_unix!(date)
    where(query, [e], e.created_at < ^date)
  end

  defp formatting([]), do: %{events: [], last_date: nil}

  defp formatting(events) do
    last = List.last(events)
    events = 
      events
      |> Enum.map(&render_event/1)
    %{events: events, last_date: last.inserted_at}
  end

  defp render_event(event) do
    user = GenServer.call(Users, {:get, event.user_id})
    comments = GenServer.call(Comments, {:preview, event.id})
    likes = GenServer.call(Likes, {:preview, event.id, event.user_id})
    %{event: event, user: user, comments: comments, likes: likes}
  end

end
