<%@ Page Title="" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="UserInfo.aspx.cs" Inherits="TechnoPurAccounts.UserRolePermissions.UserInfo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <title>Add Asin</title>
    <script>
        var module_id = 0;
        var page_id = 0;
        var role_id = 0;

        $(document).ready(function () {

            $('button').css('border-radius', '0px');
            $('input').css('border-radius', '0px');
            $('.modal-content').css('border-radius', '0px');
            showStdInfoModule(1, 10, "AddModule", "", "");
            showStdInfoPage(1, 10, "AddPage", "", "");
            showStdInfoRole(1, 10, "AddRole", "", "");
            GetAllRoles()

            $('.divhide').hide();
            //Insert Teacher Info Script
            $('#btnnewasinsubmitAddModule').on('click', function () {
                clearallboxModule()
            });
            $('#btnasinsubmitModule').on('click', function () {
                var btn = $(this);
                btn.prop('disabled', true);
                setTimeout(function () {
                    btn.prop('disabled', false);
                }, 1000);

                SaveModule("submit");

            });
            $('#btnasinupdateModule').on('click', function () {
                var btn = $(this);
                btn.prop('disabled', true);
                setTimeout(function () {
                    btn.prop('disabled', false);
                }, 1000);

                SaveModule("update");

            });
            //Get data in pop-up
            $(document).on('click', '.editStdInfoModule', function () {
                clearallboxModule()
                $('#btnasinsubmitModule').hide();
                $('#btnasinupdateModule').show();
                $('#insertHeadModule').hide();
                $('#updateHeadModule').show();

                module_id = ($(this).attr("id"));
                var $tr = $(this).closest('tr');
                $('#txtModuleName').val($tr.find('td:nth-child(2)').text());
                $('#txtModuleFontIcon').val($tr.find('td:nth-child(3)').text());
                $('#txtModuleURL').val($tr.find('td:nth-child(4)').text());
                $('#txtserstatus').val($tr.find('td:nth-child(5)').text());
                $('#txtModuleOrderby').val($tr.find('td:nth-child(6)').text());


                if ($tr.find('td:nth-child(5)').text() == "true") {
                    $('#txtserstatus').val("true");
                }
                else {
                    $('#txtserstatus').val("false");
                }
                $('#txtModuleOrderby').val($tr.find('td:nth-child(6)').text());
                $(".select2").select2({
                    placeholder: "",
                    allowClear: true
                });
            });
            $(document).on('click', '.delstdinfoModule', function () {
                module_id = ($(this).attr("id"));
                SaveModule("delete");
            });

            //Page Info Start

            $('#btnnewasinsubmitAddPage').on('click', function () {
                clearallboxPage()
            });
            $('#btnasinsubmitPage').on('click', function () {
                var btn = $(this);
                btn.prop('disabled', true);
                setTimeout(function () {
                    btn.prop('disabled', false);
                }, 1000);

                SavePage("submit");

            });
            $('#btnasinupdatePage').on('click', function () {
                var btn = $(this);
                btn.prop('disabled', true);
                setTimeout(function () {
                    btn.prop('disabled', false);
                }, 1000);

                SavePage("update");

            });
            //Get data in pop-up
            $(document).on('click', '.editStdInfoPage', function () {
                clearallboxPage();
                $('#btnasinsubmitPage').hide();
                $('#btnasinupdatePage').show();
                $('#insertHeadPage').hide();
                $('#updateHeadPage').show();

                page_id = ($(this).attr("id"));
                var $tr = $(this).closest('tr');
                $('#ddlModuleName').val($tr.find('td:nth-child(2)').attr('id'));
                $('#txtPageName').val($tr.find('td:nth-child(3)').text());
                $('#txtPageFontIcon').val($tr.find('td:nth-child(4)').text());
                $('#txtPageURL').val($tr.find('td:nth-child(5)').text());
                $('#txtPageOrderby').val($tr.find('td:nth-child(6)').text());
                $(".select2").select2({
                    placeholder: "",
                    allowClear: true
                });
            });
            $(document).on('click', '.delstdinfoPage', function () {
                page_id = ($(this).attr("id"));
                SavePage("delete");
            });

            //Page Info End

            //Role Info Start

            $('#btnnewasinsubmitAddRole').on('click', function () {
                clearallboxRole()
            });
            $('#btnasinsubmitRole').on('click', function () {
                var btn = $(this);
                btn.prop('disabled', true);
                setTimeout(function () {
                    btn.prop('disabled', false);
                }, 1000);

                SaveRole("submit");

            });
            $('#btnasinupdateRole').on('click', function () {
                var btn = $(this);
                btn.prop('disabled', true);
                setTimeout(function () {
                    btn.prop('disabled', false);
                }, 1000);

                SaveRole("update");

            });
            //Get data in pop-up
            $(document).on('click', '.editStdInfoRole', function () {
                clearallboxRole()
                $('#btnasinsubmitRole').hide();
                $('#btnasinupdateRole').show();
                $('#insertHeadRole').hide();
                $('#updateHeadRole').show();

                role_id = ($(this).attr("id"));
                var $tr = $(this).closest('tr');
                $('#txtRoleName').val($tr.find('td:nth-child(2)').text());
            });
            $(document).on('click', '.delstdinfoRole', function () {
                role_id = ($(this).attr("id"));
                SaveRole("delete");
            });

            //Role Info End
            //$(document).on('change', '#ddlSelectUser', function () {
            //    $('.divhide').show();
            //    GetUserRolePermissionIdWise()

            //});

            $(document).on('change', '#ddlSelectRole', function () {
                $('.divhide').show();
                GetUserRolePermissionIdWise()

            });
            $(document).on('click', '#btnUpdateUserPermissions', function () {
                UpdatePermission()
            });



        });


        function SaveModule(submittype) {
            var apipath = "api/AddNewModule/AddNewModuleInsert";
            var apimethod = "Post";
            if (submittype == "update") {
                apipath = "api/AddNewModule/AddNewModuleUpdate";
                apimethod = "Put";
            }

            else if (submittype == "delete") {
                apipath = "api/AddNewModule/AddNewModuleDelete?module_id=" + module_id;
                apimethod = "Delete";
            }


            var Module_info = {};


            if (submittype != "delete") {
                if ($('#txtModuleName').val() == "") {
                    toastr["error"]("Enter Module Name is required");
                    $('#txtModuleName').focus();
                    return false;
                }

                Module_info.module_name = $('#txtModuleName').val();
                Module_info.module_icon = $('#txtModuleFontIcon').val();
                Module_info.module_URL = $('#txtModuleURL').val();
                Module_info.module_nestted_list = $('#txtserstatus').val();
                Module_info.orderby = $('#txtModuleOrderby').val();
                Module_info.module_id = module_id;
            }

            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + apipath,
                async: false,
                method: apimethod,
                contentType: 'application/json;charset=utf-8',
                data: JSON.stringify(Module_info),
                success: function (data, textStatus, jqXHR) {
                    if (jqXHR.status == "200") {
                        clearallboxModule();
                        swal({
                            title: "Done",
                            text: jqXHR.responseJSON,
                            icon: "success",
                        });
                        showStdInfoModule(1, 10, "AddModule", "", "");

                        if (submittype != "delete") {
                            $('#myModalAddModule').modal('toggle');
                        }
                    }

                },
                error: function (jqXHR, exception) {
                    if (jqXHR.status == 302) {
                        toastr["info"](jqXHR.responseJSON);
                    }
                    else {
                        toastr["error"](jqXHR.responseJSON);
                    }
                }
            });
        }
        function clearallboxModule() {
            $('#txtModuleName').val("");
            $('#txtModuleFontIcon').val("");
            $('#txtModuleURL').val("");
            $('#txtserstatus').val("true");
            $('#txtModuleOrderby').val("");
            $('#btnasinsubmitModule').show();
            $('#btnasinupdateModule').hide();
            $('#insertHeadModule').show();
            $('#updateHeadModule').hide();
            $(".select2").select2({
                placeholder: "",
                allowClear: true
            });
        }
        function showStdInfoModule(pageNumber, pageSize, divide, searchtext, textsearchcolumnvalue) {
            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + "api/AddNewModule/GetAddNewModuleHistory?pageNumber=" + pageNumber + "&pageSize=" + pageSize + "&QuerySearch=" + searchtext + "&QuerySearchColumn=" + textsearchcolumnvalue + "&login_id=" + localStorage["login_id"],
                async: false,
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    var voucherOptions = $('#' + divide + ' #tablerows');
                    voucherOptions.empty();

                    if (data.jsonretrundata.length > 0) {


                        $(data.jsonretrundata).each(function (index, infostd) {
                            voucherOptions.append('<tr><td>' + (index + 1) + '</td> <td>' + removenullvalue(infostd.module_name) + '</td><td>' + removenullvalue(infostd.module_icon) + '</td><td>' + removenullvalue(infostd.module_URL) + '</td> <td>' + removenullvalue(infostd.module_nestted_list) + '</td><td>' + removenullvalue(infostd.orderby) + '</td><td><button type="button" class="btn btn-success editStdInfoModule " data-toggle="modal" data-target="#myModalAddModule" style="border-radius:0px;"  id="' + removenullvalue(infostd.module_id) + '">Edit</button> </td><td><button type="button" class="btn btn-danger delstdinfoModule" style="border-radius:0px;"  id="' + removenullvalue(infostd.module_id) + '">Delete</button> </td> </tr>');
                        });
                        generatepagination(data.paginationMetadata, divide, "tablerows", "showStdInfoModule", "", "")
                    } else {
                        generatepagination(data.paginationMetadata, divide, "tablerows", "showStdInfoModule", "", "")
                    }

                },
                error: function (jqXHR, exception) {
                    msg = 'Internal Server Error [500].';
                    swal({
                        type: 'error',
                        title: 'Oops...',
                        text: msg,
                        showConfirmButton: false,
                        timer: 2000
                    });
                }
            });
        }



        //Page Info Start
        function SavePage(submittype) {
            var apipath = "api/AddNewPage/AddNewPageInsert";
            var apimethod = "Post";
            if (submittype == "update") {
                apipath = "api/AddNewPage/AddNewPageUpdate";
                apimethod = "Put";
            }

            else if (submittype == "delete") {
                apipath = "api/AddNewPage/AddNewPageDelete?page_id=" + page_id;
                apimethod = "Delete";
            }


            var Page_info = {};


            if (submittype != "delete") {
                if ($('#txtPageName').val() == "") {
                    toastr["error"]("Enter Page Name is required");
                    $('#txtPageName').focus();
                    return false;
                }

                Page_info.page_name = $('#txtPageName').val();
                Page_info.page_icon = $('#txtPageFontIcon').val();
                Page_info.page_url = $('#txtPageURL').val();
                Page_info.orderby = $('#txtPageOrderby').val();
                Page_info.module_id = $('#ddlModuleName option:selected').val();
                Page_info.page_id = page_id;
            }

            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + apipath,
                async: false,
                method: apimethod,
                contentType: 'application/json;charset=utf-8',
                data: JSON.stringify(Page_info),
                success: function (data, textStatus, jqXHR) {
                    if (jqXHR.status == "200") {
                        clearallboxPage();
                        swal({
                            title: "Done",
                            text: jqXHR.responseJSON,
                            icon: "success",
                        });
                        showStdInfoPage(1, 10, "AddPage", "", "");

                        if (submittype != "delete") {
                            $('#myModalAddPage').modal('toggle');
                        }
                    }

                },
                error: function (jqXHR, exception) {
                    if (jqXHR.status == 302) {
                        toastr["info"](jqXHR.responseJSON);
                    }
                    else {
                        toastr["error"](jqXHR.responseJSON);
                    }
                }
            });
        }
        function clearallboxPage() {
            GetAddNewModule()
            $('#ddlModuleName').val("-1");
            $('#txtPageName').val("");
            $('#txtPageFontIcon').val("");
            $('#txtPageName').val("");
            $('#txtPageURL').val("");
            $('#txtserstatus').val("true");
            $('#txtPageOrderby').val("");
            $('#btnasinsubmitPage').show();
            $('#btnasinupdatePage').hide();
            $('#insertHeadPage').show();
            $('#updateHeadPage').hide();
            $(".select2").select2({
                placeholder: "",
                allowClear: true
            });
        }
        function showStdInfoPage(pageNumber, pageSize, divide, searchtext, textsearchcolumnvalue) {
            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + "api/AddNewPage/GetAddNewPageHistory?pageNumber=" + pageNumber + "&pageSize=" + pageSize + "&QuerySearch=" + searchtext + "&QuerySearchColumn=" + textsearchcolumnvalue + "&login_id=" + localStorage["login_id"],
                async: false,
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    var voucherOptions = $('#' + divide + ' #tablerows');
                    voucherOptions.empty();

                    if (data.jsonretrundata.length > 0) {


                        $(data.jsonretrundata).each(function (index, infostd) {
                            voucherOptions.append('<tr><td>' + (index + 1) + '</td> <td id="' + removenullvalue(infostd.module_id) + '">' + removenullvalue(infostd.module_name) + '</td><td>' + removenullvalue(infostd.page_name) + '</td><td>' + removenullvalue(infostd.page_icon) + '</td><td>' + removenullvalue(infostd.page_url) + '</td> <td>' + removenullvalue(infostd.orderby) + '</td><td><button type="button" class="btn btn-success editStdInfoPage " data-toggle="modal" data-target="#myModalAddPage" style="border-radius:0px;"  id="' + removenullvalue(infostd.page_id) + '">Edit</button> </td><td><button type="button" class="btn btn-danger delstdinfoPage" style="border-radius:0px;"  id="' + removenullvalue(infostd.page_id) + '">Delete</button> </td> </tr>');
                        });
                        generatepagination(data.paginationMetadata, divide, "tablerows", "showStdInfoPage", "", "")
                    } else {
                        generatepagination(data.paginationMetadata, divide, "tablerows", "showStdInfoPage", "", "")
                    }

                },
                error: function (jqXHR, exception) {
                    msg = 'Internal Server Error [500].';
                    swal({
                        type: 'error',
                        title: 'Oops...',
                        text: msg,
                        showConfirmButton: false,
                        timer: 2000
                    });
                }
            });
        }
        function GetAddNewModule() {
            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + "api/AddNewModule/GetAddNewModule",
                async: false,
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    $('#ddlModuleName').empty();
                    $('#ddlModuleName').append('<option value="-1">Select Module</option>')
                    $(data).each(function (index, infostd) {
                        $('#ddlModuleName').append('<option value="' + removenullvalue(infostd.module_id) + '">' + removenullvalue(infostd.module_name) + '</option>')
                    });
                },
                error: function (jqXHR, exception) {
                    msg = 'Internal Server Error [500].';
                    swal({
                        type: 'error',
                        title: 'Oops...',
                        text: msg,
                        showConfirmButton: false,
                        timer: 2000
                    });
                }
            });
        }
        //Page Info End


        //Role Info Start
        function SaveRole(submittype) {
            var apipath = "api/AddNewRole/AddNewRoleInsert";
            var apimethod = "Post";
            if (submittype == "update") {
                apipath = "api/AddNewRole/AddNewRoleUpdate";
                apimethod = "Put";
            }

            else if (submittype == "delete") {
                apipath = "api/AddNewRole/AddNewRoleDelete?role_id=" + role_id;
                apimethod = "Delete";
            }


            var userroles = {};


            if (submittype != "delete") {
                if ($('#txtRoleName').val() == "") {
                    toastr["error"]("Enter Role Name is required");
                    $('#txtRoleName').focus();
                    return false;
                }

                userroles.role_name = $('#txtRoleName').val();
                userroles.role_id = role_id;
            }

            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + apipath,
                async: false,
                method: apimethod,
                contentType: 'application/json;charset=utf-8',
                data: JSON.stringify(userroles),
                success: function (data, textStatus, jqXHR) {
                    if (jqXHR.status == "200") {
                        clearallboxRole();
                        swal({
                            title: "Done",
                            text: jqXHR.responseJSON,
                            icon: "success",
                        });
                        showStdInfoRole(1, 10, "AddRole", "", "");

                        if (submittype != "delete") {
                            $('#myModalAddRole').modal('toggle');
                        }
                    }

                },
                error: function (jqXHR, exception) {
                    if (jqXHR.status == 302) {
                        toastr["info"](jqXHR.responseJSON);
                    }
                    else {
                        toastr["error"](jqXHR.responseJSON);
                    }
                }
            });
        }
        function clearallboxRole() {
            $('#txtRoleName').val("");
            $('#btnasinsubmitRole').show();
            $('#btnasinupdateRole').hide();
            $('#insertHeadRole').show();
            $('#updateHeadRole').hide();
        }
        function showStdInfoRole(pageNumber, pageSize, divide, searchtext, textsearchcolumnvalue) {
            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + "api/AddNewRole/GetAddNewRoleHistory?pageNumber=" + pageNumber + "&pageSize=" + pageSize + "&QuerySearch=" + searchtext + "&QuerySearchColumn=" + textsearchcolumnvalue + "&login_id=" + localStorage["login_id"],
                async: false,
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    var voucherOptions = $('#' + divide + ' #tablerows');
                    voucherOptions.empty();

                    if (data.jsonretrundata.length > 0) {


                        $(data.jsonretrundata).each(function (index, infostd) {
                            voucherOptions.append('<tr><td>' + (index + 1) + '</td> <td>' + removenullvalue(infostd.role_name) + '</td><td><button type="button" class="btn btn-success editStdInfoRole " data-toggle="modal" data-target="#myModalAddRole" style="border-radius:0px;"  id="' + removenullvalue(infostd.role_id) + '">Edit</button> </td><td><button type="button" class="btn btn-danger delstdinfoRole" style="border-radius:0px;"  id="' + removenullvalue(infostd.role_id) + '">Delete</button></td> </tr>');
                        });
                        generatepagination(data.paginationMetadata, divide, "tablerows", "showStdInfoRole", "", "")
                    } else {
                        generatepagination(data.paginationMetadata, divide, "tablerows", "showStdInfoRole", "", "")
                    }

                },
                error: function (jqXHR, exception) {
                    msg = 'Internal Server Error [500].';
                    swal({
                        type: 'error',
                        title: 'Oops...',
                        text: msg,
                        showConfirmButton: false,
                        timer: 2000
                    });
                }
            });
        }
        //Role Info End



        //function GetAllUsers() {
        //    $.ajax({
        //        headers: {
        //            "Authorization": localStorage["access_token"]
        //        },
        //        url: url + "api/SetUserPagesPermissions/GetAllUsers",
        //        async: false,
        //        method: 'GET',
        //        dataType: 'json',
        //        success: function (data) {
        //            $('#ddlSelectUser').empty();
        //            $('#ddlSelectUser').append('<option value="-1">Select User</option>')
        //            $(data).each(function (index, infostd) {
        //                $('#ddlSelectUser').append('<option value="' + removenullvalue(infostd.login_id) + '">' + removenullvalue(infostd.username) + '</option>')
        //            });
        //        },
        //        error: function (jqXHR, exception) {
        //            msg = 'Internal Server Error [500].';
        //            swal({
        //                type: 'error',
        //                title: 'Oops...',
        //                text: msg,
        //                showConfirmButton: false,
        //                timer: 2000
        //            });
        //        }
        //    });
        //}

        function GetAllRoles() {
            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + "api/AddNewRole/GetAddNewRole",
                async: false,
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    $('#ddlSelectRole').empty();
                    $('#ddlSelectRole').append('<option value="-1">Select User</option>')
                    $(data).each(function (index, infostd) {
                        $('#ddlSelectRole').append('<option value="' + removenullvalue(infostd.role_id) + '">' + removenullvalue(infostd.role_name) + '</option>')
                    });
                },
                error: function (jqXHR, exception) {
                    msg = 'Internal Server Error [500].';
                    swal({
                        type: 'error',
                        title: 'Oops...',
                        text: msg,
                        showConfirmButton: false,
                        timer: 2000
                    });
                }
            });
        }
        
        //function GetUserRolePermissionIdWise() {


        //    $.ajax({
        //        headers: {
        //            "Authorization": localStorage["access_token"]
        //        },
        //        url: url + "api/SetUserPagesPermissions/GetUserRolePermissionIdWise?login_id=" + $('#ddlSelectUser option:selected').val(),
        //        async: false,
        //        method: 'GET',
        //        dataType: 'json',
        //        success: function (data) {



        //            var voucherOptions = $('#SetUserPermission #tablerows');
        //            voucherOptions.empty();
        //            $(data).each(function (index, infostd) {
        //                var checktatus = "";

        //                if (infostd.status == true) {
        //                    checktatus = "checked"
        //                }


        //                voucherOptions.append('<tr><td>' + (index + 1) + '</td> <td id="' + infostd.module_id + '">' + removenullvalue(infostd.module_name) + '</td><td id="' + infostd.page_id + '">' + removenullvalue(infostd.page_name) + '</td><td style="text-align: center;width:60px"><input  class="clsChkBox" style="width:20px; height:20px" ' + checktatus + '   type="checkbox"></td></tr>');
        //            });
        //        },
        //        error: function (jqXHR, exception) {
        //            msg = 'Internal Server Error [500].';
        //            swal({
        //                type: 'error',
        //                title: 'Oops...',
        //                text: msg,
        //                showConfirmButton: false,
        //                timer: 2000
        //            });
        //        }
        //    });
        //}
        function GetUserRolePermissionIdWise() {


            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + "api/SetUserPagesPermissions/GetRolePermissionIdWise?role_id=" + $('#ddlSelectRole option:selected').val(),
                async: false,
                method: 'GET',
                dataType: 'json',
                success: function (data) {



                    var voucherOptions = $('#SetUserPermission #tablerows');
                    voucherOptions.empty();
                    $(data).each(function (index, infostd) {
                        var checktatus = "";

                        if (infostd.status == true) {
                            checktatus = "checked"
                        }


                        voucherOptions.append('<tr><td>' + (index + 1) + '</td> <td id="' + infostd.module_id + '">' + removenullvalue(infostd.module_name) + '</td><td id="' + infostd.page_id + '">' + removenullvalue(infostd.page_name) + '</td><td style="text-align: center;width:60px"><input  class="clsChkBox" style="width:20px; height:20px" ' + checktatus + '   type="checkbox"></td></tr>');
                    });
                },
                error: function (jqXHR, exception) {
                    msg = 'Internal Server Error [500].';
                    swal({
                        type: 'error',
                        title: 'Oops...',
                        text: msg,
                        showConfirmButton: false,
                        timer: 2000
                    });
                }
            });
        }



        //function UpdatePermission() {



        //    var arrdate = [];
        //    $('#SetUserPermission #tablerows tr').each(function (index, element) {
        //        var $tr = $(this).closest('tr');

        //        if ($tr.find('td:nth-child(4) input').prop('checked') == true) {
        //            var ClsUpdatePermission = {};
        //            ClsUpdatePermission.module_id = $tr.find('td:nth-child(2)').attr("id");
        //            ClsUpdatePermission.page_id = $tr.find('td:nth-child(3)').attr("id");
        //            arrdate.push(ClsUpdatePermission);
        //        }
        //    });

        //    $.ajax({
        //        headers: {
        //            "Authorization": localStorage["access_token"]
        //        },
        //        async: true,
        //        url: url + "api/SetUserPagesPermissions/UpdatePermission?login_id=" + $('#ddlSelectUser option:selected').val(),
        //        method: "POST",
        //        contentType: 'application/json;charset=utf-8',
        //        data: JSON.stringify(arrdate),
        //        success: function (data) {
        //            toastr["success"]("Permissions Successfully Assigned");
        //        },
        //        error: function (jqXHR, exception) {
        //        }
        //    });

        //}

        function UpdatePermission() {



            var arrdate = [];
            $('#SetUserPermission #tablerows tr').each(function (index, element) {
                var $tr = $(this).closest('tr');

                if ($tr.find('td:nth-child(4) input').prop('checked') == true) {
                    var ClsUpdatePermission = {};
                    ClsUpdatePermission.module_id = $tr.find('td:nth-child(2)').attr("id");
                    ClsUpdatePermission.page_id = $tr.find('td:nth-child(3)').attr("id");
                    arrdate.push(ClsUpdatePermission);
                }
            });

            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                async: true,
                url: url + "api/SetUserPagesPermissions/UpdaterolePermission?role_id=" + $('#ddlSelectRole option:selected').val(),
                method: "POST",
                contentType: 'application/json;charset=utf-8',
                data: JSON.stringify(arrdate),
                success: function (data) {
                    toastr["success"]("Permissions Successfully Assigned");
                },
                error: function (jqXHR, exception) {
                }
            });

        }

        
    </script>
    <style>
        .nav-tabs .nav-item {
            width: 12% !important;
        }
    </style>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">


    <!-- Begin page -->
    <div id="wrapper">
        <div class="content-page">
            <div class="content">

                <!-- Start Content-->
                <div class="container-fluid">

                    <!-- start page title -->
                    <div class="row">
                        <div class="col-12">
                            <div class="page-title-box">
                                <h4 class="page-title">User Role Permissions </h4>
                            </div>
                        </div>
                    </div>



                    <div class="row">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
                            <div class="card-box">

                                <ul class="nav nav-tabs">
                                    <li class="nav-item active">
                                        <a href="#AddModule" data-toggle="tab" aria-expanded="true" class="nav-link active">
                                            <span class="d-block d-sm-none"><i class="mdi mdi-account-outline font-18"></i></span>
                                            <span class="d-none d-sm-block clstPending">Add Module</span>
                                        </a>
                                    </li>

                                    <li class="nav-item">
                                        <a href="#AddPage" data-toggle="tab" aria-expanded="true" class="nav-link">
                                            <span class="d-block d-sm-none"><i class="mdi mdi-account-outline font-18"></i></span>
                                            <span class="d-none d-sm-block clstVerified">Add Page</span>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="#AddRole" data-toggle="tab" aria-expanded="true" class="nav-link">
                                            <span class="d-block d-sm-none"><i class="mdi mdi-account-outline font-18"></i></span>
                                            <span class="d-none d-sm-block clsCancel">AddRole</span>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="#SetUserPermission" data-toggle="tab" aria-expanded="true" class="nav-link">
                                            <span class="d-block d-sm-none"><i class="mdi mdi-account-outline font-18"></i></span>
                                            <span class="d-none d-sm-block clsCancel">Set User Permissions</span>
                                        </a>
                                    </li>
                                </ul>
                                <div class="tab-content">
                                    <div class="tab-pane active" id="AddModule">





                                        <div id="divtablestart">

                                            <button type="button" style="background: #fc9d74; color: #ffffff" class="btn clsHideEditAddForCompany" id="btnnewasinsubmitAddModule" data-toggle="modal" data-target="#myModalAddModule">Add Module</button>
                                            <div style="margin-top: 20px" class="row" id="divtablestart">
                                                <div class="col-12">
                                                    <div class="card">
                                                        <div class="card-body table-responsive">


                                                            <div id="datatable_wrapper" class="dataTables_wrapper dt-bootstrap4 no-footer">
                                                                <div class="col-md-2" style="float: left; margin-bottom: 1%;">
                                                                    <b>Show entries</b>
                                                                    <select name="datatable_length" aria-controls="datatable" style="height: 34px;" class="custom-select custom-select-sm form-control form-control-sm">
                                                                        <option value="10">10</option>
                                                                        <option value="25">25</option>
                                                                        <option value="50">50</option>
                                                                        <option value="100">100</option>
                                                                    </select>
                                                                </div>
                                                                <div class="col-md-2" style="float: right">
                                                                    <br />


                                                                    <div class="input-group">
                                                                        <input type="text" class="form-control clssearchtxtinput" id="txtinput" placeholder="Search.... " />
                                                                        <div class="input-group-append">
                                                                            <button class="btn btn-secondary btnclssearchtxtinput" type="button"><i class="fa fa-search"></i></button>
                                                                        </div>
                                                                    </div>
                                                                </div>


                                                                <div id="export3">

                                                                    <div class="table-responsive">
                                                                        <table id="datatable" class="table" style="width: 100%; font-family: Arial, Helvetica, sans-serif !important;">
                                                                            <thead style="background-color: #2c2b30" class="tableheading">
                                                                                <tr role="row">
                                                                                    <th>Sr#</th>
                                                                                    <th>Module Name</th>
                                                                                    <th>Module Icon</th>
                                                                                    <th>Module Url</th>
                                                                                    <th>Module Nested List</th>
                                                                                    <th>Order by</th>
                                                                                    <th>Edit</th>
                                                                                    <th>Delete</th>


                                                                                </tr>
                                                                            </thead>

                                                                            <tbody id="tablerows" class="datatablesearch1">
                                                                            </tbody>
                                                                        </table>
                                                                    </div>

                                                                </div>
                                                                <div class="row" style="margin-top: 3%;">
                                                                    <div class="col-sm-12 col-md-3">
                                                                        <div class="dataTables_info" id="datatable_info" role="status" aria-live="polite" style="font-size: 15px; font-weight: bold;">Showing <b class="clstableshowrowsstart"></b>to <b class="clstableshowrowsend"></b>of <b class="clstableshowrowstotal"></b>entries</div>
                                                                    </div>
                                                                    <div class="col-sm-12 col-md-9">
                                                                        <div class="dataTables_paginate paging_simple_numbers" id="datatable_paginate" style="float: right;">
                                                                            <ul class="pagination">
                                                                            </ul>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                        </div>
                                                    </div>
                                                </div>
                                            </div>





                                        </div>
                                    </div>
                                    <div class="tab-pane" id="AddPage">

                                        <div id="divtablestart">

                                            <button type="button" style="background: #fc9d74; color: #ffffff" class="btn clsHideEditAddForCompany" id="btnnewasinsubmitAddPage" data-toggle="modal" data-target="#myModalAddPage">Add Page</button>
                                            <div style="margin-top: 20px" class="row" id="divtablestart">
                                                <div class="col-12">
                                                    <div class="card">
                                                        <div class="card-body table-responsive">


                                                            <div id="datatable_wrapper" class="dataTables_wrapper dt-bootstrap4 no-footer">
                                                                <div class="col-md-2" style="float: left; margin-bottom: 1%;">
                                                                    <b>Show entries</b>
                                                                    <select name="datatable_length" aria-controls="datatable" style="height: 34px;" class="custom-select custom-select-sm form-control form-control-sm">
                                                                        <option value="10">10</option>
                                                                        <option value="25">25</option>
                                                                        <option value="50">50</option>
                                                                        <option value="100">100</option>
                                                                    </select>
                                                                </div>
                                                                <div class="col-md-2" style="float: right">
                                                                    <br />


                                                                    <div class="input-group">
                                                                        <input type="text" class="form-control clssearchtxtinput" id="txtinput" placeholder="Search.... " />
                                                                        <div class="input-group-append">
                                                                            <button class="btn btn-secondary btnclssearchtxtinput" type="button"><i class="fa fa-search"></i></button>
                                                                        </div>
                                                                    </div>
                                                                </div>


                                                                <div id="export3">

                                                                    <div class="table-responsive">
                                                                        <table id="datatable" class="table" style="width: 100%; font-family: Arial, Helvetica, sans-serif !important;">
                                                                            <thead style="background-color: #2c2b30" class="tableheading">
                                                                                <tr role="row">
                                                                                    <th>Sr#</th>
                                                                                    <th>Module Name</th>
                                                                                    <th>Page Name</th>
                                                                                    <th>Page Icon</th>
                                                                                    <th>Page Url</th>
                                                                                    <th>Order by</th>

                                                                                    <th>Edit</th>
                                                                                    <th>Delete</th>

                                                                                </tr>
                                                                            </thead>

                                                                            <tbody id="tablerows" class="datatablesearch1">
                                                                            </tbody>
                                                                        </table>
                                                                    </div>

                                                                </div>
                                                                <div class="row" style="margin-top: 3%;">
                                                                    <div class="col-sm-12 col-md-3">
                                                                        <div class="dataTables_info" id="datatable_info" role="status" aria-live="polite" style="font-size: 15px; font-weight: bold;">Showing <b class="clstableshowrowsstart"></b>to <b class="clstableshowrowsend"></b>of <b class="clstableshowrowstotal"></b>entries</div>
                                                                    </div>
                                                                    <div class="col-sm-12 col-md-9">
                                                                        <div class="dataTables_paginate paging_simple_numbers" id="datatable_paginate" style="float: right;">
                                                                            <ul class="pagination">
                                                                            </ul>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>


                                    <div class="tab-pane" id="AddRole">

                                        <div id="divtablestart">

                                            <button type="button" style="background: #fc9d74; color: #ffffff" class="btn clsHideEditAddForCompany" id="btnnewasinsubmitAddRole" data-toggle="modal" data-target="#myModalAddRole">Add Role</button>
                                            <div style="margin-top: 20px" class="row" id="divtablestart">
                                                <div class="col-12">
                                                    <div class="card">
                                                        <div class="card-body table-responsive">


                                                            <div id="datatable_wrapper" class="dataTables_wrapper dt-bootstrap4 no-footer">
                                                                <div class="col-md-2" style="float: left; margin-bottom: 1%;">
                                                                    <b>Show entries</b>
                                                                    <select name="datatable_length" aria-controls="datatable" style="height: 34px;" class="custom-select custom-select-sm form-control form-control-sm">
                                                                        <option value="10">10</option>
                                                                        <option value="25">25</option>
                                                                        <option value="50">50</option>
                                                                        <option value="100">100</option>
                                                                    </select>
                                                                </div>
                                                                <div class="col-md-2" style="float: right">
                                                                    <br />


                                                                    <div class="input-group">
                                                                        <input type="text" class="form-control clssearchtxtinput" id="txtinput" placeholder="Search.... " />
                                                                        <div class="input-group-append">
                                                                            <button class="btn btn-secondary btnclssearchtxtinput" type="button"><i class="fa fa-search"></i></button>
                                                                        </div>
                                                                    </div>
                                                                </div>


                                                                <div id="export3">

                                                                    <div class="table-responsive">
                                                                        <table id="datatable" class="table" style="width: 100%; font-family: Arial, Helvetica, sans-serif !important;">
                                                                            <thead style="background-color: #2c2b30" class="tableheading">
                                                                                <tr role="row">
                                                                                    <th>Sr#</th>
                                                                                    <th>Role Name</th>
                                                                                    <th>Edit</th>
                                                                                    <th>Delete</th>


                                                                                </tr>
                                                                            </thead>

                                                                            <tbody id="tablerows" class="datatablesearch1">
                                                                            </tbody>
                                                                        </table>
                                                                    </div>

                                                                </div>
                                                                <div class="row" style="margin-top: 3%;">
                                                                    <div class="col-sm-12 col-md-3">
                                                                        <div class="dataTables_info" id="datatable_info" role="status" aria-live="polite" style="font-size: 15px; font-weight: bold;">Showing <b class="clstableshowrowsstart"></b>to <b class="clstableshowrowsend"></b>of <b class="clstableshowrowstotal"></b>entries</div>
                                                                    </div>
                                                                    <div class="col-sm-12 col-md-9">
                                                                        <div class="dataTables_paginate paging_simple_numbers" id="datatable_paginate" style="float: right;">
                                                                            <ul class="pagination">
                                                                            </ul>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

<%--                                    <div class="tab-pane" id="SetUserPermission">

                                        <div id="divtablestart">
                                            <div class="col-12">
                                                <div class="card">
                                                    <div class="card-body table-responsive">
                                                        <div class="row">
                                                            <div class="col-lg-3 col-md-3 col-sm-12">
                                                                <div class="form-group  ">
                                                                    <label for="fname">Select User</label>
                                                                    <select class="form-control select2_single select2" id="ddlSelectUser" style="width: 100%;">
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="col-lg-9 col-md-9 col-sm-12 divhide">
                                                                <button type="button" class="btn btn-dark" id="btnUpdateUserPermissions" style="float: right;">Update</button>


                                                                <div class="table-responsive" style="height: 500px; overflow: scroll;">
                                                                    <table id="datatable" class="table" style="width: 100%; font-family: Arial, Helvetica, sans-serif !important;">
                                                                        <thead style="background-color: #2c2b30" class="tableheading">
                                                                            <tr role="row">
                                                                                <th>Sr#</th>
                                                                                <th>Module Name</th>
                                                                                <th>Page Name</th>
                                                                                <th>Action</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody id="tablerows" class="datatablesearch1">
                                                                        </tbody>
                                                                    </table>
                                                                </div>
                                                            </div>
                                                        </div>



                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>--%>


                                    
                                    <div class="tab-pane" id="SetUserPermission">

                                        <div id="divtablestart">
                                            <div class="col-12">
                                                <div class="card">
                                                    <div class="card-body table-responsive">
                                                        <div class="row">
                                                            <div class="col-lg-3 col-md-3 col-sm-12">
                                                                <div class="form-group  ">
                                                                    <label for="fname">Select Role</label>
                                                                    <select class="form-control select2_single select2" id="ddlSelectRole" style="width: 100%;">
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="col-lg-9 col-md-9 col-sm-12 divhide">
                                                                <button type="button" class="btn btn-dark" id="btnUpdateUserPermissions" style="float: right;">Update</button>


                                                                <div class="table-responsive" style="height: 500px; overflow: scroll;">
                                                                    <table id="datatable" class="table" style="width: 100%; font-family: Arial, Helvetica, sans-serif !important;">
                                                                        <thead style="background-color: #2c2b30" class="tableheading">
                                                                            <tr role="row">
                                                                                <th>Sr#</th>
                                                                                <th>Module Name</th>
                                                                                <th>Page Name</th>
                                                                                <th>Action</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody id="tablerows" class="datatablesearch1">
                                                                        </tbody>
                                                                    </table>
                                                                </div>
                                                            </div>
                                                        </div>



                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>


        </div>
        <!-- sample modal content -->

        <!-- /.modal -->
        <!-- END wrapper -->
    </div>






    <div id="myModalAddModule" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="insertHeadModule"><strong>Add Module Info</strong></h4>
                    <h4 class="modal-title" id="updateHeadModule"><strong>Edit Module Info</strong></h4>
                    <!--<button type="button" class="close pull-right" data-dismiss="modal" aria-hidden="true">×</button>-->
                </div>
                <div class="modal-body">
                    <form>
                        <div class="row">

                            <div class="form-group  col-lg-6 col-md-6 col-sm-12">
                                <label for="fname">Module Name <span class="text-danger">*</span></label>
                                <input id="txtModuleName" type="text" name="" placeholder="Enter Module Name" class="form-control" />
                            </div>

                            <div class="form-group  col-lg-6 col-md-6 col-sm-12">
                                <label for="fname">Module Font Icon </label>
                                <input id="txtModuleFontIcon" type="text" name="" placeholder="Enter Module Font Icon" class="form-control" />
                            </div>
                            <div class="form-group  col-lg-6 col-md-6 col-sm-12">
                                <label for="fname">Module URL </label>
                                <input id="txtModuleURL" type="text" name="" placeholder="Enter Module URL" class="form-control" />
                            </div>
                            <div class="form-group  col-lg-6 col-md-6 col-sm-12">
                                <label for="fname">Module Nested List status </label>
                                <select class="form-control select2_single select2" id="txtserstatus" style="width: 100%;">
                                    <option value="true">True</option>
                                    <option value="false">False</option>
                                </select>
                            </div>
                            <div class="form-group  col-lg-6 col-md-6 col-sm-12">
                                <label for="fname">Order by  </label>
                                <input id="txtModuleOrderby" type="number" name="" placeholder="Enter Order by" class="form-control" />
                            </div>

                        </div>

                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary waves-effect" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="btnasinsubmitModule">Save</button>
                    <button type="button" class="btn btn-info" id="btnasinupdateModule">Update</button>
                </div>

            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </div>
    <div id="myModalAddPage" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="insertHeadPage"><strong>Add Page Info</strong></h4>
                    <h4 class="modal-title" id="updateHeadPage"><strong>Edit Page Info</strong></h4>
                    <!--<button type="button" class="close pull-right" data-dismiss="modal" aria-hidden="true">×</button>-->
                </div>
                <div class="modal-body">
                    <form>
                        <div class="row">
                            <div class="form-group  col-lg-6 col-md-6 col-sm-12">
                                <label for="fname">Module Name </label>
                                <select class="form-control select2_single select2" id="ddlModuleName" style="width: 100%;">
                                </select>
                            </div>
                            <div class="form-group  col-lg-6 col-md-6 col-sm-12">
                                <label for="fname">Page Name <span class="text-danger">*</span></label>
                                <input id="txtPageName" type="text" name="" placeholder="Enter Page Name" class="form-control" />
                            </div>

                            <div class="form-group  col-lg-6 col-md-6 col-sm-12">
                                <label for="fname">Page Font Icon </label>
                                <input id="txtPageFontIcon" type="text" name="" placeholder="Enter Page Font Icon" class="form-control" />
                            </div>
                            <div class="form-group  col-lg-6 col-md-6 col-sm-12">
                                <label for="fname">Page URL </label>
                                <input id="txtPageURL" type="text" name="" placeholder="Enter Page URL" class="form-control" />
                            </div>

                            <div class="form-group  col-lg-6 col-md-6 col-sm-12">
                                <label for="fname">Order by  </label>
                                <input id="txtPageOrderby" type="number" name="" placeholder="Enter Order by" class="form-control" />
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary waves-effect" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="btnasinsubmitPage">Save</button>
                    <button type="button" class="btn btn-info" id="btnasinupdatePage">Update</button>
                </div>

            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </div>
    <div id="myModalAddRole" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="insertHeadRole"><strong>Add Role Info</strong></h4>
                    <h4 class="modal-title" id="updateHeadRole"><strong>Edit Role Info</strong></h4>
                    <!--<button type="button" class="close pull-right" data-dismiss="modal" aria-hidden="true">×</button>-->
                </div>
                <div class="modal-body">
                    <form>
                        <div class="row">

                            <div class="form-group  col-lg-6 col-md-6 col-sm-12">
                                <label for="fname">Role Name <span class="text-danger">*</span></label>
                                <input id="txtRoleName" type="text" name="" placeholder="Enter Role Name" class="form-control" />
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary waves-effect" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="btnasinsubmitRole">Save</button>
                    <button type="button" class="btn btn-info" id="btnasinupdateRole">Update</button>
                </div>

            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </div>

</asp:Content>
