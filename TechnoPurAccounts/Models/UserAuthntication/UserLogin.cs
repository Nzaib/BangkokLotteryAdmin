using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace TechnoPurAccounts.Models.UserAuthntication
{
    public class UserLogin
    {
        public int login_id { get; set; }
        public string username { get; set; }
        public string email { get; set; }
        public int role_id { get; set; }
        public string role_name { get; set; }
        public int add_club_id { get; set; }
    }
}