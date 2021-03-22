using System;
using System.Linq;

namespace MSGraph.Teams {
    /// <summary>
    /// Team parameter class for convinient pipeline 
    /// input on parameters in *-MgaTeam commands
    /// </summary>
    [Serializable]
    public class TeamMessagingSettings {
        #region Properties
        /// <summary>
        /// If set to true, users can edit their messages.
        /// </summary>
        public bool allowUserEditMessages;

        /// <summary>
        /// If set to true, users can delete their messages.
        /// </summary>
        public bool allowUserDeleteMessages;

        /// <summary>
        /// If set to true, owners can delete any message.
        /// </summary>
        public bool allowOwnerDeleteMessages;

        /// <summary>
        /// If set to true, @team mentions are allowed.
        /// </summary>
        public bool allowTeamMentions;

        /// <summary>
        /// If set to true, @channel mentions are allowed.
        /// </summary>
        public bool allowChannelMentions;

        #endregion Properties


        #region Statics & Stuff

        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public TeamMessagingSettings() {
        }

        /// <summary>
        /// String input
        /// </summary>
        public TeamMessagingSettings(bool allowUserEditMessages, bool allowUserDeleteMessages, bool allowOwnerDeleteMessages, bool allowTeamMentions, bool allowChannelMentions) {
            this.allowUserEditMessages = allowUserEditMessages;
            this.allowUserDeleteMessages = allowUserDeleteMessages;
            this.allowOwnerDeleteMessages = allowOwnerDeleteMessages;
            this.allowTeamMentions = allowTeamMentions;
            this.allowChannelMentions = allowChannelMentions;
        }

        #endregion Constructors
    }
}
