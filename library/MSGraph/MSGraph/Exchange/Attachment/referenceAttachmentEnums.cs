namespace MSGraph.Exchange.Attachment
{
    /// <summary>
    /// names of reference attachment provider types in Microsoft Graph API
    /// </summary>
    public enum ReferenceAttachmentProvider
    {
        /// <summary>
        /// oneDriveBusiness
        /// </summary>
        oneDriveBusiness,

        /// <summary>
        /// oneDriveConsumer
        /// </summary>
        oneDriveConsumer,

        /// <summary>
        /// dropbox
        /// </summary>
        dropbox,

        /// <summary>
        /// other
        /// </summary>
        other
    }

    /// <summary>
    /// names of possible permissions in referenceAttachments in Microsoft Graph API
    /// </summary>
    public enum referenceAttachmentPermission
    {
        /// <summary>
        /// view
        /// </summary>
        view,

        /// <summary>
        /// edit
        /// </summary>
        edit,

        /// <summary>
        /// anonymousView
        /// </summary>
        anonymousView,

        /// <summary>
        /// anonymousEdit
        /// </summary>
        anonymousEdit,

        /// <summary>
        /// organizationView
        /// </summary>
        organizationView,

        /// <summary>
        /// organizationEdit
        /// </summary>
        organizationEdit,

        /// <summary>
        /// other
        /// </summary>
        other,
    }
}
