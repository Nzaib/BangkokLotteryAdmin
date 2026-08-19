<%@ Page Title="Bangkok Lottery Admin" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="BangkokDrawAdmin.aspx.cs" Inherits="TechnoPurAccounts.Game.BangkokDrawAdmin" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>.bkk-admin,.bkk-admin input,.bkk-admin select,.bkk-admin textarea,.bkk-admin button,.bkk-admin table{font-size:12px}.bkk-stat small,.bkk-stat strong{display:block}.bkk-status{display:inline-block;text-align:center}.bkk-admin .table td,.bkk-admin .table th{vertical-align:middle;white-space:nowrap}</style>
    <script>
        var selectedDrawId = 0;
        var selectedDrawStatus = '';
        var adminApi = 'api/admin/bangkok-draw';
        var autoProcessorBusy = false;

        $(document).ready(function () {
            $('.page-title').html('Bangkok Lottery Administration');
            $('#txtDrawDate').val(getTodayDate());
            setDefaultDrawIdentity($('#txtDrawDate').val());
            $('#txtScheduledStartUTC').val(getSaudiDateTimeValue());
            loadDraws();

            $('#txtDrawDate').on('change', function () {
                setDefaultDrawIdentity($(this).val());
            });

            $('#btnCreateDraw').on('click', createDraw);
            $(document).on('click', '[data-target="#createDrawModal"]', function () { resetCreateDrawForm(); });
            $(document).on('input', '.bkk-result-input', function () {
                this.value = this.value.replace(/\D/g, '').slice(0, Number($(this).attr('maxlength')) || 20);
                $(this).removeClass('is-invalid');
            });
            $('#btnRefreshDraws').on('click', loadDraws);
            $('#btnRefreshControl').on('click', function () { if (selectedDrawId) loadControl(selectedDrawId); });
            $('#btnPublish').on('click', function () { drawAction('publish', 'Draw published successfully and is now Ready.'); });

            $(document).on('click', '.btn-select-draw', function (e) {
                e.preventDefault();
                selectedDrawId = Number($(this).data('id'));
                selectedDrawStatus = $(this).data('status') || '';
                $('#tblDraws tr').removeClass('bkk-selected-row');
                $(this).closest('tr').addClass('bkk-selected-row');
                loadControl(selectedDrawId);
            });
            $(document).on('click', '.btn-save-result', function (e) { e.preventDefault(); saveResult(Number($(this).data('gameid'))); });
            $(document).on('click', '.btn-confirm-result', function (e) { e.preventDefault(); confirmResult(Number($(this).data('resultid'))); });
            $(document).on('click', '.btn-delete-draw', function (e) { e.preventDefault(); deleteDraw(Number($(this).data('id')), $(this).data('status') || ''); });

            runAutomaticProcessor();
            window.setInterval(runAutomaticProcessor, 5000);
        });

        function authHeaders() { return { 'Authorization': localStorage['access_token'] }; }
        function getTodayDate() {
            return getSaudiDateTimeValue().slice(0, 10);
        }
        function getSaudiDateTimeValue() {
            var parts = new Intl.DateTimeFormat('en-CA', {
                timeZone: 'Asia/Riyadh', year: 'numeric', month: '2-digit', day: '2-digit',
                hour: '2-digit', minute: '2-digit', hourCycle: 'h23'
            }).formatToParts(new Date());
            var value = {};
            $.each(parts, function (_, part) { value[part.type] = part.value; });
            return value.year + '-' + value.month + '-' + value.day + 'T' + value.hour + ':' + value.minute;
        }
        function resetCreateDrawForm() {
            var saudiDateTime = getSaudiDateTimeValue(), saudiDate = saudiDateTime.slice(0, 10);
            clearValidation('#createDrawModal');
            $('#txtDrawDate').val(saudiDate);
            setDefaultDrawIdentity(saudiDate);
            $('#txtScheduledStartUTC').val(saudiDateTime);
            $('#ddlTimeZone').val('Arab Standard Time');
            $('#txtCountdown').val(45); $('#txtRepeatDays').val(15);
            $('#txtDownOffset').val(0); $('#txtFirstOffset').val(300);
            $('#txtRevealInterval').val(10); $('#txtRemarks').val('');
        }
        function setDefaultDrawIdentity(dateValue) {
            if (!dateValue) return;
            var parts = dateValue.split('-');
            if (parts.length !== 3) return;
            var date = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
            if (isNaN(date.getTime())) return;
            var code = 'BKK-' + parts[0] + parts[1] + parts[2];
            var name = 'Bangkok Lottery – ' + date.toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
            $('#txtDrawCode').val(code);
            $('#txtDrawName').val(name);
        }
        function apiUrl(path) { return url + adminApi + (path || ''); }
        function safe(value) { return $('<div/>').text(value == null ? '' : value).html(); }
        function displayDate(value) {
            if (!value) return '-';
            if (typeof value === 'string' && !/[zZ]$/.test(value) && !/[+-]\d\d:\d\d$/.test(value)) value += 'Z';
            var d = new Date(value); if (isNaN(d.getTime())) return safe(value);
            return new Intl.DateTimeFormat('en-GB', {
                timeZone: 'Asia/Riyadh', day: '2-digit', month: 'short', year: 'numeric',
                hour: '2-digit', minute: '2-digit', second: '2-digit', hourCycle: 'h23'
            }).format(d);
        }
        function status(value) { value = value || 'Unknown'; return '<span class="bkk-status ' + safe(value) + '">' + safe(value) + '</span>'; }
        function errorMessage(xhr) { return (xhr.responseJSON && (xhr.responseJSON.message || xhr.responseJSON.Message)) || xhr.responseText || 'Request failed.'; }
        function notifyError(xhr) { toastr['error'](errorMessage(xhr)); }
        function notifySuccess(message) { toastr['success'](message); }

        function loadDraws(silent) {
            if (!silent) $('#tblDraws').html('<tr><td colspan="8" class="bkk-empty">Loading draws...</td></tr>');
            $.ajax({ headers: authHeaders(), url: apiUrl(''), method: 'GET', cache: false })
                .done(function (res) {
                    var rows = (res && res.data) || [], html = '';
                    if (!rows.length) html = '<tr><td colspan="8" class="bkk-empty">No Bangkok draw found.</td></tr>';
                    $.each(rows, function (_, d) {
                        html += '<tr data-id="' + d.DrawID + '"><td>' + d.DrawID + '</td><td>' + safe(d.DrawCode) + '</td><td>' + safe(d.DrawName) + '</td>' +
                            '<td>' + displayDate(d.ScheduledStartUTC) + '</td><td>' + status(d.DrawStatus) + '</td><td>' + (d.IsPublished ? 'Yes' : 'No') + '</td>' +
                            '<td>' + safe(d.GameCount) + '</td><td><button type="button" class="btn btn-sm btn-info btn-select-draw" data-id="' + d.DrawID + '" data-status="' + safe(d.DrawStatus) + '"><i class="fa fa-cogs"></i> Control</button> ' +
                            '<button type="button" class="btn btn-sm btn-danger btn-delete-draw" data-id="' + d.DrawID + '" data-status="' + safe(d.DrawStatus) + '"><i class="fa fa-trash"></i> Delete</button></td></tr>';
                    });
                    $('#tblDraws').html(html);
                    $('#statTotal').text(rows.length);
                    $('#statLive').text($.grep(rows, function (x) { return x.DrawStatus === 'Live' || x.DrawStatus === 'Paused'; }).length);
                    $('#statReady').text($.grep(rows, function (x) { return x.DrawStatus === 'Ready'; }).length);
                    $('#statCompleted').text($.grep(rows, function (x) { return x.DrawStatus === 'Completed'; }).length);
                    if (selectedDrawId) { $('#tblDraws tr[data-id="' + selectedDrawId + '"]').addClass('bkk-selected-row'); }
                }).fail(notifyError);
        }

        function createDraw() {
            var start = $('#txtScheduledStartUTC').val();
            var model = {
                DrawCode: $('#txtDrawCode').val().trim(), DrawName: $('#txtDrawName').val().trim(),
                DrawDate: $('#txtDrawDate').val(), ScheduledStartUTC: start,
                TimeZoneID: $('#ddlTimeZone').val(), CountdownMinutes: Number($('#txtCountdown').val()),
                RepeatEveryDays: Number($('#txtRepeatDays').val()), DownStartOffsetSeconds: Number($('#txtDownOffset').val()),
                FirstStartOffsetSeconds: Number($('#txtFirstOffset').val()), DigitRevealIntervalSeconds: Number($('#txtRevealInterval').val()),
                Remarks: $('#txtRemarks').val().trim()
            };
            clearValidation('#createDrawModal');
            if (!model.DrawCode) { return invalid('#txtDrawCode', 'Draw code is required.'); }
            if (!/^[A-Za-z0-9-]{4,30}$/.test(model.DrawCode)) { return invalid('#txtDrawCode', 'Use 4–30 letters, numbers or hyphens for the draw code.'); }
            if (!model.DrawName) { return invalid('#txtDrawName', 'Draw name is required.'); }
            if (!model.DrawDate) { return invalid('#txtDrawDate', 'Draw date is required.'); }
            if (!model.ScheduledStartUTC) { return invalid('#txtScheduledStartUTC', 'Scheduled start time is required.'); }
            if (model.CountdownMinutes < 1 || model.CountdownMinutes > 1440) { return invalid('#txtCountdown', 'Countdown must be between 1 and 1440 minutes.'); }
            if (model.RepeatEveryDays < 1 || model.RepeatEveryDays > 365) { return invalid('#txtRepeatDays', 'Repeat days must be between 1 and 365.'); }
            if (model.DownStartOffsetSeconds < 0) { return invalid('#txtDownOffset', 'DOWN offset cannot be negative.'); }
            if (model.FirstStartOffsetSeconds < 1) { return invalid('#txtFirstOffset', 'FIRST must start after DOWN.'); }
            if (model.FirstStartOffsetSeconds <= model.DownStartOffsetSeconds) { return invalid('#txtFirstOffset', 'FIRST offset must be later than the DOWN offset.'); }
            if (model.DigitRevealIntervalSeconds < 1 || model.DigitRevealIntervalSeconds > 300) { return invalid('#txtRevealInterval', 'Reveal interval must be between 1 and 300 seconds.'); }
            $('#btnCreateDraw').prop('disabled', true);
            $.ajax({ headers: authHeaders(), url: apiUrl(''), method: 'POST', contentType: 'application/json;charset=utf-8', data: JSON.stringify(model) })
                .done(function () { $('#createDrawModal').modal('hide'); notifySuccess('Bangkok draw created.'); loadDraws(); })
                .fail(notifyError).always(function () { $('#btnCreateDraw').prop('disabled', false); });
        }

        function normalizeControl(data) {
            var sets = data || []; if (!Array.isArray(sets)) return { draw: data.draw || {}, games: data.games || [] };
            return { draw: (sets[0] && sets[0][0]) || {}, games: sets[1] || [] };
        }
        function loadControl(drawId, silent) {
            $('#controlPanel').show(); $('#selectedDrawId').text(drawId); if (!silent) $('#tblGames').html('<tr><td colspan="8" class="bkk-empty">Loading control...</td></tr>');
            $.ajax({ headers: authHeaders(), url: apiUrl('/' + drawId + '/control'), method: 'GET', cache: false })
                .done(function (res) {
                    var c = normalizeControl(res.data), d = c.draw || {}; selectedDrawStatus = d.DrawStatus || selectedDrawStatus;
                    $('#selectedDrawCode').text(d.DrawCode || 'Draw #' + drawId); $('#selectedDrawStatus').html(status(selectedDrawStatus));
                    $('#selectedSchedule').text(displayDate(d.ScheduledStartUTC)); renderGames(c.games || []); setPublishButton(); loadResults(drawId);
                }).fail(notifyError);
        }
        function renderGames(games) {
            var html = ''; if (!games.length) html = '<tr><td colspan="8" class="bkk-empty">No active games found.</td></tr>';
            $.each(games, function (_, g) {
                html += '<tr><td>' + g.DrawGameID + '</td><td><strong>' + safe(g.GameCode) + '</strong><br/><small>' + safe(g.GameName) + '</small></td><td>' + g.DigitCount + '</td>' +
                    '<td>' + displayDate(g.ScheduledStartUTC) + '</td><td>' + status(g.GameStatus) + '</td><td id="result-' + g.DrawGameID + '">-</td>' +
                    '<td id="resultstatus-' + g.DrawGameID + '">-</td><td id="resultaction-' + g.DrawGameID + '">' +
                    '<div class="input-group input-group-sm"><input id="number-' + g.DrawGameID + '" class="form-control bkk-result-input" maxlength="' + g.DigitCount + '" inputmode="numeric" pattern="[0-9]*" required aria-required="true" data-digits="' + g.DigitCount + '" placeholder="' + g.DigitCount + ' digits required" />' +
                    '<div class="input-group-append"><button type="button" class="btn btn-dark btn-save-result" data-gameid="' + g.DrawGameID + '">Save</button></div></div></td></tr>';
            }); $('#tblGames').html(html);
        }
        function loadResults(drawId) {
            $.ajax({ headers: authHeaders(), url: apiUrl('/' + drawId + '/results'), method: 'GET', cache: false })
                .done(function (res) {
                    $.each(res.data || [], function (_, r) {
                        $('#result-' + r.DrawGameID).html('<strong>' + safe(r.ResultNumber) + '</strong>');
                        var timing = r.IsLateEntry ? '<br/><small class="text-danger">Late entry' + (r.EntryDelaySeconds != null ? ' (' + r.EntryDelaySeconds + ' sec)' : '') + '</small>' : '<br/><small class="text-muted">Entry recorded</small>';
                        $('#resultstatus-' + r.DrawGameID).html(status(r.ResultStatus) + timing);
                        var button = r.IsConfirmed ? '<span class="text-success"><i class="fa fa-check"></i> Confirmed</span>' : '<button type="button" class="btn btn-sm btn-success btn-confirm-result" data-resultid="' + r.ResultID + '">Confirm</button>';
                        $('#resultaction-' + r.DrawGameID).html(button);
                    });
                }).fail(notifyError);
        }
        function saveResult(gameId) {
            var input = $('#number-' + gameId), number = input.val().trim(), digits = Number(input.data('digits'));
            input.removeClass('is-invalid');
            if (!number) { input.addClass('is-invalid').focus(); toastr['error']('Result number is required.'); return; }
            if (!/^\d+$/.test(number)) { input.addClass('is-invalid').focus(); toastr['error']('Enter digits only.'); return; }
            if (number.length !== digits) { input.addClass('is-invalid').focus(); toastr['error']('This result must contain exactly ' + digits + ' digits.'); return; }
            var model = { DrawGameID: gameId, ResultNumber: number, ResultSource: 'Manual', Remarks: 'Entered from Bangkok Lottery Admin' };
            $.ajax({ headers: authHeaders(), url: apiUrl('/' + selectedDrawId + '/enter-result'), method: 'POST', contentType: 'application/json;charset=utf-8', data: JSON.stringify(model) })
                .done(function () { notifySuccess('Result saved.'); loadControl(selectedDrawId); }).fail(notifyError);
        }
        function confirmResult(resultId) {
            swal({ title: 'Confirm this result?', text: 'The confirmed result will be used during the live reveal.', icon: 'warning', buttons: true, dangerMode: true })
                .then(function (ok) {
                    if (!ok) return; $.ajax({ headers: authHeaders(), url: apiUrl('/results/' + resultId + '/confirm'), method: 'POST' })
                        .done(function () { notifySuccess('Result confirmed.'); loadControl(selectedDrawId); }).fail(notifyError);
                });
        }
        function drawAction(action, message) {
            if (!selectedDrawId) { toastr['error']('Select a draw first.'); return; }
            $.ajax({ headers: authHeaders(), url: apiUrl('/' + selectedDrawId + '/' + action), method: 'POST' })
                .done(function () { notifySuccess(message); loadDraws(); loadControl(selectedDrawId); }).fail(notifyError);
        }
        function setPublishButton() {
            $('#btnPublish').prop('disabled', selectedDrawStatus !== 'Draft');
        }
        function runAutomaticProcessor() {
            if (autoProcessorBusy) return;
            autoProcessorBusy = true;
            $.ajax({ headers: authHeaders(), url: apiUrl('/auto-process'), method: 'POST', cache: false })
                .done(function () {
                    $('#autoProcessorState').removeClass('text-danger').addClass('text-success').text('Automatic processor active');
                    loadDraws(true);
                    if (selectedDrawId && !$('.bkk-result-input:focus').length && !$('#createDrawModal').hasClass('show')) loadControl(selectedDrawId, true);
                })
                .fail(function (xhr) { $('#autoProcessorState').removeClass('text-success').addClass('text-danger').text('Automatic processor error: ' + errorMessage(xhr)); })
                .always(function () { autoProcessorBusy = false; });
        }
        function deleteDraw(drawId, drawStatus) {
            swal({ title: 'Delete this draw?', text: 'The draw and its active broadcast will be removed from the system, regardless of its current status.', icon: 'warning', buttons: true, dangerMode: true })
                .then(function (ok) {
                    if (!ok) return;
                    $.ajax({ headers: authHeaders(), url: apiUrl('/' + drawId + '/delete'), method: 'DELETE' })
                        .done(function () {
                            if (selectedDrawId === drawId) { selectedDrawId = 0; selectedDrawStatus = ''; $('#controlPanel').hide(); }
                            notifySuccess('Draw deleted successfully.'); loadDraws();
                        }).fail(notifyError);
                });
        }
        function clearValidation(parent) { $(parent + ' .is-invalid').removeClass('is-invalid'); }
        function invalid(selector, message) { $(selector).addClass('is-invalid').focus(); toastr['error'](message); return false; }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div id="wrapper" class="bkk-admin">
        <div class="content-page">
            <div class="content">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-12">
                            <div class="page-title-box">
                                <div><div class="bkk-page-kicker">Draw Management</div><h4 class="page-title"></h4><div class="bkk-page-subtitle">Schedule, publish and manage Bangkok Lottery draws and results.</div></div>
                                <div style="float: right; margin-top: 10px">
                                    <button id="btnRefreshDraws" type="button" class="btn btn-light"><i class="fa fa-refresh"></i>Refresh</button>
                                    <button type="button" class="btn btn-dark" data-toggle="modal" data-target="#createDrawModal"><i class="fa fa-plus"></i>Create Draw</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-3">
                            <div class="card bkk-stat"><small>Total Draws</small><strong id="statTotal">0</strong></div>
                        </div>
                        <div class="col-md-3">
                            <div class="card bkk-stat"><small>Live / Paused</small><strong id="statLive">0</strong></div>
                        </div>
                        <div class="col-md-3">
                            <div class="card bkk-stat"><small>Ready</small><strong id="statReady">0</strong></div>
                        </div>
                        <div class="col-md-3">
                            <div class="card bkk-stat"><small>Completed</small><strong id="statCompleted">0</strong></div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-body table-responsive">
                                    <h5>Draw Schedule and History</h5>
                                    <table class="table table-bordered table-hover">
                                        <thead class="thead-light">
                                            <tr>
                                                <th>ID</th>
                                                <th>Code</th>
                                                <th>Name</th>
                                                <th>Scheduled Start</th>
                                                <th>Status</th>
                                                <th>Published</th>
                                                <th>Games</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tblDraws"></tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div id="controlPanel" style="display: none">
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-7">
                                                <h5 id="selectedDrawCode">Selected Draw</h5>
                                                <div>ID: <strong id="selectedDrawId"></strong>&nbsp; Status: <span id="selectedDrawStatus"></span>&nbsp; Schedule: <strong id="selectedSchedule"></strong></div>
                                            </div>
                                            <div class="col-md-5 text-right"><span id="autoProcessorState" class="text-success mr-2">Automatic processor active</span>
                                                <button id="btnRefreshControl" type="button" class="btn btn-sm btn-light"><i class="fa fa-refresh"></i>Refresh Control</button></div>
                                        </div>
                                        <hr />
                                        <div class="bkk-action-group">
                                            <button id="btnPublish" type="button" class="btn btn-info draw-action"><i class="fa fa-upload"></i>Publish</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-body table-responsive">
                                        <h5>Games and Results</h5>
                                        <p class="text-muted">Results may be entered before or after the scheduled game time. The server records the entry time and identifies late entries for audit purposes.</p>
                                        <table class="table table-bordered">
                                            <thead class="thead-light">
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Game</th>
                                                    <th>Digits</th>
                                                    <th>Scheduled Start</th>
                                                    <th>Game Status</th>
                                                    <th>Result</th>
                                                    <th>Result Status</th>
                                                    <th>Entry / Confirmation</th>
                                                </tr>
                                            </thead>
                                            <tbody id="tblGames"></tbody>
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

    <div class="modal fade" id="createDrawModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Create Bangkok Lottery Draw</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button></div>
                <div class="modal-body">
                    <div class="form-row">
                        <div class="form-group col-md-4">
                            <label>Draw Code <span class="text-danger">*</span></label><input id="txtDrawCode" class="form-control" maxlength="30" required aria-required="true" placeholder="BKK-20260916" /><div class="invalid-feedback">A valid draw code is required.</div>
                        </div>
                        <div class="form-group col-md-8">
                            <label>Draw Name <span class="text-danger">*</span></label><input id="txtDrawName" class="form-control" maxlength="200" required aria-required="true" placeholder="Bangkok Lottery – 16 September 2026" /><div class="invalid-feedback">Draw name is required.</div>
                        </div>
                        <div class="form-group col-md-4">
                            <label>Draw Date <span class="text-danger">*</span></label><input id="txtDrawDate" type="date" class="form-control" required aria-required="true" /><div class="invalid-feedback">Draw date is required.</div>
                        </div>
                        <div class="form-group col-md-4">
                            <label>Scheduled Start (Saudi Arabia Time) <span class="text-danger">*</span></label><input id="txtScheduledStartUTC" type="datetime-local" class="form-control" required aria-required="true" /><div class="invalid-feedback">Start time is required.</div>
                        </div>
                        <div class="form-group col-md-4">
                            <label>Time Zone</label><select id="ddlTimeZone" class="form-control"><option value="Arab Standard Time">Saudi Arabia (UTC+3)</option>
                            </select></div>
                        <div class="form-group col-md-3">
                            <label>Countdown Minutes</label><input id="txtCountdown" type="number" class="form-control" value="45" min="1" /></div>
                        <div class="form-group col-md-3">
                            <label>Repeat Every Days</label><input id="txtRepeatDays" type="number" class="form-control" value="15" min="1" /></div>
                        <div class="form-group col-md-2">
                            <label>DOWN Offset</label><input id="txtDownOffset" type="number" class="form-control" value="0" min="0" /></div>
                        <div class="form-group col-md-2">
                            <label>FIRST Offset</label><input id="txtFirstOffset" type="number" class="form-control" value="300" min="1" required /><small class="form-text text-muted">300 sec = 5 minutes after DOWN</small></div>
                        <div class="form-group col-md-2">
                            <label>Reveal Seconds</label><input id="txtRevealInterval" type="number" class="form-control" value="10" min="1" /></div>
                        <div class="form-group col-12">
                            <label>Remarks</label><textarea id="txtRemarks" class="form-control" rows="2"></textarea></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-dismiss="modal">Cancel</button>
                    <button id="btnCreateDraw" type="button" class="btn btn-dark">Create Draw</button></div>
            </div>
        </div>
    </div>
</asp:Content>
