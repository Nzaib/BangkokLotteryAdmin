<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="suitespk.Dashboard" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="assets/dashboard-modern.css" />
</asp:Content>
<asp:Content ID="ContentBody" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="content-page bl-dashboard-page">
        <div class="content">
            <div class="container-fluid bl-dashboard">

                <div class="dash-heading">
                    <div>
                        <h1>Dashboard</h1>
                        <p>Live administration overview for Bangkok Lottery.</p>
                    </div>
                    <div class="dash-clock"><span class="clock-dot"></span>
                        <div><small>THAILAND TIME (UTC+7)</small><strong id="dashServerClock">--:--:--</strong></div>
                    </div>
                </div>

                <div class="stats-grid">
                    <article class="stat-card stat-blue">
                        <div class="stat-icon"><i class="mdi mdi-calendar-month-outline"></i></div>
                        <div class="stat-copy"><span>TOTAL DRAWS</span><strong id="statTotal">0</strong><small>This Month</small></div>
                    </article>
                    <article class="stat-card stat-green">
                        <div class="stat-icon"><i class="mdi mdi-check-circle-outline"></i></div>
                        <div class="stat-copy"><span>COMPLETED DRAWS</span><strong id="statCompleted">0</strong><small id="statCompletedNote">0% Completed</small></div>
                        <div class="progress-track"><b id="completedProgress"></b></div>
                    </article>
                    <article class="stat-card stat-orange">
                        <div class="stat-icon"><i class="mdi mdi-play-circle-outline"></i></div>
                        <div class="stat-copy"><span>UPCOMING DRAWS</span><strong id="statUpcoming">0</strong><small id="statNextNote">Next: --</small></div>
                    </article>
                    <article class="stat-card stat-purple">
                        <div class="stat-icon"><i class="mdi mdi-broadcast"></i></div>
                        <div class="stat-copy"><span>LIVE DRAWS</span><strong id="statLive">0</strong><small id="liveStatusText">System Ready</small></div>
                    </article>
                </div>

                <div class="dashboard-main-grid">
                    <section class="dash-card broadcast-card">
                        <div class="card-title-row">
                            <h2>NEXT BROADCAST</h2>
                            <span class="badge-live" id="nextStatus">READY</span></div>
                        <div class="broadcast-body">
                            <div class="broadcast-copy">
                                <h3 id="nextDrawName">Next Scheduled Draw</h3>
                                <p id="nextDrawCode">--</p>
                                <p id="countdownMessage">Draw will start in</p>
                                <div class="countdown">
                                    <div><strong id="cdDays">00</strong><span>DAYS</span></div>
                                    <b>:</b><div><strong id="cdHours">00</strong><span>HOURS</span></div>
                                    <b>:</b><div><strong id="cdMinutes">00</strong><span>MINUTES</span></div>
                                    <b>:</b><div><strong id="cdSeconds">00</strong><span>SECONDS</span></div>
                                </div>
                                <div class="broadcast-date"><i class="mdi mdi-calendar-month-outline"></i><span id="nextDrawDate">No scheduled draw</span></div>
                                <a id="startBroadcastLink" class="start-broadcast" href="Game/BangkokDrawAdmin.aspx"><i class="mdi mdi-play"></i>Open Draw Control</a>
                            </div>
                            <div class="mini-machine">
                                <div class="mm-ring r1"></div>
                                <div class="mm-ring r2"></div>
                                <span class="mm-ball b1">8</span><span class="mm-ball b2">3</span><span class="mm-ball b3">6</span><span class="mm-ball b4">1</span><span class="mm-ball b5">9</span></div>
                        </div>
                    </section>

                    <section class="dash-card result-card">
                        <div class="card-title-row">
                            <h2>LAST DRAW RESULT</h2>
                            <span class="badge-complete">COMPLETED</span></div>
                        <p class="draw-date" id="lastDrawDate">No completed draw</p>
                        <div class="result-list">
                            <div><span>1st Prize Six Digit</span><strong id="resultFirst">- - - - - -</strong></div>
                            <div><span>2Down Straight</span><strong id="result2Down">- -</strong></div>
                            <div><span>3Up Straight Rumble</span><strong id="result3Straight">- - -</strong></div>
                            <div><span>3Up Open Pair</span><strong id="resultOpenPair">- -</strong></div>
                            <div><span>3Up Close Pair</span><strong id="resultClosePair">- -</strong></div>
                        </div>
                        <a class="outline-action" href="Game/BangkokDrawAdmin.aspx"><i class="mdi mdi-content-copy"></i>View All Results</a>
                    </section>

                    <section class="dash-card status-card">
                        <div class="card-title-row">
                            <h2><i class="mdi mdi-shield-check-outline"></i>SYSTEM STATUS</h2>
                        </div>
                        <div class="status-list">
                            <div><span><i class="mdi mdi-database-outline"></i>Database</span><b class="status-ok" id="statusDb">Checking</b></div>
                            <div><span><i class="mdi mdi-file-code-outline"></i>API Service</span><b class="status-ok" id="statusApi">Checking</b></div>
                            <div><span><i class="mdi mdi-broadcast"></i>Broadcast Service</span><b class="status-ok" id="statusBroadcast">Checking</b></div>
                            <div><span><i class="mdi mdi-clock-outline"></i>Server Time</span><em id="serverTimeRow">--</em></div>
                        </div>
                        <button class="outline-action" type="button" id="btnRefreshDashboard"><i class="mdi mdi-refresh"></i>Refresh Dashboard</button>
<a href="/api/bangkok-draw/history-chart/pdf"
   class="btn btn-primary"
   target="_blank"
   title="Download FIRST historical chart PDF">
    <i class="fa fa-file-pdf-o"></i>
    FIRST History PDF
</a>

<a href="/api/bangkok-draw/history-chart/down/pdf"
   class="btn btn-primary"
   target="_blank"
   title="Download 2Down historical chart PDF">
    <i class="fa fa-file-pdf-o"></i>
    2Down History PDF
</a>                    </section>
                </div>

                <div class="dashboard-bottom-grid">
                    <section class="dash-card upcoming-card">
                        <div class="card-title-row">
                            <h2>UPCOMING DRAWS</h2>
                            <a href="Game/BangkokDrawAdmin.aspx">View All Schedules</a></div>
                        <div class="table-responsive">
                            <table class="dash-table">
                                <thead>
                                    <tr>
                                        <th>Draw Code</th>
                                        <th>Draw Name</th>
                                        <th>Draw Date &amp; Time</th>
                                        <th>Games</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody id="upcomingDrawRows">
                                    <tr>
                                        <td colspan="5" class="loading-cell">Loading...</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </section>
                    <section class="dash-card overview-card">
                        <div class="card-title-row">
                            <h2>DRAWS OVERVIEW <small>(This Month)</small></h2>
                        </div>
                        <div class="overview-wrap">
                            <div class="donut" id="drawDonut">
                                <div><strong id="donutTotal">0</strong><span>Total</span></div>
                            </div>
                            <div class="legend">
                                <div><i class="lg green"></i><span>Completed</span><strong id="legendCompleted">0 (0%)</strong></div>
                                <div><i class="lg orange"></i><span>Upcoming</span><strong id="legendUpcoming">0 (0%)</strong></div>
                                <div><i class="lg blue"></i><span>Other</span><strong id="legendOther">0 (0%)</strong></div>
                            </div>
                        </div>
                    </section>
                </div>

            </div>
        </div>
    </div>

    <script>
        (function () {
            var countdownTimer = null,
                dashboardRefreshTimer = null,
                serverOffset = 0,
                currentBroadcastStatus = "";
            function headers() { return { "Authorization": localStorage["access_token"] }; }
            function parseUtc(value) {
                if (!value) return null;

                var text = String(value).trim();

                // SQL/Web API can sometimes return an ISO value without Z/offset.
                // ScheduledStartUTC is defined as UTC, so make that explicit.
                if (!/[zZ]$/.test(text) && !/[+\-]\d{2}:\d{2}$/.test(text))
                    text += "Z";

                var d = new Date(text);
                return isNaN(d.getTime()) ? null : d;
            }

            function fmtThailand(utc) { if (!utc) return "--"; var d = parseUtc(utc); if (!d) return "--"; return d.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric", timeZone: "Asia/Bangkok" }) + ", " + d.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: false, timeZone: "Asia/Bangkok" }) + " (THAILAND)"; }
            function spaced(v, n) { v = String(v || "").replace(/\D/g, ""); return v ? v.split("").join(" ") : Array(n + 1).join("- "); }
            function calculateNextDrawFromLast(lastDraw) {
                if (!lastDraw || !lastDraw.ScheduledStartUTC) return null;
                var last = parseUtc(lastDraw.ScheduledStartUTC);
                if (!last) return null;

                var serverNow = new Date(Date.now() + serverOffset);
                var nowTH = new Date(serverNow.getTime() + 7 * 3600000);
                var lastTH = new Date(last.getTime() + 7 * 3600000);
                var h = lastTH.getUTCHours(), min = lastTH.getUTCMinutes(), sec = lastTH.getUTCSeconds();

                function target(y, m, day) {
                    return new Date(Date.UTC(y, m, day, h - 7, min, sec));
                }

                var y = nowTH.getUTCFullYear(), m = nowTH.getUTCMonth();
                var candidates = [target(y,m,1), target(y,m,16), target(m===11?y+1:y,(m+1)%12,1)];
                for (var i=0;i<candidates.length;i++) {
                    if (candidates[i] > serverNow && candidates[i] > last) {
                        return {
                            DrawID: 0, DrawCode: "", DrawName: "Next Bangkok Lottery Draw",
                            DrawStatus: "Scheduled", ScheduledStartUTC: candidates[i].toISOString(),
                            GameCount: 2, IsCalculated: true
                        };
                    }
                }
                return null;
            }

            function startCountdown(utc) {
                if (countdownTimer) clearInterval(countdownTimer);

                var target = parseUtc(utc);
                if (!target) {
                    $("#countdownMessage").text("Broadcast time unavailable");
                    $("#cdDays,#cdHours,#cdMinutes,#cdSeconds").text("00");
                    return;
                }

                function tick() {
                    // Use the server clock offset returned by the Dashboard API.
                    // This prevents a wrong countdown when the admin PC clock is incorrect.
                    var serverNow = new Date(new Date().getTime() + serverOffset);
                    var diff = target.getTime() - serverNow.getTime();

                    if (diff <= 0) {
                        $("#cdDays,#cdHours,#cdMinutes,#cdSeconds").text("00");
                        $("#countdownMessage").text("Broadcast is ready to start");
                        $("#nextStatus").text("READY");
                        clearInterval(countdownTimer);
                        countdownTimer = null;
                        window.setTimeout(function(){ load(true); }, 1500);
                        return;
                    }

                    var days = Math.floor(diff / 86400000);
                    var hours = Math.floor((diff % 86400000) / 3600000);
                    var minutes = Math.floor((diff % 3600000) / 60000);
                    var seconds = Math.floor((diff % 60000) / 1000);

                    $("#countdownMessage").text("Draw will start in");
                    $("#cdDays").text(String(days).padStart(2, "0"));
                    $("#cdHours").text(String(hours).padStart(2, "0"));
                    $("#cdMinutes").text(String(minutes).padStart(2, "0"));
                    $("#cdSeconds").text(String(seconds).padStart(2, "0"));
                }

                tick();
                countdownTimer = setInterval(tick, 1000);
            }
            function render(data) {
                var s = data.summary || {}, last = data.lastDraw, next = data.nextBroadcast || data.nextSchedule || calculateNextDrawFromLast(last), results = data.latestResults || [], calc = data.calculated || {}, status = data.systemStatus || {};
                currentBroadcastStatus = next && next.DrawStatus ? String(next.DrawStatus) : "";
                $("#statTotal,#donutTotal").text(s.totalDraws || 0); $("#statCompleted").text(s.completedDraws || 0); $("#statUpcoming").text(s.upcomingDraws || 0); $("#statLive").text(s.liveDraws || 0);
                $("#statCompletedNote").text((s.completedPercent || 0) + "% Completed"); $("#completedProgress").css("width", (s.completedPercent || 0) + "%");
                $("#legendCompleted").text((s.completedDraws || 0) + " (" + (s.completedPercent || 0) + "%)"); $("#legendUpcoming").text((s.upcomingDraws || 0) + " (" + (s.upcomingPercent || 0) + "%)"); $("#legendOther").text((s.otherDraws || 0) + " (" + (s.otherPercent || 0) + "%)");
                var cp = s.completedPercent || 0, up = s.upcomingPercent || 0; $("#drawDonut").css("background", "conic-gradient(#2eaf52 0 " + cp + "%,#ff8a16 " + cp + "% " + (cp + up) + "%,#2f7dd8 " + (cp + up) + "% 100%)");
                if (next) { $("#nextDrawName").text(next.DrawName || "Next Scheduled Draw"); $("#nextDrawCode").text(next.DrawCode || ""); $("#nextStatus").text(next.DrawStatus || "READY"); $("#nextDrawDate").text(fmtThailand(next.ScheduledStartUTC)); $("#statNextNote").text("Next: " + fmtThailand(next.ScheduledStartUTC)); if (next.DrawID > 0) $("#startBroadcastLink").attr("href", "Game/BangkokDrawAdmin.aspx?drawId=" + next.DrawID); else $("#startBroadcastLink").attr("href", "Game/BangkokDrawAdmin.aspx"); startCountdown(next.ScheduledStartUTC); }
                var html = ""; $.each(data.upcomingDraws || [], function (_, x) { html += "<tr><td>" + x.DrawCode + "</td><td>" + x.DrawName + "</td><td>" + fmtThailand(x.ScheduledStartUTC) + "</td><td>" + x.GameCount + "</td><td><span class='table-status'>" + x.DrawStatus.toUpperCase() + "</span></td></tr>"; }); $("#upcomingDrawRows").html(html || "<tr><td colspan='5' class='loading-cell'>No upcoming draws.</td></tr>");
                if (last) $("#lastDrawDate").text((last.DrawCode || "") + " • " + fmtThailand(last.ActualEndUTC || last.ScheduledStartUTC));
                var first = "", down = ""; $.each(results, function (_, r) { if (r.GameCode === "FIRST") first = r.ResultNumber; if (r.GameCode === "DOWN") down = r.ResultNumber; });
                $("#resultFirst").text(spaced(first, 6)); $("#result2Down").text(spaced(down, 2)); $("#result3Straight").text(spaced(calc.threeUpStraight, 3)); $("#resultOpenPair").text(spaced(calc.threeUpOpenPair, 2)); $("#resultClosePair").text(spaced(calc.threeUpClosePair, 2));
                $("#statusDb").text(status.database || "Online"); $("#statusApi").text(status.apiService || "Online"); $("#statusBroadcast").text(status.broadcastService || "Ready"); $("#liveStatusText").text((status.broadcastService || "Ready") + " System");
            }
            function scheduleDashboardRefresh() {
                if (dashboardRefreshTimer)
                    clearTimeout(dashboardRefreshTimer);

                var status = (currentBroadcastStatus || "").toLowerCase();
                var refreshMs = 30000; // Normal dashboard refresh: 30 seconds.

                // Faster refresh while the draw is actively changing.
                if (status === "live" || status === "paused" || status === "revealing")
                    refreshMs = 10000;

                dashboardRefreshTimer = setTimeout(function () {
                    load(true);
                }, refreshMs);
            }

            function load(isAutoRefresh) {
                $.ajax({
                    headers: headers(), url: "/api/admin/bangkok-draw/dashboard", method: "GET", dataType: "json", success: function (r) {
                        if (r && r.success) {
                            var server = parseUtc(r.serverUtc);
                            serverOffset = server ? (server.getTime() - Date.now()) : 0;
                            render(r.data);
                            $("#statusDb,#statusApi,#statusBroadcast").removeClass("status-bad").addClass("status-ok");
                            scheduleDashboardRefresh();
                        }
                    }, error: function (xhr) {
                        $("#statusDb,#statusApi,#statusBroadcast").text("Unavailable").removeClass("status-ok").addClass("status-bad");
                        if (xhr.status === 401) {
                            window.location = "index.aspx";
                            return;
                        }

                        if (dashboardRefreshTimer)
                            clearTimeout(dashboardRefreshTimer);

                        dashboardRefreshTimer = setTimeout(function () {
                            load(true);
                        }, 30000);
                    }
                });
            }
            $(function () {
                load(false);

                $("#btnRefreshDashboard").on("click", function () {
                    load(false);
                });

                // The visible Thailand/server clock still updates locally every second.
                setInterval(function () {
                    var d = new Date(Date.now() + serverOffset);
                    $("#dashServerClock").text(d.toLocaleTimeString("en-US", { timeZone: "Asia/Bangkok" }));
                    $("#serverTimeRow").text(d.toLocaleString("en-GB", { timeZone: "Asia/Bangkok" }));
                }, 1000);

                // When the admin returns to the browser tab, refresh immediately.
                document.addEventListener("visibilitychange", function () {
                    if (!document.hidden)
                        load(false);
                });

                window.addEventListener("beforeunload", function () {
                    if (dashboardRefreshTimer) clearTimeout(dashboardRefreshTimer);
                    if (countdownTimer) clearInterval(countdownTimer);
                });
            });
        })();
    
        $('#btnDownloadHistoryChart').on('click', function () {
            var $btn = $(this), oldHtml = $btn.html();
            $btn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Generating PDF...');
            $.ajax({
                url: '<%= ResolveUrl("~/api/bangkok-draw/history-chart/pdf") %>',
                method: 'GET',
                cache: false,
                xhrFields: { responseType: 'blob' }
            }).done(function (blob, status, xhr) {
                var fileName = 'Bangkok-Lottery-History-Chart.pdf';
                var disposition = xhr.getResponseHeader('Content-Disposition') || '';
                var match = /filename="?([^"]+)"?/i.exec(disposition);
                if (match && match[1]) fileName = match[1];
                var url = window.URL.createObjectURL(blob);
                var a = document.createElement('a');
                a.href = url; a.download = fileName;
                document.body.appendChild(a); a.click(); document.body.removeChild(a);
                window.setTimeout(function () { window.URL.revokeObjectURL(url); }, 1000);
            }).fail(function () {
                if (window.toastr) toastr.error('Unable to generate the history draw chart PDF.');
                else alert('Unable to generate the history draw chart PDF.');
            }).always(function () {
                $btn.prop('disabled', false).html(oldHtml);
            });
        });
</script>
</asp:Content>
