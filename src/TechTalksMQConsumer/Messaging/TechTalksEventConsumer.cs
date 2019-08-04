using System;
using System.Linq;
using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Newtonsoft.Json;
using TechTalksModel;
using System.Threading;
using TechTalksModel.DTO;
using Microsoft.EntityFrameworkCore;

namespace TechTalksProcessor.Messaging
{
    public class TechTalksEventConsumer : ITechTalksEventConsumer
    {
        private const string exchangeName = "TechTalksExchange";
        private const string queueName = "hello";
        private const string routingKey = "hello";

        private static ManualResetEvent _ResetEvent = new ManualResetEvent(false);

        public TechTalksEventConsumer()
        {
            // _context = context;
        }

        public void ConsumeMessage()
        {
            var factory = new ConnectionFactory()
            {
                HostName = "rabbitmq",
                UserName = "user",
                Password = "PASSWORD"
            };

            using (var connection = factory.CreateConnection())
            {
                Console.WriteLine("Inside connection");

                using (var channel = connection.CreateModel())
                {
                    Console.WriteLine("Inside model");

                    channel.QueueDeclare(
                        queue: queueName,
                        durable: true,
                        exclusive: false,
                        autoDelete: false,
                        arguments: null
                    );

                    channel.BasicQos(prefetchSize: 0, prefetchCount: 10, global: false);

                    var consumer = new EventingBasicConsumer(channel);

                    // consumer.Received += RabbitMQEventHandler;

                    consumer.Received += (TechTalksModel, ea) =>
                    {

                        Console.WriteLine("Inside RabbitMQ receiver...");
                        var body = ea.Body;
                        var message = Encoding.UTF8.GetString(body);
                        var techTalk = JsonConvert.DeserializeObject<TechTalk>(message);
                        Console.WriteLine($"Received message {message}");

                        Thread.Sleep(TimeSpan.FromMinutes(1).Minutes);

                        Console.WriteLine();
                        Console.WriteLine("----------");
                        Console.WriteLine($"Tech Talk Id : {techTalk.Id}");
                        Console.WriteLine($"Tech Talk Name : {techTalk.TechTalkName}");
                        Console.WriteLine($"Category : {techTalk.CategoryId}");
                        Console.WriteLine($"Level : {techTalk.LevelId}");
                        Console.WriteLine("----------");
                        Console.WriteLine();

                        Console.WriteLine($"TechTalk persisted successfully at {DateTime.Now.ToLongTimeString()}");

                        channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);


                    };

                    channel.BasicConsume(queue: queueName,
                                        autoAck: false,
                                        consumer: consumer);

                    Console.WriteLine($"Listening to events on {queueName}");

                    _ResetEvent.WaitOne();
                }
            }
        }
    }
}