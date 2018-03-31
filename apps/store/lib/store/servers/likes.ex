defmodule Store.Likes do
  @moduledoc false
  use GenServer
  import Ecto.Query, only: [from: 2]
  alias Store.{Users, Like}
  alias Store.FeedRepo, as: Repo

  def start_link(_, opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:preview, event_id}, _from, state) do
    event_id
    |> get_preview()
    |> send_result(state)
  end

  def handle_call({:preview, event_id, user_id}, _from, state) do
    event_id
    |> get_preview(user_id)
    |> send_result(state)
  end

  def handle_call({:index, params}, _from, state) do
    event_id = params["event_id"] || params[:event_id]

    event_id
    |> get()
    |> Enum.map(&render_user/1)
    |> send_result(state)
  end

  def handle_call({:create, params}, _from, state) do
    params
    |> create()
    |> send_result(state)
  end

  def handle_call({:delete, params}, _from, state) do
    params
    |> delete()
    |> send_result(state)
  end

  defp send_result(result, state), do: {:reply, result, state}

  defp get_preview(event_id, user_id \\ -1) do
    select_query =
      from(
        l in Like,
        where: l.event_id == ^event_id,
        order_by: [asc: :inserted_at],
        limit: 3
      )

    you_query =
      from(
        l in Like,
        where: l.event_id == ^event_id and l.user_id == ^user_id,
        limit: 1
      )

    count_query =
      from(
        l in Like,
        where: l.event_id == ^event_id,
        select: count(l.id)
      )

    likes = Repo.all(select_query)
    count = Repo.one(count_query)
    you = Repo.all(you_query)
    summary = %{
      count: count,
      likers: Enum.map(likes, &render_user/1),
      you: you != []
    }
    summary
  end

  defp get(event_id) do
    query =
      from(
        c in Like,
        where: c.event_id == ^event_id,
        order_by: [asc: :inserted_at]
      )

    Repo.all(query)
  end

  defp render_user(like) do
    GenServer.call(Users, {:get, like.user_id})
  end

  defp create(params) do
    user_id = params["user_id"] || params[:user_id]
    event_id = params["event_id"] || params[:event_id]

    you_query =
      from(
        l in Like,
        where: l.event_id == ^event_id and l.user_id == ^user_id,
        limit: 1
      )

    case Repo.one(you_query) do
      nil ->
        %Like{}
        |> Like.changeset(params)
        |> Repo.insert()

      result ->
        result
    end
  end

  defp delete(params) do
    user_id = params["user_id"] || params[:user_id]
    event_id = params["event_id"] || params[:event_id]

    you_query =
      from(
        l in Like,
        where: l.event_id == ^event_id and l.user_id == ^user_id,
        limit: 1
      )

    like =
      you_query
      |> Repo.one!()

    Repo.delete(like)
  end
end
