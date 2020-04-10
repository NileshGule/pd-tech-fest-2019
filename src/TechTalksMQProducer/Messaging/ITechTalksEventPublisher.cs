using TechTalksModel;
using TechTalksModel.DTO;
using System.Collections.Generic;

namespace TechTalksAPI.Messaging
{
    public interface ITechTalksEventPublisher
    {
        void SendMessages(List<TechTalk> talks);
    }
}