using System;
using System.Text;
using RabbitMQ.Client;
using Newtonsoft.Json;
using TechTalksModel;
using TechTalksModel.DTO;
using Bogus;

namespace TechTalksAPI.Messaging
{
    public class TechTalksEventPublisher : ITechTalksEventPublisher
    {
        private const string exchangeName = "TechTalksExchange";
        private const string queueName = "hello";
        private const string routingKey = "hello";

        public void SendMessage(TechTalkDTO talk)
        {
            Console.WriteLine("Inside send message");

            var factory = new ConnectionFactory()
            {
                HostName = "rabbitmq",
                UserName = "user",
                Password = "PASSWORD"
            };

            Console.WriteLine("Inside connection factory");

            using (var connection = factory.CreateConnection())
            {
                Console.WriteLine("Inside connection");

                using (var channel = connection.CreateModel())
                {
                    Console.WriteLine("Inside model");
                    channel.ExchangeDeclare(exchangeName, "fanout");

                    var body = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(talk));

                    channel.BasicPublish(
                        exchange: exchangeName,
                        routingKey: routingKey,
                        basicProperties: null,
                        body: body);

                    Console.WriteLine(" [x] Sent {0}", talk);
                }
            }
        }

        public void SendMessage(TechTalk talk)
        {
            Console.WriteLine("Inside send message");

            var factory = new ConnectionFactory()
            {
                HostName = "rabbitmq",
                UserName = "user",
                Password = "PASSWORD"
            };

            Console.WriteLine("Inside connection factory");

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

                    var properties = channel.CreateBasicProperties();
                    properties.Persistent = true;

                    var body = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(talk));

                    // for (int i = 0; i < 500; i++)
                    // {
                    channel.BasicPublish(exchange: "",
                                    routingKey: routingKey,
                                    basicProperties: properties,
                                    body: body);

                    Console.WriteLine($"{talk} published successfully");
                    // Console.WriteLine($"{i} Sent {0}", talk);
                    // }
                }
            }
        }

        public void SendMessages(List<TechTalk> talks)
        {
            Console.WriteLine("Inside send message");

            var factory = new ConnectionFactory()
            {
                HostName = "rabbitmq",
                UserName = "user",
                Password = "PASSWORD"
            };

            Console.WriteLine("Inside connection factory");

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

                    var properties = channel.CreateBasicProperties();
                    properties.Persistent = true;

                    talks.ForEach(talks =>
                    {
                        var body = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(talk));

                        // for (int i = 0; i < 500; i++)
                        // {
                        channel.BasicPublish(exchange: "",
                                        routingKey: routingKey,
                                        basicProperties: properties,
                                        body: body);

                        Console.WriteLine($"{talk} published successfully");

                    });
                    // Console.WriteLine($"{i} Sent {0}", talk);
                    // }
                }
            }
        }
    }
}