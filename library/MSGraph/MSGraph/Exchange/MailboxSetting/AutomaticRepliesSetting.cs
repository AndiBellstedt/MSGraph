using System;
using System.Collections;
using System.Collections.Generic;

namespace MSGraph.Exchange.MailboxSetting
{
    /// <summary>
    /// AutoReply / Out of Office settings in exchange online
    /// 
    /// Configuration settings to automatically notify the sender of an incoming email with a message from the signed-in user.
    /// For example, an automatic reply to notify that the signed-in user is unavailable to respond to emails.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/automaticrepliessetting?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class AutomaticRepliesSetting
    {
        #region Properties
        /// <summary>
        /// 
        /// </summary>
        public AutomaticRepliesStatus Status;

        /// <summary>
        /// 
        /// </summary>
        public ExternalAudienceScope ExternalAudience;

        /// <summary>
        /// 
        /// </summary>
        public String ExternalReplyMessage;

        /// <summary>
        /// 
        /// </summary>
        public String InternalReplyMessage;

        /// <summary>
        /// 
        /// </summary>
        public DateTimeTimeZone ScheduledEndDateTime;

        /// <summary>
        /// 
        /// </summary>
        public DateTimeTimeZone ScheduledStartDateTime;

        /// <summary>
        /// 
        /// </summary>
        public String User;

        /// <summary>
        /// 
        /// </summary>
        public object BaseObject;

        /// <summary>
        /// 
        /// </summary>
        public String Name;

        #endregion Properties


        #region Statics & Stuff

        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public AutomaticRepliesSetting()
        {
        }

        /// <summary>
        /// Main properties
        /// </summary>
        public AutomaticRepliesSetting(AutomaticRepliesStatus Status, ExternalAudienceScope ExternalAudience, String ExternalReplyMessage, String InternalReplyMessage, DateTimeTimeZone ScheduledStartDateTime, DateTimeTimeZone ScheduledEndDateTime, String Name)
        {
            this.Status = Status;
            this.ExternalAudience = ExternalAudience;
            this.ExternalReplyMessage = ExternalReplyMessage;
            this.InternalReplyMessage = InternalReplyMessage;
            this.ScheduledStartDateTime = ScheduledStartDateTime;
            this.ScheduledEndDateTime = ScheduledEndDateTime;
            this.Name = Name;
        }

        /// <summary>
        /// All properties
        /// </summary>
        public AutomaticRepliesSetting(AutomaticRepliesStatus Status, ExternalAudienceScope ExternalAudience, String ExternalReplyMessage, String InternalReplyMessage, DateTimeTimeZone ScheduledStartDateTime, DateTimeTimeZone ScheduledEndDateTime, String User, object BaseObject, String Name)
        {
            this.Status = Status;
            this.ExternalAudience = ExternalAudience;
            this.ExternalReplyMessage = ExternalReplyMessage;
            this.InternalReplyMessage = InternalReplyMessage;
            this.ScheduledStartDateTime = ScheduledStartDateTime;
            this.ScheduledEndDateTime = ScheduledEndDateTime;
            this.User = User;
            this.BaseObject = BaseObject;
            this.Name = Name;
        }

        #endregion Constructors
    }
}
