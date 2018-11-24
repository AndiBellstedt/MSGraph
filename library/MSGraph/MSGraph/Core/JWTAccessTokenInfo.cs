using System;
using System.Management.Automation;
using System.Security;

namespace MSGraph.Core
{
    /// <summary>
    /// Token informationen from a JWT access token
    /// </summary>
    [Serializable]
    public class JWTAccessTokenInfo
    {
        /// <summary>
        /// The type of token. Generally, only when the token is of type "Bearer" is a valid connection established.
        /// </summary>
        public String Header;

        /// <summary>
        /// The type of token. Generally, only when the token is of type "Bearer" is a valid connection established.
        /// </summary>
        public String Payload;

        /// <summary>
        /// The type of token. Generally, only when the token is of type "Bearer" is a valid connection established.
        /// </summary>
        public Byte[] Signature;
    }
}
