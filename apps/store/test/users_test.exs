defmodule UsersTest do
  use Store.TestCase
  doctest Store.Users
  alias Store.Users

  setup_all do
    UserTestHelper.ddl()
    :ok
  end

  test "get non existing user" do
    assert_raise Ecto.NoResultsError, fn ->
      Users.get("98765234234")
    end
  end

  test "get user from database when exists" do
    {id, name, pic} = UserTestHelper.generate_user()
    {tc1, user} = :timer.tc(fn -> Users.get(id) end)

    {tc2, user2} = :timer.tc(fn -> Users.get(id) end)
    assert id == user.id
    assert name == user.full_name
    assert pic == user.profile_pic

    assert user2.id == user.id
    assert user2.full_name == user.full_name
    assert user2.profile_pic == user.profile_pic

    # first get more than X times slower (cache vs db)
    assert tc1 > tc2
  end
end
