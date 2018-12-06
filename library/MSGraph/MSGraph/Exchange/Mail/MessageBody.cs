using System;
using System.Text.RegularExpressions;

namespace MSGraph.Exchange.Mail
{
    /// <summary>
    /// Class for a body object from a message
    /// https://docs.microsoft.com/en-us/graph/api/resources/itembody?view=graph-rest-1.0
    /// </summary>
    [Serializable]
    public class MessageBody
    {
        #region Properties
        /// <summary>
        /// The type of the content. Possible values are Text and HTML.
        /// </summary>
        public String contentType;

        /// <summary>
        /// The content of the item.
        /// </summary>
        public String content;

        #endregion Properties


        #region Statics & Stuff
        /// <summary>
        /// Overrides the default ToString() method 
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return content;
        }

        #endregion Statics & Stuff


        #region Constructors
        /// <summary>
        /// MessageBody input
        /// </summary>
        /// <param name="Body"></param>
        public MessageBody(MessageBody Body)
        {
            contentType = Body.contentType;
            content = Body.content;
        }
            
        /// <summary>
        /// String input parser
        /// </summary>
        /// <param name="Body"></param>
        public MessageBody(String Body)
        {
            Match match = Regex.Match(Body, @"^<html>.*|(`r|`n|`t)*<\/html>$", RegexOptions.IgnoreCase );
            if (match.Success)
            {
                contentType = "html";
                content = Body;
            }
            else
            {
                contentType = "text";
                content = Body;
            }

        }

        /// <summary>
        /// empty object
        /// </summary>
        public MessageBody()
        {
        }
        #endregion Constructors
    }
}
