using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MSGraph.Teams {
    /// <summary>
    /// 
    /// </summary>
    [Serializable]
    public class TeamFunSettings {
        #region Properties
        /// <summary>
        /// If set to true, enables Giphy use.
        /// </summary>
        public bool allowGiphy;

        /// <summary>
        /// Giphy content rating. Possible values are: moderate, strict.
        /// </summary>
        public string giphyContentRating;

        /// <summary>
        /// If set to true, enables users to include stickers and memes.
        /// </summary>
        public bool allowStickersAndMemes;

        /// <summary>
        /// If set to true, enables users to include custom memes.
        /// </summary>
        public bool allowCustomMemes;

        #endregion Properties


        #region Statics & Stuff

        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public TeamFunSettings() {
        }

        /// <summary>
        /// 
        /// </summary>
        public TeamFunSettings(bool allowGiphy, string giphyContentRating, bool allowStickersAndMemes, bool allowCustomMemes) {
            this.allowGiphy = allowGiphy;
            this.giphyContentRating = giphyContentRating;
            this.allowStickersAndMemes = allowStickersAndMemes;
            this.allowCustomMemes = allowCustomMemes;
        }
        #endregion Constructors
    }
}
