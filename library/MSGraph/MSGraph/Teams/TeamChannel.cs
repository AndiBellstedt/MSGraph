using System;
using System.Net.Mail;

namespace MSGraph.Teams {
    /// <summary>
    /// TeamChannel in MS Graph API
    ///
    /// Teams are made up of channels, which are the conversations you have with your teammates. 
    /// Each channel is dedicated to a specific topic, department, or project. Channels are where 
    /// the work actually gets done - where text, audio, and video conversations open to the 
    /// whole team happen, where files are shared, and where tabs are added.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/channel?view=graph-rest-beta
    /// </summary>
    [Serializable]
    public class TeamChannel {
        #region Properties
        /// <summary>
        /// The channels's unique identifier. Read-only.
        /// </summary>
        public String Id;

        /// <summary>
        /// Channel name as it will appear to the user in Microsoft Teams.
        /// </summary>
        public String DisplayName;

        /// <summary>
        /// Alias property on Displayname
        /// </summary>
        public String Name {
            get {
                return DisplayName;
            }
            set {
                this.DisplayName = value;
            }
        }

        /// <summary>
        /// Optional textual description for the channel.
        /// </summary>
        public String Description;

        /// <summary>
        /// Whether the channel should automatically be marked 'favorite' for all members of the team.
        /// Default: false.
        /// </summary>
        public bool isFavoriteByDefault;

        /// <summary>
        /// A hyperlink that will navigate to the channel in Microsoft Teams.
        /// This is the URL that you get when you right-click a channel in Microsoft Teams
        /// and select Get link to channel. This URL should be treated as an opaque blob,
        /// and not parsed. Read-only.
        /// </summary>
        public Uri WebUrl;

        /// <summary>
        /// The email address for sending messages to the channel. Read-only.
        /// </summary>
        public MailAddress Email;

        /// <summary>
        /// 
        /// </summary>
        public String User;

        /// <summary>
        /// data carrier object
        /// </summary>
        public object BaseObject;

        private string _returnValue;

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method
        /// </summary>
        /// <returns></returns>
        public override string ToString() {
            if (!string.IsNullOrEmpty(DisplayName)) {
                _returnValue = DisplayName;
            } else if (!string.IsNullOrEmpty(Id)) {
                _returnValue = Id;
            } else {
                _returnValue = this.GetType().Name;
            }

            return _returnValue;
        }

        #endregion Statics & Stuff

        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public TeamChannel() {
        }

        /// <summary>
        /// full object
        /// </summary>
        public TeamChannel(String Id, String DisplayName, String Description, bool isFavoriteByDefault, Uri WebUrl, MailAddress Email, String User, object BaseObject) {
            this.Id = Id;
            this.DisplayName = DisplayName;
            this.Description = Description;
            this.isFavoriteByDefault = isFavoriteByDefault;
            this.WebUrl = WebUrl;
            this.Email = Email;
            this.User = User;
            this.BaseObject = BaseObject;
        }

        #endregion Constructors
    }
}
