using System;
using System.Net.Mail;

namespace MSGraph.Exchange.Mail
{
    /// <summary>
    /// Mail message in exchange online
    /// </summary>
    [Serializable]
    public class Message
    {
        #region Properties
        /// <summary>
        /// data carrier object
        /// </summary>
        public object BaseObject;

        /// <summary>
        /// 
        /// </summary>
        public String Id;

        /// <summary>
        /// 
        /// </summary>
        public String ChangeKey;

        /// <summary>
        /// 
        /// </summary>
        public String ParentFolderId;

        /// <summary>
        /// 
        /// </summary>
        public String ConversationId;

        /// <summary>
        /// 
        /// </summary>
        public String InternetMessageId;

        /// <summary>
        /// 
        /// </summary>
        public Uri WebLink;


        /// <summary>
        /// 
        /// </summary>
        public MailAddress Sender;

        /// <summary>
        /// 
        /// </summary>
        public MailAddress From;

        /// <summary>
        /// 
        /// </summary>
        public MailAddress[] ToRecipients;

        /// <summary>
        /// 
        /// </summary>
        public MailAddress[] CCRecipients;

        /// <summary>
        /// 
        /// </summary>
        public MailAddress[] BCCRecipients;

        /// <summary>
        /// 
        /// </summary>
        public MailAddress[] ReplyTo;

        /// <summary>
        /// 
        /// </summary>
        public String Subject;

        /// <summary>
        /// 
        /// </summary>
        public MessageBody Body;

        /// <summary>
        /// 
        /// </summary>
        public String BodyPreview;

        /// <summary>
        /// 
        /// </summary>
        public object[] Categories;

        /// <summary>
        /// 
        /// </summary>
        public String Importance;

        /// <summary>
        /// 
        /// </summary>
        public String InferenceClassification;

        /// <summary>
        /// 
        /// </summary>
        public FollowupFlag Flag;

        /// <summary>
        /// 
        /// </summary>
        public object MeetingMessageType;


        /// <summary>
        /// 
        /// </summary>
        public DateTime CreatedDateTime;

        /// <summary>
        /// 
        /// </summary>
        public DateTime SentDateTime;

        /// <summary>
        /// 
        /// </summary>
        public DateTime ReceivedDateTime;

        /// <summary>
        /// 
        /// </summary>
        public DateTime lastModifiedDateTime;


        /// <summary>
        /// 
        /// </summary>
        public bool HasAttachments;

        /// <summary>
        /// 
        /// </summary>
        public bool IsDeliveryReceiptRequested;

        /// <summary>
        /// 
        /// </summary>
        public bool IsDraft;

        /// <summary>
        /// 
        /// </summary>
        public bool IsRead;

        /// <summary>
        /// 
        /// </summary>
        public bool isReadReceiptRequested;

        /// <summary>
        /// 
        /// </summary>
        public bool UnRead
        {
            get
            {
                return !IsRead;
            }

            set
            {
                IsRead = !UnRead;
            }
        }

        private string _returnValue;

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method 
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            if (!string.IsNullOrEmpty(Subject))
            {
                _returnValue = Subject;
            }
            else if (!string.IsNullOrEmpty(Id))
            {
                _returnValue = Id;
            }
            else
            {
                _returnValue = this.GetType().Name;
            }

            return _returnValue;
        }
        #endregion Statics & Stuff

    }
}