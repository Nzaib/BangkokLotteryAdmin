<%@ Page Title="" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="AddUserRole.aspx.cs" Inherits="TechnoPurAccounts.AddUser.AddUserRole" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
     <script>
        var id=0;
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
                $('#btnsubmit').hide();
                $('#btnupdate').show();
                $('#insertHead').hide();
                $('#updateHead').show();
                id = ($(this).attr("id"));
                var $tr = $(this).closest('tr');
                $('#txtRoleName').val(unescape($tr.find('td:nth-child(2)').text()));
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
            $('#txtRoleName').val("");
        
        }


        //showing Teacher info in table
        function ShowTableRecord(pageNumber, pageSize, divide, searchtext, textsearchcolumnvalue) {
            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + "api/AddUserRole/GetUserRoleHistory?pageNumber=" + pageNumber + "&pageSize=" + pageSize + "&QuerySearch=" + searchtext + "&QuerySearchColumn=" + textsearchcolumnvalue,
                async: false,
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    var voucherOptions = $('#tablerows');
                    voucherOptions.empty();

                    if (data.jsonretrundata.length > 0) {

                        $(data.jsonretrundata).each(function (index, infostd) {
                            voucherOptions.append('<tr><td>' + (index + 1) + '</td> <td>' + unescape(infostd.role_name) + '</td>  <td><button type="button" class="btn btn-info editStdInfo" data-toggle="modal" data-target="#myModal" style="border-radius:0px;"  id="' + infostd.id + '"><i class="fa fa-edit"></i></button>&nbsp;&nbsp;&nbsp;<button type="button" class="btn btn-danger delstdinfo" style="border-radius:0px;" id="' + infostd.id + '" ><i class="fa fa-trash"></i></button></td> </tr>');
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

            var apipath = "api/AddUserRole/UserRoleInsert";
            var apimethod = "Post";


            if (submittype == "update") {
                apipath = "api/AddUserRole/UserRoleUpdate";
                apimethod = "Put";
            }

            else if (submittype == "delete") {
                apipath = "api/AddUserRole/UserRoleDelete?id=" + id;
                apimethod = "Delete";
            }




            if (submittype != "delete") {
                if ($('#txtRoleName').val() == "") {
                    toastr["error"]("Club Name is required");
                    $('#txtRoleName').focus();
                    return false;
                }
            }

            var clsUserRoleInsert = {};
            clsUserRoleInsert.role_name = escape($('#txtRoleName').val());
            clsUserRoleInsert.id = id;
            $.ajax({
                headers: {
                    "Authorization": localStorage["access_token"]
                },
                url: url + apipath,
                async: false,
                method: apimethod,
                contentType: 'application/json;charset=utf-8',
                data: JSON.stringify(clsUserRoleInsert),
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




     </script>

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
                                <h4 class="page-title">Add Role</h4>
                                <button type="button" style="background: #2c2b30; float: right; margin-top: 10px; color: #ffffff" class="btn" id="btnAddstd" data-toggle="modal" data-target="#myModal">Add New Role</button>

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
                                            <b class="clstShowEntries">Show entries</b>
                                            <select name="datatable_length" aria-controls="datatable" style="height: 34px;" class="custom-select custom-select-sm form-control form-control-sm">
                                                <option value="10">10</option>
                                                <option value="25">25</option>
                                                <option value="50">50</option>
                                                <option value="100">100</option>
                                            </select>
                                        </div>
                                        <div class="col-md-2" style="float: right">
                                            <br />
                                            <input class="form-control to clssearchtxtinput" id="txtinput" type="text" style="height: 34px;" />
                                        </div>
                                        <div class="col-md-2" style="float: right">
                                            <b class="clstSearchColumnWise">Search Column Wise</b>
                                            <select class="select2_single form-control clssearchcolumn" id="txtsearch" style="width: 100%;">
                                            </select>
                                        </div>

                                        <div id="export3">

                                            <div class="table-responsive">
                                                <table id="datatable" class="table" style="width: 100%; font-family: Arial, Helvetica, sans-serif !important;">
                                                    <thead style="background-color: #2c2b30" class="tableheading">
                                                        <tr role="row">
                                                            <th style="width: 6%;">Sr#</th>
                                                            <th class="clstRoleName">Role Name</th>
                                                            <th class="clstEditDelete">Edit/Delete</th>
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

                        <h4 class="modal-title" style="color: #ffffff" id="insertHead"><strong class="clstAddRole">Add Role Info</strong></h4>
                        <h4 class="modal-title" style="color: #ffffff" id="updateHead"><strong class="clstEditRole">Edit Role Info</strong></h4>
                    </div>
                    <div style="display: flex; flex-wrap: wrap;"
                        class="modal-body">
                        <form style="float: left">
                            <div class="form-group col-lg-6 col-md-12 col-sm-12">
                                <label for="fname"><span class="clstRoleName">Role Name</span><span class="text-danger">*</span></label>
                                <input id="txtRoleName" style="height: 35px" type="text" name="" placeholder="Enter Role Name" class="form-control" />
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary waves-effect clstCancel" data-dismiss="modal">Cancel</button>
                        <button type="button" style="float: right; background-color: #f58f7c; border-color: #f58f7c" class="btn btn-primary clstSave" id="btnsubmit">Save</button>
                        <button type="button" style="float: right; background-color: #f58f7c; border-color: #f58f7c" class="btn btn-info clstUpdate" id="btnupdate">Update</button>
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
