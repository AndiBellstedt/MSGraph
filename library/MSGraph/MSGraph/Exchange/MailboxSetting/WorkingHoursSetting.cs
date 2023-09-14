using System;

namespace MSGraph.Exchange.MailboxSetting {
    /// <summary>
    /// WorkingHour settings in exchange online
    /// 
    /// Represents the days of the week and hours in a specific time zone that the user works.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/workinghours?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class WorkingHoursSetting {
        #region Properties
        /// <summary>
        /// 
        /// </summary>
        public DayOfWeek[] DaysOfWeek;

        /// <summary>
        /// 
        /// </summary>
        public DateTime StartTime;

        /// <summary>
        /// 
        /// </summary>
        public DateTime StartTimeUTC {
            get {
                return StartTime.ToUniversalTime();
            }
            set {
                StartTime = value.ToLocalTime();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public DateTime EndTime;

        /// <summary>
        /// 
        /// </summary>
        public DateTime EndTimeUTC {
            get {
                return EndTime.ToUniversalTime();
            }
            set {
                EndTime = value.ToLocalTime();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public TimeZoneBase TimeZone;

        /// <summary>
        /// 
        /// </summary>
        public String User;

        /// <summary>
        /// 
        /// </summary>
        public object BaseObject;

        /// <summary>
        /// 
        /// </summary>
        public String Name;

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method 
        /// </summary>
        /// <returns></returns>
        public override string ToString() {
            return string.Join(", ", DaysOfWeek) + " (" + StartTime.ToLongTimeString() + "-" + EndTime.ToLongTimeString() + ")";
        }


        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public WorkingHoursSetting() {
        }

        /// <summary>
        /// object it self
        /// </summary>
        public WorkingHoursSetting(WorkingHoursSetting WorkingHoursSetting) {
            this.DaysOfWeek = WorkingHoursSetting.DaysOfWeek;
            this.StartTime = WorkingHoursSetting.StartTime;
            this.EndTime = WorkingHoursSetting.EndTime;
            this.TimeZone = WorkingHoursSetting.TimeZone;
            this.User = WorkingHoursSetting.User;
        }

        /// <summary>
        /// Main properties
        /// </summary>
        public WorkingHoursSetting(DayOfWeek[] DaysOfWeek, DateTime StartTime, DateTime EndTime, TimeZoneBase TimeZone, String Name) {
            this.DaysOfWeek = DaysOfWeek;
            this.StartTime = StartTime;
            this.EndTime = EndTime;
            this.TimeZone = TimeZone;
            this.Name = Name;
        }

        /// <summary>
        /// All properties
        /// </summary>
        public WorkingHoursSetting(DayOfWeek[] DaysOfWeek, DateTime StartTime, DateTime EndTime, TimeZoneBase TimeZone, String User, object BaseObject, String Name) {
            this.DaysOfWeek = DaysOfWeek;
            this.StartTime = StartTime;
            this.EndTime = EndTime;
            this.TimeZone = TimeZone;
            this.User = User;
            this.BaseObject = BaseObject;
            this.Name = Name;
        }

        #endregion Constructors
    }
}
