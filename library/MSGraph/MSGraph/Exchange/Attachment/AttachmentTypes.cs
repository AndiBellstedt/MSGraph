namespace MSGraph.Exchange.Attachment {
    /// <summary>
    /// names of the attachment types in Microsoft Graph API
    /// 
    /// https://docs.microsoft.com/en-us/graph/api/resources/attachment?view=graph-rest-1.0
    /// </summary>
    public enum AttachmentTypes {
        /// <summary>
        /// A file (such as a text file or Word document) attached to an event, message or post.
        /// The contentBytes property contains the base64-encoded contents of the file.
        /// 
        /// https://docs.microsoft.com/en-us/graph/api/resources/fileattachment?view=graph-rest-1.0
        /// </summary>
        fileAttachment,

        /// <summary>
        /// A contact, event, or message that's attached to another event, message, or post.
        /// 
        /// https://docs.microsoft.com/en-us/graph/api/resources/itemattachment?view=graph-rest-1.0
        /// </summary>
        itemAttachment,

        /// <summary>
        /// A link to a file (such as a text file or Word document) on a OneDrive for Business cloud drive 
        /// or other supported storage locations, attached to an event, message, or post.
        /// 
        /// https://docs.microsoft.com/en-us/graph/api/resources/referenceattachment?view=graph-rest-1.0
        /// </summary>
        referenceAttachment,
    }
}
