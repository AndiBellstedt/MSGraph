using System;
using System.Management.Automation;
using System.Security;

namespace MSGraph.Exchange.Mail
{
    /// <summary>
    /// Mail folder in exchange online
    /// </summary>
    public class Folder
    {
        /// <summary>
        /// The mailFolder's unique identifier.
        /// </summary>
        public String Id;

        /// <summary>
        /// The mailFolder's display name.
        /// </summary>
        public String DisplayName;

        /// <summary>
        /// Alias property from display name.
        /// </summary>
        public string Name
        {
            get {
                return DisplayName;
            }

            set { }
        }

        /// <summary>
        /// The unique identifier for the mailFolder's parent mailFolder.
        /// </summary>
        public String ParentFolderId;

        /// <summary>
        /// The number of immediate child mailFolders in the current mailFolder.
        /// </summary>
        public Int32 ChildFolderCount;

        /// <summary>
        /// The number of items in the mailFolder marked as unread.
        /// </summary>
        public Int32 UnreadItemCount;

        /// <summary>
        /// The number of items in the mailFolder.
        /// </summary>
        public Int32 TotalItemCount;

        /// <summary>
        /// Percentage of unread items in mailFolder.
        /// </summary>
        public Double UnreadInPercent
        {
            get
            {
                if(TotalItemCount > 0)
                {
                    Double percentage = Math.Round(Double.Parse(UnreadItemCount.ToString()) / Double.Parse(TotalItemCount.ToString()) * 100, 2);
                    return percentage;
                }
                else
                {
                    return Double.Parse("0");
                }
            }

            set { }
        }

        /// <summary>
        /// The user name which owns the folder
        /// </summary>
        public String User;
    }
}
