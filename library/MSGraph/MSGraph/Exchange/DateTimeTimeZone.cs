using System;

namespace MSGraph.Exchange
{
    /// <summary>
    /// Describes the date, time, and time zone of a point in time.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/datetimetimezone?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class DateTimeTimeZone
    {
        #region Properties
        /// <summary>
        /// A single point of time in a combined date and time representation (date)T(time).
        /// </summary>
        public DateTime DateTime;

        /// <summary>
        /// The date and time that the follow-up is to be finished.
        /// 
        /// type format: microsoft.graph.dateTimeTimeZone
        /// </summary>
        public String TimeZone;

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method 
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return string.Format("{0:yyyy-MM-dd HH:mm:ss}", DateTime) + "(" + TimeZone + ")";
        }

        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// 
        /// </summary>
        public DateTimeTimeZone()
        {
        }

        /// <summary>
        /// input DateTimeTimeZone
        /// </summary>
        public DateTimeTimeZone(DateTimeTimeZone DateTimeTimeZone)
        {
            this.DateTime = DateTimeTimeZone.DateTime;
            this.TimeZone = DateTimeTimeZone.TimeZone;
        }

        /// <summary>
        /// input only DateTime, sets UTC as default to TimeZone
        /// </summary>
        public DateTimeTimeZone(DateTime DateTime)
        {
            this.DateTime = DateTime;
            this.TimeZone = "UTC";
        }

        /// <summary>
        /// input DateTime and TimeZone
        /// </summary>
        public DateTimeTimeZone(DateTime DateTime, String TimeZone)
        {
            this.DateTime = DateTime;
            this.TimeZone = TimeZone;
        }
        #endregion Constructors
    }
}
