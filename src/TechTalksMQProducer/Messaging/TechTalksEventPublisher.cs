using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using RabbitMQ.Client;
using Newtonsoft.Json;
using TechTalksModel;
using TechTalksModel.DTO;
using Microsoft.Extensions.Configuration;
using Dapr.Client;

namespace TechTalksAPI.Messaging
{
    public class TechTalksEventPublisher : ITechTalksEventPublisher
    {
        private const string queueName = "hello";
        private const string routingKey = "hello";

        private readonly string rabbitMQHostName;
        private readonly string rabbitMQUserName;
        private readonly string rabbitMQPassword;

        private readonly string pubsubName;

        private readonly string topicName;

        public TechTalksEventPublisher(IConfiguration config)
        {
            rabbitMQHostName = config.GetValue<string>("RABBITMQ_HOST_NAME");
            rabbitMQUserName = config.GetValue<string>("RABBITMQ_USER_NAME");
            rabbitMQPassword = config.GetValue<string>("RABBITMQ_PASSWORD");
            pubsubName = "rabbitmq-pubsub";
            topicName = "techtalks";

            Console.WriteLine("Configuration inititalized in constructor");
        }

        public void SendMessages(List<TechTalk> talks)
        {
            Console.WriteLine("Inside send messages");

            // var factory = new ConnectionFactory()
            // {
            //     HostName = rabbitMQHostName,
            //     UserName = rabbitMQUserName,
            //     Password = rabbitMQPassword
            // };

            List<byte[]> serializedTalks = new List<byte[]>();

            talks.ForEach(talk =>
            {
                serializedTalks.Add(
                    Encoding.UTF8.GetBytes(
                        JsonConvert.SerializeObject(talk)
                        ));
            });

            Console.WriteLine("Serialized talks count: " + serializedTalks.Count);

            using (var client = new DaprClientBuilder().Build())
            {
                Console.WriteLine($"Created Dapr client successfully");

                Dictionary<string, string> queueMetadata = new Dictionary<string, string>();
                queueMetadata.Add("routingKey", "hello");

                serializedTalks.ForEach(talk =>
                {
                    CancellationTokenSource source = new CancellationTokenSource();
                    CancellationToken cancellationToken = source.Token;

                    client.PublishEventAsync(pubsubName, topicName, talk, cancellationToken);



                    // client.PublishEventAsync(pubsubName, topicName, talk, queueMetadata);

                    // publish messages with routing key `keyA`, and these will be received by the above example.
                    // client.PublishEvent(context.Background(), pubsubName, topicName, talk, client.PublishEventWithMetadata(map[string]string{ "routingKey": "hello"}));

                    Console.WriteLine($"{talk} published to message queue");
                });

                Console.WriteLine($"Client Type {client.GetType()}");
            }

            // Console.WriteLine("Inside connection factory");

            // using (var connection = factory.CreateConnection())
            // {
            //     Console.WriteLine("Inside connection");

            //     using (var channel = connection.CreateModel())
            //     {
            //         Console.WriteLine("Inside model");

            //         channel.QueueDeclare(
            //             queue: queueName,
            //             durable: true,
            //             exclusive: false,
            //             autoDelete: false,
            //             arguments: null
            //         );

            //         var properties = channel.CreateBasicProperties();
            //         properties.Persistent = true;

            //         serializedTalks.ForEach(body =>
            //         {
            //             channel.BasicPublish(exchange: "",
            //                     routingKey: routingKey,
            //                     basicProperties: properties,
            //                     body: body);

            //             Console.WriteLine($"{body} published to message queue");
            //         });

            //     }
            // }
        }
    }
}