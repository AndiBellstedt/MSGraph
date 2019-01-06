using System;
using System.Collections;
using System.Collections.Generic;

namespace MSGraph.Exchange.Category {
    /// <summary>
    /// Category in exchange online
    /// 
    /// Represents a category by which a user can group Outlook items such as messages and events.
    /// The user defines categories in a master list, and can apply one or more of these user-defined categories to an item.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/outlookcategory?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class OutlookCategory {
        #region Properties
        /// <summary>
        /// 
        /// </summary>
        public Guid Id;

        /// <summary>
        /// 
        /// </summary>
        public String DisplayName;

        /// <summary>
        /// 
        /// </summary>
        public String Name {
            get {
                return DisplayName;
            }
            set {
                this.DisplayName = value;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public ColorKey Color;

        /// <summary>
        /// 
        /// </summary>
        public ColorName ColorName {
            get {
                if(ColorTable.ContainsKey(Color.ToString().ToLower())) {
                    string name = (string)ColorTable[Color.ToString().ToLower()];
                    return (ColorName)Enum.Parse(typeof(ColorName), name, true);
                } else {
                    return (ColorName)Enum.Parse(typeof(ColorName), @"NoColorMapped", true);
                }

            }
            set { }
        }

        /// <summary>
        /// 
        /// </summary>
        public String ColorCode {
            get {
                if(ColorCodeTable.ContainsKey(Color.ToString().ToLower())) {
                    return (string)ColorCodeTable[Color.ToString().ToLower()];
                } else {
                    return @"";
                }

            }
            set { }
        }

        /// <summary>
        /// 
        /// </summary>
        public String User;

        /// <summary>
        /// carrier object for the original api result
        /// </summary>
        public object BaseObject;

        private static Hashtable ColorTable {
            get {
                Hashtable table = new Hashtable
                {
                    { "none", "NoColorMapped" },
                    { "preset0", "Red" },
                    { "preset1", "Orange" },
                    { "preset2", "Brown" },
                    { "preset3", "Yellow" },
                    { "preset4", "Green" },
                    { "preset5", "Teal" },
                    { "preset6", "Olive" },
                    { "preset7", "Blue" },
                    { "preset8", "Purple" },
                    { "preset9", "Cranberry" },
                    { "preset10", "Steel" },
                    { "preset11", "DarkSteel" },
                    { "preset12", "Gray" },
                    { "preset13", "DarkGray" },
                    { "preset14", "Black" },
                    { "preset15", "DarkRed" },
                    { "preset16", "DarkOrange" },
                    { "preset17", "DarkBrown" },
                    { "preset18", "DarkYellow" },
                    { "preset19", "DarkGreen" },
                    { "preset20", "DarkTeal" },
                    { "preset21", "DarkOlive" },
                    { "preset22", "DarkBlue" },
                    { "preset23", "DarkPurple" },
                    { "preset24", "DarkCranberry" }
                };
                return table;
            }
            set { }
        }

        private static Hashtable ColorNameTable {
            get {
                Hashtable table = new Hashtable
                {
                    { "nocolormapped", "None"},
                    { "red"          , "Preset0" },
                    { "orange"       , "Preset1" },
                    { "brown"        , "Preset2" },
                    { "yellow"       , "Preset3" },
                    { "green"        , "Preset4" },
                    { "teal"         , "Preset5" },
                    { "olive"        , "Preset6" },
                    { "blue"         , "Preset7" },
                    { "purple"       , "Preset8" },
                    { "cranberry"    , "Preset9" },
                    { "steel"        , "Preset10"},
                    { "darksteel"    , "Preset11"},
                    { "gray"         , "Preset12"},
                    { "darkgray"     , "Preset13"},
                    { "black"        , "Preset14"},
                    { "darkred"      , "Preset15"},
                    { "darkorange"   , "Preset16"},
                    { "darkbrown"    , "Preset17"},
                    { "darkyellow"   , "Preset18"},
                    { "darkgreen"    , "Preset19"},
                    { "darkteal"     , "Preset20"},
                    { "darkolive"    , "Preset21"},
                    { "darkblue"     , "Preset22"},
                    { "darkpurple"   , "Preset23"},
                    { "darkcranberry", "Preset24"}
                };
                return table;
            }
            set { }
        }

        private static Hashtable ColorCodeTable {
            get {
                Hashtable table = new Hashtable
                {
                    { "none", "" },
                    { "preset0", "E7A1A2" },
                    { "preset1", "F9BA89" },
                    { "preset2", "F7DD8F" },
                    { "preset3", "FCFA90" },
                    { "preset4", "78D168" },
                    { "preset5", "9FDCC9" },
                    { "preset6", "C6D2B0" },
                    { "preset7", "9DB7E8" },
                    { "preset8", "B5A1E2" },
                    { "preset9", "daaec2" },
                    { "preset10", "dad9dc" },
                    { "preset11", "6b7994" },
                    { "preset12", "bfbfbf" },
                    { "preset13", "6f6f6f" },
                    { "preset14", "4f4f4f" },
                    { "preset15", "c11a25" },
                    { "preset16", "e2620d" },
                    { "preset17", "c79930" },
                    { "preset18", "b9b300" },
                    { "preset19", "368f2b" },
                    { "preset20", "329b7a" },
                    { "preset21", "778b45" },
                    { "preset22", "2858a5" },
                    { "preset23", "5c3fa3" },
                    { "preset24", "93446b" }
                };
                return table;
            }
            set { }
        }

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method 
        /// </summary>
        /// <returns></returns>
        public override string ToString() {
            return DisplayName;
        }

        /// <summary>
        /// 
        /// </summary>
        public static string Parse(String Color) {
            return (string)ColorTable[Color.ToString().ToLower()];
        }

        /// <summary>
        /// 
        /// </summary>
        public static ColorName Parse(ColorKey ColorKey) {
            string name = (string)ColorTable[ColorKey.ToString().ToLower()];
            return (ColorName)Enum.Parse(typeof(ColorName), name, true);
        }

        /// <summary>
        /// 
        /// </summary>
        public static ColorKey Parse(ColorName ColorName) {
            string name = (string)ColorNameTable[ColorName.ToString().ToLower()];
            return (ColorKey)Enum.Parse(typeof(ColorKey), name, true);
        }

        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public OutlookCategory() {
        }

        /// <summary>
        /// Only name input
        /// </summary>
        public OutlookCategory(String Name) {
            this.DisplayName = Name;
        }

        /// <summary>
        /// Only Id input
        /// </summary>
        public OutlookCategory(Guid Id) {
            this.Id = Id;
        }

        /// <summary>
        /// Only ColorKey
        /// </summary>
        public OutlookCategory(ColorKey Color) {
            this.Color = Color;
        }

        /// <summary>
        /// All relevant properties
        /// </summary>
        public OutlookCategory(Guid Id, String DisplayName, ColorKey Color, String User) {
            this.Id = Id;
            this.DisplayName = DisplayName;
            this.Color = Color;
            this.User = User;
        }

        /// <summary>
        /// All relevant properties including Baseobject
        /// </summary>
        public OutlookCategory(Guid Id, String DisplayName, ColorKey Color, String User, object BaseObject) {
            this.Id = Id;
            this.DisplayName = DisplayName;
            this.Color = Color;
            this.User = User;
            this.BaseObject = BaseObject;
        }
        #endregion Constructors
    }
}
