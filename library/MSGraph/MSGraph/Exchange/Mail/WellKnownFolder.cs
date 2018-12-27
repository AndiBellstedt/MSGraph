namespace MSGraph.Exchange.Mail
{
    /// <summary>
    /// name of well-known-folders in a outlook mailboxes
    /// 
    /// Outlook creates certain folders for users by default. 
    /// Instead of using the corresponding folder id value, for convenience, 
    /// you can use the well-known folder names from the table below when accessing these folders. 
    /// 
    /// For example, you can get the Drafts folder using its well-known name with the following query.
    /// </summary>
    public enum WellKnownFolder
    {
        /// <summary>
        /// Represent all folders in the mailbox.
        /// </summary>
        AllItems,

        /// <summary>
        /// The archive folder messages are sent to when using the One_Click Archive feature in Outlook clients that support it. 
        /// Note: this is not the same as the Archive Mailbox feature of Exchange online.
        /// </summary>
        Archive,

        /// <summary>
        /// The clutter folder low-priority messages are moved to when using the Clutter feature.
        /// </summary>
        Clutter,

        /// <summary>
        /// The folder that contains conflicting items in the mailbox.
        /// </summary>
        Conflicts,

        /// <summary>
        /// The folder where Skype saves IM conversations (if Skype is configured to do so).
        /// </summary>
        Conversationhistory,

        /// <summary>
        /// The folder items are moved to when they are deleted.
        /// </summary>
        DeletedItems,

        /// <summary>
        /// The folder that contains unsent messages.
        /// </summary>
        Drafts,

        /// <summary>
        /// The inbox folder.
        /// </summary>
        Inbox,

        /// <summary>
        /// The junk email folder.
        /// </summary>
        JunkEmail,

        /// <summary>
        /// The folder that contains items that exist on the local client but could not be uploaded to the server.
        /// </summary>
        LocalFailures,

        /// <summary>
        /// The "Top of Information Store" folder. This folder is the parent folder for folders that are displayed in normal mail clients, such as the inbox.
        /// </summary>
        MsgFolderRoot,

        /// <summary>
        /// The outbox folder.
        /// </summary>
        Outbox,

        /// <summary>
        /// The folder that contains soft-deleted items: 
        /// deleted either from the Deleted Items folder, or by pressing shift+delete in Outlook. 
        /// This folder is not visible in any Outlook email client, but end users can interact with 
        /// it through the Recover Deleted Items from Server feature in Outlook or Outlook on the web.
        /// </summary>
        RecoverableItemsDeletions,

        /// <summary>
        /// The folder that contains messages that are scheduled to reappear in the inbox using the Schedule feature in Outlook for iOS.
        /// </summary>
        Scheduled,

        /// <summary>
        /// The parent folder for all search folders defined in the user's mailbox.
        /// </summary>
        SearchFolders,

        /// <summary>
        /// The sent items folder.
        /// </summary>
        SentItems,

        /// <summary>
        /// The folder that contains items that exist on the server but could not be synchronized to the local client.
        /// </summary>
        ServerFailures,

        /// <summary>
        /// The folder that contains synchronization logs created by Outlook.
        /// </summary>
        SyncIssues,
    }
}
