using System;
using System.Net;
using System.Security.Principal;

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

        /// <summary>
        /// 
        /// </summary>
        public String Algorithm;

        /// <summary>
        /// 
        /// </summary>
        public Guid ApplicationID;

        /// <summary>
        /// 
        /// </summary>
        public String ApplicationName;

        /// <summary>
        /// 
        /// </summary>
        public String Audience;

        /// <summary>
        /// 
        /// </summary>
        public String[] AuthenticationMethod;

        /// <summary>
        /// 
        /// </summary>
        public DateTime ExpirationTime;

        /// <summary>
        /// 
        /// </summary>
        public String GivenName;

        /// <summary>
        /// 
        /// </summary>
        public DateTime IssuedAt;

        /// <summary>
        /// 
        /// </summary>
        public String Issuer;

        /// <summary>
        /// 
        /// </summary>
        public String Name;

        /// <summary>
        /// 
        /// </summary>
        public DateTime NotBefore;

        /// <summary>
        /// 
        /// </summary>
        public Guid OID;

        /// <summary>
        /// 
        /// </summary>
        public Int16 Plattform;

        /// <summary>
        /// 
        /// </summary>
        public String Scope;

        /// <summary>
        /// 
        /// </summary>
        public SecurityIdentifier SID;

        /// <summary>
        /// 
        /// </summary>
        public IPAddress SourceIPAddr;

        /// <summary>
        /// 
        /// </summary>
        public String SureName;

        /// <summary>
        /// 
        /// </summary>
        public Guid TenantID;

        /// <summary>
        /// 
        /// </summary>
        public String Type;

        /// <summary>
        /// 
        /// </summary>
        public String UniqueName;

        /// <summary>
        /// 
        /// </summary>
        public String UPN;

        /// <summary>
        /// 
        /// </summary>
        public Version Version;
    }
}
