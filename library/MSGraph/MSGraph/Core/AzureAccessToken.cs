using System;
using System.Management.Automation;
using System.Security;

namespace MSGraph.Core
{
    /// <summary>
    /// Token used to authenticate against azure with
    /// </summary>
    [Serializable]
    public class AzureAccessToken
    {
        /// <summary>
        /// The type of token. Generally, only when the token is of type "Bearer" is a valid connection established.
        /// </summary>
        public string TokenType;

        /// <summary>
        /// The service uri where to connect
        /// </summary>
        public string Resource;

        /// <summary>
        /// The service uri where to connect
        /// </summary>
        public string AppRedirectUrl;

        /// <summary>
        /// The permission scopes contained on the token
        /// </summary>
        public string[] Scope;

        /// <summary>
        /// Until when the token is valid (utc)
        /// </summary>
        public DateTime ValidUntilUtc;

        /// <summary>
        /// Since when the token is valid (utc)
        /// </summary>
        public DateTime ValidFromUtc;

        /// <summary>
        /// Until when the token is valid
        /// </summary>
        public DateTime ValidUntil;

        /// <summary>
        /// Since when the token is valid
        /// </summary>
        public DateTime ValidFrom;

        /// <summary>
        /// The actual access token
        /// </summary>
        public SecureString AccessToken;

        /// <summary>
        /// The token used to refresh the access token. Refreshing a token will extends its maximum use time.
        /// </summary>
        public SecureString RefreshToken;

        /// <summary>
        /// The Identity Token
        /// </summary>
        public SecureString IDToken;

        /// <summary>
        /// The credentials used to authenticate. Used for unattended connections
        /// </summary>
        public PSCredential Credential;

        /// <summary>
        /// The client ID used to connect
        /// </summary>
        public string ClientId;

        /// <summary>
        /// Whether the token is valid for connections
        /// </summary>
        public bool IsValid
        {
            get
            {
                if (TokenType.ToLower() != "bearer")
                    return false;
                if (ValidUntil < DateTime.Now)
                    return false;
                if (Scope == null)
                    return false;
                if (Scope.Length == 0)
                    return false;
                if (AccessToken == null)
                    return false;
                return true;
            }

            set
            {
            }
        }

        /// <summary>
        /// Informationen from JWT access token
        /// </summary>
        public JWTAccessTokenInfo AccessTokenInfo;
    }
}
