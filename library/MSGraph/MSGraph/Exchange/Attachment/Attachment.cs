using System;

namespace MSGraph.Exchange.Attachment {
    /// <summary>
    /// Attachment in exchange online
    /// 
    /// Attachment is the base resource for the following derived types of attachments:
    /// A file(fileAttachment resource)
    /// An item(contact, event or message, represented by an itemAttachment resource)
    /// A link to a file(referenceAttachment resource)
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/attachment?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class Attachment {
        #region Properties

        /// <summary>
        /// 
        /// </summary>
        public String Id;

        /// <summary>
        /// 
        /// </summary>
        public String Name;

        /// <summary>
        /// Alias property from name.
        /// </summary>
        public string DisplayName {
            get {
                return Name;
            }

            set { }
        }

        /// <summary>
        /// 
        /// </summary>
        public AttachmentTypes AttachmentType;

        /// <summary>
        /// 
        /// </summary>
        public String ContentType;

        /// <summary>
        /// 
        /// </summary>
        public bool IsInline;

        /// <summary>
        /// 
        /// </summary>
        public object LastModifiedDateTime;

        /// <summary>
        /// </summary>
        /// 
        public Int32 Size;

        /// <summary>
        /// 
        /// </summary>
        public double SizeKB {
            get {
                double kb = (double)(Math.Round(ConvertBytesToKiloBytes(Size), 2));
                return kb;
            }

            set { }
        }

        /// <summary>
        /// 
        /// </summary>
        public double SizeMB {
            get {
                double mb = (double)(Math.Round(ConvertBytesToMegaBytes(Size), 2));
                return mb;
            }

            set { }
        }

        /// <summary>
        /// The user name which owns the folder
        /// </summary>
        public String User;

        /// <summary>
        /// carrier object for the original api result
        /// </summary>
        public object BaseObject;

        /// <summary>
        /// The parent object, where the attachmentcame from
        /// </summary>
        public object ParentObject;

        private string _returnValue;

        #endregion Properties


        #region Statics & Stuff
        static double ConvertBytesToMegaBytes(long bytes) {
            return (bytes / 1024f) / 1024f;
        }

        static double ConvertBytesToKiloBytes(long kilobytes) {
            return kilobytes / 1024f;
        }

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
                _returnValue = this.GetType().Name;
            }

            return _returnValue;
        }
        #endregion Statics & Stuff
    }
}
