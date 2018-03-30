defmodule FeedTestHelper do
  def create(num \\ 1_000) do
  	users = (0..10)
      |> Enum.map(&create_user/1)
    companies = (0..5)
      |> Enum.map(fn _ -> :rand.uniform(1_000_000_000) end)
    (0..num)
      |> Enum.map(fn x -> event(x, users, companies) end)
  end

  defp create_user(_) do
    UserTestHelper.generate_user()
  end

  defp event(_, users, companies) do
    user_num = :rand.uniform(10) - 1
    company_num = :rand.uniform(5) - 1
    {uid, _, _} = Enum.at(users, user_num)
    %{
    	"event" => %{
    		"type" => "x",
        "external_id" => :rand.uniform(1_000_000_000),
    		"tenant_id" => Enum.at(companies, company_num),
    		"user_id" => uid,
    		"content" => Faker.Lorem.paragraph(),
    		"data" => %{},
    		"date" => fake_date()
    	}, "type" => "create"
    }
  end

  defp fake_date do
  	datetime = DateTime.to_unix(DateTime.utc_now())
    datetime - :rand.uniform(31_556_952)
  end
end