<%@ Page Title="" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="UserInfo.aspx.cs" Inherits="TechnoPurAccounts.UserRolePermissions.UserInfo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <title>User Role Permissions</title>
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
        //            $('#ddlSelectUser').append('<option value="-1">Choose a role...</option>')
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
                    $('#ddlSelectRole').append('<option value="-1">Choose a role...</option>')
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



        // User-friendly permission helpers
        $(document).on('change', '#ddlSelectRole', function () {
            var hasRole = $(this).val() && $(this).val() !== '-1';
            $('#btnUpdateUserPermissions').prop('disabled', !hasRole);
        });
        $(document).on('click', '#btnUpdateUserPermissions', function () {
            var btn = $(this);
            if ($('#ddlSelectRole').val() === '-1') { toastr["error"]("Please choose a role first"); return false; }
            btn.addClass('ux-saving').html('<i class="fa fa-spinner fa-spin"></i> Saving...');
            setTimeout(function () { btn.removeClass('ux-saving').html('<i class="fa fa-save"></i> Save Permissions'); }, 1200);
        });
    </script>
    <style>
        /* Bangkok Lottery - modern access control UI */
        #wrapper {
            background: #f4f7fb;
            min-height: 100vh;
        }

        .content-page .content {
            padding-bottom: 40px;
        }

        .container-fluid {
            max-width: 1600px;
        }

        .page-title-box {
            padding: 24px 0 14px;
        }

            .page-title-box .page-title {
                margin: 0;
                color: #16213e;
                font-size: 25px;
                font-weight: 800;
                letter-spacing: -.3px;
            }

                .page-title-box .page-title:after {
                    content: "Manage modules, pages, roles and access permissions";
                    display: block;
                    margin-top: 6px;
                    color: #7b8798;
                    font-size: 13px;
                    font-weight: 500;
                    letter-spacing: 0;
                }

        .card-box {
            background: #fff;
            border: 1px solid #e8edf4;
            border-radius: 16px !important;
            box-shadow: 0 8px 28px rgba(26,39,71,.06);
            padding: 20px;
        }

        .card {
            border: 1px solid #e8edf4 !important;
            border-radius: 14px !important;
            box-shadow: none !important;
            overflow: hidden;
        }

        .card-body {
            padding: 20px !important;
        }

        .nav-tabs {
            border: 0 !important;
            background: #f4f6fa;
            padding: 5px;
            border-radius: 12px;
            display: flex;
            gap: 5px;
            margin-bottom: 22px;
        }

            .nav-tabs .nav-item {
                width: auto !important;
                flex: 1 1 0;
                margin: 0 !important;
            }

            .nav-tabs .nav-link {
                border: 0 !important;
                border-radius: 9px !important;
                color: #667085;
                font-weight: 700;
                text-align: center;
                padding: 11px 12px;
                transition: .2s ease;
            }

                .nav-tabs .nav-link:hover {
                    color: #172554;
                    background: #fff;
                }

                .nav-tabs .nav-link.active {
                    color: #fff !important;
                    background: #172554 !important;
                    box-shadow: 0 4px 12px rgba(23,37,84,.18);
                }

        .tab-content {
            padding-top: 2px;
        }

        .btn {
            border-radius: 9px !important;
            font-weight: 700;
            box-shadow: none !important;
        }

        .clsHideEditAddForCompany {
            background: #172554 !important;
            border-color: #172554 !important;
            color: #fff !important;
            padding: 9px 16px;
        }

            .clsHideEditAddForCompany:hover {
                background: #243b7a !important;
            }

        .btn-success {
            background: #eef8f3 !important;
            border: 1px solid #ccebdc !important;
            color: #18794e !important;
            padding: 6px 12px;
        }

        .btn-danger {
            background: #fff1f2 !important;
            border: 1px solid #ffd4d8 !important;
            color: #c6283d !important;
            padding: 6px 12px;
        }

        .btn-dark, #btnUpdateUserPermissions {
            background: #172554 !important;
            border-color: #172554 !important;
            color: #fff !important;
            padding: 9px 18px;
        }

        .btn-secondary {
            background: #172554 !important;
            border-color: #172554 !important;
        }

        .form-control, .custom-select, .select2-container .select2-selection--single {
            border: 1px solid #dbe2ea !important;
            border-radius: 9px !important;
            min-height: 40px;
            box-shadow: none !important;
        }

            .form-control:focus, .custom-select:focus {
                border-color: #8294c4 !important;
                box-shadow: 0 0 0 3px rgba(23,37,84,.08) !important;
            }

        label, .form-group label {
            color: #344054;
            font-weight: 700;
            font-size: 13px;
        }

        .input-group .form-control {
            border-radius: 9px 0 0 9px !important;
        }

        .input-group-append .btn {
            border-radius: 0 9px 9px 0 !important;
        }

        .table-responsive {
            border-radius: 11px;
        }

        table.table {
            margin-bottom: 0;
            color: #344054;
        }

            table.table thead, table.table thead.tableheading {
                background: #172554 !important;
            }

                table.table thead th {
                    background: #172554 !important;
                    color: #fff !important;
                    border: 0 !important;
                    font-size: 12px;
                    font-weight: 800;
                    text-transform: uppercase;
                    letter-spacing: .35px;
                    padding: 13px 12px !important;
                    white-space: nowrap;
                }

            table.table tbody td {
                border-top: 1px solid #edf1f5 !important;
                padding: 12px !important;
                vertical-align: middle !important;
                font-size: 13px;
            }

            table.table tbody tr:hover {
                background: #f8faff;
            }

        .dataTables_info {
            color: #667085 !important;
            font-size: 13px !important;
            font-weight: 600 !important;
        }

        .pagination {
            gap: 4px;
        }

            .pagination .page-link {
                border-radius: 7px !important;
                border-color: #e1e7ef;
                color: #344054;
            }

        .modal-content {
            border: 0 !important;
            border-radius: 16px !important;
            box-shadow: 0 24px 70px rgba(15,23,42,.2);
            overflow: hidden;
        }

        .modal-header {
            background: #172554;
            color: #fff;
            border: 0;
            padding: 16px 20px;
        }

            .modal-header .modal-title, .modal-header h4, .modal-header h5 {
                color: #fff !important;
                font-weight: 800;
            }

            .modal-header .close {
                color: #fff;
                opacity: .85;
                text-shadow: none;
            }

        .modal-body {
            padding: 22px !important;
        }

        .modal-footer {
            border-top: 1px solid #edf1f5;
            padding: 14px 20px;
        }

        #SetUserPermission .card-body {
            overflow: visible !important;
        }

        #SetUserPermission .divhide {
            background: #f8faff;
            border: 1px solid #e7ecf4;
            border-radius: 12px;
            padding: 16px;
        }

        #SetUserPermission .table-responsive {
            background: #fff;
            margin-top: 14px;
        }

        #SetUserPermission input[type=checkbox] {
            width: 18px;
            height: 18px;
            accent-color: #172554;
            cursor: pointer;
        }

        @media (max-width: 767.98px) {
            .card-box {
                padding: 12px;
                border-radius: 12px !important;
            }

            .page-title-box {
                padding-top: 16px;
            }

                .page-title-box .page-title {
                    font-size: 21px;
                }

            .nav-tabs {
                display: grid;
                grid-template-columns: 1fr 1fr;
            }

                .nav-tabs .nav-item {
                    width: 100% !important;
                }

                .nav-tabs .nav-link {
                    min-height: 44px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }

                    .nav-tabs .nav-link .d-block.d-sm-none {
                        display: block !important;
                    }

            .card-body {
                padding: 14px !important;
            }

            .clsHideEditAddForCompany {
                width: 100%;
                margin-bottom: 12px;
            }

            .dataTables_wrapper > .col-md-2 {
                float: none !important;
                width: 100% !important;
                max-width: 100% !important;
                margin-bottom: 12px !important;
            }

            .dataTables_paginate {
                float: none !important;
                margin-top: 12px;
                overflow-x: auto;
            }

            #SetUserPermission .col-lg-3, #SetUserPermission .col-lg-9 {
                padding-left: 0;
                padding-right: 0;
            }

            #btnUpdateUserPermissions {
                float: none !important;
                width: 100%;
                margin-bottom: 10px;
            }
        }

        /* UX V2 - Roles & Permissions */
        .ux-subtitle {
            margin-top: 4px;
            color: #667085;
            font-size: 13px;
            font-weight: 500
        }

        .page-title-box {
            padding: 20px 4px 14px !important
        }

            .page-title-box .page-title {
                margin: 0 !important
            }

        .nav-tabs {
            display: flex !important;
            gap: 6px !important;
            flex-wrap: wrap !important;
            border-bottom: 1px solid #eaecf0 !important;
            padding: 0 4px 12px !important
        }

            .nav-tabs .nav-item {
                margin: 0 !important
            }

            .nav-tabs .nav-link {
                border: 1px solid #eaecf0 !important;
                border-radius: 9px !important;
                background: #fff !important;
                color: #475467 !important;
                padding: 9px 14px !important;
                font-weight: 700 !important;
                font-size: 13px !important
            }

                .nav-tabs .nav-link.active {
                    background: #172554 !important;
                    border-color: #172554 !important;
                    color: #fff !important;
                    box-shadow: 0 2px 5px rgba(16,24,40,.12) !important
                }

        .tab-content {
            padding-top: 16px !important
        }

        .card {
            border: 1px solid #e4e7ec !important;
            border-radius: 14px !important;
            box-shadow: 0 4px 18px rgba(16,24,40,.05) !important
        }

        .card-body {
            padding: 22px !important
        }

        .form-control, .custom-select {
            min-height: 42px !important;
            border: 1px solid #d0d5dd !important;
            border-radius: 9px !important;
            background: #fff !important
        }

        .form-group label {
            color: #344054;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 6px
        }

        .ux-field-help {
            display: block;
            color: #98a2b3;
            font-size: 11px;
            margin: -2px 0 8px
        }

        .table thead th {
            padding: 12px 13px !important;
            font-size: 11px !important;
            text-transform: uppercase;
            letter-spacing: .035em;
            white-space: nowrap;
            background: #101828 !important;
            color: #fff !important
        }

        .table tbody td {
            padding: 13px !important;
            vertical-align: middle !important;
            color: #344054 !important
        }

        .table tbody tr:hover {
            background: #f9fafb !important
        }

        .editStdInfoModule, .editStdInfoPage, .editStdInfoRole {
            background: #eff8ff !important;
            color: #175cd3 !important;
            border: 1px solid #b2ddff !important;
            border-radius: 8px !important
        }

        .delstdinfoModule, .delstdinfoPage, .delstdinfoRole {
            background: #fff1f3 !important;
            color: #c01048 !important;
            border: 1px solid #fecdd6 !important;
            border-radius: 8px !important
        }

        .clsHideEditAddForCompany {
            background: #172554 !important;
            border-color: #172554 !important;
            border-radius: 9px !important;
            font-weight: 700 !important;
            padding: 9px 14px !important;
            margin-bottom: 14px !important
        }

        .divhide {
            border-left: 1px solid #eaecf0 !important;
            padding-left: 22px !important
        }

        #btnUpdateUserPermissions {
            background: #172554 !important;
            border-color: #172554 !important;
            border-radius: 9px !important;
            min-height: 42px !important;
            font-weight: 700 !important;
            padding: 9px 16px !important;
            margin-bottom: 12px !important
        }

            #btnUpdateUserPermissions:disabled {
                opacity: .55;
                cursor: not-allowed
            }

        .divhide .table-responsive {
            height: auto !important;
            max-height: 560px !important;
            border: 1px solid #eaecf0 !important;
            border-radius: 10px !important
        }

        .divhide .table {
            margin-bottom: 0 !important
        }

            .divhide .table tbody tr td:last-child {
                text-align: center
            }

        .divhide input[type=checkbox] {
            width: 18px;
            height: 18px;
            cursor: pointer
        }

        .modal-content {
            border: 0 !important;
            border-radius: 16px !important;
            overflow: hidden !important;
            box-shadow: 0 24px 48px rgba(16,24,40,.2) !important
        }

        .modal-header {
            background: #101828 !important
        }

        .modal-footer .btn {
            border-radius: 9px !important;
            font-weight: 700 !important
        }

        .pagination .page-link {
            border-radius: 7px !important;
            margin: 0 2px !important
        }

        @media(max-width:767px) {
            .nav-tabs {
                display: grid !important;
                grid-template-columns: 1fr 1fr !important
            }

                .nav-tabs .nav-link {
                    text-align: center !important
                }

            .card-body {
                padding: 14px !important
            }

            .divhide {
                border-left: 0 !important;
                border-top: 1px solid #eaecf0 !important;
                padding-left: 15px !important;
                padding-top: 16px !important;
                margin-top: 8px !important
            }

            #btnUpdateUserPermissions {
                width: 100% !important;
                float: none !important
            }

            .table {
                min-width: 680px
            }

            .ux-subtitle {
                font-size: 12px
            }
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
                                <div>
                                    <h4 class="page-title"><i class="fa fa-shield" style="margin-right: 9px"></i>Roles & Permissions</h4>
                                    <div class="ux-subtitle">Manage roles, menu pages and access permissions in one place.</div>
                                </div>
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
                                            <span class="d-none d-sm-block clstPending">Modules</span>
                                        </a>
                                    </li>

                                    <li class="nav-item">
                                        <a href="#AddPage" data-toggle="tab" aria-expanded="true" class="nav-link">
                                            <span class="d-block d-sm-none"><i class="mdi mdi-account-outline font-18"></i></span>
                                            <span class="d-none d-sm-block clstVerified">Pages</span>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="#AddRole" data-toggle="tab" aria-expanded="true" class="nav-link">
                                            <span class="d-block d-sm-none"><i class="mdi mdi-account-outline font-18"></i></span>
                                            <span class="d-none d-sm-block clsCancel">Roles</span>
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

                                            <button type="button" style="background: #fc9d74; color: #ffffff" class="btn clsHideEditAddForCompany" id="btnnewasinsubmitAddModule" data-toggle="modal" data-target="#myModalAddModule">Modules</button>
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

                                            <button type="button" style="background: #fc9d74; color: #ffffff" class="btn clsHideEditAddForCompany" id="btnnewasinsubmitAddPage" data-toggle="modal" data-target="#myModalAddPage">Pages</button>
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

                                            <button type="button" style="background: #fc9d74; color: #ffffff" class="btn clsHideEditAddForCompany" id="btnnewasinsubmitAddRole" data-toggle="modal" data-target="#myModalAddRole">Roles</button>
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
                                                                <button type="button" class="btn btn-dark" id="btnUpdateUserPermissions" style="float: right;"><i class="fa fa-save"></i> Save Permissions</button>


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
                                                                    <label for="ddlSelectRole">Role to configure</label><small class="ux-field-help">Choose a role to view and update its page access.</small>
                                                                    <select class="form-control select2_single select2" id="ddlSelectRole" style="width: 100%;">
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="col-lg-9 col-md-9 col-sm-12 divhide">
                                                                <button type="button" class="btn btn-dark" id="btnUpdateUserPermissions" style="float: right;"><i class="fa fa-save"></i>Save Permissions</button>


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
