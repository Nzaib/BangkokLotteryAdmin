using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace TechnoPurAccounts.Models
{
    public static class MD5
    {
static public DateTime USADateTime = DateTime.UtcNow.AddHours(-5);
        public static string GetMD5HashData(this string data)
        {
            //create new instance of md5
            System.Security.Cryptography.MD5 md5 = System.Security.Cryptography.MD5.Create();
            //convert the input text to array of bytes
            byte[] hashData = md5.ComputeHash(Encoding.Default.GetBytes(data));
            //create new instance of StringBuilder to save hashed data
            StringBuilder returnValue = new StringBuilder();
            //loop for each byte and add it to StringBuilder
            for (int i = 0; i < hashData.Length; i++)
            {
                returnValue.Append(hashData[i].ToString());
            }
            // return hexadecimal string
            return returnValue.ToString();
        }
    }
}