using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Web;

namespace TechnoPurAccounts.Models
{
    public class MailNotification
    {
        static public bool FunSendMail(string EmailBody, string EmailAddress, string Subject)
        {
            //EmailAddress = "genial365erp123@gmail.com";
            //string htmlbody = EmailBody;
            //SmtpClient client = new SmtpClient();
            //client.Port = 587;
            //client.Host = "smtp.office365.com";
            //client.EnableSsl = true;
            //client.DeliveryMethod = SmtpDeliveryMethod.Network;
            //client.UseDefaultCredentials = false;
            //client.Credentials = new NetworkCredential("sales@esindbaad.com", "Sindbaad@123");
            //MailMessage mm = new MailMessage(EmailAddress, EmailAddress, Subject, htmlbody);
            //mm.From = new MailAddress("sales@esindbaad.com", "eSindbaad");

            string htmlbody = EmailBody;
            SmtpClient client = new SmtpClient();
            client.Port = 8889;
            client.Host = "mail5016.site4now.net";
            ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;
            //client.EnableSsl = true;
            client.DeliveryMethod = SmtpDeliveryMethod.Network;
            client.UseDefaultCredentials = false;
            client.Credentials = new NetworkCredential("notification@omnibok.se", "123456#As");
            MailMessage mm = new MailMessage(EmailAddress, EmailAddress, Subject, htmlbody);
            mm.From = new MailAddress("notification@omnibok.se", "omnibok");

            mm.IsBodyHtml = true;
            mm.Priority = MailPriority.Normal;
            //mm.ReplyToList.Add("genial365erp123@gmail.com");

            mm.BodyEncoding = Encoding.Default;
            mm.DeliveryNotificationOptions = DeliveryNotificationOptions.OnFailure;
            try
            {
                client.Send(mm);
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }
        static public string emailTempleteNew(string username, string text)
        {
            return "<div style='font-size: 12.0pt; font-family: 'Calibri',sans-serif;'> <p>Dear " + username + ",</p> <p> " + text + "</p> <div> <br> <p><strong>Note</strong>: This is an automatic system generated email. Please do not reply.</p> <hr />  </div> <table border='0' cellspacing='0' cellpadding='0'> <tbody>  <tr> <td style='text-align: center;' colspan='2' width='372'> <p></p> </td> </tr> </tbody> </table> </div>";
        }
    }
}