<%@ Page Title="" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="suitespk.Profile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Profile</title>
    <script src="PasswordCheck/password.js"></script>
    <link href="PasswordCheck/password.css" rel="stylesheet" />
    <script>
        var getimgpath, getimgpath2, oldimg, getcityname;
        $(document).ready(function () {
            $('#txtxUsername').val(localStorage["username"]);
            $('#txtemail').val(localStorage["email"]);


            $("#txtconpassword").keyup(function () {
                if ($(".txtpassword").val() != $("#txtconpassword").val()) {
                    $("#label-msg").html("Password do not match").css("color", "red");
                } else {
                    $("#label-msg").html("Password matched").css("color", "green");
                }
            });
        
            $(document).on('click',
                '#btnupdatepassword',
                function () {
                    var ClsUpdatePassword = {};
                    ClsUpdatePassword.newpassword = $('.txtpassword').val();
                    ClsUpdatePassword.oldpassword = $('#txtoldpass').val();
                    $.ajax({
                        headers: {
                            "Authorization": localStorage["access_token"]
                        },
                        url: url + "api/AddUser/UpdatePassword",
                        async: false,
                        method: 'PUT',
                        contentType: 'application/json;charset=utf-8',
                        data: JSON.stringify(ClsUpdatePassword),
                        success: function (data) {
                            swal({
                                title: "Done",
                                text: "New Password Succefully Updated",
                                icon: "success",
                            });
                        },
                        error: function (jqXHR, exception) {
                            toastr["info"](jqXHR.responseJSON);
                        }
                    });

                });
          
         

        });
      
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
                                <h4 class="page-title">Profile</h4>
                                <div class="clearfix"></div>
                            </div>
                        </div>
                    </div>
                    <!-- end page title -->
                    <hr />
                    <div class="row">
                        <div class="col-12">

                            <div class="col-md-6 col-sm-12 col-xs-12" style="float: left">

                                <div class="card">
                                    <div class="card-body table-responsive">
                                        <div class="x_panel">
                                            <div class="x_title">
                                                <h2>Profile</h2>
                                                <div class="clearfix"></div>
                                            </div>
                                            <div class="x_content">
                                                <form>
                                                    <div class="form-group">
                                                        <label>User Name</label>
                                                        <input type="email" class="form-control" style=" height:34px;"  disabled="disabled" id="txtxUsername" placeholder="User Name" />
                                                    </div>
                                                    <div class="form-group">
                                                        <label>Email address</label>
                                                        <input type="email" class="form-control" style=" height:34px;" disabled="disabled" id="txtemail" placeholder="E-mail" />
                                                    </div>
                                                </form>
                                            </div>
                                        </div>

                                    </div>




                                </div>
                            </div>
                            <div class="col-md-6 col-sm-12 col-xs-12" style="float: right">

                                <div class="card">
                                    <div class="card-body table-responsive">

                                        <div class="x_panel">
                                            <div class="x_title">
                                                <h2>Change Password</h2>
                                                <div class="clearfix"></div>
                                            </div>
                                            <div class="x_content">

                                                <div class="form-group">
                                                    <label>Old Password</label>
                                                    <input type="password" style=" height:34px;"  class="form-control" id="txtoldpass" placeholder="Old Password">
                                                </div>
                                                <div class="form-group">
                                                    <label>New Password</label>
                                                    <input id="events" type="password" style=" height:34px;" class="form-control txtpassword" placeholder="New Password">
                                                </div>
                                                <div class="form-group">
                                                    <label>Confirm Password</label>
                                                    <input type="password" id="txtconpassword" style=" height:34px;" placeholder="confirm password" class="form-control">
                                                </div>
                                                <div class="form-group">
                                                    <span id="label-msg" style="float: left;"></span>
                                                </div>
                                                <br />
                                                <button type="button" style="background-color:#2c2b30; float:right" class="btn btn-success" id="btnupdatepassword"><i class="fa fa-refresh fa-spin" id="idupdatepassword" style="display: none;"></i>Update</button>

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
</asp:Content>
