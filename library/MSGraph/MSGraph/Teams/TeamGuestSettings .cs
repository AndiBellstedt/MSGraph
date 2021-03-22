using System;
using System.Linq;

namespace MSGraph.Teams {
    /// <summary>
    /// Team parameter class for convinient pipeline 
    /// input on parameters in *-MgaTeam commands
    /// </summary>
    [Serializable]
    public class TeamGuestSettings {
        #region Properties
        /// <summary>
        /// If set to true, guests can add and update channels.
        /// </summary>
        public bool allowCreateUpdateChannels;

        /// <summary>
        /// If set to true, guests can delete channels.
        /// </summary>
        public bool allowDeleteChannels;

        #endregion Properties


        #region Statics & Stuff

        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public TeamGuestSettings() {
        }

        /// <summary>
        /// 
        /// </summary>
        public TeamGuestSettings(bool allowCreateUpdateChannels, bool allowDeleteChannels) {
            this.allowCreateUpdateChannels = allowCreateUpdateChannels;
            this.allowDeleteChannels = allowDeleteChannels;
        }
        #endregion Constructors
    }
}
