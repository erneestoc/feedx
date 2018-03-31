defmodule Store.Comments do
  @moduledoc false
  use GenServer
  import Ecto.Query, only: [from: 2]
  alias Store.{Comment, Users, Broadcast}
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

  def handle_call({:index, params}, _from, state) do
    event_id = params["event_id"] || params[:event_id]

    event_id
    |> get()
    |> Enum.map(&render/1)
    |> send_result(state)
  end

  def handle_call({:create, params}, _from, state) do
    params
    |> create()
    |> cache()
    |> emit("add_comment")
    |> send_result(state)
  end

  def handle_call({:update, params}, _from, state) do
    params
    |> update()
    |> emit("update_comment")
    |> send_result(state)
  end

  def handle_call({:delete, params}, _from, state) do
    params
    |> delete()
    |> emit("remove_comment")
    |> send_result(state)
  end

  defp send_result(result, state), do: {:reply, result, state}

  def get_preview(event_id) do
    retrieve_hot_summary(event_id) || retrieve_cold_summary(event_id)
  end

  defp retrieve_hot_summary(event_id) do
    ConCache.get(:interactions_cache, "#{event_id}c")
  end

  defp retrieve_cold_summary(event_id) do
    select_query =
      from(
        c in Comment,
        where: c.event_id == ^event_id,
        order_by: [asc: :inserted_at],
        limit: 3
      )

    count_query =
      from(
        c in Comment,
        where: c.event_id == ^event_id,
        select: count(c.id)
      )

    comments = Repo.all(select_query)
    count = Repo.one(count_query)
    summary = %{count: count, comments: Enum.map(comments, &render/1)}
    ConCache.put(:interactions_cache, "#{event_id}c", summary)
    summary
  end

  defp get(event_id) do
    query =
      from(
        c in Comment,
        where: c.event_id == ^event_id,
        order_by: [asc: :inserted_at]
      )

    Repo.all(query)
  end

  defp render(comment) do
    user = GenServer.call(Users, {:get, comment.user_id})

    %{
      user: user,
      comment: comment
    }
  end

  defp create(params) do
    %Comment{}
    |> Comment.changeset(params)
    |> Repo.insert()
  end

  defp cache({:ok, comment}) do
    case retrieve_hot_summary(comment.event_id) do
      nil ->
        nil

      cached ->
        cached = Map.put(cached, :count, cached.count + 1)

        comments =
          if length(cached.comments) >= 3 do
            {_popped, comments_list} = List.pop_at(cached.comments, 0)
            comments_list
          else
            cached.comments
          end

        cached = Map.put(cached, :comments, comments ++ [comment])
        ConCache.put(:interactions_cache, "#{comment.event_id}c", cached)
    end

    {:ok, comment}
  end

  defp cache(result), do: result

  defp emit({:ok, comment}, event) do
    payload = render(comment)
    Broadcast.event(event, comment.event_id, payload)
    {:ok, comment}
  end

  defp emit(result, _), do: result

  defp update(params) do
    comment_id = params["comment_id"] || params[:comment_id]
    comment = Repo.get_by(Comment, id: comment_id)
    ConCache.delete(:interactions_cache, "#{comment.event_id}c")

    comment
    |> Comment.changeset(params)
    |> Repo.insert()
  end

  defp delete(params) do
    comment_id = params["comment_id"] || params[:comment_id]
    comment = Repo.get_by(Comment, id: comment_id)
    ConCache.delete(:interactions_cache, "#{comment.event_id}c")
    Repo.delete(comment)
  end
end
