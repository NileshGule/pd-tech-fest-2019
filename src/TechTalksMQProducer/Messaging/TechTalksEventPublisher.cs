using System;
using System.Collections.Generic;
using System.Text;
using RabbitMQ.Client;
using Newtonsoft.Json;
using TechTalksModel;
using TechTalksModel.DTO;
using Bogus;
using Microsoft.Extensions.Configuration;

namespace TechTalksAPI.Messaging
{
    public class TechTalksEventPublisher : ITechTalksEventPublisher
    {
        private const string queueName = "hello";
        private const string routingKey = "hello";

        private readonly string rabbitMQHostName;
        private readonly string rabbitMQUserName;
        private readonly string rabbitMQPassword;

        public TechTalksEventPublisher(IConfiguration config)
        {
            rabbitMQHostName = config.GetValue<string>("RABBITMQ_HOST_NAME");
            rabbitMQUserName = config.GetValue<string>("RABBITMQ_USER_NAME");
            rabbitMQPassword = config.GetValue<string>("RABBITMQ_PASSWORD");
        }

        public void SendMessages(List<TechTalk> talks)
        {
            Console.WriteLine("Inside send message");

            var factory = new ConnectionFactory()
            {
                HostName = rabbitMQHostName,
                UserName = rabbitMQUserName,
                Password = rabbitMQPassword
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

                    List<byte[]> serializedTalks = new List<byte[]>();

                    talks.ForEach(talk =>
                    {
                        serializedTalks.Add(
                            Encoding.UTF8.GetBytes(
                                JsonConvert.SerializeObject(talk)
                                ));
                    });

                    serializedTalks.ForEach(body =>
                    {
                        channel.BasicPublish(exchange: "",
                                routingKey: routingKey,
                                basicProperties: properties,
                                body: body);

                        Console.WriteLine($"{body} published to message queue");
                    });

                }
            }
        }
    }
}