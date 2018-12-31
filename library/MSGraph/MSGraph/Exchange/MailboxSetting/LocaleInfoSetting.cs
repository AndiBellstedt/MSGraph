using System;
using System.Collections;
using System.Collections.Generic;

namespace MSGraph.Exchange.MailboxSetting
{
    /// <summary>
    /// Language settings in exchange online
    /// 
    /// Information about the locale, including the preferred language and country/region, of the signed-in user.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/localeinfo?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class LocaleInfoSetting
    {
        #region Properties
        /// <summary>
        /// 
        /// </summary>
        public System.Globalization.CultureInfo Locale
        {
            get
            {
                return _locale;
            }
            set
            {
                _locale = value;
                if(!String.Equals(_locale.DisplayName, DisplayName))
                {
                    DisplayName = _locale.DisplayName;
                }
            }
        }

        private System.Globalization.CultureInfo _locale;

        /// <summary>
        /// 
        /// </summary>
        public String DisplayName;

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
        public override string ToString()
        {
            return DisplayName;
        }

        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public LocaleInfoSetting()
        {
        }

        /// <summary>
        /// All properties
        /// </summary>
        public LocaleInfoSetting(System.Globalization.CultureInfo Locale)
        {
            this.Locale = Locale;
        }

        /// <summary>
        /// Main properties
        /// </summary>
        public LocaleInfoSetting(System.Globalization.CultureInfo Locale, String DisplayName, String Name)
        {
            this.Locale = Locale;
            this.DisplayName = DisplayName;
            this.Name = Name;
        }

        /// <summary>
        /// All properties
        /// </summary>
        public LocaleInfoSetting(System.Globalization.CultureInfo Locale, String DisplayName, String User, object BaseObject, String Name)
        {
            this.Locale = Locale;
            this.DisplayName = DisplayName;
            this.User = User;
            this.BaseObject = BaseObject;
            this.Name = Name;
        }

        #endregion Constructors
    }
}
