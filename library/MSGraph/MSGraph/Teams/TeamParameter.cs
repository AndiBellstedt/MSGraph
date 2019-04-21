using System;
using System.Linq;

namespace MSGraph.Teams {
    /// <summary>
    /// Team parameter class for convinient pipeline 
    /// input on parameters in *-MgaTeam commands
    /// </summary>
    [Serializable]
    public class TeamParameter {
        #region Properties
        /// <summary>
        /// category id
        /// </summary>
        public string Id;

        /// <summary>
        /// name of the category
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
            if (!string.IsNullOrEmpty(Name)) {
                _returnValue = Name;
            } else if (!string.IsNullOrEmpty(Id)) {
                _returnValue = Id;
            } else {
                _returnValue = InputObject.ToString();
            }

            return _returnValue;
        }
        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// Mail Folderinput
        /// </summary>
        public TeamParameter(Team Team) {
            this.InputObject = Team;
            this._typeName = InputObject.GetType().ToString();
            this.Id = Team.Id.ToString();
            this.Name = Team.DisplayName;
        }

        /// <summary>
        /// String input
        /// </summary>
        public TeamParameter(Guid Id) {
            this.InputObject = Id.ToString();
            this._typeName = InputObject.GetType().ToString();
            this.Id = Id.ToString();
        }

        /// <summary>
        /// String input
        /// </summary>
        public TeamParameter(string Text) {
            this.InputObject = Text;
            this._typeName = InputObject.GetType().ToString();

            Guid _id;
            if (!String.IsNullOrEmpty(Text) && Guid.TryParse(Text, out _id)) {
                this.Id = Text;
            } else {
                this.Name = Text;
            }
        }
        #endregion Constructors
    }
}
