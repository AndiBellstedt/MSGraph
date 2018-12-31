using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MSGraph.Exchange
{
    /// <summary>
    /// The basic representation of a time zone.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/timezonebase?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class TimeZoneBase
    {
        #region Properties
        /// <summary>
        /// The name of a time zone. It can be a standard time zone name such as "Hawaii-Aleutian Standard Time", or "Customized Time Zone" for a custom time zone.
        /// </summary>
        public TimeZoneInfo DisplayName;

        /// <summary>
        /// 
        /// </summary>
        public String Name
        {
            get
            {
                return DisplayName.Id;
            }
            set
            {
                DisplayName = TimeZoneInfo.FindSystemTimeZoneById(value);
            }
        }

        #endregion Properties

        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method 
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return Name;
        }

        #endregion Statics & Stuff

        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public TimeZoneBase()
        {
        }

        /// <summary>
        /// input TimeZoneBase
        /// </summary>
        public TimeZoneBase(TimeZoneBase TimeZoneBase)
        {
            this.DisplayName = TimeZoneBase.DisplayName;
        }

        /// <summary>
        /// 
        /// </summary>
        public TimeZoneBase(TimeZoneInfo TimeZoneInfo)
        {
            this.DisplayName = TimeZoneInfo;
        }

        /// <summary>
        /// 
        /// </summary>
        public TimeZoneBase(String Id)
        {
            this.DisplayName = TimeZoneInfo.FindSystemTimeZoneById(Id);
        }
        #endregion Constructors

    }
}
