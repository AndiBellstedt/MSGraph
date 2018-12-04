using System;
using System.Linq;

namespace MSGraph.Exchange.Mail
{
    /// <summary>
    /// Mail message parameter class for convinient pipeline 
    /// input on parameters in *-MgaMail* commands
    /// </summary>
    [Serializable]
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
        /// The type name of inputobject
        /// </summary>
        public string TypeName
        {
            get
            {
                return _typeName;
            }

            set { }
        }

        private string _typeName;

        /// <summary>
        /// carrier object for the input object
        /// </summary>
        public object InputObject;

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method 
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            if (Name.Length > 0)
            {
                return Name;
            }
            else
            {
                return Id;
            }

        }
        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// Mail Folderinput
        /// </summary>
        public MailMessageParameter(Message Message)
        {
            InputObject = Message;
            _typeName = InputObject.GetType().ToString();
            Id = Message.Id;
            Name = Message.Subject;
        }

        /// <summary>
        /// String input
        /// </summary>
        public MailMessageParameter(string Text)
        {
            InputObject = Text;
            string[] names = Enum.GetNames(typeof(WellKnownFolder));
            _typeName = InputObject.GetType().ToString();

            if (names.Contains(Text, StringComparer.InvariantCultureIgnoreCase))
            {
                Name = Text.ToLower();
                Id = Name;
            }
            else if (Text.Length == 152 && Text.EndsWith("="))
            {
                Id = Text;
            }
            else
            {
                Name = Text;
            }
        }
        #endregion Constructors
    }
}