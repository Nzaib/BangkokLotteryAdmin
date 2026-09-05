<%@ Page Title="" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="AddUser.aspx.cs" Inherits="TechnoPurAccounts.AddUser.AddUser" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Add User</title>
    <script>
        var id = 0;
        $(document).ready(function () {


            //html styles
            $('button').css('border-radius', '0px');
            $('input').css('border-radius', '0px');
            $('.modal-content').css('border-radius', '0px');
            $(document).on('click', '#btnAddstd', function () {
                $('#btnsubmit').show();
                $('#btnupdate').hide();
                $('#insertHead').show();
                $('#updateHead').hide();
                clearallbox();
            });
            ShowTableRecord(1, 10, "divtablestart");
            //Insert Teacher Info Script

            $('#btnsubmit').on('click', function () {
                var btn = $(this);
                btn.prop('disabled', true);
                setTimeout(function () {
                    btn.prop('disabled', false);
                }, 1000);
                Save("save")
            });

            //Get data in pop-up

            $('#btnupdate').on('click', function () {
                var btn = $(this);
                btn.prop('disabled', true);
                setTimeout(function () {
                    btn.prop('disabled', false);
                }, 1000);

                Save("update")

            });


            $(document).on('click', '.editStdInfo', function () {

                showRole();

                $('#btnsubmit').hide();
                $('#btnupdate').show();
                $('#insertHead').hide();
                $('#updateHead').show();
                id = ($(this).attr("id"));
                var $tr = $(this).closest('tr');
                $('#txtusername').val($tr.find('td:nth-child(2)').text());
                $('#txtemail').val($tr.find('td:nth-child(3)').text());


                $('#ddlrolename').val($tr.find('td:nth-child(4)').attr("id"));
                $('#txtpassword').val($tr.find('td:nth-child(5)').attr("id"));


                $(".select2_single").select2({
                    placeholder: "",
                    allowClear: true
                });

            });

            //Update Teacher info
            //Delete Teacher info
            $(document).on('click', '.delstdinfo', function () {
                id = ($(this).attr("id"));
                if (confirm("Are you really want to delete this User info?") == true) {
                    Save("delete")
                    return true;
                }
                else {
                    swal({
                        text: "Teacher info is saved.",
                        icon: "error",
                    });
                    return false;
                }
            });
        });


        function clearallbox() {
            showRole();

            $('#ddlrolename').val("-1");
            $('#txtusername').val("");
            $('#txtemail').val("");
            $('#txtpassword').val("");


            $(".select2_single").select2({
                placeholder: "",
                allowClear: true
            });
        }


        //showing Teacher info in table
        function ShowTableRecord(pageNumber, pageSize, divide, searchtext, textsearchcolumnvalue) {
            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + "api/AddUser/GetUserHistory?pageNumber=" + pageNumber + "&pageSize=" + pageSize + "&QuerySearch=" + searchtext + "&QuerySearchColumn=" + textsearchcolumnvalue,
                async: false,
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    var voucherOptions = $('#tablerows');
                    voucherOptions.empty();

                    if (data.jsonretrundata.length > 0) {

                        $(data.jsonretrundata).each(function (index, infostd) {
                            voucherOptions.append('<tr><td>' + (index + 1) + '</td> <td>' + unescape(infostd.username) + '</td> <td>' + unescape(infostd.email) + '</td> <td id="' + infostd.role_id + '">' + unescape(infostd.role_name) + '</td> <td id="' + infostd.withouthashpassword + '">*****</td> <td><button type="button" class="btn btn-info editStdInfo" data-toggle="modal" data-target="#myModal" style="border-radius:0px;"  id="' + infostd.login_id + '"><i class="fa fa-edit"></i></button>&nbsp;&nbsp;&nbsp;<button type="button" class="btn btn-danger delstdinfo" style="border-radius:0px;" id="' + infostd.login_id + '" ><i class="fa fa-trash"></i></button></td> </tr>');
                        });
                        generatepagination(data.paginationMetadata, divide, "tablerows", "ShowTableRecord", 0, 0)
                    } else {
                        generatepagination(data.paginationMetadata, divide, "tablerows", "ShowTableRecord", 0, 0)
                    }

                },
                error: function (jqXHR, exception) {
                    msg = jqXHR.responseJSON;
                    swal({
                        type: 'error',
                        title: 'Oops...',
                        text: msg,
                        showConfirmButton: false,
                        timer: 2000
                    });
                }
            });
            dropdounesearchbox()
        }



        function Save(submittype) {

            var apipath = "api/AddUser/UserInsert";
            var apimethod = "Post";


            if (submittype == "update") {
                apipath = "api/AddUser/UserUpdate";
                apimethod = "Put";
            }

            else if (submittype == "delete") {
                apipath = "api/AddUser/UserDelete?id=" + id;
                apimethod = "Delete";
            }




            if (submittype != "delete") {
                if ($('#ddlrolename option:selected').val() == "-1") {
                    toastr["error"]("Plan Category required");
                    $('#ddlrolename').focus();
                    return false;
                }
                if ($('#txtusername').val().trim() == "") {
                    toastr["error"]("User Name is required");
                    $('#txtusername').focus();
                    return false;
                }
                if ($('#txtemail').val() == "") {
                    toastr["error"]("E-mail is required");
                    $('#txtemail').focus();
                    return false;
                }

                if (!isEmail($('#txtemail').val())) {

                    toastr["error"]("Please Enter E-mail Formate Correct");
                    $('#txtemail').focus();
                    return false;
                }
                if ($('#txtpassword').val() == "") {
                    toastr["error"]("Password is required");
                    $('#txtpassword').focus();
                    return false;
                }
            }

            var clsUserInsert = {};

            clsUserInsert.role_id = $('#ddlrolename').val();
            clsUserInsert.username = escape($('#txtusername').val());
            clsUserInsert.email = escape($('#txtemail').val());
            clsUserInsert.password = $('#txtpassword').val();
            clsUserInsert.login_id = id;
            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + apipath,
                async: false,
                method: apimethod,
                contentType: 'application/json;charset=utf-8',
                data: JSON.stringify(clsUserInsert),
                success: function (data, textStatus, jqXHR) {
                    if (jqXHR.status == "200") {
                        clearallbox();
                        swal({
                            title: "Done",
                            text: jqXHR.responseJSON,
                            icon: "success",
                        });
                        ShowTableRecord(1, 10, "divtablestart");

                        if (submittype != "delete") {
                            $('#myModal').modal('toggle');
                        }
                    }

                },
                error: function (jqXHR, exception) {
                    if (jqXHR.status == 302) {
                        toastr["info"](jqXHR.responseJSON);
                    }
                    else {
                        toastr["error"]("Internal server error <b>[500]</b> occured");

                    }
                }
            });
        }


        function isEmail(email) {
            var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
            return regex.test(email);
        }
        function showRole() {
            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + "api/AddUserRole/GetUserRoles",
                async: false,
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    var voucherOptions = $('#ddlrolename');
                    voucherOptions.empty();
                    voucherOptions.append('<option  value="-1">--Select Role--</option>');

                    $(data).each(function (index, infostd) {
                        voucherOptions.append('<option value="' + infostd.role_id + '">' + unescape(infostd.role_name) + '</option>');
                    });
                    $(".select2_single").select2({
                        placeholder: "",
                        allowClear: true
                    });
                },
                error: function (jqXHR, exception) {
                    msg = jqXHR.responseJSON;
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


        // User-friendly helpers
        $(document).on('click', '#btnTogglePassword', function () {
            var input = $('#txtpassword');
            var showing = input.attr('type') === 'text';
            input.attr('type', showing ? 'password' : 'text');
            $(this).find('i').toggleClass('fa-eye', showing).toggleClass('fa-eye-slash', !showing);
            $(this).attr('aria-label', showing ? 'Show password' : 'Hide password');
        });
        $(document).on('shown.bs.modal', '#myModal', function () {
            setTimeout(function () { $('#ddlrolename').focus(); }, 100);
        });
    </script>

    <style>
        :root{--bl-navy:#101828;--bl-ink:#344054;--bl-muted:#667085;--bl-line:#e4e7ec;--bl-soft:#f8fafc;--bl-accent:#f58f7c;--bl-accent-dark:#e97965;}
        .content-page{background:#f6f8fb;min-height:100vh;}
        .page-title-box{display:flex;align-items:center;justify-content:space-between;gap:16px;padding:24px 0 14px;margin:0!important;}
        .page-title-box .page-title{font-size:25px;font-weight:700;color:var(--bl-navy);margin:0!important;line-height:1.25;}
        .page-title-box .page-title:after{content:'Manage access securely and efficiently';display:block;font-size:13px;font-weight:400;color:var(--bl-muted);margin-top:5px;}
        #btnAddstd{float:none!important;margin:0!important;background:var(--bl-navy)!important;color:#fff!important;border:1px solid var(--bl-navy)!important;border-radius:9px!important;padding:10px 17px!important;font-weight:600;box-shadow:0 2px 5px rgba(16,24,40,.12);}
        #btnAddstd:hover{background:#1d2939!important;transform:translateY(-1px);}
        #divtablestart{margin-top:10px!important;}
        #divtablestart .card{border:1px solid var(--bl-line);border-radius:14px;box-shadow:0 3px 14px rgba(16,24,40,.05);overflow:hidden;background:#fff;}
        #divtablestart .card-body{padding:22px!important;}
        #datatable_wrapper>.col-md-2{margin-bottom:16px!important;}
        #datatable_wrapper b{font-size:12px!important;font-weight:600!important;color:var(--bl-ink);display:block;margin-bottom:6px;}
        #datatable_wrapper .form-control,#datatable_wrapper .custom-select{height:40px!important;border:1px solid #d0d5dd;border-radius:8px!important;box-shadow:none;background:#fff;}
        #datatable_wrapper .form-control:focus{border-color:#98a2b3;box-shadow:0 0 0 3px rgba(152,162,179,.14);}
        #datatable{border-collapse:separate!important;border-spacing:0;font-family:inherit!important;margin-top:8px;}
        #datatable thead{background:var(--bl-navy)!important;}
        #datatable thead th{background:var(--bl-navy)!important;color:#fff;border:0!important;padding:13px 12px;font-size:12px;font-weight:600;letter-spacing:.02em;vertical-align:middle;}
        #datatable thead th:first-child{border-radius:9px 0 0 9px;}
        #datatable thead th:last-child{border-radius:0 9px 9px 0;}
        #datatable tbody td{padding:13px 12px;border-top:0;border-bottom:1px solid #eef2f6;color:var(--bl-ink);vertical-align:middle;font-size:13px;}
        #datatable tbody tr:hover{background:#fafbfc;}
        #datatable .btn{width:35px;height:35px;padding:0!important;display:inline-flex;align-items:center;justify-content:center;border-radius:8px!important;border:0;box-shadow:none;}
        #datatable .btn-info{background:#eef4ff;color:#3538cd;}
        #datatable .btn-danger{background:#fff1f3;color:#c01048;}
        #datatable_info{font-size:12px!important;font-weight:500!important;color:var(--bl-muted)!important;}
        .pagination .page-link{border-radius:7px!important;margin:0 2px;border:1px solid var(--bl-line);color:var(--bl-ink);}
        .modal-dialog{max-width:650px;margin-top:7vh;}
        .modal-content{border:0!important;border-radius:15px!important;overflow:hidden;box-shadow:0 24px 60px rgba(16,24,40,.22);}
        .modal-header{background:var(--bl-navy)!important;border:0;padding:20px 24px;}
        .modal-title{font-size:18px!important;font-weight:700;margin:0;}
        .modal-body{padding:25px 24px!important;background:#fff;}
        .modal-body form{float:none!important;width:100%;display:flex;flex-wrap:wrap;margin:0 -6px;}
        .modal-body .form-group{padding:0 6px;margin-bottom:18px;}
        .modal-body label{font-size:12px;font-weight:600;color:var(--bl-ink);margin-bottom:7px;}
        .modal-body .form-control,.modal-body .select2-container .select2-selection{height:43px!important;border:1px solid #d0d5dd!important;border-radius:8px!important;box-shadow:none;}
        .modal-body input.form-control{padding:9px 12px;}
        .modal-footer{padding:16px 24px;border-top:1px solid var(--bl-line);background:#fbfcfd;}
        .modal-footer .btn{border-radius:8px!important;padding:9px 17px;font-weight:600;border:1px solid transparent;}
        .modal-footer .btn-secondary{background:#fff;color:var(--bl-ink);border-color:#d0d5dd;}
        #btnsubmit,#btnupdate{float:none!important;background:var(--bl-accent)!important;border-color:var(--bl-accent)!important;color:#fff!important;}
        #btnsubmit:hover,#btnupdate:hover{background:var(--bl-accent-dark)!important;}
        @media(max-width:767px){.page-title-box{align-items:flex-start;flex-direction:column;padding-top:18px}.page-title-box .page-title{font-size:22px}#btnAddstd{width:100%}.card-body{padding:14px!important}#datatable_wrapper>.col-md-2{float:none!important;width:100%!important;max-width:none!important;padding:0!important}#datatable_wrapper>.col-md-2 br{display:none}.table-responsive{border:0}.modal-dialog{margin:12px}.modal-body .form-group{width:100%;flex:0 0 100%;max-width:100%}.modal-footer{display:flex;flex-wrap:wrap}.modal-footer .btn{flex:1;min-width:90px}}
    
        /* UX V2 */
        .ux-subtitle{margin-top:4px;color:#667085;font-size:13px;font-weight:500}.page-title-box{display:flex!important;align-items:center!important;justify-content:space-between!important;gap:16px!important;border-bottom:0!important}.page-title-box .page-title{margin:0!important}.card{border:1px solid #e4e7ec!important;box-shadow:0 4px 18px rgba(16,24,40,.05)!important}.card-body{padding:22px!important}#datatable_wrapper{position:relative}#datatable_wrapper>.col-md-2{margin-bottom:16px!important}#datatable_wrapper>.col-md-2 b{display:block;margin-bottom:6px;color:#344054;font-size:12px;font-weight:700}.form-control,.custom-select{min-height:42px!important;border:1px solid #d0d5dd!important;border-radius:9px!important;background:#fff!important;box-shadow:0 1px 2px rgba(16,24,40,.04)!important}.form-control:focus,.custom-select:focus{border-color:#98a2b3!important;box-shadow:0 0 0 3px rgba(152,162,179,.14)!important}.table thead th{padding:13px 14px!important;font-size:12px!important;text-transform:uppercase;letter-spacing:.035em;white-space:nowrap}.table tbody td{padding:14px!important;vertical-align:middle!important;color:#344054!important}.table tbody tr:hover{background:#f9fafb!important}.editStdInfo,.delstdinfo{width:36px;height:36px;padding:0!important;display:inline-flex!important;align-items:center;justify-content:center;border-radius:8px!important}.editStdInfo{background:#eff8ff!important;color:#175cd3!important;border:1px solid #b2ddff!important}.delstdinfo{background:#fff1f3!important;color:#c01048!important;border:1px solid #fecdd6!important}.modal-dialog{max-width:720px!important}.modal-content{border:0!important;border-radius:16px!important;overflow:hidden!important;box-shadow:0 24px 48px rgba(16,24,40,.2)!important}.modal-header{background:#101828!important;padding:20px 24px!important}.modal-title{font-size:18px!important}.modal-body{padding:24px!important;background:#fff}.modal-body form{width:100%!important}.modal-body .form-group{padding:0 10px!important;margin-bottom:20px!important}.modal-body label{display:block;color:#344054;font-size:13px;font-weight:700;margin-bottom:6px}.ux-field-help{display:block;color:#98a2b3;font-size:11px;margin:-2px 0 7px}.ux-password-wrap{position:relative}.ux-password-wrap .form-control{padding-right:46px!important}.ux-password-toggle{position:absolute;right:6px;top:5px;width:34px;height:32px;border:0!important;background:transparent!important;color:#667085;border-radius:7px!important}.ux-password-toggle:hover{background:#f2f4f7!important;color:#101828}.modal-footer{padding:16px 24px!important;background:#f9fafb!important;border-top:1px solid #eaecf0!important}.modal-footer .btn{border-radius:9px!important;min-height:40px;padding:9px 16px!important;font-weight:700!important}.modal-footer #btnsubmit,.modal-footer #btnupdate{background:#172554!important;border-color:#172554!important}.dataTables_info{color:#667085!important;font-size:12px!important;font-weight:500!important}.pagination .page-link{border-radius:7px!important;margin:0 2px!important}
        @media(max-width:767px){.ux-subtitle{font-size:12px}.page-title-box{align-items:stretch!important}.modal-dialog{max-width:none!important}.modal-body{padding:18px 14px!important}.modal-body .form-group{padding:0!important}.table{min-width:720px}.modal-footer .btn{width:100%!important;flex:none!important}}
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
                                <div><h4 class="page-title clstAddUser"><i class="fa fa-users" style="margin-right:9px"></i>User Management</h4><div class="ux-subtitle">Create accounts, assign roles and manage access from one simple screen.</div></div>
                                <button type="button" style="background: #2c2b30; float: right; margin-top: 10px; color: #ffffff" class="btn clstAddNewUser" id="btnAddstd" data-toggle="modal" data-target="#myModal"><i class="fa fa-plus" style="margin-right:7px"></i>Add New User</button>

                            </div>
                        </div>
                    </div>
                    <!-- end page title -->
                    <div style="margin-top: 20px" class="row" id="divtablestart">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-body table-responsive">

                                    <div id="datatable_wrapper" class="dataTables_wrapper dt-bootstrap4 no-footer">
                                        <div class="col-md-2" style="float: left; margin-bottom: 1%;">
                                            <b class="clstShowEntries">Rows per page</b>
                                            <select name="datatable_length" aria-controls="datatable" style="height: 34px;" class="custom-select custom-select-sm form-control form-control-sm">
                                                <option value="10">10</option>
                                                <option value="25">25</option>
                                                <option value="50">50</option>
                                                <option value="100">100</option>
                                            </select>
                                        </div>
                                        <div class="col-md-2" style="float: right">
                                            <br />
                                            <input class="form-control to clssearchtxtinput" id="txtinput" type="text" style="height: 34px;" placeholder="Type to search users..." autocomplete="off" />
                                        </div>
                                        <div class="col-md-2" style="float: right">
                                            <b class="clstSearchColumnWise">Search by</b>
                                            <select class="select2_single form-control clssearchcolumn" id="txtsearch" style="width: 100%;">
                                            </select>
                                        </div>

                                        <div id="export3">

                                            <div class="table-responsive">
                                                <table id="datatable" class="table" style="width: 100%; font-family: Arial, Helvetica, sans-serif !important;">
                                                    <thead style="background-color: #2c2b30" class="tableheading">
                                                        <tr role="row">
                                                            <th style="width: 6%;">Sr#</th>
                                                            <th class="clstusername">User Name</th>
                                                            <th class="clstEmail">Email</th>
                                                            <th class="clstRoleName">Role Name</th>
                                                            <th class="clstPassword">Security</th>
                                                            <th class="clstEditDelete">Actions</th>
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


        </div>
        <div id="myModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header" style="background-color: #4f4f51">

                        <h4 class="modal-title" style="color: #ffffff" id="insertHead"><strong><i class="fa fa-user-plus" style="margin-right:8px"></i>Add User</strong></h4>
                        <h4 class="modal-title" style="color: #ffffff" id="updateHead"><strong><i class="fa fa-user" style="margin-right:8px"></i>Edit User</strong></h4>
                        <!--<button type="button" class="close pull-right" data-dismiss="modal" aria-hidden="true">×</button>-->
                    </div>
                    <div style="display: flex; flex-wrap: wrap;"
                        class="modal-body">
                        <form style="float: left">

                            <div class="form-group col-lg-6 col-md-12 col-sm-12">
                                <label for="ddlrolename"><span class="clstSelectRoleName">Role</span><span class="text-danger">*</span></label><small class="ux-field-help">Choose the access role for this user.</small>
                                <select class="select2_single form-control " style="height: 34px ;width: 100%;" id="ddlrolename">
                                </select>
                            </div>
                            <div class="form-group col-lg-6 col-md-12 col-sm-12">
                                <label for="txtusername"><span class="clstusername">User Name</span><span class="text-danger">*</span></label>
                                <input id="txtusername" style="height: 35px" type="text" name="" placeholder="Enter User Name" class="form-control" />
                            </div>
                            <div class="form-group col-lg-6 col-md-12 col-sm-12">
                                <label for="txtemail"><span class="clstEmail">Email Address</span><span class="text-danger">*</span></label>
                                <input id="txtemail" style="height: 35px" type="email" name="txtemail" placeholder="name@example.com" class="form-control" autocomplete="email" />
                            </div>
                            <div class="form-group col-lg-6 col-md-12 col-sm-12">
                                <label for="txtpassword"><span class="clstPassword">Password</span><span class="text-danger">*</span></label><small class="ux-field-help">Use a secure password for this account.</small>
                                <div class="ux-password-wrap"><input id="txtpassword" style="height: 35px" type="password" name="txtpassword" placeholder="Enter password" class="form-control" autocomplete="new-password" /><button type="button" id="btnTogglePassword" class="ux-password-toggle" aria-label="Show password"><i class="fa fa-eye"></i></button></div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary waves-effect clstCancel" data-dismiss="modal"><i class="fa fa-times"></i> Cancel</button>
                        <button type="button" style="float: right; background-color: #f58f7c; border-color: #f58f7c" class="btn btn-primary clstSave" id="btnsubmit"><i class="fa fa-check"></i> Create User</button>
                        <button type="button" style="float: right; background-color: #f58f7c; border-color: #f58f7c" class="btn btn-info clstUpdate" id="btnupdate"><i class="fa fa-check"></i> Save Changes</button>
                    </div>

                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
    </div>
    <!-- sample modal content -->

    <!-- /.modal -->
    <!-- END wrapper -->
</asp:Content>
