defmodule Backbone.FeedBuilder do

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
  	cond do
  	  member -> {:ok, json}
  	  true -> {:error, "Type not found"}
  	end
  end

  defp store({:ok, event}) do

  end

  defp store(err), do: err

  defp emit({:ok, event}) do

  end

  defp emit(err), do: err
end