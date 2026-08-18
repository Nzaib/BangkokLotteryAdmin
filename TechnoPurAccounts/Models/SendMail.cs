using DataAccessLayer;
using RestSharp;
using RestSharp.Authenticators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Web;

namespace TechnoPurAccounts.Models
{
    static public class SendMail
    {
        public static string funSendMail(string email, string subject, string body)
        {
            System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;
            // create the mail message
            MailMessage mail = new MailMessage();

            //set the addresses 
            mail.From = new MailAddress("sales@ecomreturnservice.com"); //IMPORTANT: This must be same as your smtp authentication address.
            mail.To.Add(email);

            //set the content 
            mail.Subject = subject;
            mail.Body = body;
            //send the message 
            SmtpClient smtp = new SmtpClient("sm15.internetmailserver.net");
            //SmtpClient smtp = new SmtpClient("mail.ecomreturnservice.com");

            //IMPORANT:  Your smtp login email MUST be same as your FROM address. 
            NetworkCredential Credentials = new NetworkCredential("sales@ecomreturnservice.com", "kj9Tzn3!sieUsx3");
            smtp.UseDefaultCredentials = false;
            smtp.Credentials = Credentials;
            smtp.Port = 25;    //alternative port number is 8889
            smtp.EnableSsl = false;



            try
            {
                smtp.Send(mail);
                return "OK";


            }
            catch (Exception ex)
            {
                return (ex.Message);

            }
        }



    }
}