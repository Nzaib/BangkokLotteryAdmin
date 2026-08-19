<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="suitespk.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>DPBOSS -Login page</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta content="Responsive bootstrap 4 admin template" name="description" />
    <meta content="Coderthemes" name="author" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />

    <link rel="icon" type="image/png" href="~/Webimages/favicon-96x96.png" sizes="96x96" />
    <link rel="icon" type="image/svg+xml" href="~/Webimages/favicon.svg" />
    <link rel="shortcut icon" href="~/Webimages/favicon.ico" />
    <link rel="apple-touch-icon" sizes="180x180" href="~/Webimages/apple-touch-icon.png" />

    <!-- App favicon -->
    <script src="js/jquery-3.4.1.min.js"></script>
    <%--<link rel="shortcut icon" href="img/logoa.png" />--%>
    <script src="assets/js/vendor.min.js"></script>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="./assets/css/toastr.min.css" />
    <link href="assets/libs/sweetalert2/sweetalert2.min.css" rel="stylesheet" type="text/css" />
    <script src="assets/libs/sweetalert2/sweetalert2.min.js"></script>
    <script src="assets/libs/toastr/toastr.min.js"></script>
    <script>
        var url = "/"

        localStorage.clear();
        $(document).ready(function () {

            var email = sessionStorage.getItem("useremail")
            var password = sessionStorage.getItem("password")

            if (email !== null) {
                $('#txtemailaddress').val(email);
            }

            if (password !== null) {
                $('#txtpassword').val(password);
            }


            $(document).on('click', '#btnlogin', function () {


                if ($('#txtemailaddress').val() == "") {
                    toastr["error"]("Enter E-mail");
                    $('#txtemailaddress').focus();
                    return false;
                }

                if ($('#txtpassword').val() == "") {
                    toastr["error"]("Enter Password");
                    $('#txtpassword').focus();
                    return false;
                }

                sessionStorage.setItem("useremail", $('#txtemailaddress').val());
                sessionStorage.setItem("password", $('#txtpassword').val());



                var status = false;
                var UserLogin = {};
                UserLogin.username = $('#txtemailaddress').val();
                UserLogin.password = $('#txtpassword').val()
                UserLogin.grant_type = "password";
                $.ajax({
                    async: false,
                    type: "POST",
                    url: url + "login",
                    data: UserLogin,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {

                        status = true;
                        $(data).each(function (index, value) {


                            if (value.token_type == "bearer") {


                                localStorage["access_token"] = value.token_type + " " + value.access_token;
                                $.ajax({
                                    headers: {
                                        "Authorization": localStorage["access_token"]
                                    },
                                    url: url + "api/logged-user-info",
                                    async: false,
                                    method: 'GET',
                                    success: function (data) {
                                        $(data).each(function (index, value) {
                                            localStorage["username"] = value.username;
                                            localStorage["role_id"] = value.role_id;
                                            localStorage["login_id"] = value.login_id;
                                            localStorage["email"] = value.email;
                                            localStorage["company_id"] = value.company_id;
                                        });
                                       swal({
                                            type: 'success',
                                            title: 'User Have Been Login Successfully ',
                                            icon: "success",
                                            showConfirmButton: false,
                                            timer: 2000
                                        });
                                        window.location.href = "../Game/BangkokDrawAdmin.aspx";

                                      



                                    }
                                });
                            }

                        });


                    }
                });



                if (status == false) {
                    swal({
                        type: 'error',
                        title: 'Oops...',
                        text: 'Invalid Username or Password!',
                        showConfirmButton: false,
                        timer: 2000
                    });
                }

            });


            $(document).on('keypress', function (e) {
                if (e.which == 13) {
                    $('#btnlogin').click();
                }
            });

        });
    </script>
    <style>
        #divRecapticha {
            padding: 5px;
        }

        .tool-tip {
            display: inline-block;
        }

            .tool-tip [disabled] {
                pointer-events: none;
            }
    </style>
    <style>
        .justify-content-center {
            margin-top: 10%;
        }

        .bg-primary {
            background-color: #421a1a00 !important;
        }

        /*.btn-primary:hover {
            color: #fff;
            background-color: #1a5051;
            border-color: #083334;
        }
*/
        body {
            /*background-image: url(images/bg10.jpg);*/
            /*background-size: 100%;*/

            background-color: #d3cece;
            /*background-attachment: fixed;
            background-repeat: repeat-x;
            background-size: contain;*/
        }

        /* .card-body {
            color: #fff;
        }*/

        .card {
            background-color: #ffffff00 !important;
            background-clip: border-box;
            border: 0px;
        }

        .text-muted {
            color: #ffffff !important;
        }

        .mt-4, .my-4 {
            margin-top: 0px !important;
        }

        .maindiv {
            border-radius: 15px;
            padding-top: 3%;
            background-color: #ffffffd6;
        }

        .card, .card-box {
            margin-bottom: 0px !important;
        }

        @media (max-width: 768px) {
            body {
                background-color: #ffffffd6;
                margin: 5%;
            }

            .maindiv {
                border-radius: 15px;
                padding-top: 3%;
                background-color: #ffffffd6;
                border: 1px dashed;
                margin-top: 10%;
            }
        }
    </style>
</head>
<body class="authentication-page">

    <div class="account-pages my-5">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-8 col-lg-6 col-xl-5 maindiv" style="">
                    <%--<igc src="img\logo.png" style="height: 157px; margin-left: 37%;" />--%>
                    <center>




                        <h2>
                            <b style="color: #f58f7c">

                                <ul>
                                    <img src="/img/logo2.png" alt="" style="width: 60%; float: none; margin-left: -7%;" height="" />

                                </ul>
                            </b>
                        </h2>



                    </center>
                    <div class="card mt-4">

                        <div class=" bg-primary" style="border-radius: 15px;">
                            <h4 class="text-white text-center mb-0 mt-0" style="color: #000000 !important;">Login Panel</h4>
                        </div>
                        <div class="card-body">
                            <form action="#" class="p-2">

                                <div class="form-group mb-3">
                                    <label style="font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif;" for="emailaddress">Email Address :</label>
                                    <input style="background-color: #d6d6d6;" class="form-control" type="text" id="txtemailaddress" required="" placeholder="user@dpboss.com" />
                                </div>

                                <div class="form-group mb-3">
                                    <label style="font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif;" for="password">Password :</label>
                                    <input style="background-color: #d6d6d6;" class="form-control" type="password" required="" id="txtpassword" placeholder="Enter your password" />
                                </div>


                                <div class="form-group mb-3">
                                    <button style="background-color: #35a571;" class="btn btn-md btn-block ry waves-effect waves-light" type="button" id="btnlogin">LogIn</button>
                                    <%--<a style="float: right; color: white; text-decoration: underline" href="/forgot_password.aspx">Reset Password</a>--%>
                                </div>

                            </form>

                        </div>
                        <!-- end card-body -->
                    </div>
                    <!-- end card -->

                    <!-- end row -->








                </div>
                <!-- end col -->
            </div>
            <!-- end row -->

        </div>
    </div>



</body>
</html>
