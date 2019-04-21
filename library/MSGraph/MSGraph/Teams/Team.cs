using System;

namespace MSGraph.Teams {
    /// <summary>
    /// Team in MS Graph API
    ///
    /// A team in Microsoft Teams is a collection of channel objects. A channel represents a topic,
    /// and therefore a logical isolation of discussion, within a team. Every team is associated 
    /// with a group. The group has the same ID as the team.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/team?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class Team {
        #region Properties
        /// <summary>
        /// data carrier object
        /// </summary>
        public object BaseObject;

        /// <summary>
        /// 
        /// </summary>
        public String Id;

        /// <summary>
        /// 
        /// </summary>
        public String InternalId;

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
        public bool IsArchived;

        /// <summary>
        /// 
        /// </summary>
        public String User;

        /// <summary>
        /// Indicator if the team is accessible by the connected user.
        /// If a team is not accessible, only basic information like the name and 
        /// the description are received from the directory.
        /// </summary>
        public bool Accessible {
            get {
                if (!string.IsNullOrEmpty(InternalId)) {
                    _accessible = true;
                } else {
                    _accessible = false;
                }
                return _accessible;
            }
            set {
            }
        }

        /// <summary>
        /// Indicates, that the info in the class is queried by joinedTeams API call
        /// </summary>
        public bool InfoFromJoinedTeam;

        /// <summary>
        /// 
        /// </summary>
        public Uri WebUrl;

        /// <summary>
        /// 
        /// </summary>
        public TeamMemberSettings memberSettings;

        /// <summary>
        /// 
        /// </summary>
        public TeamGuestSettings guestSettings;

        /// <summary>
        /// 
        /// </summary>
        public TeamMessagingSettings messagingSettings;

        /// <summary>
        /// 
        /// </summary>
        public TeamFunSettings funSettings;

        private string _returnValue;
        private bool _accessible;

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
        public Team() {
        }

        /// <summary>
        /// minimal information
        /// </summary>
        public Team(String Id, String DisplayName, String Description, String User, bool IsArchived, bool InfoFromJoinedTeam) {
            this.Id = Id;
            this.DisplayName = DisplayName;
            this.Description = Description;
            this.User = User;
            this.IsArchived = IsArchived;
            this.InfoFromJoinedTeam = InfoFromJoinedTeam;
        }

        /// <summary>
        /// full information
        /// </summary>
        public Team(String Id, string InternalId, String DisplayName, String Description, String User, bool IsArchived, bool InfoFromJoinedTeam, Uri WebUrl, object BaseObject) {
            this.Id = Id;
            this.InternalId = InternalId;
            this.DisplayName = DisplayName;
            this.Description = Description;
            this.User = User;
            this.IsArchived = IsArchived;
            this.InfoFromJoinedTeam = InfoFromJoinedTeam;
            this.WebUrl = WebUrl;
            this.BaseObject = BaseObject;
        }

        #endregion Constructors
    }
}
