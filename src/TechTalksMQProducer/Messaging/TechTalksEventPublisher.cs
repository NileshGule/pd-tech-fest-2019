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
        private readonly string pubsubName;

        private readonly string topicName;

        public TechTalksEventPublisher(IConfiguration config)
        {
            pubsubName = "rabbitmq-pubsub";
            topicName = "techtalks";
        }

        public void SendMessages(List<TechTalk> talks)
        {
            Console.WriteLine("Inside send messages");

            using (var client = new DaprClientBuilder().Build())
            {
                talks.ForEach(talk =>
                {
                    CancellationTokenSource source = new CancellationTokenSource();
                    CancellationToken cancellationToken = source.Token;

                    client.PublishEventAsync(pubsubName, topicName, talk, cancellationToken);

                    Console.WriteLine($"{talk} published to message queue");
                });
            }
        }
    }
}