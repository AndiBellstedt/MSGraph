using System;

namespace MSGraph.Exchange
{
    /// <summary>
    /// followupFlag resource type
    /// Allows setting a flag in an item for the user to follow up on later.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/followupflag?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class FollowupFlag
    {
        #region Properties
        /// <summary>
        /// The date and time that the follow-up was finished.
        /// 
        /// type format: microsoft.graph.dateTimeTimeZone
        /// </summary>
        public object CompletedDateTime;

        /// <summary>
        /// The date and time that the follow-up is to be finished.
        /// 
        /// type format: microsoft.graph.dateTimeTimeZone
        /// </summary>
        public object DueDateTime;

        /// <summary>
        /// The status for follow-up for an item. 
        /// Possible values are notFlagged, complete, and flagged.
        /// </summary>
        public String FlagStatus;

        /// <summary>
        /// The date and time that the follow-up is to begin.
        /// 
        /// type format: microsoft.graph.dateTimeTimeZone
        /// </summary>
        public object StartDateTime;

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method 
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return FlagStatus;
        }

        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// MessageBody input
        /// </summary>
        /// <param name="Flag"></param>
        public FollowupFlag(FollowupFlag Flag)
        {
            CompletedDateTime = Flag.CompletedDateTime;
            DueDateTime = Flag.CompletedDateTime;
            FlagStatus = Flag.FlagStatus;
            StartDateTime = Flag.StartDateTime;
        }

        /// <summary>
        /// String input parser
        /// </summary>
        /// <param name="StatusText"></param>
        public FollowupFlag(String StatusText)
        {
            string[] possibleValues = { "notflagged", "complete", "flagged" };
            
            if (Array.IndexOf(possibleValues, StatusText.ToLower()) >= 0)
            {
                FlagStatus = StatusText;
            }
            else
            {
                throw new InvalidCastException("FlagStatus '" + StatusText + "' is invalid. This is not a possible status. Must be one of: notFlagged, complete, flagged");
            }
        }

        /// <summary>
        /// empty object
        /// </summary>
        public FollowupFlag()
        {
        }
        #endregion Constructors
    }
}
