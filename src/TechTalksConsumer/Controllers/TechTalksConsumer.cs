using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using TechTalksModel;
using Dapr;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TechTalksAPI.Controllers
{
    [Route("api/[controller]")]
    public class TechTalksConsumerController : Controller
    {
        public TechTalksConsumerController()
        {

        }

        // POST: api/TechTalksConsumer
        [HttpPost("process")]
        [Topic("rabbitmq-pubsub", "techtalks")]
        public void Process([FromBody] TechTalk techTalk)
        {
            Console.WriteLine("Received message: " + techTalk.TechTalkName);
        }

    }
}
