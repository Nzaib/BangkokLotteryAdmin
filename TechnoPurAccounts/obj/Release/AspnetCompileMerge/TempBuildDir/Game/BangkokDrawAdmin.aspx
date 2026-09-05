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

        .bkk-history-toolbar {
            display: flex;
            gap: 10px;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            margin: 0 0 12px
        }

        .bkk-history-tools {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: wrap
        }

        .bkk-history-search {
            min-width: 230px
        }

        .bkk-history-meta {
            font-size: 12px;
            color: #6c757d
        }

        .bkk-pagination {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 12px
        }

        .bkk-page-buttons {
            display: flex;
            gap: 4px;
            align-items: center;
            flex-wrap: wrap
        }

            .bkk-page-buttons .btn {
                min-width: 34px
            }

        .bkk-download-chart {
            box-shadow: 0 5px 14px rgba(0,123,255,.18);
            font-weight: 600
        }

            .bkk-download-chart i {
                margin-right: 5px
            }

        @media(max-width:767px) {
            .bkk-history-toolbar, .bkk-pagination {
                align-items: stretch
            }

            .bkk-history-tools {
                width: 100%
            }

            .bkk-history-search {
                min-width: 0;
                flex: 1 1 180px
            }
        }

        .bkk-admin {
            --bkk-navy: #071b3f;
            --bkk-blue: #1f66d1;
            --bkk-border: #e2e8f0
        }

            .bkk-admin .card {
                border: 1px solid var(--bkk-border);
                border-radius: 14px;
                box-shadow: 0 7px 22px rgba(22,43,77,.06);
                overflow: hidden
            }

            .bkk-admin .card-body {
                padding: 18px
            }

        .bkk-stat {
            padding: 17px 18px;
            background: linear-gradient(180deg,#fff,#f9fbfe);
            border-left: 4px solid var(--bkk-blue) !important
        }

            .bkk-stat small {
                font-weight: 700;
                color: #75839a;
                text-transform: uppercase
            }

            .bkk-stat strong {
                font-size: 25px;
                color: var(--bkk-navy);
                margin-top: 4px
            }

        .bkk-admin .table thead th {
            background: #f5f8fc;
            color: #53627a;
            text-transform: uppercase;
            font-size: 10px;
            padding: 11px 10px
        }

        .bkk-admin .table tbody td {
            padding: 11px 10px;
            border-color: #edf1f6
        }

        .bkk-selected-row td {
            background: #eef5ff !important
        }

        .bkk-result-number {
            display: inline-flex;
            min-width: 86px;
            justify-content: center;
            padding: 7px 10px;
            border-radius: 9px;
            background: #eef5ff;
            color: #0b4ea2;
            font-size: 17px;
            font-weight: 800;
            letter-spacing: .15em
        }

        .bkk-audit-note {
            font-size: 10px;
            margin-top: 5px
        }

        .bkk-confirmed {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            color: #16833a;
            background: #edf9f0;
            border: 1px solid #ccebd4;
            border-radius: 9px;
            padding: 7px 10px
        }

            .bkk-confirmed small {
                margin-left: 4px;
                color: #6d8a75
            }

        .bkk-saving {
            color: #1f66d1;
            font-weight: 600;
            padding: 7px
        }

        .bkk-result-input {
            font-weight: 800;
            letter-spacing: .18em
        }

        .bkk-history-toolbar {
            background: #f8fafc;
            border: 1px solid #e5ebf3;
            border-radius: 11px;
            padding: 12px
        }

        /* Broadcast-control redesign */
        .bkk-section-head {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 18px
        }

        .bkk-eyebrow {
            display: block;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: .13em;
            color: #315efb;
            margin-bottom: 4px
        }

        .bkk-game-grid {
            display: grid;
            grid-template-columns: repeat(2,minmax(0,1fr));
            gap: 16px
        }

        .bkk-game-card {
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            background: #fff;
            box-shadow: 0 8px 25px rgba(15,36,71,.06);
            padding: 18px;
            min-width: 0
        }

            .bkk-game-card:first-child {
                border-top: 4px solid #315efb
            }

            .bkk-game-card:nth-child(2) {
                border-top: 4px solid #071b3f
            }

        .bkk-game-top {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: flex-start
        }

        .bkk-game-title {
            display: flex;
            gap: 12px;
            align-items: center
        }

        .bkk-game-icon {
            width: 42px;
            height: 42px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #edf4ff;
            color: #1f66d1;
            font-size: 18px
        }

        .bkk-game-title small {
            font-size: 9px;
            font-weight: 800;
            letter-spacing: .12em;
            color: #8190a5
        }

        .bkk-game-title h3 {
            font-size: 16px;
            margin: 2px 0 0;
            color: #12213b;
            font-weight: 800
        }

        .bkk-game-meta {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            margin: 16px 0;
            padding: 10px 12px;
            background: #f7f9fc;
            border-radius: 10px;
            color: #66758b;
            font-size: 11px
        }

        .bkk-game-body {
            display: grid;
            grid-template-columns: 1.15fr .85fr;
            gap: 14px;
            align-items: start
        }

        .bkk-field-label {
            display: block;
            font-size: 9px;
            font-weight: 800;
            letter-spacing: .12em;
            color: #8995a8;
            margin-bottom: 7px
        }

        .bkk-result-display, .bkk-result-state {
            min-height: 48px;
            display: flex;
            align-items: center
        }

        .bkk-result-placeholder {
            font-size: 24px;
            letter-spacing: .18em;
            color: #c1cad7;
            font-weight: 800
        }

        .bkk-result-number {
            font-size: 26px !important;
            min-width: 120px !important;
            padding: 9px 14px !important
        }

        .bkk-game-action {
            margin-top: 16px;
            padding-top: 15px;
            border-top: 1px solid #edf1f6
        }

            .bkk-game-action > small {
                color: #8491a4;
                display: block;
                margin-top: 6px
            }

        .bkk-result-entry {
            display: flex;
            gap: 8px
        }

            .bkk-result-entry .form-control {
                height: 42px !important;
                font-size: 18px !important;
                letter-spacing: .2em !important;
                font-weight: 800 !important;
                max-width: 220px
            }

            .bkk-result-entry .btn {
                min-width: 125px
            }

        .bkk-confirm-button {
            min-width: 180px;
            font-size: 12px !important
        }

        .bkk-confirmed-panel {
            display: flex;
            gap: 11px;
            align-items: center;
            background: #effaf2;
            border: 1px solid #ccebd4;
            border-radius: 11px;
            padding: 11px;
            color: #147638
        }

            .bkk-confirmed-panel strong, .bkk-confirmed-panel small {
                display: block
            }

            .bkk-confirmed-panel small {
                font-size: 10px;
                color: #63806b;
                margin-top: 2px
            }

        .bkk-confirmed-icon {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background: #1d9a49;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center
        }

        .bkk-next-action {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 9px 12px;
            border-radius: 10px;
            background: #eef5ff;
            color: #245ba4;
            font-size: 11px;
            font-weight: 700
        }

            .bkk-next-action.warning {
                background: #fff7e7;
                color: #9a6500
            }

            .bkk-next-action.success {
                background: #effaf2;
                color: #147638
            }

        .bkk-processor {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            font-size: 11px;
            font-weight: 800;
            padding: 7px 10px;
            border-radius: 20px
        }

            .bkk-processor > i {
                width: 8px;
                height: 8px;
                border-radius: 50%;
                display: block
            }

        .bkk-processor-wait {
            background: #f2f4f7;
            color: #6f7c8e
        }

            .bkk-processor-wait > i {
                background: #9aa6b5
            }

        .bkk-processor-ok {
            background: #ecf9f0;
            color: #16743a
        }

            .bkk-processor-ok > i {
                background: #23a653;
                box-shadow: 0 0 0 4px rgba(35,166,83,.12);
                animation: bkkPulse 1.8s infinite
            }

        .bkk-processor-error {
            background: #fff0f0;
            color: #b42a2a
        }

            .bkk-processor-error > i {
                background: #d83c3c
            }

        .bkk-last-check {
            display: block;
            color: #8995a8;
            margin-top: 5px
        }

        @keyframes bkkPulse {
            0%,100% {
                box-shadow: 0 0 0 3px rgba(35,166,83,.10)
            }

            50% {
                box-shadow: 0 0 0 7px rgba(35,166,83,.03)
            }
        }

        .bkk-filter-pills {
            display: flex;
            gap: 5px;
            flex-wrap: wrap
        }

        .bkk-filter-pill {
            border: 1px solid #dce4ef;
            background: #fff;
            color: #65748a;
            border-radius: 20px;
            padding: 6px 10px;
            font-size: 10px;
            font-weight: 800;
            cursor: pointer
        }

            .bkk-filter-pill.active {
                background: #071b3f;
                color: #fff;
                border-color: #071b3f
            }

        .bkk-confirm-dialog small {
            display: block;
            color: #8491a4;
            font-weight: 800;
            letter-spacing: .12em
        }

        .bkk-confirm-dialog strong {
            display: block;
            font-size: 38px;
            letter-spacing: .18em;
            color: #071b3f;
            margin: 8px 0
        }

        .bkk-confirm-dialog p {
            color: #65748a;
            margin: 0
        }

        @media(max-width:991px) {
            .bkk-game-grid {
                grid-template-columns: 1fr
            }

            .bkk-section-head {
                display: block
            }

            .bkk-next-action {
                margin-top: 12px
            }

            .bkk-game-body {
                grid-template-columns: 1fr
            }
        }

        @media(max-width:575px) {
            .bkk-result-entry {
                display: block
            }

                .bkk-result-entry .form-control {
                    max-width: none;
                    margin-bottom: 8px
                }

                .bkk-result-entry .btn {
                    width: 100%
                }

            .bkk-game-card {
                padding: 14px
            }

            .bkk-game-meta {
                display: block
            }

                .bkk-game-meta span {
                    display: block;
                    margin: 4px 0
                }
        }
    </style>
    <script>
        var selectedDrawId = 0;
        var selectedDrawStatus = '';
        var adminApi = 'api/admin/bangkok-draw';
        var schedulerHealthBusy = false;
        var resultEditorBusy = false;
        var resultRequestBusy = false;
        var lastControlSignature = '';
        var allDrawRows = [];
        var filteredDrawRows = [];
        var drawPage = 1;
        var drawPageSize = 2;
        var drawStatusFilter = 'active';

        $(document).ready(function () {
            $('.page-title').html('Bangkok Lottery Administration');
            $('#txtDrawDate').val(getDefaultDrawDate());
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
            $(document).on('focusin', '.bkk-result-input', function () { resultEditorBusy = true; });
            $(document).on('focusout', '.bkk-result-input', function () {
                window.setTimeout(function () { resultEditorBusy = $('.bkk-result-input:focus').length > 0; }, 100);
            });
            $(document).on('keydown', '.bkk-result-input', function (e) {
                if (e.which === 13) { e.preventDefault(); $(this).closest('td').find('.btn-save-result').trigger('click'); }
            });
            $('#btnRefreshDraws').on('click', loadDraws);
            $('#txtDrawSearch').on('input', function () { drawPage = 1; applyDrawFilter(); });
            $(document).on('click', '.bkk-filter-pill', function () {
                $('.bkk-filter-pill').removeClass('active'); $(this).addClass('active');
                drawStatusFilter = String($(this).data('filter') || 'all');
                drawPage = 1; applyDrawFilter();
            });
            $('#ddlDrawPageSize').on('change', function () { drawPageSize = Number(this.value) || 2; drawPage = 1; renderDrawPage(); });
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
            loadSchedulerHealth();
            window.setInterval(loadSchedulerHealth, 30000);
        });

        function authHeaders() { return { 'Authorization': localStorage['access_token'] }; }
        function getTodayDate() {
            return getThailandDateTimeValue().slice(0, 10);
        }
        function getDefaultDrawDate() {
            var today = getTodayDate().split('-');
            var year = Number(today[0]), monthIndex = Number(today[1]) - 1, day = Number(today[2]);
            var next = day < 16
                ? new Date(year, monthIndex, 16)
                : new Date(year, monthIndex + 1, 1);
            return next.getFullYear() + '-' + String(next.getMonth() + 1).padStart(2, '0') + '-' + String(next.getDate()).padStart(2, '0');
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
            var thailandDateTime = getThailandDateTimeValue(), thailandDate = getDefaultDrawDate();
            clearValidation('#createDrawModal');
            $('#txtDrawDate').val(thailandDate);
            setDefaultDrawIdentity(thailandDate);
            $('#txtScheduledStartUTC').val(thailandDate + thailandDateTime.slice(10));
            $('#ddlTimeZone').val('SE Asia Standard Time');
            $('#txtCountdown').val(45);
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
            filteredDrawRows = $.grep(allDrawRows, function (d) {
                var st = String(d.DrawStatus || '');
                var statusOk = drawStatusFilter === 'all'
                    || (drawStatusFilter === 'active' && st !== 'Completed' && st !== 'Cancelled')
                    || st === drawStatusFilter;
                if (!statusOk) return false;
                if (!q) return true;
                return String(d.DrawID || '').toLowerCase().indexOf(q) >= 0 ||
                    String(d.DrawCode || '').toLowerCase().indexOf(q) >= 0 ||
                    String(d.DrawName || '').toLowerCase().indexOf(q) >= 0 ||
                    st.toLowerCase().indexOf(q) >= 0 ||
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
                RepeatEveryDays: 15, DownStartOffsetSeconds: Number($('#txtDownOffset').val()),
                FirstStartOffsetSeconds: Number($('#txtFirstOffset').val()), DigitRevealIntervalSeconds: Number($('#txtRevealInterval').val()),
                Remarks: $('#txtRemarks').val().trim()
            };
            clearValidation('#createDrawModal');
            if (!model.DrawCode) { return invalid('#txtDrawCode', 'Draw code is required.'); }
            if (!/^[A-Za-z0-9-]{4,30}$/.test(model.DrawCode)) { return invalid('#txtDrawCode', 'Use 4–30 letters, numbers or hyphens for the draw code.'); }
            if (!model.DrawName) { return invalid('#txtDrawName', 'Draw name is required.'); }
            if (!model.DrawDate) { return invalid('#txtDrawDate', 'Draw date is required.'); }
            var drawDay = Number(model.DrawDate.slice(8, 10));
            //if (drawDay !== 1 && drawDay !== 2 && drawDay !== 16) { return invalid('#txtDrawDate', 'Bangkok Lottery draws are only on the 1st and 16th.'); }
            if (!model.ScheduledStartUTC) { return invalid('#txtScheduledStartUTC', 'Scheduled start time is required.'); }
            if (model.ScheduledStartUTC.slice(0, 10) !== model.DrawDate) { return invalid('#txtScheduledStartUTC', 'Scheduled date must match the draw date.'); }
            if (model.CountdownMinutes < 1 || model.CountdownMinutes > 1440) { return invalid('#txtCountdown', 'Countdown must be between 1 and 1440 minutes.'); }
            if (model.DownStartOffsetSeconds < 0) { return invalid('#txtDownOffset', 'DOWN offset cannot be negative.'); }
            if (model.FirstStartOffsetSeconds < 60 || model.FirstStartOffsetSeconds > 3600) { return invalid('#txtFirstOffset', 'FIRST delay must be between 60 and 3600 seconds after DOWN completes.'); }
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
            if (resultEditorBusy || resultRequestBusy) return;
            $('#controlPanel').show(); $('#selectedDrawId').text(drawId);
            if (!silent && !$('#tblGames tr').length) $('#tblGames').html('<div class="bkk-empty bkk-game-empty">Loading draw control...</div>');
            $.ajax({ headers: authHeaders(), url: apiUrl('/' + drawId + '/control'), method: 'GET', cache: false })
                .done(function (res) {
                    var c = normalizeControl(res.data), d = c.draw || {}, games = c.games || [];
                    selectedDrawStatus = d.DrawStatus || selectedDrawStatus;
                    $('#selectedDrawCode').text(d.DrawCode || 'Draw #' + drawId); $('#selectedDrawStatus').html(status(selectedDrawStatus));
                    $('#selectedSchedule').text(displayDate(d.ScheduledStartUTC));
                    var signature = $.map(games, function (g) { return [g.DrawGameID, g.GameStatus, g.DigitCount, g.ScheduledStartUTC].join('|'); }).join('~');
                    if (!silent || signature !== lastControlSignature || !$('#tblGames tr').length) { renderGames(games); lastControlSignature = signature; }
                    setPublishButton(); loadResults(drawId);
                }).fail(notifyError);
        }
        function renderGames(games) {
            var html = '';
            if (!games.length) {
                html = '<div class="bkk-empty bkk-game-empty">No active games found.</div>';
            }
            $.each(games, function (_, g) {
                var isFirst = String(g.GameCode).toUpperCase() === 'FIRST';
                var label = isFirst ? '1ST PRIZE' : '2DOWN STRAIGHT';
                var icon = isFirst ? 'fa-trophy' : 'fa-sort-numeric-asc';
                html += '<article class="bkk-game-card" data-gameid="' + g.DrawGameID + '">' +
                    '<div class="bkk-game-top"><div class="bkk-game-title"><span class="bkk-game-icon"><i class="fa ' + icon + '"></i></span><div><small>' + label + '</small><h3>' + safe(g.GameName || g.GameCode) + '</h3></div></div>' +
                    '<div id="game-status-' + g.DrawGameID + '">' + status(g.GameStatus) + '</div></div>' +
                    '<div class="bkk-game-meta"><span><i class="fa fa-clock-o"></i> ' + displayDate(g.ScheduledStartUTC) + ' Thailand</span><span><i class="fa fa-circle-o"></i> ' + g.DigitCount + ' digits</span></div>' +
                    '<div class="bkk-game-body"><div><span class="bkk-field-label">RESULT</span><div id="result-' + g.DrawGameID + '" class="bkk-result-display"><span class="bkk-result-placeholder">' + Array(Number(g.DigitCount) + 1).join('–') + '</span></div></div>' +
                    '<div><span class="bkk-field-label">RESULT STATUS</span><div id="resultstatus-' + g.DrawGameID + '" class="bkk-result-state">Waiting for entry</div></div></div>' +
                    '<div id="resultaction-' + g.DrawGameID + '" class="bkk-game-action"><div class="bkk-result-entry"><input id="number-' + g.DrawGameID + '" class="form-control bkk-result-input" maxlength="' + g.DigitCount + '" inputmode="numeric" pattern="[0-9]*" autocomplete="off" data-digits="' + g.DigitCount + '" placeholder="Enter ' + g.DigitCount + ' digits" />' +
                    '<button type="button" class="btn btn-primary btn-save-result" data-gameid="' + g.DrawGameID + '"><i class="fa fa-save"></i> Save Result</button></div><small>Leading zeroes are supported. Result will require confirmation.</small></div>' +
                    '</article>';
            });
            $('#tblGames').html(html);
        }
        function loadResults(drawId) {
            $.ajax({ headers: authHeaders(), url: apiUrl('/' + drawId + '/results'), method: 'GET', cache: false })
                .done(function (res) {
                    var results = res.data || [], needsConfirm = 0, confirmed = 0;
                    $.each(results, function (_, r) {
                        $('#result-' + r.DrawGameID).html('<div class="bkk-result-number">' + safe(r.ResultNumber) + '</div>');
                        var timing = r.IsLateEntry
                            ? '<div class="bkk-audit-note text-danger"><i class="fa fa-clock-o"></i> Late entry' + (r.EntryDelaySeconds != null ? ' (' + r.EntryDelaySeconds + ' sec)' : '') + '</div>'
                            : '<div class="bkk-audit-note text-muted"><i class="fa fa-check-circle-o"></i> Entry recorded</div>';
                        $('#resultstatus-' + r.DrawGameID).html(status(r.ResultStatus) + timing);
                        if (r.IsConfirmed) {
                            confirmed++;
                            $('#resultaction-' + r.DrawGameID).html('<div class="bkk-confirmed-panel"><span class="bkk-confirmed-icon"><i class="fa fa-check"></i></span><div><strong>Result Confirmed</strong><small>Locked for the scheduled automatic reveal.</small></div></div>');
                        } else {
                            needsConfirm++;
                            $('#resultaction-' + r.DrawGameID).html('<button type="button" class="btn btn-success btn-confirm-result bkk-confirm-button" data-resultid="' + r.ResultID + '" data-number="' + safe(r.ResultNumber) + '"><i class="fa fa-check-circle"></i> Confirm ' + safe(r.ResultNumber) + '</button><small class="d-block mt-2 text-muted">Verify the number carefully before confirming.</small>');
                        }
                    });
                    if (needsConfirm) setNextAction('Confirmation required for ' + needsConfirm + ' result' + (needsConfirm > 1 ? 's' : '') + '.', 'warning');
                    else if (confirmed) setNextAction('Results confirmed — waiting for scheduled reveal.', 'success');
                    else setNextAction('Enter the draw results when they are available.', 'info');
                }).fail(notifyError);
        }
        function setNextAction(text, kind) {
            $('#controlNextAction').attr('class', 'bkk-next-action ' + (kind || 'info')).html('<i class="fa fa-info-circle"></i><span>' + safe(text) + '</span>');
        }
        function saveResult(gameId) {
            var input = $('#number-' + gameId), number = input.val().trim(), digits = Number(input.data('digits'));
            input.removeClass('is-invalid');
            if (!number) { input.addClass('is-invalid').focus(); toastr['error']('Result number is required.'); return; }
            if (!/^\d+$/.test(number)) { input.addClass('is-invalid').focus(); toastr['error']('Enter digits only.'); return; }
            if (number.length !== digits) { input.addClass('is-invalid').focus(); toastr['error']('This result must contain exactly ' + digits + ' digits.'); return; }
            var cell = $('#resultaction-' + gameId), old = cell.html();
            var model = { DrawGameID: gameId, ResultNumber: number, ResultSource: 'Manual', Remarks: 'Entered from Bangkok Lottery Admin' };
            resultRequestBusy = true; input.prop('disabled', true);
            cell.html('<div class="bkk-saving"><i class="fa fa-spinner fa-spin"></i> Saving result...</div>');
            $.ajax({ headers: authHeaders(), url: apiUrl('/' + selectedDrawId + '/enter-result'), method: 'POST', contentType: 'application/json;charset=utf-8', data: JSON.stringify(model) })
                .done(function () { notifySuccess('Result saved. Please confirm it.'); loadResults(selectedDrawId); })
                .fail(function (xhr) { cell.html(old); input.prop('disabled', false).focus(); notifyError(xhr); })
                .always(function () { resultRequestBusy = false; });
        }
        function confirmResult(resultId) {
            var button = $('.btn-confirm-result[data-resultid="' + resultId + '"]');
            var number = String(button.data('number') || '');
            Swal.fire({
                title: 'Confirm Lottery Result?',
                html: '<div class="bkk-confirm-dialog"><small>YOU ARE CONFIRMING</small><strong>' + safe(number) + '</strong><p>This result will be used by the automatic live reveal.</p></div>',
                type: 'warning', showCancelButton: true,
                confirmButtonText: '<i class="fa fa-check"></i> Yes, Confirm ' + safe(number),
                cancelButtonText: 'Cancel', confirmButtonColor: '#16833a',
                reverseButtons: true, allowOutsideClick: false, allowEscapeKey: false
            }).then(function (result) {
                if (result.value !== true) return;
                resultRequestBusy = true; button.prop('disabled', true);
                $.ajax({ headers: authHeaders(), url: apiUrl('/results/' + resultId + '/confirm'), method: 'POST' })
                    .done(function () { notifySuccess('Result ' + number + ' confirmed.'); loadResults(selectedDrawId); })
                    .fail(notifyError).always(function () { resultRequestBusy = false; });
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
        function loadSchedulerHealth() {
            if (schedulerHealthBusy) return;
            schedulerHealthBusy = true;
            $.ajax({ headers: authHeaders(), url: apiUrl('/scheduler-health'), method: 'GET', cache: false })
                .done(function (res) {
                    var item = (res && res.data) || null;
                    if (!item) {
                        $('#autoProcessorState').attr('class', 'bkk-processor bkk-processor-error').html('<i></i><span>Scheduler has not run yet</span>');
                        $('#autoProcessorLastCheck').text('Configure the protected SmarterASP Scheduled Task.');
                        return;
                    }
                    var ok = item.RunStatus === 'Completed' || item.RunStatus === 'NoChange';
                    $('#autoProcessorState').attr('class', 'bkk-processor ' + (ok ? 'bkk-processor-ok' : 'bkk-processor-error'))
                        .html('<i></i><span>Scheduler ' + safe(item.RunStatus) + '</span>');
                    $('#autoProcessorLastCheck').text('Last run: ' + displayDate(item.CompletedUTC || item.StartedUTC) + ' Thailand · ' + safe(item.Message || ''));
                    loadDraws(true);
                    if (selectedDrawId && !resultEditorBusy && !resultRequestBusy && !$('.bkk-result-input:focus').length && !$('#createDrawModal').hasClass('show')) loadControl(selectedDrawId, true);
                })
                .fail(function (xhr) {
                    $('#autoProcessorState').attr('class', 'bkk-processor bkk-processor-error').html('<i></i><span>Scheduler health unavailable</span>');
                    $('#autoProcessorLastCheck').text(errorMessage(xhr));
                })
                .always(function () { schedulerHealthBusy = false; });
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
                                    </a>
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
                                            <div class="bkk-filter-pills" id="drawStatusFilters">
                                                <button type="button" class="bkk-filter-pill active" data-filter="active">Active</button>
                                                <button type="button" class="bkk-filter-pill" data-filter="Ready">Ready</button>
                                                <button type="button" class="bkk-filter-pill" data-filter="Live">Live</button>
                                                <button type="button" class="bkk-filter-pill" data-filter="Completed">Completed</button>
                                                <button type="button" class="bkk-filter-pill" data-filter="all">All</button>
                                            </div>
                                            <input id="txtDrawSearch" type="search" class="form-control form-control-sm bkk-history-search" placeholder="Search code, name, status, date..." />
                                            <select id="ddlDrawPageSize" class="form-control form-control-sm" style="width: auto">
                                                <option value="2" selected>2 / page</option>
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
                                                <span id="autoProcessorState" class="text-muted mr-2">Checking scheduler...</span>
                                                <small id="autoProcessorLastCheck" class="d-block text-muted mt-1">Read-only status check</small>
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
                                    <div class="card-body">
                                        <div class="bkk-section-head">
                                            <div>
                                                <span class="bkk-eyebrow">LIVE DRAW CONTROL</span>
                                                <h5 class="mb-1">Games &amp; Results</h5>
                                                <p class="text-muted mb-0">Enter and confirm each result. Automatic processing will handle the scheduled reveal.</p>
                                            </div>
                                            <div id="controlNextAction" class="bkk-next-action"><i class="fa fa-info-circle"></i><span>Select or prepare a result.</span></div>
                                        </div>
                                        <div id="tblGames" class="bkk-game-grid"></div>
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
                            <label>Countdown Minutes</label><input id="txtCountdown" type="number" class="form-control" value="45" min="1" /><small class="form-text text-muted">Public banner appears during the final 45 minutes.</small>
                        </div>
                        <div class="form-group col-md-3">
                            <label>Draw Recurrence</label><div class="form-control bg-light">1st and 16th monthly</div>
                            <small class="form-text text-muted">The next date is calculated automatically.</small>
                        </div>
                        <div class="form-group col-md-2">
                            <label>DOWN Offset</label><input id="txtDownOffset" type="number" class="form-control" value="0" min="0" />
                        </div>
                        <div class="form-group col-md-2">
                            <label>FIRST Delay</label><input id="txtFirstOffset" type="number" class="form-control" value="300" min="60" max="3600" required /><small class="form-text text-muted">300 sec = 5 minutes after DOWN completes</small>
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

