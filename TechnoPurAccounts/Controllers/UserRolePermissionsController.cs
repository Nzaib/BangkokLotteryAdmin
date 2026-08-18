using System;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using DataAccessLayer;
using TechnoPurAccounts.Models;
using Newtonsoft.Json;
using System.Web;
using System.Security.Claims;

namespace TechnoPurAccounts.Controllers
{


    public class UserRolePermissionsController : ApiController
    {
        private return_orderEntities1 db = new return_orderEntities1();

        #region AddUserRole
        [Route("api/AddNewRole/GetAddNewRoleHistory")]
        [HttpGet]
        public HttpResponseMessage GetAddNewRoleHistory([FromUri] PagingParameterModel pagingparametermodel)
        {
            // Return List of Customer  
            var source = (from c1 in db.userroles
                          orderby c1.role_name
                          select c1).AsQueryable();
            //Search Parameter [With null check]  
            // ------------------------------------ Search Parameter-------------------   

            if (!string.IsNullOrEmpty(pagingparametermodel.QuerySearch))
            {
                string name = pagingparametermodel.QuerySearchColumn.ToString();
                source = source.Where(a => a.role_name.Contains(pagingparametermodel.QuerySearch));
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
            // Returing List of Customers Collections  

            return Request.CreateResponse(HttpStatusCode.OK, responsedata);
        }

        [Route("api/AddNewRole/GetAddNewRole")]
        [HttpGet]
        public HttpResponseMessage GetAddNewRole()
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                // Return List of Customer  
                var source = from c1 in db.userroles
                             select c1;
                // Returing List of Customers Collections  
                transaction.Commit();
                return Request.CreateResponse(HttpStatusCode.OK, source);
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }

        [Route("api/AddNewRole/AddNewRoleInsert")]
        [HttpPost]
        public HttpResponseMessage AddNewRoleInsert([FromBody] userrole objclsAddNewRole)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.userroles
                              where (comp.role_name == objclsAddNewRole.role_name)
                              select comp).SingleOrDefault();
                string userfoundstring = "";

                if (longin != null)
                {
                    userfoundstring = " Already Exist";
                }
                if (userfoundstring == "")
                {
                    userrole objadd_new_column = new userrole();
                    objadd_new_column.role_name = objclsAddNewRole.role_name;
                    db.userroles.Add(objadd_new_column);
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


        [Route("api/AddNewRole/AddNewRoleUpdate")]
        [HttpPut]
        public HttpResponseMessage AddNewRoleUpdate([FromBody] userrole objclsAddNewRole)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.userroles
                              where (comp.role_id == objclsAddNewRole.role_id)
                              select comp).SingleOrDefault();
                if (longin != null)
                {
                    longin.role_name = objclsAddNewRole.role_name;
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
        [Route("api/AddNewRole/AddNewRoleDelete")]
        [HttpDelete]
        public HttpResponseMessage AddNewRoleDelete(int role_id)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.userroles
                              where (comp.role_id == role_id)
                              select comp).SingleOrDefault();
                if (longin != null)
                {
                    var tabmanual_journal_entry =
                from details in db.userroles
                where details.role_id == role_id
                select details;
                    db.userroles.RemoveRange(tabmanual_journal_entry);
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
        #endregion


        #region AddModule
        [Route("api/AddNewModule/GetAddNewModuleHistory")]
        [HttpGet]
        public HttpResponseMessage GetAddNewModuleHistory([FromUri] PagingParameterModel pagingparametermodel)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                // Return List of Customer  
                var source = (from c1 in db.Module_info
                              orderby c1.@orderby

                              select c1).AsQueryable();
                //Search Parameter [With null check]  
                // ------------------------------------ Search Parameter-------------------   

                if (!string.IsNullOrEmpty(pagingparametermodel.QuerySearch))
                {
                    string name = pagingparametermodel.QuerySearchColumn.ToString();
                    source = source.Where(a => a.module_name.Contains(pagingparametermodel.QuerySearch));
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
                // Returing List of Customers Collections  
                transaction.Commit();

                return Request.CreateResponse(HttpStatusCode.OK, responsedata);

            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }

        [Route("api/AddNewModule/GetAddNewModule")]
        [HttpGet]
        public HttpResponseMessage GetAddNewModule()
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                // Return List of Customer  
                var source = from c1 in db.Module_info
                             select c1;
                // Returing List of Customers Collections  
                transaction.Commit();
                return Request.CreateResponse(HttpStatusCode.OK, source);
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }

        [Route("api/AddNewModule/AddNewModuleInsert")]
        [HttpPost]
        public HttpResponseMessage AddNewModuleInsert([FromBody] Module_info objclsAddNewModule)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.Module_info
                              where (comp.module_name == objclsAddNewModule.module_name)
                              select comp).SingleOrDefault();
                string userfoundstring = "";

                if (longin != null)
                {
                    userfoundstring = " Already Exist";
                }
                if (userfoundstring == "")
                {
                    Module_info objadd_new_column = new Module_info();
                    objadd_new_column.module_name = objclsAddNewModule.module_name;
                    objadd_new_column.module_icon = objclsAddNewModule.module_icon;
                    objadd_new_column.module_URL = objclsAddNewModule.module_URL;
                    objadd_new_column.module_nestted_list = objclsAddNewModule.module_nestted_list;
                    objadd_new_column.orderby = objclsAddNewModule.orderby;
                    db.Module_info.Add(objadd_new_column);
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


        [Route("api/AddNewModule/AddNewModuleUpdate")]
        [HttpPut]
        public HttpResponseMessage AddNewModuleUpdate([FromBody] Module_info objclsAddNewModule)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.Module_info
                              where (comp.module_id == objclsAddNewModule.module_id)
                              select comp).SingleOrDefault();
                if (longin != null)
                {

                    longin.module_name = objclsAddNewModule.module_name;
                    longin.module_icon = objclsAddNewModule.module_icon;
                    longin.module_URL = objclsAddNewModule.module_URL;
                    longin.module_nestted_list = objclsAddNewModule.module_nestted_list;
                    longin.orderby = objclsAddNewModule.orderby;
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
        [Route("api/AddNewModule/AddNewModuleDelete")]
        [HttpDelete]
        public HttpResponseMessage AddNewModuleDelete(int module_id)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.Module_info
                              where (comp.module_id == module_id)
                              select comp).SingleOrDefault();
                if (longin != null)
                {
                    var tabmanual_journal_entry =
                from details in db.Module_info
                where details.module_id == module_id
                select details;
                    db.Module_info.RemoveRange(tabmanual_journal_entry);
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
        #endregion




        #region AddPageInfo
        [Route("api/AddNewPage/GetAddNewPageHistory")]
        [HttpGet]
        public HttpResponseMessage GetAddNewPageHistory([FromUri] PagingParameterModel pagingparametermodel)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                // Return List of Customer  
                var source = (from c1 in db.page_info
                              orderby c1.@orderby
                              select new
                              {
                                  c1.page_id,
                                  c1.page_name,
                                  c1.page_icon,
                                  c1.page_url,
                                  c1.module_id,
                                  c1.@orderby,
                                  module_name = (from e in db.Module_info
                                                 where e.module_id == c1.module_id
                                                 select e.module_name).FirstOrDefault(),
                              }

                              ).AsQueryable();
                //Search Parameter [With null check]  
                // ------------------------------------ Search Parameter-------------------   

                if (!string.IsNullOrEmpty(pagingparametermodel.QuerySearch))
                {
                    string name = pagingparametermodel.QuerySearchColumn.ToString();
                    source = source.Where(a => a.page_name.Contains(pagingparametermodel.QuerySearch));
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
                // Returing List of Customers Collections  
                transaction.Commit();

                return Request.CreateResponse(HttpStatusCode.OK, responsedata);

            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }

        [Route("api/AddNewPage/GetAddNewPage")]
        [HttpGet]
        public HttpResponseMessage GetAddNewPage()
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                // Return List of Customer  
                var source = from c1 in db.page_info
                             select c1;
                // Returing List of Customers Collections  
                transaction.Commit();
                return Request.CreateResponse(HttpStatusCode.OK, source);
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }

        [Route("api/AddNewPage/AddNewPageInsert")]
        [HttpPost]
        public HttpResponseMessage AddNewPageInsert([FromBody] page_info objclsAddNewPage)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.page_info
                              where (comp.page_name == objclsAddNewPage.page_name && comp.module_id == objclsAddNewPage.module_id)
                              select comp).SingleOrDefault();
                string userfoundstring = "";

                if (longin != null)
                {
                    userfoundstring = " Already Exist";
                }
                if (userfoundstring == "")
                {
                    page_info objadd_new_column = new page_info();
                    objadd_new_column.page_name = objclsAddNewPage.page_name;
                    objadd_new_column.page_icon = objclsAddNewPage.page_icon;
                    objadd_new_column.page_url = objclsAddNewPage.page_url;
                    objadd_new_column.module_id = objclsAddNewPage.module_id;
                    objadd_new_column.orderby = objclsAddNewPage.orderby;
                    db.page_info.Add(objadd_new_column);
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


        [Route("api/AddNewPage/AddNewPageUpdate")]
        [HttpPut]
        public HttpResponseMessage AddNewPageUpdate([FromBody] page_info objclsAddNewPage)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.page_info
                              where (comp.page_id == objclsAddNewPage.page_id)
                              select comp).SingleOrDefault();
                if (longin != null)
                {

                    longin.page_name = objclsAddNewPage.page_name;
                    longin.page_icon = objclsAddNewPage.page_icon;
                    longin.page_url = objclsAddNewPage.page_url;
                    longin.module_id = objclsAddNewPage.module_id;
                    longin.orderby = objclsAddNewPage.orderby;
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
        [Route("api/AddNewPage/AddNewPageDelete")]
        [HttpDelete]
        public HttpResponseMessage AddNewPageDelete(int page_id)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                var longin = (from comp in db.page_info
                              where (comp.page_id == page_id)
                              select comp).SingleOrDefault();
                if (longin != null)
                {
                    var tabmanual_journal_entry =
                from details in db.page_info
                where details.page_id == page_id
                select details;
                    db.page_info.RemoveRange(tabmanual_journal_entry);
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
        #endregion






        #region SetUserPagesPermissions

        [Route("api/SetUserPagesPermissions/GetAllUsers")]
        [HttpGet]
        public HttpResponseMessage GetAllUsers()
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {

                // Return List of Customer  
                var source = from c1 in db.logins
                             select new
                             {
                                 c1.username,
                                 c1.login_id,
                             };
                // Returing List of Customers Collections  
                transaction.Commit();
                return Request.CreateResponse(HttpStatusCode.OK, source);
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }



        public class ClsGetUserRolePermissionIdWise
        {
            public int role_id { get; set; }
            public int login_id { get; set; }
            public int module_id { get; set; }
            public int page_id { get; set; }
            public string page_name { get; set; }
            public string module_name { get; set; }
            public string status { get; set; }
        }

        [Route("api/SetUserPagesPermissions/GetUserRolePermissionIdWise")]
        [HttpGet]
        public HttpResponseMessage GetUserRolePermissionIdWise(int login_id)
        {
            try
            {
                string query = "SELECT   user_p.login_id, vg.module_id, vg.module_name, vg.page_id, vg.page_name, user_p.status FROM            dbo.View_GetPages AS vg LEFT OUTER JOIN dbo.user_permission AS user_p ON user_p.page_id = vg.page_id and user_p.login_id='" + login_id + "'";
                var source = (db.Database.SqlQuery<View_GetUserPermissions>(query).ToList()).AsQueryable();
                return Request.CreateResponse(HttpStatusCode.OK, source);
            }
            catch (Exception ex)
            {
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }

        [Route("api/SetUserPagesPermissions/GetRolePermissionIdWise")]
        [HttpGet]
        public HttpResponseMessage GetRolePermissionIdWise(int role_id)
        {
            try
            {
                string query = "SELECT   user_p.role_id,  user_p.login_id,vg.module_id, vg.module_name, vg.page_id, vg.page_name, user_p.status FROM            dbo.View_GetPages AS vg LEFT OUTER JOIN dbo.user_permission AS user_p ON user_p.page_id = vg.page_id and user_p.role_id='" + role_id + "'";
                var source = (db.Database.SqlQuery<View_GetUserPermissions>(query).ToList()).AsQueryable();
                return Request.CreateResponse(HttpStatusCode.OK, source);
            }
            catch (Exception ex)
            {
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }

        public class ClsUpdatePermission
        {
            public int module_id { get; set; }
            public int page_id { get; set; }
        }

        [Route("api/SetUserPagesPermissions/UpdatePermission")]
        [HttpPost]
        public HttpResponseMessage UpdatePermission(int login_id, ClsUpdatePermission[] objClsUpdatePermission)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {
                var tabmanual_journal_entry =
                 from details in db.user_permission
                 where details.login_id == login_id
                 select details;
                db.user_permission.RemoveRange(tabmanual_journal_entry);
                db.SaveChanges();


                foreach (var item in objClsUpdatePermission)
                {
                    user_permission objadd_new_column = new user_permission();
                    objadd_new_column.module_id = item.module_id;
                    objadd_new_column.page_id = item.page_id;
                    objadd_new_column.login_id = login_id;
                    objadd_new_column.status = true;
                    db.user_permission.Add(objadd_new_column);
                    db.SaveChanges();
                }


                transaction.Commit();
                return Request.CreateResponse(HttpStatusCode.OK, "Update");
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }

        [Route("api/SetUserPagesPermissions/UpdaterolePermission")]
        [HttpPost]
        public HttpResponseMessage UpdaterolePermission(int role_id, ClsUpdatePermission[] objClsUpdatePermission)
        {
            DbContextTransaction transaction = db.Database.BeginTransaction();
            try
            {
                var tabmanual_journal_entry =
                 from details in db.user_permission
                 where details.role_id == role_id
                 select details;
                db.user_permission.RemoveRange(tabmanual_journal_entry);
                db.SaveChanges();


                foreach (var item in objClsUpdatePermission)
                {
                    user_permission objadd_new_column = new user_permission();
                    objadd_new_column.module_id = item.module_id;
                    objadd_new_column.page_id = item.page_id;
                    objadd_new_column.role_id = role_id;
                    objadd_new_column.status = true;
                    db.user_permission.Add(objadd_new_column);
                    db.SaveChanges();
                }


                transaction.Commit();
                return Request.CreateResponse(HttpStatusCode.OK, "Update");
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }


        [Route("api/GetRolePermission")]
        [HttpGet]
        public HttpResponseMessage GetRolePermission()
        {
            var identity = (ClaimsIdentity)User.Identity;
            var role_name = (identity.Claims
                           .FirstOrDefault(c => c.Type == "role_name").Value);
            var loginId = (identity.Claims
               .FirstOrDefault(c => c.Type == "role_id").Value);
            int chartId, RoleId;
            try { RoleId = Convert.ToInt16(loginId); } catch (Exception) { RoleId = 0; };


            try
            {
                var source = from c1 in db.View_GetUserPermissionModule
                             where c1.role_id == RoleId
                             select new
                             {
                                 c1.module_id,
                                 c1.module_name,
                                 c1.module_icon,
                                 c1.module_URL,
                                 c1.module_nestted_list,
                                 permission_pages = (from comp in db.user_permission
                                                     join c in db.page_info on comp.page_id equals c.page_id
                                                     where c1.module_id == comp.module_id && comp.role_id==RoleId
                                                     select c)
                             };





                return Request.CreateResponse(HttpStatusCode.OK, source);
            }
            catch (Exception ex)
            {
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }

        [Route("api/CheckUserPagePermission")]
        [HttpGet]
        public HttpResponseMessage CheckUserPagePermission(string PageUrl)
        {
            var identity = (ClaimsIdentity)User.Identity;
            var role_name = (identity.Claims
                           .FirstOrDefault(c => c.Type == "role_name").Value);
            var loginId = (identity.Claims
               .FirstOrDefault(c => c.Type == "role_id").Value);
            int chartId, RoleId;
            try { RoleId = Convert.ToInt16(loginId); } catch (Exception) { RoleId = 0; };


            try
            {


                var longin = (from comp in db.user_permission
                              join c in db.page_info on comp.page_id equals c.page_id
                              where c.page_url == PageUrl && comp.role_id == RoleId && comp.status == true
                              select c).SingleOrDefault();
                if (longin != null)
                {
                    return Request.CreateResponse(HttpStatusCode.OK, "true");
                }
                else
                {
                    return Request.CreateResponse(HttpStatusCode.OK, "false");
                }
            }
            catch (Exception ex)
            {
                var message = Request.CreateResponse(HttpStatusCode.InternalServerError);
                return message;
            }
        }

        //[Route("api/AddNewRole/GetModulePages")]
        //[HttpGet]
        //public HttpResponseMessage GetModulePages()
        //{
        //    // Return List of Customer  
        //    var source = from c1 in db.Module_info
        //                 select new
        //                 {
        //                     c1,
        //                     all_pages = (from c2 in db.Module_info )
        //                 };
        //    // Returing List of Customers Collections  
        //    return Request.CreateResponse(HttpStatusCode.OK, source);
        //}


        #endregion

    }
}