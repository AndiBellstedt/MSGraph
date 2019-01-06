using System;
using System.Linq;

namespace MSGraph.Exchange.Attachment {
    /// <summary>
    /// Mail message parameter class for convinient pipeline 
    /// input on parameters in *-MgaMail* commands
    /// </summary>
    [Serializable]
    public class AttachmentParameter {
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
        /// Constructor for parsing in a basic Attachment
        /// </summary>
        public AttachmentParameter(Attachment Attachment) {
            InputObject = Attachment;
            _typeName = InputObject.GetType().ToString();
            Id = Attachment.Id;
            Name = Attachment.Name;
        }

        /// <summary>
        /// Constructor for parsing in a FileAttachment
        /// </summary>
        public AttachmentParameter(FileAttachment Attachment) {
            InputObject = Attachment;
            _typeName = InputObject.GetType().ToString();
            Id = Attachment.Id;
            Name = Attachment.Name;
        }

        /// <summary>
        /// Constructor for parsing in a ItemAttachment
        /// </summary>
        public AttachmentParameter(ItemAttachment Attachment) {
            InputObject = Attachment;
            _typeName = InputObject.GetType().ToString();
            Id = Attachment.Id;
            Name = Attachment.Name;
        }

        /// <summary>
        /// Constructor for parsing in a ReferenceAttachment
        /// </summary>
        public AttachmentParameter(ReferenceAttachment Attachment) {
            InputObject = Attachment;
            _typeName = InputObject.GetType().ToString();
            Id = Attachment.Id;
            Name = Attachment.Name;
        }
        #endregion Constructors
    }
}