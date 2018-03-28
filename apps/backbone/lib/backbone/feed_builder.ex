defmodule Backbone.FeedBuilder do
  @moduledoc false
  defp types, do: Application.get_env(:backbone, :event_types)

  def build(json) do
    json
    |> validate()
    |> store()
    |> emit()
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
