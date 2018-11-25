using System;
using System.Linq;
using System.Management.Automation;
using System.Security;

namespace MSGraph.Exchange.Mail
{
    /// <summary>
    /// Mail message parameter class for convinient pipeline 
    /// input on parameters in *-MgaMail* commands
    /// </summary>
    public class MailMessageParameter
    {
        #region Properties
        /// <summary>
        /// message or folder id
        /// </summary>
        public string Id;

        /// <summary>
        /// name of a folder
        /// </summary>
        public string Name;

        /// <summary>
        /// indicator wether name is a WellKnownFolder
        /// </summary>
        public bool IsWellKnownName;

        /// <summary>
        /// carrier object for the input object
        /// </summary>
        public object InputObject;

        #endregion Properties


        #region Constructors
        /// <summary>
        /// Mail Message input
        /// </summary>
        public MailMessageParameter(Mail.Message Message)
        {
            InputObject = Message;
            Id = Message.Id;
        }

        /// <summary>
        /// Mail Folderinput
        /// </summary>
        public MailMessageParameter(Mail.Folder Folder)
        {
            InputObject = Folder;
            Id = Folder.Id;
        }

        /// <summary>
        /// String input
        /// </summary>
        public MailMessageParameter(string Text)
        {
            InputObject = Text;
            string[] names = Enum.GetNames(typeof(WellKnownFolder));
            if (names.Contains(Text, StringComparer.InvariantCultureIgnoreCase))
            {
                IsWellKnownName = true;
                Name = Text.ToLower();
            }
            else
            {
                Id = Text;
            }
        }
        #endregion Constructors
    }
}
