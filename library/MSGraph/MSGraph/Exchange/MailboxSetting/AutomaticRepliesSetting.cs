using System;

namespace MSGraph.Exchange.MailboxSetting {
    /// <summary>
    /// AutoReply / Out of Office settings in exchange online
    /// 
    /// Configuration settings to automatically notify the sender of an incoming email with a message from the signed-in user.
    /// For example, an automatic reply to notify that the signed-in user is unavailable to respond to emails.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/automaticrepliessetting?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class AutomaticRepliesSetting {
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
        public bool ExternalReplyMessageIsPresent {
            get {
                if(!String.IsNullOrEmpty(ExternalReplyMessage) || !String.IsNullOrWhiteSpace(ExternalReplyMessage)) {
                    return true;
                } else {
                    return false;
                }
            }
            set { }
        }

        /// <summary>
        /// 
        /// </summary>
        public String InternalReplyMessage;

        /// <summary>
        /// 
        /// </summary>
        public bool InternalReplyMessageIsPresent {
            get {
                if(!String.IsNullOrEmpty(InternalReplyMessage) || !String.IsNullOrWhiteSpace(InternalReplyMessage)) {
                    return true;
                } else {
                    return false;
                }
            }
            set { }
        }

        /// <summary>
        /// 
        /// </summary>
        public DateTimeTimeZone ScheduledEndDateTimeUTC;

        /// <summary>
        /// 
        /// </summary>
        public DateTime ScheduledEndDateTime {
            get {
                return ScheduledEndDateTimeUTC.DateTime.ToLocalTime();
            }
            set {
                ScheduledEndDateTimeUTC = new DateTimeTimeZone(value.ToUniversalTime());
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public DateTimeTimeZone ScheduledStartDateTimeUTC;

        /// <summary>
        /// 
        /// </summary>
        public DateTime ScheduledStartDateTime {
            get {
                return ScheduledStartDateTimeUTC.DateTime.ToLocalTime();
            }
            set {
                ScheduledStartDateTimeUTC = new DateTimeTimeZone(value.ToUniversalTime());
            }
        }

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
        public AutomaticRepliesSetting() {
        }

        /// <summary>
        /// Main properties
        /// </summary>
        public AutomaticRepliesSetting(AutomaticRepliesStatus Status, ExternalAudienceScope ExternalAudience, String ExternalReplyMessage, String InternalReplyMessage, DateTimeTimeZone ScheduledStartDateTimeUTC, DateTimeTimeZone ScheduledEndDateTimeUTC, String Name) {
            this.Status = Status;
            this.ExternalAudience = ExternalAudience;
            this.ExternalReplyMessage = ExternalReplyMessage;
            this.InternalReplyMessage = InternalReplyMessage;
            this.ScheduledStartDateTimeUTC = ScheduledStartDateTimeUTC;
            this.ScheduledEndDateTimeUTC = ScheduledEndDateTimeUTC;
            this.Name = Name;
        }

        /// <summary>
        /// All properties
        /// </summary>
        public AutomaticRepliesSetting(AutomaticRepliesStatus Status, ExternalAudienceScope ExternalAudience, String ExternalReplyMessage, String InternalReplyMessage, DateTimeTimeZone ScheduledStartDateTimeUTC, DateTimeTimeZone ScheduledEndDateTimeUTC, String User, object BaseObject, String Name) {
            this.Status = Status;
            this.ExternalAudience = ExternalAudience;
            this.ExternalReplyMessage = ExternalReplyMessage;
            this.InternalReplyMessage = InternalReplyMessage;
            this.ScheduledStartDateTimeUTC = ScheduledStartDateTimeUTC;
            this.ScheduledEndDateTimeUTC = ScheduledEndDateTimeUTC;
            this.User = User;
            this.BaseObject = BaseObject;
            this.Name = Name;
        }

        #endregion Constructors
    }
}
