using System;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using DataAccessLayer;
using TechnoPurAccounts.Models;
using System.Web;
using Newtonsoft.Json;
using System.Security.Claims;

namespace TechnoPurAccounts.Controllers
{
    [System.Web.Http.Authorize]
    public class AddUserController : ApiController
    {
        private return_orderEntities1 db = new return_orderEntities1();


        [Route("api/AddUser/GetUserHistory")]
        [HttpGet]
        public HttpResponseMessage GetUserHistory([FromUri] PagingParameterModel pagingparametermodel)
        {


            var identity = (ClaimsIdentity)User.Identity;
            var login_id2 = (identity.Claims
                 .FirstOrDefault(c => c.Type == "login_id").Value);
            var add_club_id1 = (identity.Claims
               .FirstOrDefault(c => c.Type == "add_club_id").Value);
            int logId, add_club_id;
            try { logId = Convert.ToInt16(login_id2); } catch (Exception) { logId = 0; }
            try { add_club_id = Convert.ToInt16(add_club_id1); } catch (Exception) { add_club_id = 0; }


            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {
                // Return List of Customer  
                var source = (from c1 in db.logins
                              orderby c1.date
                              select new
                              {
                                  c1.username,
                                  c1.password,
                                  c1.email,
                                  c1.login_id,
                                  c1.role_id,
                                  c1.withouthashpassword,
                                  role_name = (from e in db.userroles
                                               where c1.role_id == e.role_id
                                               select e.role_name).FirstOrDefault(),
                              }).AsQueryable();
                //Search Parameter [With null check]  
                // ------------------------------------ Search Parameter-------------------   

                if (!string.IsNullOrEmpty(pagingparametermodel.QuerySearch))
                {
                    string name = pagingparametermodel.QuerySearchColumn;
                    switch (name)
                    {
                        case "User Name":
                            source = source.Where(a => a.username.Contains(pagingparametermodel.QuerySearch));
                            break;
                    }
                }

                // ------------------------------------ Search Parameter-------------------  
                // Get's No of Rows Count   
                int count = source.Count();

                // Parameter is passed from Query string if it is null then it default Value will be pageNumber:1  
                int CurrentPage = pagingparametermodel.pageNumber;

                // Parameter is passed from Query string if it is null then it default Value will be pageSize:20  
                int PageSize = pagingparametermodel.pageSize;

                // Display TotalCount to Records to User  
                int TotalCount = count;

                // Calculating Totalpage by Dividing (No of Records / Pagesize)  
                int TotalPages = (int)Math.Ceiling(count / (double)PageSize);

                // Returns List of Customer after applying Paging   
                var jsonretrundata = source.Skip((CurrentPage - 1) * PageSize).Take(PageSize).ToList();

                // if CurrentPage is greater than 1 means it has previousPage  
                var previousPage = CurrentPage > 1 ? "Yes" : "No";

                // if TotalPages is greater than CurrentPage means it has nextPage  
                var nextPage = CurrentPage < TotalPages ? "Yes" : "No";

                // Object which we are going to send in header   
                var paginationMetadata = new
                {
                    totalCount = TotalCount,
                    pageSize = PageSize,
                    currentPage = CurrentPage,
                    totalPages = TotalPages,
                    previousPage,
                    nextPage
                };
                var responsedata = new
                {
                    jsonretrundata,
                    paginationMetadata,
                };
                // Setting Header  
                HttpContext.Current.Response.Headers.Add("Paging-Headers", JsonConvert.SerializeObject(paginationMetadata));
                transaction.Commit();
                // Returing List of Customers Collections  
                return Request.CreateResponse(HttpStatusCode.OK, responsedata);


            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }
        public class clsUserInsert
        {
            public string username { get; set; }
            public string password { get; set; }
            public string email { get; set; }
            public string type { get; set; }
            public int role_id { get; set; }
            public int login_id { get; set; }
        }


        [Route("api/AddUser/UserInsert")]
        [HttpPost]
        public HttpResponseMessage UserInsert([FromBody] clsUserInsert objclsUserInsert)
        {
            var identity = (ClaimsIdentity)User.Identity;
            var login_id2 = (identity.Claims
                 .FirstOrDefault(c => c.Type == "login_id").Value);
            var add_club_id1 = (identity.Claims
               .FirstOrDefault(c => c.Type == "add_club_id").Value);
            int logId, add_club_id;
            try { logId = Convert.ToInt16(login_id2); } catch (Exception) { logId = 0; }
            try { add_club_id = Convert.ToInt16(add_club_id1); } catch (Exception) { add_club_id = 0; }

            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                //var longin = (from comp in db.companies
                //              where (comp.email == objclsUserInsert.email)
                //              select comp).SingleOrDefault();

                var longin2 = (from comp in db.logins
                               where (comp.username == objclsUserInsert.username || comp.email == objclsUserInsert.email)
                               select comp).SingleOrDefault();


                string userfoundstring = "";
                if (longin2 != null)
                {
                    userfoundstring = "User Name Already Exist";
                }

                if (userfoundstring == "")
                {
                    DateTime today = DateTime.Today;
                    login objlogin = new login();
                    objlogin.username = objclsUserInsert.username;
                    objlogin.password = objclsUserInsert.password.GetMD5HashData();
                    objlogin.withouthashpassword = objclsUserInsert.password;
                    objlogin.email = objclsUserInsert.email;
                    objlogin.role_id = objclsUserInsert.role_id;
                    objlogin.date = today;
                    db.logins.Add(objlogin);
                    db.SaveChanges();
                    transaction.Commit();
                    return Request.CreateResponse(HttpStatusCode.OK, "Created");
                }
                else
                {
                    return Request.CreateResponse(HttpStatusCode.Found, userfoundstring);
                }
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }


        [Route("api/AddUser/UserUpdate")]
        [HttpPut]
        public HttpResponseMessage UserUpdate([FromBody] clsUserInsert objclsUserInsert)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.logins
                              where (comp.login_id == objclsUserInsert.login_id)
                              select comp).SingleOrDefault();


                if (longin != null)
                {

                    longin.username = objclsUserInsert.username;
                    longin.password = objclsUserInsert.password.GetMD5HashData();
                    longin.withouthashpassword = objclsUserInsert.password;
                    longin.email = objclsUserInsert.email;
                    longin.role_id = objclsUserInsert.role_id;
                    db.SaveChanges();
                    transaction.Commit();

                    return Request.CreateResponse(HttpStatusCode.OK, "Updated");
                }
                else
                {
                    return Request.CreateResponse(HttpStatusCode.NotFound, "Not Found");
                }
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }

        public class ClsClsUpdatePassword
        {
            public string newpassword { get; set; }
            public string oldpassword { get; set; }
        }

        [Route("api/AddUser/UpdatePassword")]
        [HttpPut]
        public HttpResponseMessage UpdatePassword([FromBody] ClsClsUpdatePassword objclsUserInsert)
        {
            var identity = (ClaimsIdentity)User.Identity;
            var login_id2 = (identity.Claims
                 .FirstOrDefault(c => c.Type == "login_id").Value);
            var role_id = (identity.Claims
                .FirstOrDefault(c => c.Type == "role_id").Value);


            int logId, roleid;
            try { logId = Convert.ToInt16(login_id2); } catch (Exception) { logId = 0; }
            try { roleid = Convert.ToInt16(role_id); } catch (Exception) { roleid = 0; }

            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.logins
                              where (comp.login_id == logId && comp.withouthashpassword== objclsUserInsert.oldpassword)
                              select comp).SingleOrDefault();
                if (longin != null)
                {
                    longin.password = objclsUserInsert.newpassword.GetMD5HashData();
                    longin.withouthashpassword = objclsUserInsert.newpassword;
                    db.SaveChanges();
                    transaction.Commit();
                    return Request.CreateResponse(HttpStatusCode.OK, "Updated");
                }
                else
                {
                    return Request.CreateResponse(HttpStatusCode.NotFound, "Password Not Match");
                }
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }
        [Route("api/AddUser/UserDelete")]
        [HttpDelete]
        public HttpResponseMessage UserDelete(int id)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.logins
                              where (comp.login_id == id)
                              select comp).SingleOrDefault();


                if (longin != null)
                {

                    var longin_table =
           from details in db.logins
           where details.login_id == id
           select details;
                    db.logins.RemoveRange(longin_table);
                    db.SaveChanges();
                    transaction.Commit();

                    return Request.CreateResponse(HttpStatusCode.OK, "Deleted");
                }
                else
                {
                    return Request.CreateResponse(HttpStatusCode.NotFound, "Not Found");
                }
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }


        //[Route("api/AddUser/GetUserIdWise")]
        //[HttpGet]
        //public HttpResponseMessage GetUserIdWise(int id)
        //{
        //    try
        //    {
        //        var longin = from comp in db.logins
        //                     where (comp.login_id == id)
        //                     select comp;
        //        return Request.CreateResponse(HttpStatusCode.OK, longin);
        //    }
        //    catch (Exception ex)
        //    {
        //        var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
        //        return message;
        //    }
        //}

    }
}