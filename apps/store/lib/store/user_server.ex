defmodule Store.UserServer do
  use GenServer
  import Ecto.Query, only: [from: 2]
  alias Store.SourceRepo

  def start_link(_, opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get, id}, _, _) do
    user = retrieve_hot(id) || retrieve_cold(id)
    send_result(user)
  end

  defp send_result(result), do: {:reply, result, %{}}

  defp retrieve_hot(id) do
    ConCache.get(:feed_cache, "#{id}")
  end

  defp retrieve_cold(id) do
    id
    |> build_query()
    |> FondRepo.one!()
  end

  defp build_query(id) do
    from(
      r in table(),
      where: field(r, ^user_id()) == type(^id, :integer),
      select: map(r, [user_id(), full_name(), profile_pic()])
    )
  end

  defp table, do: Application.get_env(:store, :external_db_table_name)
  defp user_id, do: Application.get_env(:store, :external_db_user_id)
  defp full_name, do: Application.get_env(:store, :external_db_full_name)
  defp profile_pic, do: Application.get_env(:store, :external_db_profile_pic)
end
