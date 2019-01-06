using System;
using System.Net;
using System.Security.Principal;

namespace MSGraph.Core {
    /// <summary>
    /// Token informationen from a JWT access token
    /// </summary>
    [Serializable]
    public class JWTAccessTokenInfo {
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
        /// Indicates the algorithm that was used to sign the token, for example, "RS256"
        /// </summary>
        public String Algorithm;

        /// <summary>
        /// Only present in v1.0 tokens. The application ID of the client using the token.
        /// The application can act as itself or on behalf of a user.
        /// The application ID typically represents an application object,
        /// but it can also represent a service principal object in Azure AD.
        /// </summary>
        public Guid ApplicationID;

        /// <summary>
        /// Application name from registered Azure Application
        /// </summary>
        public String ApplicationName;

        /// <summary>
        /// Identifies the intended recipient of the token.
        /// In access tokens, the audience is your app's Application ID, assigned to your app in the Azure portal.
        /// Your app should validate this value and reject the token if the value does not match.
        /// </summary>
        public String Audience;

        /// <summary>
        /// Only present in v1.0 tokens. Identifies how the subject of the token was authenticated. 
        /// See https://docs.microsoft.com/en-us/azure/active-directory/develop/access-tokens#the-amr-claim for more details.
        /// Microsoft identities can authenticate in a variety of ways, which may be relevant to your application. 
        /// The amr claim is an array that can contain multiple items, such as ["mfa", "rsa", "pwd"], 
        /// for an authentication that used both a password and the Authenticator app. 
        /// </summary>
        public String[] AuthenticationMethod;

        /// <summary>
        /// The "exp" (expiration time) claim identifies the expiration time on or after which the
        /// JWT must not be accepted for processing. It's important to note that a resource may
        /// reject the token before this time as well, such as when a change in authentication is
        /// required or a token revocation has been detected.
        /// </summary>
        public DateTime ExpirationTime;

        /// <summary>
        /// Provides the first or given name of the user, as set on the user object.
        /// </summary>
        public String GivenName;

        /// <summary>
        /// "Issued At" indicates when the authentication for this token occurred.
        /// </summary>
        public DateTime IssuedAt;

        /// <summary>
        /// Alias property from Audience
        /// </summary>
        public String Issuer {
            get {
                return Audience;
            }

            set {
            }
        }

        /// <summary>
        /// Provides a human-readable value that identifies the subject of the token.
        /// The value is not guaranteed to be unique, it is mutable, and it's designed
        /// to be used only for display purposes. The profile scope is required in
        /// order to receive this claim.
        /// </summary>
        public String Name;

        /// <summary>
        /// The "nbf" (not before) claim identifies the time before which the JWT must not be accepted for processing.
        /// </summary>
        public DateTime NotBefore;

        /// <summary>
        /// he immutable identifier for an object in the Microsoft identity platform, in this case, a user account.
        /// It can also be used to perform authorization checks safely and as a key in database tables. This ID 
        /// uniquely identifies the user across applications - two different applications signing in the same user 
        /// will receive the same value in the oid claim. Thus, oid can be used when making queries to Microsoft
        /// online services, such as the Microsoft Graph. The Microsoft Graph will return this ID as the id 
        /// property for a given user account. Because the oid allows multiple apps to correlate users, the profile
        /// scope is required in order to receive this claim. Note that if a single user exists in multiple 
        /// tenants, the user will contain a different object ID in each tenant - they are considered different 
        /// accounts, even though the user logs into each account with the same credentials.
        /// </summary>
        public Guid OID;

        /// <summary>
        /// The plattform
        /// </summary>
        public String Plattform;

        /// <summary>
        /// The set of scopes exposed by your application for which the client application has requested
        /// (and received) consent. Your app should verify that these scopes are valid ones exposed by
        /// your app, and make authorization decisions based on the value of these scopes.
        /// Only included for user tokens.
        /// </summary>
        public String Scope;

        /// <summary>
        /// In cases where the user has an on-premises authentication, this claim provides their SID.
        /// This can be used for authorization in legacy applications.
        /// </summary>
        public SecurityIdentifier SID;

        /// <summary>
        /// The IP address the user authenticated from.
        /// </summary>
        public IPAddress SourceIPAddr;

        /// <summary>
        /// Provides the last name, surname, or family name of the user as defined on the user object.
        /// </summary>
        public String SureName;

        /// <summary>
        /// Represents the Azure AD tenant that the user is from. For work and school accounts,
        /// the GUID is the immutable tenant ID of the organization that the user belongs to.
        /// For personal accounts, the value is 9188040d-6c67-4c5b-b112-36a304b66dad.
        /// The profile scope is required in order to receive this claim.
        /// </summary>
        public Guid TenantID;

        /// <summary>
        /// Indicates that the token is a JWT.
        /// </summary>
        public String Type;

        /// <summary>
        /// Only present in v1.0 tokens.
        /// Provides a human readable value that identifies the subject of the token.
        /// This value is not guaranteed to be unique within a tenant and should 
        /// be used only for display purposes.
        /// </summary>
        public String UniqueName;

        /// <summary>
        /// The username of the user. May be a phone number, email address, or unformatted string.
        /// Should only be used for display purposes and providing username hints in reauthentication scenarios.
        /// </summary>
        public String UPN;

        /// <summary>
        /// Indicates the version of the access token.
        /// </summary>
        public Version Version;
    }
}
