Code.require_file("test_case.exs", "./test/support")
Code.require_file("user_test_helper.exs", "./test/support")
Code.require_file("feed_test_helper.exs", "./test/support")
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Store.FeedRepo, :auto)
Ecto.Adapters.SQL.Sandbox.mode(Store.SourceRepo, :auto)
