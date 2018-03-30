defmodule Store.Comments do
  @moduledoc false
  use GenServer
  import Ecto.Query, only: [from: 2]
  alias Store.Comment
  alias Store.FeedRepo, as: Repo
  def start_link(_, opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:summary, event_id}, _from, state) do
    event_id
    |> get_summary()
    |> send_result(state)
  end

  def handle_call({:index, params}, _from, state) do
    event_id = params["event_id"] || params[:event_id]
    event_id
    |> get()
    |> Enum.map(&render/1)
    |> send_result(state)
  end

  def handle_call({:create, params}, _from, state) do
    send_result(nil, state)
  end

  def handle_call({:update, params}, _from, state) do
    send_result(nil, state)
  end

  def handle_call({:delete, params}, _from, state) do
    send_result(nil, state)
  end

  defp send_result(result, state), do: {:reply, result, state}

  def get_summary(event_id) do
    retrieve_hot_summary(event_id) || retrieve_cold_summary(event_id)
  end

  defp retrieve_hot_summary(event_id) do
    ConCache.get(:user_cache, "#{event_id}c")
  end

  defp retrieve_cold_summary(event_id) do
    select_query = from c in Comment,
            where: c.event_id == ^event_id,
            order_by: [asc: :inserted_at],
            limit: 3
    count_query = from c in Comment,
            where: c.event_id == ^event_id,
            select: count(c.id)
    comments = Repo.all(select_query)
    count = Repo.one(count_query)
    summary = %{count: count, comments: Enum.map(comments, &render/1)}
    ConCache.put(:user_cache, "#{event_id}c", summary)
    summary
  end

  defp get(event_id) do
    query = from c in Comment,
            where: c.event_id == ^event_id,
            order_by: [asc: :inserted_at]
    Repo.all(query)
  end

  defp render(comment) do
    user = GenServer.call(Users, {:get, comment.user_id})
    %{
      user: user,
      comment: comment
    }
  end
end
