using System;

namespace MSGraph.Exchange.Mail {
    /// <summary>
    /// Mail message parameter class for convinient pipeline 
    /// input on parameters in *-MgaMail* commands
    /// </summary>
    [Serializable]
    public class MessageParameter {
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

            set { }
        }

        private string _typeName;
        private string _returnValue;

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
        /// Mail message input
        /// </summary>
        public MessageParameter(Message Message) {
            InputObject = Message;
            _typeName = InputObject.GetType().ToString();
            Id = Message.Id;
            Name = Message.Subject;
        }

        /// <summary>
        /// String input
        /// </summary>
        public MessageParameter(string Text) {
            InputObject = Text;
            _typeName = InputObject.GetType().ToString();

            if(Text.Length == 152 || Text.Length == 136) {
                Id = Text;
            } else {
                Name = Text;
            }
        }
        #endregion Constructors
    }
}