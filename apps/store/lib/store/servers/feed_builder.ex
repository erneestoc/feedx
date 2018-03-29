defmodule Store.FeedBuilder do
  @moduledoc false
  use GenServer

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
    |> validate()
    |> store()
    |> emit()
    |> send_result()
  end

  defp validate(%{"type" => type} = json) do
    member =
      types()
      |> Enum.member?(type)

    if member do
      {:ok, json}
    else
      {:error, "Type not found"}
    end
  end

  defp store({:ok, event}) do
  end

  defp store(err), do: err

  defp emit({:ok, event}) do
  end

  defp emit(err), do: err
end
