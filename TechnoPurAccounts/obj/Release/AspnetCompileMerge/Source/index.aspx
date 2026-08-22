<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="suitespk.Default" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta charset="utf-8" />
<title>Bangkok Lottery Administration</title>
<meta name="viewport" content="width=device-width,initial-scale=1" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<link rel="icon" href="img/glo-logo.jpeg" />
<script src="js/jquery-3.4.1.min.js"></script>
<script src="assets/js/vendor.min.js"></script>
<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
<link rel="stylesheet" href="./assets/css/toastr.min.css" />
<link href="assets/libs/sweetalert2/sweetalert2.min.css" rel="stylesheet" />
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
                                        window.location.href = "Dashboard.aspx";

                                      



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
*{box-sizing:border-box}html,body{margin:0;min-height:100%;font-family:"Segoe UI",Arial,sans-serif}body{overflow:hidden;background:#f3f7fc}
.login-page{min-height:100vh;display:grid;grid-template-columns:56% 44%}
.visual-panel{position:relative;overflow:hidden;padding:40px 52px;color:#fff;background:radial-gradient(circle at 85% 15%,rgba(65,135,255,.30),transparent 25%),linear-gradient(145deg,#061631,#092657 55%,#0b3579);background-size:140% 140%;animation:bgMove 9s ease-in-out infinite}
.visual-grid{position:absolute;inset:0;opacity:.22;background-image:linear-gradient(rgba(255,255,255,.06) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.06) 1px,transparent 1px);background-size:48px 48px;animation:gridMove 12s linear infinite}
.brand{position:relative;z-index:3;display:flex;align-items:center;gap:15px;animation:slideIn .8s both}.brand img{width:76px;height:76px;object-fit:contain;background:#fff;border-radius:18px;padding:7px;box-shadow:0 15px 35px rgba(0,0,0,.2);animation:logoFloat 3s ease-in-out infinite}.brand small{display:block;color:#9fc2ff;font-size:12px;font-weight:800;letter-spacing:2px;margin-bottom:5px}.brand strong{font-size:18px}
.hero{position:relative;z-index:3;max-width:590px;margin-top:12vh}.status-chip{display:inline-flex;align-items:center;gap:8px;padding:7px 11px;border-radius:30px;border:1px solid rgba(255,255,255,.14);background:rgba(255,255,255,.07);font-size:12px;font-weight:800;letter-spacing:1px;color:#d2e3ff;animation:rise .7s .1s both,chipFloat 3s 1s ease-in-out infinite}.dot{width:7px;height:7px;border-radius:50%;background:#4ce09c;animation:pulse 1.8s infinite}
.hero h1{    color: aliceblue;font-size:clamp(44px,4.5vw,70px);line-height:1.02;letter-spacing:-2.5px;margin:22px 0 18px;font-weight:800;animation:rise .8s .2s both}.hero h1 span{display:block;color:#8bbcff;animation:titleGlow 3s 1s ease-in-out infinite}.hero p{max-width:510px;color:#c5d6ef;font-size:13px;line-height:1.8;animation:rise .8s .34s both}
.feature-row{display:flex;gap:10px;flex-wrap:wrap;margin-top:28px;animation:rise .8s .48s both}.feature{position:relative;overflow:hidden;padding:9px 12px;border:1px solid rgba(255,255,255,.1);border-radius:10px;background:rgba(255,255,255,.07);font-size:12px;color:#d1e1f8;animation:featureFloat 3.6s ease-in-out infinite}.feature:nth-child(2){animation-delay:-1.2s}.feature:nth-child(3){animation-delay:-2.4s}
.machine{position:absolute;right:5%;bottom:5%;width:340px;height:300px;z-index:2;animation:machineFloat 4s ease-in-out infinite}.ring{position:absolute;left:50%;top:50%;border-radius:50%;transform:translate(-50%,-50%)}.r1{width:270px;height:270px;border:1px solid rgba(135,184,255,.28);animation:spin 14s linear infinite}.r2{width:220px;height:220px;border:1px dashed rgba(135,184,255,.25);animation:spinBack 9s linear infinite}.r3{width:165px;height:165px;border:1px solid rgba(135,184,255,.18);background:rgba(44,111,220,.08);animation:ringPulse 3s ease-in-out infinite}
.ball{position:absolute;width:44px;height:44px;border-radius:50%;display:grid;place-items:center;background:linear-gradient(145deg,#fff,#dbe8fa);color:#124a99;font-size:14px;font-weight:900;border:3px solid rgba(255,255,255,.75);box-shadow:0 12px 24px rgba(0,0,0,.22);animation:ballFloat 2.7s ease-in-out infinite}.b1{left:20%;top:25%}.b2{right:19%;top:24%;animation-delay:-.45s}.b3{left:13%;bottom:22%;animation-delay:-.9s}.b4{right:12%;bottom:20%;animation-delay:-1.35s}.b5{left:44%;top:43%;animation-delay:-1.8s}.b6{left:52%;bottom:2%;animation-delay:-2.25s}
.form-panel{position:relative;overflow:hidden;display:flex;align-items:center;justify-content:center;padding:45px;background:radial-gradient(circle at 85% 15%,rgba(35,104,216,.08),transparent 25%),linear-gradient(145deg,#fbfdff,#eef5fc);background-size:140% 140%;animation:rightBg 9s ease-in-out infinite}
.login-stage{position:relative;width:100%;max-width:455px;z-index:3;animation:stageFloat 4s ease-in-out infinite}
.orbit{position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);border-radius:50%;pointer-events:none}.o1{width:540px;height:540px;border:1px solid rgba(38,103,201,.10);animation:orbitPulse 3.5s ease-in-out infinite}.o2{width:610px;height:610px;border:1px dashed rgba(38,103,201,.09);animation:orbitSpin 22s linear infinite}
.login-card{position:relative;overflow:hidden;width:100%;padding:42px 40px 34px;border:0;border-radius:26px;background:rgba(255,255,255,.95);box-shadow:0 30px 75px rgba(17,48,91,.13),0 7px 22px rgba(17,48,91,.05);animation:cardEnter .85s cubic-bezier(.16,1,.3,1) both}
.login-card:before{content:"";position:absolute;width:220px;height:220px;left:-125px;top:-145px;border-radius:50%;background:radial-gradient(circle,rgba(45,111,211,.12),transparent 70%);animation:softGlow 5s ease-in-out infinite}.login-card:after{content:"";position:absolute;width:180px;height:180px;right:-95px;bottom:-105px;border-radius:50%;background:radial-gradient(circle,rgba(87,159,255,.10),transparent 70%);animation:softGlow2 6s ease-in-out infinite}
.login-content{position:relative;z-index:2}.admin-label{display:inline-flex;align-items:center;gap:7px;padding:6px 9px;border-radius:20px;background:#eaf2ff;color:#2865bf;font-size:12px;font-weight:850;letter-spacing:1.3px;animation:rise .6s .15s both}.admin-label i{width:6px;height:6px;border-radius:50%;background:#2cb278;animation:pulse 1.8s infinite}
.login-card h2{margin:15px 0 8px;font-size:36px;letter-spacing:-1.2px;color:#112342;font-weight:800;animation:rise .65s .22s both}.login-card h2 span{color:#2d6dc9;animation:titleGlowRight 3s ease-in-out infinite}.subtitle{margin:0 0 28px;color:#78869b;font-size:12px;line-height:1.65;animation:rise .65s .3s both}
.field{margin-bottom:18px;opacity:0;animation:fieldEnter .65s forwards}.email{animation-delay:.38s}.password{animation-delay:.50s}.field label{display:block;margin-bottom:8px;color:#536178;font-size:10px;font-weight:800}.field-shell{position:relative}.field-icon{position:absolute;left:15px;top:50%;transform:translateY(-50%);width:18px;height:18px;color:#91a0b6;transition:.25s}
.form-control{width:100%;height:51px!important;padding:0 48px!important;border:1px solid #dce5f0!important;border-radius:12px!important;background:#fff!important;font-size:12px!important;box-shadow:0 5px 18px rgba(21,51,93,.03)!important;transition:.25s!important}.field-shell:focus-within .form-control{transform:translateY(-2px);border-color:#5a8edb!important;box-shadow:0 10px 25px rgba(35,104,216,.10),0 0 0 4px rgba(35,104,216,.07)!important}.field-shell:focus-within .field-icon{color:#2867c4;transform:translateY(-50%) scale(1.08)}
.toggle-password{position:absolute;right:10px;top:50%;transform:translateY(-50%);border:0;border-radius:7px;background:#f1f5fa;color:#6d7b90;font-size:12px;font-weight:800;padding:6px 7px;cursor:pointer}
.login-button{position:relative;overflow:hidden;width:100%;height:51px;margin-top:4px;border:0;border-radius:12px;background:linear-gradient(100deg,#0c418c,#1f63c7 65%,#337bdf);color:#fff;display:flex;align-items:center;justify-content:center;gap:10px;font-size:13px;font-weight:800;box-shadow:0 15px 30px rgba(24,84,176,.24);opacity:0;animation:buttonEnter .65s .62s forwards,buttonBreath 2.5s 1.5s ease-in-out infinite;cursor:pointer}.login-button:before{content:"";position:absolute;left:-80%;top:0;width:55%;height:100%;background:linear-gradient(90deg,transparent,rgba(255,255,255,.30),transparent);transform:skewX(-22deg);animation:buttonShine 3.5s 1.2s infinite}.button-arrow{font-size:17px;transition:.25s}.login-button:hover .button-arrow{transform:translateX(5px)}
.security{display:flex;justify-content:center;align-items:center;gap:7px;margin-top:18px;color:#8b97a9;font-size:12px;opacity:0;animation:rise .6s .78s forwards}.security-dot{width:7px;height:7px;border-radius:50%;background:#2bb075;animation:pulse 2s infinite}
.mobile-logo{display:none;text-align:center;margin-bottom:22px}.mobile-logo img{width:84px;height:84px;object-fit:contain}
@keyframes bgMove{0%,100%{background-position:0 50%}50%{background-position:100% 50%}}@keyframes rightBg{0%,100%{background-position:0 0}50%{background-position:100% 100%}}@keyframes gridMove{to{background-position:48px 48px,48px 48px}}@keyframes slideIn{from{opacity:0;transform:translateX(-35px)}to{opacity:1;transform:none}}@keyframes rise{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:none}}@keyframes logoFloat{50%{transform:translateY(-8px)}}@keyframes chipFloat{50%{transform:translateY(-5px)}}@keyframes pulse{0%{box-shadow:0 0 0 0 rgba(75,224,154,.4)}70%{box-shadow:0 0 0 8px rgba(75,224,154,0)}}@keyframes titleGlow{50%{color:#acd0ff;text-shadow:0 0 28px rgba(96,160,255,.34)}}@keyframes titleGlowRight{50%{color:#347fe5;text-shadow:0 0 16px rgba(52,127,229,.20)}}@keyframes featureFloat{50%{transform:translateY(-6px)}}@keyframes machineFloat{50%{transform:translateY(-13px) scale(1.02)}}@keyframes spin{to{transform:translate(-50%,-50%) rotate(360deg)}}@keyframes spinBack{to{transform:translate(-50%,-50%) rotate(-360deg)}}@keyframes ringPulse{50%{transform:translate(-50%,-50%) scale(1.08);box-shadow:0 0 35px rgba(75,144,255,.14)}}@keyframes ballFloat{50%{transform:translateY(-23px) rotate(10deg) scale(1.07)}}@keyframes stageFloat{50%{transform:translateY(-8px)}}@keyframes orbitPulse{50%{transform:translate(-50%,-50%) scale(1.05);opacity:1}}@keyframes orbitSpin{to{transform:translate(-50%,-50%) rotate(360deg)}}@keyframes cardEnter{from{opacity:0;transform:translateX(40px) scale(.96)}to{opacity:1;transform:none}}@keyframes softGlow{50%{transform:translate(25px,18px) scale(1.08)}}@keyframes softGlow2{50%{transform:translate(-18px,-14px) scale(1.10)}}@keyframes fieldEnter{from{opacity:0;transform:translateX(28px)}to{opacity:1;transform:none}}@keyframes buttonEnter{from{opacity:0;transform:translateY(22px) scale(.97)}to{opacity:1;transform:none}}@keyframes buttonBreath{50%{box-shadow:0 19px 38px rgba(24,84,176,.38)}}@keyframes buttonShine{0%,55%{left:-80%}78%,100%{left:140%}}
@media(max-width:850px){body{overflow:auto}.login-page{display:block}.visual-panel{display:none}.form-panel{min-height:100vh;padding:26px 20px}.login-stage{max-width:430px}.orbit.o1{width:470px;height:470px}.orbit.o2{width:530px;height:530px}.login-card{padding:34px 25px 29px;border-radius:22px}.login-card h2{font-size:31px}.mobile-logo{display:block}}
</style>
</head>
<body>
<div class="login-page">
<section class="visual-panel">
    <div class="visual-grid"></div>
    <div class="brand"><img src="img/glo-logo.jpeg" alt="GLO" /><div><small>GOVERNMENT LOTTERY OFFICE</small><strong>Bangkok Lottery Administration</strong></div></div>
    <div class="hero">
        <div class="status-chip"><span class="dot"></span>SECURE ADMINISTRATION SYSTEM</div>
        <h1>Control every draw.<span>Publish with confidence.</span></h1>
        <p>A dedicated administration workspace for scheduling broadcasts, managing draw operations and publishing verified lottery results.</p>
        <div class="feature-row"><div class="feature">Live Draw Control</div><div class="feature">Secure Result Management</div><div class="feature">Central Administration</div></div>
    </div>
    <div class="machine"><div class="ring r1"></div><div class="ring r2"></div><div class="ring r3"></div><span class="ball b1">2</span><span class="ball b2">7</span><span class="ball b3">4</span><span class="ball b4">9</span><span class="ball b5">1</span><span class="ball b6">6</span></div>
</section>

<section class="form-panel">
    <div class="login-stage">
        <div class="orbit o1"></div><div class="orbit o2"></div>
        <main class="login-card">
            <div class="login-content">
                <div class="mobile-logo"><img src="img/glo-logo.jpeg" alt="GLO" /></div>
                <div class="admin-label"><i></i>ADMINISTRATOR ACCESS</div>
                <h2>Welcome <span>back.</span></h2>
                <p class="subtitle">Enter your credentials to continue to the Bangkok Lottery administration panel.</p>

                <div class="field email"><label>Email address</label><div class="field-shell">
                    <svg class="field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 5h16v14H4z"/><path d="m4 7 8 6 8-6"/></svg>
                    <input class="form-control" type="text" id="txtemailaddress" autocomplete="username" placeholder="Enter email address" />
                </div></div>

                <div class="field password"><label>Password</label><div class="field-shell">
                    <svg class="field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="5" y="10" width="14" height="10" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></svg>
                    <input class="form-control" type="password" id="txtpassword" autocomplete="current-password" placeholder="Enter password" />
                    <button type="button" class="toggle-password" id="togglePassword">SHOW</button>
                </div></div>

                <button class="login-button" type="button" id="btnlogin"><span>Sign in to Admin Panel</span><span class="button-arrow">→</span></button>
                <div class="security"><span class="security-dot"></span>Protected administration access</div>
            </div>
        </main>
    </div>
</section>
</div>

<script>
$(function(){
    $("#togglePassword").on("click",function(){
        var p=$("#txtpassword"),show=p.attr("type")==="password";
        p.attr("type",show?"text":"password");
        $(this).text(show?"HIDE":"SHOW");
    });
    $("#txtemailaddress,#txtpassword").on("keydown",function(e){
        if(e.keyCode===13){e.preventDefault();$("#btnlogin").trigger("click");}
    });
});
</script>
</body>
</html>