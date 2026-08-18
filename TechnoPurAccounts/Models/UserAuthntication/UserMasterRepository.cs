using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DataAccessLayer;

namespace TechnoPurAccounts.Models.UserAuthntication
{
    public class UserMasterRepository : IDisposable
    {
        private return_orderEntities1 context = new return_orderEntities1();

        //This method is used to check and validate the user credentials
        public UserLogin ValidateUser(string username, string password)
        {
            
            //return context.login.FirstOrDefault(user =>
            //user.username.Equals(username, StringComparison.OrdinalIgnoreCase)
            //&& user.password == password.GetMD5HashData() );
            password = password.GetMD5HashData();
            var result = from co in context.logins
                         join ci in context.userroles on co.role_id equals ci.role_id
                         where (co.username.Equals(username, StringComparison.OrdinalIgnoreCase)  || co.email.Equals(username, StringComparison.OrdinalIgnoreCase)) && co.password == password
                         select new
                         {
                             co.login_id,
                             co.username,
                             co.email,
                             ci.role_id,
                             ci.role_name,
                             co.add_club_id,
                         };

            string status = "false";
            UserLogin l = new UserLogin();
            foreach (var item in result)
            {
                l.email = item.email;
                l.login_id = item.login_id;
                l.username = item.username;
                l.role_id = item.role_id;
                l.role_name = item.role_name;
                l.add_club_id = item.add_club_id;
                status = "true";
            }
           
            if (status=="true")
            {
             

                return l;
            }
            else
            {

                return null;
            }

        }
        public void Dispose()
        {
            context.Dispose();
        }
    }

}