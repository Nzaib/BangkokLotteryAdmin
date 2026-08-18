using DataAccessLayer;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using TechnoPurAccounts.Models;

namespace TechnoPurAccounts.Controllers
{
    [System.Web.Http.Authorize]

    public class AddUserRoleController : ApiController
    {

        private return_orderEntities1 db = new return_orderEntities1();
        [Route("api/AddUserRole/GetUserRoles")]
        [HttpGet]
        public HttpResponseMessage GetUserRoles()
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {
                // Return List of Customer  
                var source = from c1 in db.userroles
                             where c1.role_id!=1
                             orderby c1.role_name
                             select c1;
                transaction.Commit();
                // Returing List of Customers Collections  
                return Request.CreateResponse(HttpStatusCode.OK, source);
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }
        [Route("api/AddUserRole/GetUserRoleHistory")]
        [HttpGet]
        public HttpResponseMessage GetUserRoleHistory([FromUri] PagingParameterModel pagingparametermodel)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {
                // Return List of Customer  
                var source = (from c1 in db.userroles
                              orderby c1.role_name
                              select new
                              {
                                  c1.role_name,
                                  id = c1.role_id,
                              }).AsQueryable();
                //Search Parameter [With null check]  
                // ------------------------------------ Search Parameter-------------------   

                if (!string.IsNullOrEmpty(pagingparametermodel.QuerySearch))
                {
                    string name = pagingparametermodel.QuerySearchColumn;
                    switch (name)
                    {
                        case "Role Name":
                            source = source.Where(a => a.role_name.Contains(pagingparametermodel.QuerySearch));
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

                // Display TotalCount to Records to UserRole  
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
        public class clsUserRoleInsert
        {
            public int id { get; set; }
            public string role_name { get; set; }
        }


        [Route("api/AddUserRole/UserRoleInsert")]
        [HttpPost]
        public HttpResponseMessage UserRoleInsert([FromBody] clsUserRoleInsert objclsUserRoleInsert)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                //var longin = (from comp in db.companies
                //              where (comp.email == objclsUserRoleInsert.email)
                //              select comp).SingleOrDefault();

                var longin2 = (from comp in db.userroles
                               where (comp.role_name == objclsUserRoleInsert.role_name)
                               select comp).SingleOrDefault();


                string userfoundstring = "";
                if (longin2 != null)
                {
                    userfoundstring = "Role Name Already Exist";
                }

                if (userfoundstring == "")
                {
                    userrole objcat1 = new userrole();
                    objcat1.role_name = objclsUserRoleInsert.role_name;
                    db.userroles.Add(objcat1);
                    db.SaveChanges();
                    transaction.Commit();
                    return Request.CreateResponse(HttpStatusCode.OK, "Role Name successfully Created");
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


        [Route("api/AddUserRole/UserRoleUpdate")]
        [HttpPut]
        public HttpResponseMessage UserRoleUpdate([FromBody] clsUserRoleInsert objclsUserRoleInsert)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.userroles
                              where (comp.role_id == objclsUserRoleInsert.id)
                              select comp).SingleOrDefault();



                if (longin != null)
                {
                    var longin2 = (from comp in db.userroles
                                   where (comp.role_name == objclsUserRoleInsert.role_name)
                                   select comp).SingleOrDefault();
                    string userfoundstring = "";
                    if (longin2 != null)
                    {
                        userfoundstring = "Role Name Already Exist";
                    }
                    if (userfoundstring == "")
                    {
                        longin.role_name = objclsUserRoleInsert.role_name;
                        db.SaveChanges();
                        transaction.Commit();
                        return Request.CreateResponse(HttpStatusCode.OK, "Role Name successfully Updated");
                    }
                    else
                    {
                        return Request.CreateResponse(HttpStatusCode.Found, userfoundstring);
                    }
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

        [Route("api/AddUserRole/UserRoleDelete")]
        [HttpDelete]
        public HttpResponseMessage UserRoleDelete(int id)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.userroles
                              where (comp.role_id == id)
                              select comp).SingleOrDefault();


                if (longin != null)
                {

                    var longin_table =
           from details in db.userroles
           where details.role_id == id
           select details;
                    db.userroles.RemoveRange(longin_table);
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
    }
}
