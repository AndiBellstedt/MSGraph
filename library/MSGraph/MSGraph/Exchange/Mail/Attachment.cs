using System;

namespace MSGraph.Exchange.Mail
{
    /// <summary>
    /// Mail attachments in exchange online
    /// fileAttachment resource type
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/fileattachment?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class Attachment
    {
        #region Properties
        /// <summary>
        /// raw data carrier object
        /// </summary>
        public object BaseObject;

        /// <summary>
        /// 
        /// </summary>
        public String Id;

        /// <summary>
        /// 
        /// </summary>
        public String Name;

        /// <summary>
        /// 
        /// </summary>
        public String ContentType;

        /// <summary>
        /// 
        /// </summary>
        public String ContentId;

        /// <summary>
        /// 
        /// </summary>
        public String ContentLocation;

        /// <summary>
        /// 
        /// </summary>
        public bool IsInline;

        /// <summary>
        /// 
        /// </summary>
        public object LastModifiedDateTime;

        /// <summary>
        /// 
        /// </summary>
        public Int32 Size;

        /// <summary>
        /// 
        /// </summary>
        public double SizeKB
        {
            get
            {
                double kb = (double)(Math.Round( ConvertBytesToKiloBytes(Size), 2));
                return kb;
            }

            set { }
        }

        /// <summary>
        /// 
        /// </summary>
        public double SizeMB
        {
            get
            {
                double mb = (double)(Math.Round(ConvertBytesToMegaBytes(Size), 2));
                return mb;
            }

            set { }
        }
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
        #endregion Statics & Stuff
    }
}
