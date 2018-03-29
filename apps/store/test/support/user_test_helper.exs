defmodule UserTestHelper do
  def table, do: Application.get_env(:store, :external_db_table_name)
  def user_id, do: Application.get_env(:store, :external_db_user_id)
  def first_name, do: Application.get_env(:store, :external_db_full_name)
  def profile_pic, do: Application.get_env(:store, :external_db_profile_pic)

  def ddl do
    Ecto.Adapters.SQL.query!(Store.SourceRepo, ddl_query(), [])
  end

  defp ddl_query do
    """
    CREATE TABLE IF NOT EXISTS #{table()} (
     #{user_id()} int,
     #{first_name()} varchar(255),
     #{profile_pic()} varchar(255)
    );
    """
  end

  def generate_user do
    id = :rand.uniform(1_000_000_000)
    name = Faker.Name.first_name()
    pic = Faker.Internet.image_url()
    Ecto.Adapters.SQL.query!(Store.SourceRepo, user_query(id, name, pic), [])
    {id, name, pic}
  end

  defp user_query(id, name, pic) do
    """
    INSERT INTO #{table()} (#{user_id()}, #{first_name()}, #{profile_pic()}) 
    VALUES (#{id}, '#{name}', '#{pic}')
    """
  end
end
