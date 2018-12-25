using System;

namespace MSGraph.Exchange.Attachment
{
    /// <summary>
    /// Attachments in exchange online
    /// referenceAttachment resource type
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/referenceattachment?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class ReferenceAttachment : Attachment
    {
        #region Properties
        /// <summary>
        /// 
        /// </summary>
        public string SourceUrl;

        /// <summary>
        /// 
        /// </summary>
        public string ProviderType;

        /// <summary>
        /// 
        /// </summary>
        public string ThumbnailUrl;

        /// <summary>
        /// 
        /// </summary>
        public string PreviewUrl;

        /// <summary>
        /// 
        /// </summary>
        public string Permission;

        /// <summary>
        /// 
        /// </summary>
        public string IsFolder;

        private string _returnValue;

        #endregion Properties


        #region Statics & Stuff
        static double ConvertBytesToMegaBytes(long bytes)
        {
            return (bytes / 1024f) / 1024f;
        }

        static double ConvertBytesToKiloBytes(long kilobytes)
        {
            return kilobytes / 1024f;
        }

        /// <summary>
        /// Overrides the default ToString() method
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            if (!string.IsNullOrEmpty(Name))
            {
                _returnValue = Name;
            }
            else if (!string.IsNullOrEmpty(Id))
            {
                _returnValue = Id;
            }
            else
            {
                _returnValue = this.GetType().Name;
            }

            return _returnValue;
        }
        #endregion Statics & Stuff
    }
}
