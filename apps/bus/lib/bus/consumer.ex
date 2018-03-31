defmodule Bus.Consumer do
  @moduledoc false
  use GenServer
  use AMQP
  alias Store.FeedBuilder
  require Logger

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
    # Limit unacknowledged messages to 10
    :ok = Basic.qos(chan, prefetch_count: 10)
    # Register the GenServer process as a consumer
    {:ok, _consumer_tag} = Basic.consume(chan, @queue)
    {:ok, chan}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  # Sent by the broker when the consumer is
  # unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    spawn(fn -> consume(chan, tag, redelivered, payload) end)
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

  defp consume(channel, tag, redelivered, payload) do
    json = Poison.decode!(payload)

    case FeedBuilder.build(json) do
      {:ok, _built} ->
        Logger.debug(fn -> "[Bus.Consumer] - consume\\4 SUCCESS" end)

      _ ->
        :ok = Basic.reject(channel, tag, requeue: false)
        Logger.debug(fn -> "[Bus.Consumer] - consume\\4 FAIL REQUEUE" end)
    end

    :ok = Basic.ack(channel, tag)
  rescue
    # Requeue unless it's a redelivered message.
    # This means we will retry consuming a message once in case of exception
    # before we give up and have it moved to the error queue
    #
    # You might also want to catch :exit signal in production code.
    # Make sure you call ack, nack or reject otherwise comsumer will stop
    # receiving messages.
    _exception ->
      :ok = Basic.reject(channel, tag, requeue: not redelivered)
      Logger.error(fn -> "Error converting #{payload} to integer" end)
  end
end
