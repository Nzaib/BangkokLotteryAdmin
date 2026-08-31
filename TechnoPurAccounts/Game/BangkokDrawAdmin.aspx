<%@ Page Title="Bangkok Lottery Admin" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="BangkokDrawAdmin.aspx.cs" Inherits="TechnoPurAccounts.Game.BangkokDrawAdmin" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .bkk-admin, .bkk-admin input, .bkk-admin select, .bkk-admin textarea, .bkk-admin button, .bkk-admin table {
            font-size: 12px
        }

        .bkk-stat small, .bkk-stat strong {
            display: block
        }

        .bkk-status {
            display: inline-block;
            text-align: center
        }

        .bkk-admin .table td, .bkk-admin .table th {
            vertical-align: middle;
            white-space: nowrap
        }

        .bkk-history-toolbar{display:flex;gap:10px;align-items:center;justify-content:space-between;flex-wrap:wrap;margin:0 0 12px}
        .bkk-history-tools{display:flex;gap:8px;align-items:center;flex-wrap:wrap}
        .bkk-history-search{min-width:230px}
        .bkk-history-meta{font-size:12px;color:#6c757d}
        .bkk-pagination{display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;margin-top:12px}
        .bkk-page-buttons{display:flex;gap:4px;align-items:center;flex-wrap:wrap}
        .bkk-page-buttons .btn{min-width:34px}
        .bkk-download-chart{box-shadow:0 5px 14px rgba(0,123,255,.18);font-weight:600}
        .bkk-download-chart i{margin-right:5px}
        @media(max-width:767px){
            .bkk-history-toolbar,.bkk-pagination{align-items:stretch}
            .bkk-history-tools{width:100%}
            .bkk-history-search{min-width:0;flex:1 1 180px}
        }
    </style>
    <script>
        var selectedDrawId = 0;
        var selectedDrawStatus = '';
        var adminApi = 'api/admin/bangkok-draw';
        var autoProcessorBusy = false;
        var allDrawRows = [];
        var filteredDrawRows = [];
        var drawPage = 1;
        var drawPageSize = 2;

        $(document).ready(function () {
            $('.page-title').html('Bangkok Lottery Administration');
            $('#txtDrawDate').val(getTodayDate());
            setDefaultDrawIdentity($('#txtDrawDate').val());
            $('#txtScheduledStartUTC').val(getThailandDateTimeValue());
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
            $('#txtDrawSearch').on('input', function () { drawPage = 1; applyDrawFilter(); });
            $('#ddlDrawPageSize').on('change', function () { drawPageSize = Number(this.value) || 25; drawPage = 1; renderDrawPage(); });
            $(document).on('click', '.btn-draw-page', function () { drawPage = Number($(this).data('page')) || 1; renderDrawPage(); });
            $('#btnDrawPrev').on('click', function () { if (drawPage > 1) { drawPage--; renderDrawPage(); } });
            $('#btnDrawNext').on('click', function () { var pages = Math.max(1, Math.ceil(filteredDrawRows.length / drawPageSize)); if (drawPage < pages) { drawPage++; renderDrawPage(); } });
            $('#btnDownloadHistoryChart').on('click', downloadHistoryChart);
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
            $(document).on('click', '.btn-delete-draw', function (e) {

                e.preventDefault();

                var drawId = Number($(this).data('id'));
                var drawStatus = $(this).data('status') || '';

                deleteDraw(drawId, drawStatus);

            });
            runAutomaticProcessor();
            window.setInterval(runAutomaticProcessor, 5000);
        });

        function authHeaders() { return { 'Authorization': localStorage['access_token'] }; }
        function getTodayDate() {
            return getThailandDateTimeValue().slice(0, 10);
        }
        function getThailandDateTimeValue() {
            var parts = new Intl.DateTimeFormat('en-CA', {
                timeZone: 'Asia/Bangkok', year: 'numeric', month: '2-digit', day: '2-digit',
                hour: '2-digit', minute: '2-digit', hourCycle: 'h23'
            }).formatToParts(new Date());
            var value = {};
            $.each(parts, function (_, part) { value[part.type] = part.value; });
            return value.year + '-' + value.month + '-' + value.day + 'T' + value.hour + ':' + value.minute;
        }
        function resetCreateDrawForm() {
            var thailandDateTime = getThailandDateTimeValue(), thailandDate = thailandDateTime.slice(0, 10);
            clearValidation('#createDrawModal');
            $('#txtDrawDate').val(thailandDate);
            setDefaultDrawIdentity(thailandDate);
            $('#txtScheduledStartUTC').val(thailandDateTime);
            $('#ddlTimeZone').val('SE Asia Standard Time');
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
                timeZone: 'Asia/Bangkok', day: '2-digit', month: 'short', year: 'numeric',
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
                    allDrawRows = (res && res.data) || [];
                    $('#statTotal').text(allDrawRows.length);
                    $('#statLive').text($.grep(allDrawRows, function (x) { return x.DrawStatus === 'Live' || x.DrawStatus === 'Paused'; }).length);
                    $('#statReady').text($.grep(allDrawRows, function (x) { return x.DrawStatus === 'Ready'; }).length);
                    $('#statCompleted').text($.grep(allDrawRows, function (x) { return x.DrawStatus === 'Completed'; }).length);
                    applyDrawFilter();
                }).fail(notifyError);
        }

        function applyDrawFilter() {
            var q = ($('#txtDrawSearch').val() || '').trim().toLowerCase();
            filteredDrawRows = !q ? allDrawRows.slice() : $.grep(allDrawRows, function (d) {
                return String(d.DrawID || '').toLowerCase().indexOf(q) >= 0 ||
                    String(d.DrawCode || '').toLowerCase().indexOf(q) >= 0 ||
                    String(d.DrawName || '').toLowerCase().indexOf(q) >= 0 ||
                    String(d.DrawStatus || '').toLowerCase().indexOf(q) >= 0 ||
                    displayDate(d.ScheduledStartUTC).toLowerCase().indexOf(q) >= 0;
            });
            drawPage = 1;
            renderDrawPage();
        }

        function renderDrawPage() {
            var total = filteredDrawRows.length;
            var pages = Math.max(1, Math.ceil(total / drawPageSize));
            if (drawPage > pages) drawPage = pages;
            if (drawPage < 1) drawPage = 1;

            var start = (drawPage - 1) * drawPageSize;
            var rows = filteredDrawRows.slice(start, start + drawPageSize);
            var html = '';

            if (!rows.length) {
                html = '<tr><td colspan="8" class="bkk-empty">No matching Bangkok draw found.</td></tr>';
            } else {
                $.each(rows, function (_, d) {
                    html += '<tr data-id="' + d.DrawID + '"><td>' + d.DrawID + '</td><td>' + safe(d.DrawCode) + '</td><td>' + safe(d.DrawName) + '</td>' +
                        '<td>' + displayDate(d.ScheduledStartUTC) + '</td><td>' + status(d.DrawStatus) + '</td><td>' + (d.IsPublished ? 'Yes' : 'No') + '</td>' +
                        '<td>' + safe(d.GameCount) + '</td><td><button type="button" class="btn btn-sm btn-info btn-select-draw" data-id="' + d.DrawID + '" data-status="' + safe(d.DrawStatus) + '"><i class="fa fa-cogs"></i> Control</button> ' +
                        '<button type="button" class="btn btn-sm btn-danger btn-delete-draw" data-id="' + d.DrawID + '" data-status="' + safe(d.DrawStatus) + '"><i class="fa fa-trash"></i> Delete</button></td></tr>';
                });
            }

            $('#tblDraws').html(html);
            if (selectedDrawId) $('#tblDraws tr[data-id="' + selectedDrawId + '"]').addClass('bkk-selected-row');

            var from = total ? start + 1 : 0;
            var to = Math.min(start + drawPageSize, total);
            $('#drawPageInfo').text('Showing ' + from + '–' + to + ' of ' + total + ' records');
            $('#drawPageCurrent').text('Page ' + drawPage + ' of ' + pages);
            $('#btnDrawPrev').prop('disabled', drawPage <= 1);
            $('#btnDrawNext').prop('disabled', drawPage >= pages);
            renderDrawPageButtons(pages);
        }

        function renderDrawPageButtons(pages) {
            var html = '', first = Math.max(1, drawPage - 2), last = Math.min(pages, drawPage + 2);
            if (first > 1) {
                html += pageButton(1);
                if (first > 2) html += '<span class="px-1 text-muted">…</span>';
            }
            for (var p = first; p <= last; p++) html += pageButton(p);
            if (last < pages) {
                if (last < pages - 1) html += '<span class="px-1 text-muted">…</span>';
                html += pageButton(pages);
            }
            $('#drawPageButtons').html(html);
        }

        function pageButton(page) {
            return '<button type="button" class="btn btn-sm ' + (page === drawPage ? 'btn-dark' : 'btn-light') +
                ' btn-draw-page" data-page="' + page + '">' + page + '</button>';
        }

        function downloadHistoryChart() {
            var button = $('#btnDownloadHistoryChart');
            var old = button.html();
            button.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Generating PDF...');

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
                a.href = url;
                a.download = fileName;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                window.setTimeout(function () { window.URL.revokeObjectURL(url); }, 1000);
                notifySuccess('History draw chart downloaded.');
            }).fail(function () {
                toastr['error']('Unable to generate the history draw chart PDF.');
            }).always(function () {
                button.prop('disabled', false).html(old);
            });
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

            Swal.fire({
                title: 'Delete Draw?',

                html:
                    '<div style="font-size:13px;line-height:1.6;">' +
                    'Are you sure you want to delete this draw?<br><br>' +
                    '<strong>This action cannot be undone.</strong>' +
                    '</div>',

                type: 'warning',

                showCancelButton: true,

                confirmButtonText:
                    '<i class="fa fa-trash"></i> Yes, Delete',

                cancelButtonText:
                    '<i class="fa fa-times"></i> No, Cancel',

                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',

                reverseButtons: true,

                allowOutsideClick: false,
                allowEscapeKey: false

            }).then(function (result) {

                /*
                 * NO / CANCEL
                 *
                 * result:
                 * {
                 *     dismiss: "cancel"
                 * }
                 */
                if (result.dismiss === 'cancel') {
                    return;
                }

                /*
                 * YES / CONFIRM
                 *
                 * result:
                 * {
                 *     value: true
                 * }
                 */
                if (result.value !== true) {
                    return;
                }


                /* ==========================================
                   USER CLICKED YES
                   ========================================== */

                $.ajax({

                    headers: authHeaders(),

                    url: apiUrl('/' + drawId + '/delete'),

                    type: 'DELETE',

                    beforeSend: function () {

                        Swal.fire({
                            title: 'Deleting Draw...',
                            text: 'Please wait.',
                            allowOutsideClick: false,
                            allowEscapeKey: false,

                            onOpen: function () {
                                Swal.showLoading();
                            }
                        });

                    }

                })
                    .done(function (response) {

                        /* Clear selected draw */
                        if (Number(selectedDrawId) === Number(drawId)) {

                            selectedDrawId = 0;
                            selectedDrawStatus = '';

                            $('#controlPanel').hide();
                        }


                        /* Success */
                        Swal.fire({
                            title: 'Deleted!',
                            text: 'Draw deleted successfully.',
                            type: 'success',
                            timer: 1800,
                            showConfirmButton: false
                        });


                        /* Reload table */
                        loadDraws();

                    })
                    .fail(function (xhr) {

                        var message = 'Unable to delete the draw.';

                        if (typeof errorMessage === 'function') {

                            message = errorMessage(xhr);

                        } else if (
                            xhr.responseJSON &&
                            xhr.responseJSON.message
                        ) {

                            message = xhr.responseJSON.message;
                        }


                        Swal.fire({
                            title: 'Delete Failed',
                            text: message,
                            type: 'error',
                            confirmButtonText: 'OK'
                        });

                    });

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
                                <div>
                                    <div class="bkk-page-kicker">Draw Management</div>
                                    <h4 class="page-title"></h4>
                                    <div class="bkk-page-subtitle">Schedule, publish and manage Bangkok Lottery draws and results.</div>
                                </div>
                                <div style="float: right; margin-top: 10px">
                                    <button id="btnDownloadHistoryChart" type="button" class="btn btn-primary bkk-download-chart"><i class="fa fa-file-pdf-o"></i>Download Draw Chart</button>
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
                                    <div class="bkk-history-toolbar">
                                        <div>
                                            <h5 class="mb-1">Draw Schedule and History</h5>
                                            <div class="bkk-history-meta">Search and browse historical draws without loading thousands of rows on screen at once.</div>
                                        </div>
                                        <div class="bkk-history-tools">
                                            <input id="txtDrawSearch" type="search" class="form-control form-control-sm bkk-history-search" placeholder="Search code, name, status, date..." />
                                            <select id="ddlDrawPageSize" class="form-control form-control-sm" style="width:auto">
                                                <option value="2" selected>3 / page</option>
                                                <option value="4">4 / page</option>
                                                <option value="8">8 / page</option>
                                                <option value="10">10 / page</option>
                                                <option value="25">25 / page</option>
                                                <option value="50">50 / page</option>
                                                <option value="100">100 / page</option>
                                            </select>
                                        </div>
                                    </div>
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
                                    <div class="bkk-pagination">
                                        <div>
                                            <strong id="drawPageInfo">Showing 0–0 of 0 records</strong>
                                            <span id="drawPageCurrent" class="text-muted ml-2">Page 1 of 1</span>
                                        </div>
                                        <div class="bkk-page-buttons">
                                            <button id="btnDrawPrev" type="button" class="btn btn-sm btn-light"><i class="fa fa-chevron-left"></i></button>
                                            <span id="drawPageButtons"></span>
                                            <button id="btnDrawNext" type="button" class="btn btn-sm btn-light"><i class="fa fa-chevron-right"></i></button>
                                        </div>
                                    </div>
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
                                            <div class="col-md-5 text-right">
                                                <span id="autoProcessorState" class="text-success mr-2">Automatic processor active</span>
                                                <button id="btnRefreshControl" type="button" class="btn btn-sm btn-light"><i class="fa fa-refresh"></i>Refresh Control</button>
                                            </div>
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
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
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
                            <label>Scheduled Start (Thailand Time) <span class="text-danger">*</span></label><input id="txtScheduledStartUTC" type="datetime-local" class="form-control" required aria-required="true" /><div class="invalid-feedback">Start time is required.</div>
                        </div>
                        <div class="form-group col-md-4">
                            <label>Time Zone</label><select id="ddlTimeZone" class="form-control"><option value="SE Asia Standard Time">Thailand (UTC+7)</option>
                            </select>
                        </div>
                        <div class="form-group col-md-3">
                            <label>Countdown Minutes</label><input id="txtCountdown" type="number" class="form-control" value="45" min="1" />
                        </div>
                        <div class="form-group col-md-3">
                            <label>Repeat Every Days</label><input id="txtRepeatDays" type="number" class="form-control" value="15" min="1" />
                        </div>
                        <div class="form-group col-md-2">
                            <label>DOWN Offset</label><input id="txtDownOffset" type="number" class="form-control" value="0" min="0" />
                        </div>
                        <div class="form-group col-md-2">
                            <label>FIRST Offset</label><input id="txtFirstOffset" type="number" class="form-control" value="300" min="1" required /><small class="form-text text-muted">300 sec = 5 minutes after DOWN</small>
                        </div>
                        <div class="form-group col-md-2">
                            <label>Reveal Seconds</label><input id="txtRevealInterval" type="number" class="form-control" value="10" min="1" />
                        </div>
                        <div class="form-group col-12">
                            <label>Remarks</label><textarea id="txtRemarks" class="form-control" rows="2"></textarea>

                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-dismiss="modal">Cancel</button>
                    <button id="btnCreateDraw" type="button" class="btn btn-dark">Create Draw</button>

                </div>
            </div>
        </div>
    </div>
</asp:Content>

