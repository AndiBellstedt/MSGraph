using System;
using System.Management.Automation;
using System.Security;

namespace MSGraph.Core
{
    /// <summary>
    /// Token used to authenticate against azure with
    /// 
    /// https://docs.microsoft.com/en-us/azure/active-directory/develop/access-tokens
    /// 
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
        public Uri Resource;

        /// <summary>
        /// The service uri where to connect
        /// </summary>
        public Uri AppRedirectUrl;

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
        public Guid ClientId;

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

        /// <summary>
        /// The owner of the Token extracted from the JWT
        /// </summary>
        public String TokenOwner
        {
            get
            {
                return AccessTokenInfo.Name;
            }

            set
            {
            }
        }

        /// <summary>
        /// The user principal in the Token extracted from the JWT
        /// </summary>
        public String UserprincipalName
        {
            get
            {
                return AccessTokenInfo.UPN;
            }

            set
            {
            }
        }

        /// <summary>
        /// Tenant ID for the Application in Azure (extracted from the JWT)
        /// </summary>
        public Guid TenantID
        {
            get
            {
                return AccessTokenInfo.TenantID;
            }

            set
            {
            }
        }

        /// <summary>
        /// The Application Name in Azure (extracted from the JWT)
        /// </summary>
        public string AppName
        {
            get
            {
                return AccessTokenInfo.ApplicationName;
            }

            set
            {
            }
        }

        /// <summary>
        /// The Lifetime of the Access Token
        /// </summary>
        public TimeSpan AccessTokenLifeTime
        {
            get
            {
                return  ValidUntil.Subtract ( ValidFrom );
            }

            set
            {
            }
        }

        /// <summary>
        /// Remaining time of the token Lifetime
        /// </summary>
        public TimeSpan TimeRemaining
        {
            get
            {
                if (ValidUntil > DateTime.Now )
                {
                    TimeSpan timeSpan = ValidUntil - DateTime.Now;
                    return TimeSpan.Parse(timeSpan.ToString(@"dd\.hh\:mm\:ss"));
                }
                else {
                    TimeSpan timeSpan = TimeSpan.Parse("0:0:0:0");
                    return timeSpan;
                }
            }

            set
            {
            }
        }

        /// <summary>
        /// Percentage value of the Tokenlifetime
        /// </summary>
        public Int16 PercentRemaining
        {
            get
            {
                if (ValidUntil > DateTime.Now)
                {
                    Int16 percentage = (Int16)(Math.Round( TimeRemaining.TotalMilliseconds / AccessTokenLifeTime.TotalMilliseconds * 100 ));
                    return percentage;
                }
                else
                {
                    return 0;
                }
            }

            set
            {
            }
        }
    }
}
