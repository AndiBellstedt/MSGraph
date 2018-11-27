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
    public class MailMessageOrMailFolderParameter
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
        /// The type name of inputobject
        /// </summary>
        public string TypeName
        {
            get
            {
                return _typeName;
            }

            set
            {
            }
        }

        private string _typeName;

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
        public MailMessageOrMailFolderParameter(Message Message)
        {
            InputObject = Message;
            _typeName = InputObject.GetType().ToString();
            Id = Message.Id;
        }

        /// <summary>
        /// Mail Folderinput
        /// </summary>
        public MailMessageOrMailFolderParameter(Folder Folder)
        {
            InputObject = Folder;
            _typeName = InputObject.GetType().ToString();
            Id = Folder.Id;
        }

        /// <summary>
        /// String input
        /// </summary>
        public MailMessageOrMailFolderParameter(string Text)
        {
            InputObject = Text;
            string[] names = Enum.GetNames(typeof(WellKnownFolder));
            if (names.Contains(Text, StringComparer.InvariantCultureIgnoreCase))
            {
                IsWellKnownName = true;
                _typeName = InputObject.GetType().ToString();
                Name = Text.ToLower();
            }
            else
            {
                Id = Text;
                _typeName = "Unknown";
            }
        }
        #endregion Constructors
    }
}
