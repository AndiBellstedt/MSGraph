using System;
using System.Linq;

namespace MSGraph.Teams {
    /// <summary>
    /// Team parameter class for convinient pipeline 
    /// input on parameters in *-MgaTeam commands
    /// </summary>
    [Serializable]
    public class TeamMemberSettings {
        #region Properties
        /// <summary>
        /// If set to true, members can add and update channels.
        /// </summary>
        public bool allowCreateUpdateChannels;

        /// <summary>
        /// If set to true, members can delete channels.
        /// </summary>
        public bool allowDeleteChannels;

        /// <summary>
        /// If set to true, members can add and remove apps.
        /// </summary>
        public bool allowAddRemoveApps;

        /// <summary>
        /// If set to true, members can add, update, and remove tabs.
        /// </summary>
        public bool allowCreateUpdateRemoveTabs;

        /// <summary>
        /// If set to true, members can add, update, and remove connectors.
        /// </summary>
        public bool allowCreateUpdateRemoveConnectors;
        #endregion Properties


        #region Statics & Stuff

        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public TeamMemberSettings() {
        }

        /// <summary>
        /// 
        /// </summary>
        public TeamMemberSettings(bool allowCreateUpdateChannels, bool allowDeleteChannels, bool allowAddRemoveApps, bool allowCreateUpdateRemoveTabs, bool allowCreateUpdateRemoveConnectors) {
            this.allowCreateUpdateChannels = allowCreateUpdateChannels;
            this.allowDeleteChannels = allowDeleteChannels;
            this.allowAddRemoveApps = allowAddRemoveApps;
            this.allowCreateUpdateRemoveTabs = allowCreateUpdateRemoveTabs;
            this.allowCreateUpdateRemoveConnectors = allowCreateUpdateRemoveConnectors;
        }
        #endregion Constructors
    }
}
