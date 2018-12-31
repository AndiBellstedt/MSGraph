using System;
using System.Linq;

namespace MSGraph.Exchange.Mail {
    /// <summary>
    /// Mail message parameter class for convinient pipeline 
    /// input on parameters in *-MgaMail* commands
    /// </summary>
    [Serializable]
    public class MessageOrFolderParameter {
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
        public string TypeName {
            get {
                return _typeName;
            }

            set {
            }
        }

        private string _typeName;

        private string _returnValue;

        /// <summary>
        /// indicator wether name is a WellKnownFolder
        /// </summary>
        public bool IsWellKnownName;

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
        public override string ToString() {
            if(!string.IsNullOrEmpty(Name)) {
                _returnValue = Name;
            } else if(!string.IsNullOrEmpty(Id)) {
                _returnValue = Id;
            } else {
                _returnValue = InputObject.ToString();
            }

            return _returnValue;
        }
        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// Mail Message input
        /// </summary>
        public MessageOrFolderParameter(Message Message) {
            InputObject = Message;
            _typeName = InputObject.GetType().ToString();
            Id = Message.Id;
            Name = Message.Subject;
        }

        /// <summary>
        /// Mail Folderinput
        /// </summary>
        public MessageOrFolderParameter(Folder Folder) {
            InputObject = Folder;
            _typeName = InputObject.GetType().ToString();
            Id = Folder.Id;
            Name = Folder.Name;
        }

        /// <summary>
        /// String input
        /// </summary>
        public MessageOrFolderParameter(string Text) {
            InputObject = Text;
            _typeName = InputObject.GetType().ToString();

            string[] names = Enum.GetNames(typeof(WellKnownFolder));
            if(names.Contains(Text, StringComparer.InvariantCultureIgnoreCase)) {
                IsWellKnownName = true;
                Name = Text.ToLower();
            } else if(Text.Length == 120 || Text.Length == 104 || Text.Length == 152 || Text.Length == 136) {
                IsWellKnownName = false;
                Id = Text;
            } else {
                IsWellKnownName = false;
                Name = Text;
            }
        }
        #endregion Constructors
    }
}