using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin.Security.OAuth;

namespace TechnoPurAccounts.Models.UserAuthntication
{
    public class MyAuthorizationServerProvider : OAuthAuthorizationServerProvider
    {
        public override async Task ValidateClientAuthentication(OAuthValidateClientAuthenticationContext context)
        {
            context.Validated();
        }
        public override async Task GrantResourceOwnerCredentials(OAuthGrantResourceOwnerCredentialsContext context)
        {
            using (UserMasterRepository _repo = new UserMasterRepository())
            {
                var user = _repo.ValidateUser(context.UserName, context.Password);
                if (user == null)
                {
                    context.SetError("invalid_grant", "Provided username and password is incorrect");
                    return;
                }
                var identity = new ClaimsIdentity(context.Options.AuthenticationType);
                identity.AddClaim(new Claim(ClaimTypes.Role, user.role_name));
                identity.AddClaim(new Claim(ClaimTypes.Name, user.username));
                identity.AddClaim(new Claim("Email", user.email));
                identity.AddClaim(new Claim("login_id", user.login_id.ToString()));
                identity.AddClaim(new Claim("role_id", user.role_id.ToString()));
                identity.AddClaim(new Claim("role_name", user.role_name.ToString()));
                identity.AddClaim(new Claim("add_club_id", user.add_club_id.ToString()));

                context.Validated(identity);
            }
        }
    }
}