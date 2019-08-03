using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TechTalksModel.DTO;
using TechTalksAPI.Messaging;
using TechTalksModel;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TechTalksAPI.Controllers
{
    [Route("api/[controller]")]
    public class TechTalksController : Controller
    {
        private readonly ITechTalksEventPublisher _messageQueue;

        public TechTalksController(ITechTalksEventPublisher messageQueue)
        {
            _messageQueue = messageQueue;
        }

        // GET: api/TechTalks
        [HttpGet]
        public IEnumerable<TechTalk> GetAll()
        {
            // List<TechTalk> techTalks = _context.TechTalk
            //     .Include(t => t.Category)
            //     .Include(t => t.Level)
            //     .ToList();

            List<TechTalk> techTalks = new List<TechTalk>();

            return techTalks;

        }


        // POST api/TechTalks
        [HttpPost]
        public IActionResult Create([FromBody]TechTalkDTO techTalkDto)
        {
            if (techTalkDto == null)
            {
                return BadRequest();
            }

            Category dummyCategory = new Category
            {
                Id = techTalkDto.CategoryId,
                CategoryName = "Paid Event",
                Description = "Paid Event"
            };

            Level dummyLevel = new Level
            {
                Id = techTalkDto.LevelId,
                LevelName = techTalkDto.LevelName
            };

            TechTalk techTalk = new TechTalk
            {
                TechTalkName = techTalkDto.TechTalkName,
                CategoryId = techTalkDto.CategoryId,
                // Category = _context.Categories.FirstOrDefault(x => x.Id == techTalkDto.CategoryId),
                Category = dummyCategory,
                LevelId = techTalkDto.LevelId,
                // Level = _context.Levels.FirstOrDefault(x => x.Id == techTalkDto.LevelId)
                Level = dummyLevel
            };

            Console.WriteLine("Sending message to queue");
            _messageQueue.SendMessage(techTalk);

            return Ok();
        }

    }
}
