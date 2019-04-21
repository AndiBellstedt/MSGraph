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
        /// 
        /// </summary>
        public String Id;

        /// <summary>
        /// 
        /// </summary>
        public String DisplayName;

        /// <summary>
        /// 
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
        /// 
        /// </summary>
        public String Description;

        /// <summary>
        /// 
        /// </summary>
        public bool isFavoriteByDefault;

        /// <summary>
        /// 
        /// </summary>
        public Uri WebUrl;

        /// <summary>
        /// 
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
