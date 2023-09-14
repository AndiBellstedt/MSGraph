using System;

namespace MSGraph.Exchange.MailboxSetting {
    /// <summary>
    /// Mailbox settings in exchange online
    /// 
    /// This includes settings for automatic replies (notify people automatically upon receipt of their email), locale (language and country/region), and time zone, and working hours.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/user-get-mailboxsettings?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class MailboxSettings {
        #region Properties
        /// <summary>
        /// 
        /// </summary>
        public String Name;

        /// <summary>
        /// 
        /// </summary>
        public Mail.Folder ArchiveFolder;

        /// <summary>
        /// 
        /// </summary>
        public TimeZoneInfo TimeZone;
        /// <summary>
        /// 
        /// </summary>
        public AutomaticRepliesSetting AutomaticRepliesSetting;

        /// <summary>
        /// 
        /// </summary>
        public LocaleInfoSetting Language;

        /// <summary>
        /// 
        /// </summary>
        public object WorkingHours;

        /// <summary>
        /// 
        /// </summary>
        public String User;

        /// <summary>
        /// carrier object for the original api result
        /// </summary>
        public object BaseObject;

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method 
        /// </summary>
        /// <returns></returns>
        public override string ToString() {
            return Name;
        }

        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public MailboxSettings() {
        }

        #endregion Constructors
    }
}
