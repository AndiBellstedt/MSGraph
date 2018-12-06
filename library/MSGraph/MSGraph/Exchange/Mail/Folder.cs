using System;

namespace MSGraph.Exchange.Mail
{
    /// <summary>
    /// Mail folder in exchange online
    /// </summary>
    [Serializable]
    public class Folder
    {
        #region Properties
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
            get
            {
                return DisplayName;
            }

            set { }
        }

        /// <summary>
        /// The realive level of the queried folder.
        /// Indicates wether it is a directly queried folder ( =1 ),
        /// or a childfolder from a queried folder ( =2 ),
        /// or a recursive queried folder within a folder structure ( >2 )
        /// 
        /// needed to build a Fullname and a folder chain
        /// </summary>
        public Int32 HierarchyLevel;

        /// <summary>
        /// The unique identifier for the mailFolder's parent mailFolder.
        /// </summary>
        public String ParentFolderId;

        /// <summary>
        /// 
        /// </summary>
        public Folder ParentFolder;

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
                if (TotalItemCount > 0)
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

        private string _returnValue;

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method 
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            if (!string.IsNullOrEmpty(DisplayName))
            {
                _returnValue = DisplayName;
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