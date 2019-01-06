using System;

namespace MSGraph.Exchange.Attachment {
    /// <summary>
    /// Attachments in exchange online
    /// referenceAttachment resource type
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/referenceattachment?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class ReferenceAttachment : Attachment {
        #region Properties
        /// <summary>
        /// SourceUrl
        /// </summary>
        public Uri SourceUrl;

        /// <summary>
        /// ProviderType
        /// </summary>
        public ReferenceAttachmentProvider ProviderType;

        /// <summary>
        /// ThumbnailUrl
        /// </summary>
        public Uri ThumbnailUrl;

        /// <summary>
        /// PreviewUrl
        /// </summary>
        public Uri PreviewUrl;

        /// <summary>
        /// Permission
        /// </summary>
        public referenceAttachmentPermission Permission;

        /// <summary>
        /// IsFolder
        /// </summary>
        public bool IsFolder;

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
