using System;
using System.Globalization;
using System.Linq;

namespace MSGraph.Exchange.MailboxSetting {
    /// <summary>
    /// mailboxSetting parameter class for convinient pipeline 
    /// input on parameters in Set-MgaMailboxSettings command
    /// </summary>
    [Serializable]
    public class MailboxSettingParameter {
        #region Properties
        /// <summary>
        /// name of the category
        /// </summary>
        public string Name;

        /// <summary>
        /// The type name of inputobject
        /// </summary>
        public string TypeName {
            get {
                return _typeName;
            }

            set { }
        }

        /// <summary>
        /// carrier object for the input object
        /// </summary>
        public object InputObject;

        private string _typeName;
        private string _returnValue;

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method 
        /// </summary>
        /// <returns></returns>
        public override string ToString() {
            if(!string.IsNullOrEmpty(Name)) {
                _returnValue = Name;
            } else {
                _returnValue = TypeName;
            }

            return _returnValue;
        }
        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// 
        /// </summary>
        public MailboxSettingParameter(MailboxSettings MailboxSetting) {
            TextInfo TextInfo = CultureInfo.CurrentCulture.TextInfo;

            this.InputObject = MailboxSetting;
            this._typeName = InputObject.GetType().ToString();
            // this.Name = TextInfo.ToTitleCase(MailboxSetting.Name.Split('/').Last());
            this.Name = "AllSettings";
        }

        /// <summary>
        /// 
        /// </summary>
        public MailboxSettingParameter(AutomaticRepliesSetting AutomaticRepliesSetting) {
            TextInfo TextInfo = CultureInfo.CurrentCulture.TextInfo;

            this.InputObject = AutomaticRepliesSetting;
            this._typeName = InputObject.GetType().ToString();
            // this.Name = TextInfo.ToTitleCase(AutomaticRepliesSetting.Name.Split('/').Last());
            this.Name = "AutomaticReplySetting";
        }

        /// <summary>
        /// 
        /// </summary>
        public MailboxSettingParameter(LocaleInfoSetting LocaleInfoSetting) {
            TextInfo TextInfo = CultureInfo.CurrentCulture.TextInfo;

            this.InputObject = LocaleInfoSetting;
            this._typeName = InputObject.GetType().ToString();
            // this.Name = TextInfo.ToTitleCase(LocaleInfoSetting.Name.Split('/').Last());
            this.Name = "LanguageSetting";
        }

        /// <summary>
        /// 
        /// </summary>
        public MailboxSettingParameter(WorkingHoursSetting WorkingHoursSetting) {
            TextInfo TextInfo = CultureInfo.CurrentCulture.TextInfo;

            this.InputObject = WorkingHoursSetting;
            this._typeName = InputObject.GetType().ToString();
            // this.Name = TextInfo.ToTitleCase(WorkingHoursSetting.Name.Split('/').Last());
            this.Name = "WorkingHoursSetting";
        }

        /// <summary>
        /// 
        /// </summary>
        public MailboxSettingParameter(TimeZoneInfo TimeZoneInfo) {
            this.InputObject = TimeZoneInfo;
            this._typeName = InputObject.GetType().ToString();
            this.Name = "TimeZoneSetting";
        }

        /// <summary>
        /// 
        /// </summary>
        public MailboxSettingParameter(Mail.Folder Folder) {
            this.InputObject = Folder;
            this._typeName = InputObject.GetType().ToString();
            this.Name = "ArchiveFolderSetting";
        }
        #endregion Constructors

    }
}
