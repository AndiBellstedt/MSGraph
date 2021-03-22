using MSGraph.Exchange.MailboxSetting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MSGraph.AzureAD.Users {
    /// <summary>
    /// User in MS Graph API
    ///
    /// Represents an Azure AD user account.
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/user?view=graph-rest-beta
    /// </summary>
    [Serializable]
    public class User {
        #region Properties
        /// <summary>
        /// A freeform text entry field for the user to describe themselves.
        /// </summary>
        public String AboutMe;

        /// <summary>
        /// true if the account is enabled; otherwise, false. This property is required when a user is created. Supports $filter.
        /// </summary>
        public Boolean AccountEnabled;

        /// <summary>
        /// Sets the age group of the user. Allowed values: null, minor, notAdult and adult. Refer to the legal age group property definitions for further information.
        /// </summary>
        public String AgeGroup;

        /// <summary>
        /// The licenses that are assigned to the user. Not nullable.
        /// assignedLicense collection
        /// </summary>
        public object[] AssignedLicenses;

        /// <summary>
        /// The plans that are assigned to the user. Read-only. Not nullable.
        /// assignedPlan collection
        /// </summary>
        public object[] AssignedPlans;

        /// <summary>
        /// The birthday of the user. The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 would look like this: '2014-01-01T00:00:00Z'
        /// </summary>
        public DateTimeOffset Birthday;

        /// <summary>
        /// The birthday of the user. The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 would look like this: '2014-01-01T00:00:00Z'
        /// </summary>
        public string[] businessPhones;

        /// <summary>
        /// The city in which the user is located. Supports $filter.
        /// </summary>
        public String City;

        /// <summary>
        /// The company name which the user is associated. This property can be useful for describing the company that an external user comes from.
        /// </summary>
        public String CompanyName;

        /// <summary>
        /// Sets whether consent has been obtained for minors. Allowed values: null, granted, denied and notRequired. Refer to the legal age group property definitions for further information.
        /// </summary>
        public String ConsentProvidedForMinor;

        /// <summary>
        /// The country/region in which the user is located; for example, "US" or "UK". Supports $filter.
        /// </summary>
        public String Country;

        /// <summary>
        /// The date and time the user was created. The value cannot be modified and is automatically populated when the entity is created. The DateTimeOffset type represents date and time information using ISO 8601 format and is always in UTC time. Property is nullable. A null value indicates that an accurate creation time couldn't be determined for the user. Read-only. Supports $filter.
        /// </summary>
        public DateTimeOffset CreatedDateTime;

        /// <summary>
        /// The date and time the user was deleted.
        /// </summary>
        public DateTimeOffset DeletedDateTime;

        /// <summary>
        /// The name for the department in which the user works. Supports $filter.
        /// </summary>
        public String Department;

        /// <summary>
        /// 
        /// </summary>
        public object DeviceKeys;

        /// <summary>
        /// The name displayed in the address book for the user. This value is usually the combination of the user's first name, middle initial, and last name. This property is required when a user is created and it cannot be cleared during updates. Supports $filter and $orderby.
        /// </summary>
        public String DisplayName;

        /// <summary>
        /// The employee identifier assigned to the user by the organization. Supports $filter.
        /// </summary>
        public String EmployeeId;

        /// <summary>
        /// For an external user invited to the tenant using the invitation API, this property represents the invited user's invitation status. For invited users, the state can be 'PendingAcceptance' or 'Accepted', or null for all other users. Supports $filter with the supported values. For example: $filter=externalUserState eq 'PendingAcceptance'.
        /// </summary>
        public String ExternalUserState;

        /// <summary>
        /// Shows the timestamp for the latest change to the externalUserState property.
        /// </summary>
        public String ExternalUserStateChangeDateTime;

        /// <summary>
        /// The fax number of the user.
        /// </summary>
        public String FaxNumber;

        /// <summary>
        /// The given name (first name) of the user. Supports $filter.
        /// </summary>
        public String GivenName;

        /// <summary>
        /// The hire date of the user. The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 would look like this: '2014-01-01T00:00:00Z'
        /// </summary>
        public DateTimeOffset HireDate;

        /// <summary>
        /// The unique identifier for the user. Inherited from directoryObject. Key. Not nullable. Read-only.
        /// </summary>
        public String Id;

        /// <summary>
        /// A list for the user to describe their interests.
        /// </summary>
        public String[] Interests;

        /// <summary>
        /// A list for the user to describe their interests.
        /// </summary>
        public String ImAddresses;

        /// <summary>
        /// true if the user is a resource account; otherwise, false. Null value should be considered false.
        /// </summary>
        public Boolean IsResourceAccount;

        /// <summary>
        /// The user?s job title. Supports $filter.
        /// </summary>
        public String JobTitle;

        /// <summary>
        /// Used by enterprise applications to determine the legal age group of the user. This property is read-only and calculated based on ageGroup and consentProvidedForMinor properties. Allowed values: null, minorWithOutParentalConsent, minorWithParentalConsent, minorNoParentalConsentRequired, notAdult and adult. Refer to the legal age group property definitions for further information.)
        /// </summary>
        public String LegalAgeGroupClassification;

        /// <summary>
        /// State of license assignments for this user. Read-only.
        /// licenseAssignmentState collection
        /// </summary>
        public object[] LicenseAssignmentStates;

        /// <summary>
        /// The SMTP address for the user, for example, "jeff@contoso.onmicrosoft.com". Read-Only. Supports $filter.
        /// </summary>
        public String Mail;

        /// <summary>
        /// Settings for the primary mailbox of the signed-in user. You can get or update settings for sending automatic replies to incoming messages, locale, and time zone.
        /// </summary>
        public MailboxSettings MailboxSettings;

        /// <summary>
        /// The mail alias for the user. This property must be specified when a user is created. Supports $filter.
        /// </summary>
        public String MailNickname;

        /// <summary>
        /// The primary cellular telephone number for the user.
        /// </summary>
        public String MobilePhone;

        /// <summary>
        /// The URL for the user's personal site.
        /// </summary>
        public String MySite;

        /// <summary>
        /// The office location in the user's place of business.
        /// </summary>
        public String OfficeLocation;

        /// <summary>
        /// Contains the on-premises Active Directory distinguished name or DN. The property is only populated for customers who are synchronizing their on-premises directory to Azure Active Directory via Azure AD Connect. Read-only.
        /// </summary>
        public String OnPremisesDistinguishedName;

        /// <summary>
        /// Contains the on-premises domainFQDN, also called dnsDomainName synchronized from the on-premises directory. The property is only populated for customers who are synchronizing their on-premises directory to Azure Active Directory via Azure AD Connect. Read-only.
        /// </summary>
        public String OnPremisesDomainName;

        /// <summary>
        /// Contains extensionAttributes 1-15 for the user. Note that the individual extension attributes are neither selectable nor filterable. For an onPremisesSyncEnabled user, this set of properties is mastered on-premises and is read-only. For a cloud-only user (where onPremisesSyncEnabled is false), these properties may be set during creation or update.
        /// OnPremisesExtensionAttributes 
        /// </summary>
        public object OnPremisesExtensionAttributes;

        /// <summary>
        /// This property is used to associate an on-premises Active Directory user account to their Azure AD user object. This property must be specified when creating a new user account in the Graph if you are using a federated domain for the user?s userPrincipalName (UPN) property. Important: The $ and _ characters cannot be used when specifying this property. Supports $filter.
        /// </summary>
        public String OnPremisesImmutableId;

        /// <summary>
        /// Indicates the last time at which the object was synced with the on-premises directory; for example: "2013-02-16T03:04:54Z". The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 would look like this: '2014-01-01T00:00:00Z'. Read-only.
        /// </summary>
        public DateTimeOffset OnPremisesLastSyncDateTime;

        /// <summary>
        /// Errors when using Microsoft synchronization product during provisioning.
        /// onPremisesProvisioningError collection
        /// </summary>
        public object[] OnPremisesProvisioningErrors;

        /// <summary>
        /// Contains the on-premises sAMAccountName synchronized from the on-premises directory. The property is only populated for customers who are synchronizing their on-premises directory to Azure Active Directory via Azure AD Connect. Read-only.
        /// </summary>
        public String OnPremisesSamAccountName;

        /// <summary>
        /// Contains the on-premises security identifier (SID) for the user that was synchronized from on-premises to the cloud. Read-only.
        /// </summary>
        public String OnPremisesSecurityIdentifier;

        /// <summary>
        /// true if this object is synced from an on-premises directory; false if this object was originally synced from an on-premises directory but is no longer synced; null if this object has never been synced from an on-premises directory (default). Read-only
        /// </summary>
        public Boolean OnPremisesSyncEnabled;

        /// <summary>
        /// Contains the on-premises userPrincipalName synchronized from the on-premises directory. The property is only populated for customers who are synchronizing their on-premises directory to Azure Active Directory via Azure AD Connect. Read-only.
        /// </summary>
        public String OnPremisesUserPrincipalName;

        /// <summary>
        /// A list of additional email addresses for the user; for example: ["bob@contoso.com", "Robert@fabrikam.com"]. Supports $filter.
        /// </summary>
        public String OtherMails;

        /// <summary>
        /// Specifies password policies for the user. This value is an enumeration with one possible value being ?DisableStrongPassword?, which allows weaker passwords than the default policy to be specified. ?DisablePasswordExpiration? can also be specified. The two may be specified together; for example: "DisablePasswordExpiration, DisableStrongPassword".
        /// </summary>
        public String PasswordPolicies;

        /// <summary>
        /// Specifies the password profile for the user. The profile contains the user?s password. This property is required when a user is created. The password in the profile must satisfy minimum requirements as specified by the passwordPolicies property. By default, a strong password is required.
        /// PasswordProfile
        /// </summary>
        public object PasswordProfile;

        /// <summary>
        /// A list for the user to enumerate their past projects.
        /// </summary>
        public String[] PastProjects;

        /// <summary>
        /// The postal code for the user's postal address. The postal code is specific to the user's country/region. In the United States of America, this attribute contains the ZIP code.
        /// </summary>
        public String PostalCode;

        /// <summary>
        /// The preferred data location for the user. For more information, see OneDrive Online Multi-Geo.
        /// </summary>
        public String PreferredDataLocation;

        /// <summary>
        /// The preferred language for the user. Should follow ISO 639-1 Code; for example "en-US".
        /// </summary>
        public String PreferredLanguage;

        /// <summary>
        /// The preferred name for the user.
        /// </summary>
        public String PreferredName;

        /// <summary>
        /// The plans that are provisioned for the user. Read-only. Not nullable.
        /// ProvisionedPlan
        /// </summary>
        public object ProvisionedPlans;

        /// <summary>
        /// For example: ["SMTP: bob@contoso.com", "smtp: bob@sales.contoso.com"] The any operator is required for filter expressions on multi-valued properties. Read-only, Not nullable. Supports $filter.
        /// </summary>
        public String[] ProxyAddresses;

        /// <summary>
        /// Any refresh tokens or sessions tokens (session cookies) issued before this time are invalid, and applications will get an error when using an invalid refresh or sessions token to acquire a delegated access token (to access APIs such as Microsoft Graph). If this happens, the application will need to acquire a new refresh token by making a request to the authorize endpoint. Read-only. Use invalidateAllRefreshTokens to reset.
        /// </summary>
        public DateTimeOffset RefreshTokensValidFromDateTime;

        /// <summary>
        /// A list for the user to enumerate their responsibilities.
        /// </summary>
        public String[] Responsibilities;

        /// <summary>
        /// A list for the user to enumerate the schools they have attended.
        /// </summary>
        public String[] Schools;

        /// <summary>
        /// true if the Outlook global address list should contain this user, otherwise false. If not set, this will be treated as true. For users invited through the invitation manager, this property will be set to false.
        /// </summary>
        public Boolean ShowInAddressList;

        /// <summary>
        /// Any refresh tokens or sessions tokens (session cookies) issued before this time are invalid, and applications will get an error when using an invalid refresh or sessions token to acquire a delegated access token (to access APIs such as Microsoft Graph). If this happens, the application will need to acquire a new refresh token by making a request to the authorize endpoint. Read-only. Use revokeSignInSessions to reset.
        /// </summary>
        public DateTimeOffset SignInSessionsValidFromDateTime;

        /// <summary>
        /// A list for the user to enumerate their skills.
        /// </summary>
        public String[] Skills;

        /// <summary>
        /// The state or province in the user's address. Supports $filter.
        /// </summary>
        public String State;

        /// <summary>
        /// The street address of the user's place of business.
        /// </summary>
        public String StreetAddress;

        /// <summary>
        /// The user's surname (family name or last name). Supports $filter.
        /// </summary>
        public String Surname;

        /// <summary>
        /// A two letter country code (ISO standard 3166). Required for users that will be assigned licenses due to legal requirement to check for availability of services in countries. Examples include: "US", "JP", and "GB". Not nullable. Supports $filter.
        /// </summary>
        public String UsageLocation;

        /// <summary>
        /// The user principal name (UPN) of the user. The UPN is an Internet-style login name for the user based on the Internet standard RFC 822. By convention, this should map to the user's email name. The general format is alias@domain, where domain must be present in the tenant?s collection of verified domains. This property is required when a user is created. The verified domains for the tenant can be accessed from the verifiedDomains property of organization. Supports $filter and $orderby.
        /// </summary>
        public String UserPrincipalName;

        /// <summary>
        /// A string value that can be used to classify user types in your directory, such as "Member" and "Guest". Supports $filter.
        /// </summary>
        public String UserType;


        /// <summary>
        /// Alias property on Displayname
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
        /// data carrier object
        /// </summary>
        public object BaseObject;

        private string _returnValue;

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method
        /// </summary>
        /// <returns></returns>
        public override string ToString() {
            if (!string.IsNullOrEmpty(DisplayName)) {
                _returnValue = DisplayName;
            } else if (!string.IsNullOrEmpty(Id)) {
                _returnValue = Id;
            } else {
                _returnValue = this.GetType().Name;
            }

            return _returnValue;
        }

        #endregion Statics & Stuff

        #region Constructors
        /// <summary>
        /// empty
        /// </summary>
        public User() {
        }

        #endregion Constructors
    }
}
