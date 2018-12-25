using System;
using System.Linq;

namespace MSGraph.Exchange.Mail
{
    /// <summary>
    /// Mail message parameter class for convinient pipeline 
    /// input on parameters in *-MgaMail* commands
    /// </summary>
    [Serializable]
    public class FolderParameter
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

        /// <summary>
        /// indicator wether name is a WellKnownFolder
        /// </summary>
        public bool IsWellKnownName;

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
                _returnValue = InputObject.ToString();
            }

            return _returnValue;
        }
        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// Mail Folderinput
        /// </summary>
        public FolderParameter(Folder Folder)
        {
            InputObject = Folder;
            _typeName = InputObject.GetType().ToString();
            Id = Folder.Id;
            Name = Folder.DisplayName;
        }

        /// <summary>
        /// String input
        /// </summary>
        public FolderParameter(string Text)
        {
            InputObject = Text;
            string[] names = Enum.GetNames(typeof(WellKnownFolder));
            _typeName = InputObject.GetType().ToString();

            if (names.Contains(Text, StringComparer.InvariantCultureIgnoreCase))
            {
                IsWellKnownName = true;
                Name = Text.ToLower();
                Id = Name;
            }
            else if (Text.Length == 120 || Text.Length == 104)
            {
                IsWellKnownName = false;
                Id = Text;
            }
            else
            {
                IsWellKnownName = false;
                Name = Text;
            }
        }
        #endregion Constructors
    }
}