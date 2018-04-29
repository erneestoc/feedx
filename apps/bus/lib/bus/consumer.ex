defmodule Bus.Consumer do
  @moduledoc false
  use GenServer
  use AMQP
  require Logger

  @type error :: {:error, reason :: :blocked | :closing}

  @exchange "gen_server_test_exchange"
  @queue "gen_server_test_queue"
  @queue_error "#{@queue}_error"

  defp settings, do: Application.get_env(:bus, :rabbitmq)

  def start_link(_, opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, conn} = Connection.open(settings())
    {:ok, chan} = Channel.open(conn)
    setup_queue(chan)
    :ok = Basic.qos(chan, prefetch_count: 10)
    {:ok, _consumer_tag} = Basic.consume(chan, @queue)
    {:ok, chan}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, chan) do
    _ = Logger.debug(fn -> "[Consumer] - :basic_consume_ok, consumer_tag: #{consumer_tag}" end)
    {:noreply, chan}
  end

  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, chan) do
    _ = Logger.info(fn -> "[Consumer] - :basic_cancel. Broker cancelled consumer." end)
    {:stop, :normal, chan}
  end

  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    consume(chan, tag, redelivered, payload)
    {:noreply, chan}
  end

  defp setup_queue(chan) do
    {:ok, _} = Queue.declare(chan, @queue_error, durable: true)

    # Messages that cannot be delivered to any consumer in the
    # main queue will be routed to the error queue
    {:ok, _} =
      Queue.declare(
        chan,
        @queue,
        durable: true,
        arguments: [
          {"x-dead-letter-exchange", :longstr, ""},
          {"x-dead-letter-routing-key", :longstr, @queue_error}
        ]
      )

    :ok = Exchange.fanout(chan, @exchange, durable: true)
    :ok = Queue.bind(chan, @queue, @exchange)
  end

  @spec consume(Channel.t(), String.t(), boolean(), map()) :: :ok | error
  defp consume(channel, tag, redelivered, payload) do
    json = Poison.decode!(payload)

    _ =
      case GenServer.call(:feed_builder, {:build, json}) do
        {:ok, _built} ->
          Logger.debug(fn -> "[Bus.Consumer] - consume\\4 SUCCESS" end)

        _ ->
          :ok = Basic.reject(channel, tag, requeue: false)
          Logger.debug(fn -> "[Bus.Consumer] - consume\\4 FAIL REQUEUE" end)
      end

    Basic.ack(channel, tag)
  rescue
    exception ->
      :ok = Basic.reject(channel, tag, requeue: not redelivered)
      :ok = Logger.error(fn -> "Error converting #{inspect(exception)} to integer" end)
  end
end
