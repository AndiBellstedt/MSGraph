using System;
using System.Management.Automation;
using System.Security;

namespace MSGraph.Exchange
{
    namespace Mail
    {
        /// <summary>
        /// Mail message in exchange online
        /// </summary>
        public class Message
        {
            /// <summary>
            /// data carrier object
            /// </summary>
            public object BaseObject;
        }

        /// <summary>
        /// Mail folder in exchange online
        /// </summary>
        public class Folder
        {
            /// <summary>
            /// data carrier object
            /// </summary>
            public object BaseObject;
        }

        /// <summary>
        /// Mail attachments in exchange online
        /// </summary>
        public class Attachment
        {
            /// <summary>
            /// data carrier object
            /// </summary>
            public object BaseObject;
        }
    }
}
