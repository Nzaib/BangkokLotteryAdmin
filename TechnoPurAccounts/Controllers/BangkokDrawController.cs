using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Core.EntityClient;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Http;
using System.IO;
using System.Net.Http.Headers;
using iTextSharp.text;
using iTextSharp.text.pdf;
using DataAccessLayer;

namespace TechnoPurAccounts.Controllers
{
    [AllowAnonymous]
    [RoutePrefix("api/bangkok-draw")]
    public class BangkokDrawController : ApiController
    {
        private readonly return_orderEntities1 db = new return_orderEntities1();
        private static readonly object LiveStateCacheLock = new object();

        [HttpGet, Route("next-broadcast")]
        public HttpResponseMessage NextBroadcast()
        {
            try
            {
                var data = db.Database.SqlQuery<NextBroadcastDto>(@"
SELECT TOP (1) D.DrawID,D.DrawCode,D.DrawStatus,CAST(D.CountdownMinutes AS int) CountdownMinutes,
       MIN(G.ScheduledStartUTC) ScheduledStartUTC,
       CAST(COUNT(*) AS int) GameCount
FROM dbo.BangkokDraw D
JOIN dbo.BangkokDrawGame G ON G.DrawID=D.DrawID AND G.IsActive=1
WHERE D.IsDeleted=0 AND D.IsPublished=1
  AND D.DrawStatus IN ('Scheduled','Ready','Live','Paused')
GROUP BY D.DrawID,D.DrawCode,D.DrawStatus,D.CountdownMinutes
ORDER BY CASE WHEN D.DrawStatus IN ('Live','Paused') THEN 0 ELSE 1 END,
         MIN(G.ScheduledStartUTC);").FirstOrDefault();
                if (data == null) return ApiError(HttpStatusCode.NotFound, "No upcoming broadcast was found.");
                data.ScheduledStartUTC = AsUtc(data.ScheduledStartUTC);
                return OkResponse(data, 1);
            }
            catch (Exception ex) { return ExceptionResponse(ex); }
        }

        [HttpGet, Route("broadcast-schedule")]
        public HttpResponseMessage BroadcastSchedule()
        {
            try
            {
                var rows = db.Database.SqlQuery<BroadcastScheduleRowDto>(@"
SELECT TOP (2)
       D.DrawID,D.DrawCode,D.DrawDate,D.DrawStatus,D.ScheduledStartUTC,
       CAST(D.CountdownMinutes AS int) CountdownMinutes
FROM dbo.BangkokDraw D
WHERE D.IsDeleted=0 AND D.IsPublished=1
  AND D.DrawStatus IN ('Scheduled','Ready','Live','Paused')
ORDER BY CASE WHEN D.DrawStatus IN ('Live','Paused') THEN 0 ELSE 1 END,
         D.ScheduledStartUTC,D.DrawID;").ToList();

                foreach (var row in rows)
                    row.ScheduledStartUTC = AsUtc(row.ScheduledStartUTC);

                var last = db.Database.SqlQuery<BroadcastScheduleRowDto>(@"
SELECT TOP (1)
       D.DrawID,D.DrawCode,D.DrawDate,D.DrawStatus,D.ScheduledStartUTC,
       CAST(D.CountdownMinutes AS int) CountdownMinutes
FROM dbo.BangkokDraw D
WHERE D.IsDeleted=0
ORDER BY D.DrawDate DESC,D.DrawID DESC;").FirstOrDefault();

                if (last != null)
                    last.ScheduledStartUTC = AsUtc(last.ScheduledStartUTC);

                var nextDrawDate = rows.Count > 0
                    ? rows[0].DrawDate.Date
                    : NextLotteryDate(last == null ? ThailandToday() : last.DrawDate.Date);

                DateTime? nextScheduledStartUtc = rows.Count > 0
                    ? rows[0].ScheduledStartUTC
                    : CalculateNextScheduledStartUtc(last, nextDrawDate);

                return OkResponse(new
                {
                    timeZoneId = "SE Asia Standard Time",
                    timeZone = "Asia/Bangkok",
                    recurrence = "Monthly on the 1st and 16th",
                    nextDrawDate,
                    nextScheduledStartUtc,
                    draws = rows
                }, 30);
            }
            catch (Exception ex) { return ExceptionResponse(ex); }
        }

        [HttpGet, Route("{drawId:int}/live-state")]
        public HttpResponseMessage LiveState(int drawId)
        {
            if (drawId <= 0) return ApiError(HttpStatusCode.BadRequest, "A valid drawId is required.");
            try
            {
                var cacheKey = "BangkokDraw.LiveState.v3." + drawId;
                var snapshot = HttpRuntime.Cache[cacheKey] as LiveStateSnapshot;
                if (snapshot == null)
                {
                    lock (LiveStateCacheLock)
                    {
                        snapshot = HttpRuntime.Cache[cacheKey] as LiveStateSnapshot;
                        if (snapshot == null)
                        {
                            snapshot = LoadLiveStateSnapshot(drawId, DateTime.UtcNow);
                            if (snapshot != null)
                                HttpRuntime.Cache.Insert(cacheKey, snapshot, null,
                                    DateTime.UtcNow.AddSeconds(1), System.Web.Caching.Cache.NoSlidingExpiration);
                        }
                    }
                }

                if (snapshot == null) return ApiError(HttpStatusCode.NotFound, "Draw was not found.");
                return OkResponse(new { draw = snapshot.Draw, games = snapshot.Games }, 1);
            }
            catch (Exception ex) { return ExceptionResponse(ex); }
        }

        [HttpGet, Route("latest-results")]
        public HttpResponseMessage LatestResults()
        {
            try
            {
                var draw = db.Database.SqlQuery<DrawDto>(@"
SELECT TOP (1) DrawID,DrawCode,DrawDate,ScheduledStartUTC,CAST(CountdownMinutes AS int) CountdownMinutes,
       DrawStatus,ActualStartUTC,ActualEndUTC
FROM dbo.BangkokDraw
WHERE IsDeleted=0 AND IsPublished=1 AND DrawStatus='Completed'
ORDER BY ActualEndUTC DESC,DrawID DESC;").FirstOrDefault();
                if (draw == null) return ApiError(HttpStatusCode.NotFound, "No completed draw was found.");

                var results = db.Database.SqlQuery<ResultDto>(@"
SELECT G.GameCode,G.GameName,CAST(G.DisplayOrder AS int) DisplayOrder,R.ResultNumber,R.RevealCompletedUTC
FROM dbo.BangkokDrawGame G
JOIN dbo.BangkokDrawResult R ON R.DrawGameID=G.DrawGameID
WHERE G.DrawID=@p0 AND G.IsActive=1 AND R.IsConfirmed=1 AND R.ResultStatus='Revealed'
  AND R.ResultVersion=(
      SELECT MAX(R2.ResultVersion)
      FROM dbo.BangkokDrawResult R2
      WHERE R2.DrawGameID=R.DrawGameID
  )
ORDER BY G.DisplayOrder;", draw.DrawID).ToList();
                NormalizeUtc(draw);
                foreach (var result in results)
                    result.RevealCompletedUTC = AsUtc(result.RevealCompletedUTC);

                var first = results.FirstOrDefault(x => x.GameCode == "FIRST");
                var n = first == null ? null : first.ResultNumber;
                object calculated = null;
                if (!String.IsNullOrEmpty(n) && n.Length >= 6)
                    calculated = new
                    {
                        threeUpStraight = n.Substring(n.Length - 3, 3),
                        threeUpOpenPair = n.Substring(3, 2),
                        threeUpClosePair = n.Substring(n.Length - 2, 2)
                    };
                return OkResponse(new { draw, results, calculated }, 30);
            }
            catch (Exception ex) { return ExceptionResponse(ex); }
        }

        [HttpGet, Route("results-history")]
        public HttpResponseMessage ResultsHistory(int page = 1, int pageSize = 10)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 10;
            if (pageSize > 50) pageSize = 50;

            try
            {
                var offset = (page - 1) * pageSize;
                var rows = db.Database.SqlQuery<HistoryResultRowDto>(@"
WITH FilteredDraws AS
(
    SELECT D.DrawID,D.DrawCode,D.DrawDate,D.ScheduledStartUTC,D.ActualEndUTC,
           ISNULL(D.ActualEndUTC,D.ScheduledStartUTC) AS SortUTC,
           CAST(COUNT(*) OVER() AS int) AS TotalRecords
    FROM dbo.BangkokDraw D
    WHERE D.IsDeleted=0 AND D.IsPublished=1 AND D.DrawStatus='Completed'
),
PagedDraws AS
(
    SELECT DrawID,DrawCode,DrawDate,ScheduledStartUTC,ActualEndUTC,SortUTC,TotalRecords
    FROM FilteredDraws
    ORDER BY SortUTC DESC,DrawID DESC
    OFFSET @p0 ROWS FETCH NEXT @p1 ROWS ONLY
)
SELECT D.DrawID,D.DrawCode,D.DrawDate,D.ScheduledStartUTC,D.ActualEndUTC,
       D.TotalRecords,G.GameCode,G.GameName,R.ResultNumber,R.RevealCompletedUTC
FROM PagedDraws D
JOIN dbo.BangkokDrawGame G
  ON G.DrawID=D.DrawID AND G.IsActive=1
OUTER APPLY
(
    SELECT TOP (1) R1.ResultNumber,R1.RevealCompletedUTC
    FROM dbo.BangkokDrawResult R1
    WHERE R1.DrawGameID=G.DrawGameID
      AND R1.IsConfirmed=1
      AND R1.ResultStatus='Revealed'
    ORDER BY R1.ResultVersion DESC,R1.ResultID DESC
) R
ORDER BY D.SortUTC DESC,D.DrawID DESC,G.DisplayOrder,G.DrawGameID;", offset, pageSize).ToList();

                var totalRecords = rows.Count == 0 ? 0 : rows[0].TotalRecords;

                foreach (var row in rows)
                {
                    row.ScheduledStartUTC = AsUtc(row.ScheduledStartUTC);
                    row.ActualEndUTC = AsUtc(row.ActualEndUTC);
                    row.RevealCompletedUTC = AsUtc(row.RevealCompletedUTC);
                }

                var records = rows
                    .GroupBy(x => new
                    {
                        x.DrawID,
                        x.DrawCode,
                        x.DrawDate,
                        x.ScheduledStartUTC,
                        x.ActualEndUTC
                    })
                    .Select(group =>
                    {
                        var firstPrize = group
                            .Where(x => x.GameCode == "FIRST")
                            .Select(x => x.ResultNumber)
                            .FirstOrDefault();
                        var twoDown = group
                            .Where(x => x.GameCode == "DOWN")
                            .Select(x => x.ResultNumber)
                            .FirstOrDefault();

                        return new
                        {
                            drawId = group.Key.DrawID,
                            drawCode = group.Key.DrawCode,
                            drawDate = group.Key.DrawDate,
                            scheduledStartUtc = group.Key.ScheduledStartUTC,
                            completedUtc = group.Key.ActualEndUTC,
                            firstPrize = firstPrize ?? "",
                            threeUpStraight = !String.IsNullOrEmpty(firstPrize) && firstPrize.Length >= 6
                                ? firstPrize.Substring(firstPrize.Length - 3, 3) : "",
                            threeUpOpenPair = !String.IsNullOrEmpty(firstPrize) && firstPrize.Length >= 6
                                ? firstPrize.Substring(3, 2) : "",
                            threeUpClosePair = !String.IsNullOrEmpty(firstPrize) && firstPrize.Length >= 6
                                ? firstPrize.Substring(firstPrize.Length - 2, 2) : "",
                            twoDown = twoDown ?? ""
                        };
                    })
                    .ToList();

                var totalPages = totalRecords == 0
                    ? 0
                    : (int)Math.Ceiling(totalRecords / (double)pageSize);

                return OkResponse(new
                {
                    page,
                    pageSize,
                    totalRecords,
                    totalPages,
                    records
                }, 60);
            }
            catch (Exception ex) { return ExceptionResponse(ex); }
        }


        // FIRST historical chart PDF.
        // The 58-year window always ends at the current Thailand year.
        [HttpGet, Route("history-chart/pdf")]
        public HttpResponseMessage HistoryChartPdf()
        {
            try
            {
                var thailandTimeZone = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
                var nowThailand = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, thailandTimeZone);
                var endYear = nowThailand.Year;
                var startYear = endYear - 57;

                var rows = LoadHistoryChartRows("FIRST", startYear, endYear);
                var pdfBytes = BuildHistoryChartPdf(rows, startYear, endYear, false);

                return CreatePdfResponse(pdfBytes,
                    String.Format("Bangkok-Lottery-FIRST-History-Chart-{0}-{1}.pdf", startYear, endYear));
            }
            catch (Exception ex) { return ExceptionResponse(ex); }
        }

        // DOWN historical chart PDF.
        // Starts at 1977 and always ends at the current Thailand year.
        [HttpGet, Route("history-chart/down/pdf")]
        public HttpResponseMessage DownHistoryChartPdf()
        {
            try
            {
                var thailandTimeZone = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
                var nowThailand = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, thailandTimeZone);
                const int startYear = 1977;
                var endYear = nowThailand.Year;

                var rows = LoadHistoryChartRows("DOWN", startYear, endYear);
                var pdfBytes = BuildHistoryChartPdf(rows, startYear, endYear, true);

                return CreatePdfResponse(pdfBytes,
                    String.Format("Bangkok-Lottery-DOWN-History-Chart-{0}-{1}.pdf", startYear, endYear));
            }
            catch (Exception ex) { return ExceptionResponse(ex); }
        }

        private List<HistoryChartPdfRowDto> LoadHistoryChartRows(string gameCode, int startYear, int endYear)
        {
            return db.Database.SqlQuery<HistoryChartPdfRowDto>(@"
SELECT D.DrawDate,R.ResultNumber
FROM dbo.BangkokDraw D
JOIN dbo.BangkokDrawGame G
  ON G.DrawID=D.DrawID
 AND G.IsActive=1
 AND G.GameCode=@p0
OUTER APPLY
(
    SELECT TOP (1) R1.ResultNumber
    FROM dbo.BangkokDrawResult R1
    WHERE R1.DrawGameID=G.DrawGameID
      AND R1.IsConfirmed=1
      AND R1.ResultStatus='Revealed'
    ORDER BY R1.ResultVersion DESC,R1.ResultID DESC
) R
WHERE D.IsDeleted=0
  AND D.IsPublished=1
  AND D.DrawStatus='Completed'
  AND YEAR(D.DrawDate) BETWEEN @p1 AND @p2
  AND R.ResultNumber IS NOT NULL
ORDER BY D.DrawDate;", gameCode, startYear, endYear).ToList();
        }

        private HttpResponseMessage CreatePdfResponse(byte[] pdfBytes, string fileName)
        {
            var response = new HttpResponseMessage(HttpStatusCode.OK);
            response.Content = new ByteArrayContent(pdfBytes);
            response.Content.Headers.ContentType = new MediaTypeHeaderValue("application/pdf");
            response.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
            {
                FileName = fileName
            };
            response.Headers.CacheControl = new CacheControlHeaderValue { NoCache = true, NoStore = true };
            return response;
        }

        private byte[] BuildHistoryChartPdf(List<HistoryChartPdfRowDto> rows, int startYear, int endYear, bool downOnly)
        {
            var pageSize = PageSize.A3.Rotate();
            using (var ms = new MemoryStream())
            {
                var document = new Document(pageSize, 8f, 8f, 8f, 8f);
                var writer = PdfWriter.GetInstance(document, ms);
                document.Open();

                AddGloWatermark(writer, document);

                var normal = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 7.6f, Font.BOLD, BaseColor.BLACK);
                var bold = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 8.5f, Font.BOLD, BaseColor.BLACK);
                var tinyBold = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 7.3f, Font.BOLD, BaseColor.BLACK);
                var downFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 9.2f, Font.BOLD, BaseColor.BLACK);

                var years = Enumerable.Range(startYear, endYear - startYear + 1).ToList();

                // Same date rows as the existing historical chart.
                var slots = new[]
                {
                    new HistoryChartSlot(1,16,"16-Jan"),
                    new HistoryChartSlot(2,1,"1-Feb"),
                    new HistoryChartSlot(2,16,"16-Feb"),
                    new HistoryChartSlot(3,1,"1-Mar"),
                    new HistoryChartSlot(3,16,"16-Mar"),
                    new HistoryChartSlot(4,1,"1-Apr"),
                    new HistoryChartSlot(4,16,"16-Apr"),
                    new HistoryChartSlot(5,2,"2-May"),
                    new HistoryChartSlot(5,16,"16-May"),
                    new HistoryChartSlot(6,1,"1-Jun"),
                    new HistoryChartSlot(6,16,"16-Jun"),
                    new HistoryChartSlot(7,1,"1-Jul"),
                    new HistoryChartSlot(7,16,"16-Jul"),
                    new HistoryChartSlot(8,1,"1-Aug"),
                    new HistoryChartSlot(8,16,"16-Aug"),
                    new HistoryChartSlot(9,1,"1-Sep"),
                    new HistoryChartSlot(9,16,"16-Sep"),
                    new HistoryChartSlot(10,1,"1-Oct"),
                    new HistoryChartSlot(10,16,"16-Oct"),
                    new HistoryChartSlot(11,1,"1-Nov"),
                    new HistoryChartSlot(11,16,"16-Nov"),
                    new HistoryChartSlot(12,1,"1-Dec"),
                    new HistoryChartSlot(12,16,"16-Dec"),
                    new HistoryChartSlot(12,30,"30-Dec")
                };

                var lookup = rows
                    .GroupBy(x => String.Format("{0:0000}-{1:00}-{2:00}",
                        x.DrawDate.Year, x.DrawDate.Month, x.DrawDate.Day))
                    .ToDictionary(g => g.Key, g => g.Last().ResultNumber);

                // Official holiday / no-draw dates.
                // Both FIRST and DOWN charts display only * for these cells.
                var holidayDates = new HashSet<DateTime>
                {
                    new DateTime(2020, 4, 1),
                    new DateTime(2020, 4, 16),
                    new DateTime(2020, 5, 2)
                };

                var table = new PdfPTable(years.Count + 1);
                table.WidthPercentage = 100f;
                var widths = Enumerable.Repeat(1f, years.Count + 1).ToArray();
                widths[0] = 2.15f;
                table.SetWidths(widths);
                table.HeaderRows = 1;

                AddChartCell(table, "Year", bold, 18f, Element.ALIGN_CENTER, true);
                foreach (var year in years)
                    AddChartCell(table, (year % 100).ToString("00"), bold, 18f, Element.ALIGN_CENTER, true);

                foreach (var slot in slots)
                {
                    AddChartCell(table, slot.Label, tinyBold, 32.2f, Element.ALIGN_CENTER, true);

                    foreach (var year in years)
                    {
                        var cellDate = new DateTime(year, slot.Month, slot.Day);

                        if (holidayDates.Contains(cellDate))
                        {
                            AddChartCell(table, "*", bold, 32.2f, Element.ALIGN_CENTER, false);
                            continue;
                        }

                        var key = String.Format("{0:0000}-{1:00}-{2:00}", year, slot.Month, slot.Day);
                        string result;
                        if (!lookup.TryGetValue(key, out result) || String.IsNullOrWhiteSpace(result))
                        {
                            AddChartCell(table, "", normal, 32.2f, Element.ALIGN_CENTER, false);
                            continue;
                        }

                        if (downOnly)
                        {
                            // Exact DOWN result only. Leading zero is preserved, e.g. "03".
                            AddChartCell(table, result, downFont, 32.2f, Element.ALIGN_CENTER, false);
                            continue;
                        }

                        if (result.Length < 3)
                        {
                            AddChartCell(table, "", normal, 32.2f, Element.ALIGN_CENTER, false);
                            continue;
                        }

                        var last3 = result.Substring(result.Length - 3, 3);
                        var sum = last3.Sum(ch => ch - '0');
                        var topDigit = (sum % 10).ToString();

                        var phrase = new Phrase();
                        phrase.Add(new Chunk(topDigit + "\n", bold));
                        phrase.Add(new Chunk(last3, normal));
                        AddChartPhraseCell(table, phrase, 32.2f);
                    }
                }

                document.Add(table);
                document.Close();
                return ms.ToArray();
            }
        }

        private void AddGloWatermark(PdfWriter writer, Document document)
        {
            var path = HttpContext.Current.Server.MapPath("~/assets/pdf/glo-logo.jpg");
            if (!File.Exists(path)) return;

            var image = iTextSharp.text.Image.GetInstance(path);
            image.ScaleToFit(document.PageSize.Width * 0.62f, document.PageSize.Height * 0.62f);
            image.SetAbsolutePosition(
                (document.PageSize.Width - image.ScaledWidth) / 2f,
                (document.PageSize.Height - image.ScaledHeight) / 2f);

            var canvas = writer.DirectContentUnder;
            canvas.SaveState();
            var state = new PdfGState { FillOpacity = 0.16f, StrokeOpacity = 0.16f };
            canvas.SetGState(state);
            canvas.AddImage(image);
            canvas.RestoreState();
        }

        private static void AddChartCell(PdfPTable table, string text, Font font, float height, int alignment, bool shaded)
        {
            var cell = new PdfPCell(new Phrase(text ?? "", font))
            {
                HorizontalAlignment = alignment,
                VerticalAlignment = Element.ALIGN_MIDDLE,
                FixedHeight = height,
                Padding = 0.35f,
                BorderWidth = 0.45f,
                BackgroundColor = shaded ? new BaseColor(245, 245, 245) : null
            };
            table.AddCell(cell);
        }

        private static void AddChartPhraseCell(PdfPTable table, Phrase phrase, float height)
        {
            var cell = new PdfPCell(phrase)
            {
                HorizontalAlignment = Element.ALIGN_CENTER,
                VerticalAlignment = Element.ALIGN_MIDDLE,
                FixedHeight = height,
                Padding = 0.30f,
                BorderWidth = 0.45f,
                BackgroundColor = null
            };
            table.AddCell(cell);
        }

        public class HistoryChartPdfRowDto
        {
            public DateTime DrawDate { get; set; }
            public string ResultNumber { get; set; }
        }

        private sealed class HistoryChartSlot
        {
            public HistoryChartSlot(int month, int day, string label)
            {
                Month = month;
                Day = day;
                Label = label;
            }
            public int Month { get; private set; }
            public int Day { get; private set; }
            public string Label { get; private set; }
        }

        private LiveStateSnapshot LoadLiveStateSnapshot(int drawId, DateTime nowUtc)
        {
            var draw = db.Database.SqlQuery<DrawDto>(@"
SELECT TOP (1) DrawID,DrawCode,DrawDate,ScheduledStartUTC,
       CAST(CountdownMinutes AS int) CountdownMinutes,
       DrawStatus,ActualStartUTC,ActualEndUTC
FROM dbo.BangkokDraw
WHERE DrawID=@p0 AND IsDeleted=0 AND IsPublished=1;", drawId).FirstOrDefault();

            if (draw == null) return null;
            draw.PersistedDrawStatus = draw.DrawStatus;
            NormalizeUtc(draw);

            var rawGames = db.Database.SqlQuery<GameStateRawDto>(@"
SELECT G.DrawGameID,G.GameCode,G.GameName,
       CAST(G.DisplayOrder AS int) DisplayOrder,
       CAST(G.DigitCount AS int) DigitCount,
       CAST(G.DigitRevealIntervalSeconds AS int) DigitRevealIntervalSeconds,
       CAST(G.HostPickupSeconds AS decimal(9,2)) HostPickupSeconds,
       CAST(G.BallFlightSeconds AS decimal(9,2)) BallFlightSeconds,
       CAST(G.MachineRunSeconds AS decimal(9,2)) MachineRunSeconds,
       G.GameStatus,G.ScheduledStartUTC,G.ActualStartUTC,G.RevealStartedUTC,G.ActualEndUTC,
       R.ResultID,R.ResultNumber SecuredResultNumber,R.ConfirmedDateUTC,
       ISNULL(R.ResultStatus,'') ResultStatus,
       CONVERT(bit,ISNULL(R.IsConfirmed,0)) IsConfirmed,
       CONVERT(bit,ISNULL(R.IsLocked,0)) IsLocked,
       CONVERT(int,CASE WHEN R.IsConfirmed=1 THEN ISNULL(R.RevealedDigitCount,0) ELSE 0 END) RevealedDigitCount
FROM dbo.BangkokDrawGame G
OUTER APPLY
(
    SELECT TOP (1) R1.*
    FROM dbo.BangkokDrawResult R1
    WHERE R1.DrawGameID=G.DrawGameID
    ORDER BY R1.ResultVersion DESC,R1.ResultID DESC
) R
WHERE G.DrawID=@p0 AND G.IsActive=1
ORDER BY G.DisplayOrder,G.DrawGameID;", drawId).ToList();

            var pauses = db.Database.SqlQuery<PauseStateDto>(@"
SELECT PauseHistoryID,DrawGameID,PauseStartedUTC,ResumeDateUTC
FROM dbo.BangkokDrawPauseHistory
WHERE DrawID=@p0
  AND PauseStartedUTC<=@p1
ORDER BY PauseStartedUTC,PauseHistoryID;", drawId, nowUtc).ToList();

            foreach (var pause in pauses)
            {
                pause.PauseStartedUTC = DateTime.SpecifyKind(pause.PauseStartedUTC, DateTimeKind.Utc);
                pause.ResumeDateUTC = AsUtc(pause.ResumeDateUTC);
            }

            var games = new List<GameStateDto>();
            var downCompleted = false;
            var timelineMayAdvance = draw.PersistedDrawStatus == "Scheduled" ||
                                     draw.PersistedDrawStatus == "Ready" ||
                                     draw.PersistedDrawStatus == "Live" ||
                                     draw.PersistedDrawStatus == "Paused" ||
                                     draw.PersistedDrawStatus == "Completed";
            foreach (var raw in rawGames.OrderBy(x => x.DisplayOrder).ThenBy(x => x.DrawGameID))
            {
                raw.ScheduledStartUTC = AsUtc(raw.ScheduledStartUTC);
                raw.ActualStartUTC = AsUtc(raw.ActualStartUTC);
                raw.RevealStartedUTC = AsUtc(raw.RevealStartedUTC);
                raw.ConfirmedDateUTC = AsUtc(raw.ConfirmedDateUTC);
                raw.ActualEndUTC = AsUtc(raw.ActualEndUTC);

                var scheduledStart = raw.ScheduledStartUTC ?? draw.ScheduledStartUTC ?? nowUtc;
                var preparationSeconds = (int)Math.Ceiling((double)
                    (raw.MachineRunSeconds + raw.HostPickupSeconds + raw.BallFlightSeconds));
                var plannedRevealAnchor = scheduledStart.AddSeconds(preparationSeconds);
                var safeRevealAnchor = raw.ConfirmedDateUTC.HasValue && raw.ConfirmedDateUTC.Value > plannedRevealAnchor
                    ? raw.ConfirmedDateUTC.Value
                    : plannedRevealAnchor;
                var revealAnchor = raw.RevealStartedUTC ?? safeRevealAnchor;
                var pauseReferenceUtc = raw.ConfirmedDateUTC.HasValue && raw.ConfirmedDateUTC.Value > plannedRevealAnchor
                    ? raw.ConfirmedDateUTC.Value
                    : (draw.ScheduledStartUTC ?? scheduledStart);
                var pausedSeconds = CalculatePausedSeconds(pauses, pauseReferenceUtc, nowUtc);
                var effectiveRevealAnchor = revealAnchor.AddSeconds(pausedSeconds);
                var isPaused = pauses.Any(x => !x.ResumeDateUTC.HasValue);

                var revealedCount = Math.Max(0, Math.Min(raw.DigitCount, raw.RevealedDigitCount));
                if (timelineMayAdvance && raw.IsConfirmed && !raw.IsLocked && nowUtc >= revealAnchor)
                {
                    var elapsedSeconds = Math.Max(0,
                        (int)Math.Floor((nowUtc - revealAnchor).TotalSeconds) - pausedSeconds);
                    var interval = Math.Max(1, raw.DigitRevealIntervalSeconds);
                    var calculatedCount = Math.Min(raw.DigitCount, (elapsedSeconds / interval) + 1);

                    if (!String.Equals(raw.GameCode, "FIRST", StringComparison.OrdinalIgnoreCase) || downCompleted)
                        revealedCount = Math.Max(revealedCount, calculatedCount);
                }

                if (String.Equals(raw.GameCode, "FIRST", StringComparison.OrdinalIgnoreCase) && !downCompleted)
                    revealedCount = Math.Min(revealedCount, raw.RevealedDigitCount);

                var revealedNumber = raw.IsConfirmed && !String.IsNullOrEmpty(raw.SecuredResultNumber)
                    ? raw.SecuredResultNumber.Substring(0, Math.Min(revealedCount, raw.SecuredResultNumber.Length))
                    : "";

                var effectiveGameStatus = raw.GameStatus;
                var effectiveResultStatus = raw.ResultStatus;
                if (isPaused)
                {
                    effectiveGameStatus = "Paused";
                }
                else if (raw.IsConfirmed && revealedCount >= raw.DigitCount)
                {
                    effectiveGameStatus = "Completed";
                    effectiveResultStatus = "Revealed";
                }
                else if (timelineMayAdvance && raw.IsConfirmed && nowUtc >= effectiveRevealAnchor &&
                         (!String.Equals(raw.GameCode, "FIRST", StringComparison.OrdinalIgnoreCase) || downCompleted))
                {
                    effectiveGameStatus = "Revealing";
                    effectiveResultStatus = revealedCount > 0 ? "Revealing" : "Confirmed";
                }
                else if (timelineMayAdvance && raw.IsConfirmed && nowUtc >= scheduledStart)
                {
                    effectiveGameStatus = "Live";
                }

                DateTime? nextTransitionUtc = null;
                if (timelineMayAdvance && raw.IsConfirmed && !raw.IsLocked && !isPaused && revealedCount < raw.DigitCount &&
                    (!String.Equals(raw.GameCode, "FIRST", StringComparison.OrdinalIgnoreCase) || downCompleted))
                {
                    nextTransitionUtc = effectiveRevealAnchor.AddSeconds(
                        Math.Max(1, raw.DigitRevealIntervalSeconds) * revealedCount);
                }

                var game = new GameStateDto
                {
                    DrawGameID = raw.DrawGameID,
                    GameCode = raw.GameCode,
                    GameName = raw.GameName,
                    DisplayOrder = raw.DisplayOrder,
                    DigitCount = raw.DigitCount,
                    GameStatus = effectiveGameStatus,
                    PersistedGameStatus = raw.GameStatus,
                    ScheduledStartUTC = raw.ScheduledStartUTC,
                    ActualStartUTC = raw.ActualStartUTC,
                    ActualEndUTC = raw.ActualEndUTC,
                    ResultID = raw.ResultID,
                    RevealedNumber = revealedNumber,
                    ResultStatus = effectiveResultStatus,
                    IsConfirmed = raw.IsConfirmed,
                    RevealedDigitCount = revealedCount,
                    RevealAnchorUTC = effectiveRevealAnchor,
                    NextTransitionUTC = nextTransitionUtc,
                    IsPaused = isPaused
                };

                games.Add(game);
                if (String.Equals(raw.GameCode, "DOWN", StringComparison.OrdinalIgnoreCase))
                    downCompleted = revealedCount >= raw.DigitCount;
            }

            var hasActivePause = games.Any(x => x.IsPaused);
            var allGamesCompleted = games.Count > 0 && games.All(x => x.RevealedDigitCount >= x.DigitCount);
            if (hasActivePause && draw.DrawStatus != "Completed" && draw.DrawStatus != "Cancelled")
                draw.DrawStatus = "Paused";
            else if (allGamesCompleted)
                draw.DrawStatus = "Completed";
            else if (draw.ScheduledStartUTC.HasValue && nowUtc >= draw.ScheduledStartUTC.Value &&
                     (draw.DrawStatus == "Ready" || draw.DrawStatus == "Scheduled" || draw.DrawStatus == "Live"))
                draw.DrawStatus = "Live";

            return new LiveStateSnapshot { Draw = draw, Games = games };
        }

        private static int CalculatePausedSeconds(IEnumerable<PauseStateDto> pauses,
            DateTime fromUtc, DateTime toUtc)
        {
            var windows = pauses
                .Select(x => new
                {
                    Start = x.PauseStartedUTC > fromUtc ? x.PauseStartedUTC : fromUtc,
                    End = (x.ResumeDateUTC ?? toUtc) < toUtc ? (x.ResumeDateUTC ?? toUtc) : toUtc
                })
                .Where(x => x.End > x.Start)
                .OrderBy(x => x.Start)
                .ToList();

            if (windows.Count == 0) return 0;
            var total = TimeSpan.Zero;
            var currentStart = windows[0].Start;
            var currentEnd = windows[0].End;
            for (var i = 1; i < windows.Count; i++)
            {
                if (windows[i].Start <= currentEnd)
                {
                    if (windows[i].End > currentEnd) currentEnd = windows[i].End;
                }
                else
                {
                    total += currentEnd - currentStart;
                    currentStart = windows[i].Start;
                    currentEnd = windows[i].End;
                }
            }
            total += currentEnd - currentStart;
            return Math.Max(0, (int)Math.Floor(total.TotalSeconds));
        }

        private static DateTime ThailandToday()
        {
            var zone = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
            return TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, zone).Date;
        }

        private static DateTime NextLotteryDate(DateTime afterDate)
        {
            var date = afterDate.Date;
            if (date.Day < 16) return new DateTime(date.Year, date.Month, 16);
            var nextMonth = new DateTime(date.Year, date.Month, 1).AddMonths(1);
            return nextMonth;
        }

        private static DateTime? CalculateNextScheduledStartUtc(BroadcastScheduleRowDto last, DateTime nextDrawDate)
        {
            if (last == null || !last.ScheduledStartUTC.HasValue) return null;
            var zone = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
            var lastUtc = DateTime.SpecifyKind(last.ScheduledStartUTC.Value, DateTimeKind.Utc);
            var lastThailand = TimeZoneInfo.ConvertTimeFromUtc(lastUtc, zone);
            var nextThailand = DateTime.SpecifyKind(nextDrawDate.Date.Add(lastThailand.TimeOfDay),
                DateTimeKind.Unspecified);
            return DateTime.SpecifyKind(TimeZoneInfo.ConvertTimeToUtc(nextThailand, zone), DateTimeKind.Utc);
        }

        private static DateTime? AsUtc(DateTime? value)
        {
            return value.HasValue
                ? DateTime.SpecifyKind(value.Value, DateTimeKind.Utc)
                : value;
        }

        private static void NormalizeUtc(DrawDto item)
        {
            if (item == null) return;
            item.ScheduledStartUTC = AsUtc(item.ScheduledStartUTC);
            item.ActualStartUTC = AsUtc(item.ActualStartUTC);
            item.ActualEndUTC = AsUtc(item.ActualEndUTC);
        }

        private static void NormalizeUtc(GameStateDto item)
        {
            if (item == null) return;
            item.ScheduledStartUTC = AsUtc(item.ScheduledStartUTC);
            item.ActualStartUTC = AsUtc(item.ActualStartUTC);
            item.ActualEndUTC = AsUtc(item.ActualEndUTC);
        }

        private HttpResponseMessage OkResponse(object data, int publicMaxAgeSeconds = 0)
        {
            var response = Request.CreateResponse(HttpStatusCode.OK,
                new { success = true, serverUtc = DateTime.UtcNow, data });
            if (publicMaxAgeSeconds > 0)
            {
                response.Headers.CacheControl = new CacheControlHeaderValue
                {
                    Public = true,
                    MaxAge = TimeSpan.FromSeconds(publicMaxAgeSeconds),
                    MustRevalidate = true
                };
                response.Headers.TryAddWithoutValidation("Vary", "Accept-Encoding");
            }
            return response;
        }
        private HttpResponseMessage ApiError(HttpStatusCode status, string message)
        {
            return Request.CreateResponse(status, new { success = false, message });
        }
        private HttpResponseMessage ExceptionResponse(Exception ex)
        {
            var errorId = Guid.NewGuid().ToString("N");
            Trace.TraceError("Bangkok draw API error {0}: {1}", errorId, ex);
            return Request.CreateResponse(HttpStatusCode.InternalServerError,
                new { success = false, message = "Bangkok draw request failed.", errorId });
        }
        protected override void Dispose(bool disposing) { if (disposing) db.Dispose(); base.Dispose(disposing); }

        public class NextBroadcastDto { public int DrawID { get; set; } public string DrawCode { get; set; } public string DrawStatus { get; set; } public DateTime? ScheduledStartUTC { get; set; } public int CountdownMinutes { get; set; } public int GameCount { get; set; } }
        public class DrawDto { public int DrawID { get; set; } public string DrawCode { get; set; } public DateTime DrawDate { get; set; } public DateTime? ScheduledStartUTC { get; set; } public int CountdownMinutes { get; set; } public string DrawStatus { get; set; } public string PersistedDrawStatus { get; set; } public DateTime? ActualStartUTC { get; set; } public DateTime? ActualEndUTC { get; set; } }
        public class GameStateDto { public int DrawGameID { get; set; } public string GameCode { get; set; } public string GameName { get; set; } public int DisplayOrder { get; set; } public int DigitCount { get; set; } public string GameStatus { get; set; } public string PersistedGameStatus { get; set; } public DateTime? ScheduledStartUTC { get; set; } public DateTime? ActualStartUTC { get; set; } public DateTime? ActualEndUTC { get; set; } public int? ResultID { get; set; } public string RevealedNumber { get; set; } public string ResultStatus { get; set; } public bool IsConfirmed { get; set; } public int RevealedDigitCount { get; set; } public DateTime? RevealAnchorUTC { get; set; } public DateTime? NextTransitionUTC { get; set; } public bool IsPaused { get; set; } }
        public class ResultDto { public string GameCode { get; set; } public string GameName { get; set; } public int DisplayOrder { get; set; } public string ResultNumber { get; set; } public DateTime? RevealCompletedUTC { get; set; } }
        public class HistoryResultRowDto
        {
            public int DrawID { get; set; }
            public string DrawCode { get; set; }
            public DateTime DrawDate { get; set; }
            public DateTime? ScheduledStartUTC { get; set; }
            public DateTime? ActualEndUTC { get; set; }
            public int TotalRecords { get; set; }
            public string GameCode { get; set; }
            public string GameName { get; set; }
            public string ResultNumber { get; set; }
            public DateTime? RevealCompletedUTC { get; set; }
        }
        public class BroadcastScheduleRowDto { public int DrawID { get; set; } public string DrawCode { get; set; } public DateTime DrawDate { get; set; } public string DrawStatus { get; set; } public DateTime? ScheduledStartUTC { get; set; } public int CountdownMinutes { get; set; } }
        private class LiveStateSnapshot { public DrawDto Draw { get; set; } public List<GameStateDto> Games { get; set; } }
        private class PauseStateDto { public int PauseHistoryID { get; set; } public int? DrawGameID { get; set; } public DateTime PauseStartedUTC { get; set; } public DateTime? ResumeDateUTC { get; set; } }
        private class GameStateRawDto
        {
            public int DrawGameID { get; set; }
            public string GameCode { get; set; }
            public string GameName { get; set; }
            public int DisplayOrder { get; set; }
            public int DigitCount { get; set; }
            public int DigitRevealIntervalSeconds { get; set; }
            public decimal HostPickupSeconds { get; set; }
            public decimal BallFlightSeconds { get; set; }
            public decimal MachineRunSeconds { get; set; }
            public string GameStatus { get; set; }
            public DateTime? ScheduledStartUTC { get; set; }
            public DateTime? ActualStartUTC { get; set; }
            public DateTime? RevealStartedUTC { get; set; }
            public DateTime? ConfirmedDateUTC { get; set; }
            public DateTime? ActualEndUTC { get; set; }
            public int? ResultID { get; set; }
            public string SecuredResultNumber { get; set; }
            public string ResultStatus { get; set; }
            public bool IsConfirmed { get; set; }
            public bool IsLocked { get; set; }
            public int RevealedDigitCount { get; set; }
        }
    }

    [AllowAnonymous]
    [RoutePrefix("api/scheduled-tasks/bangkok-draw")]
    public class BangkokDrawScheduledTaskController : ApiController
    {
        private readonly return_orderEntities1 db = new return_orderEntities1();

        // SmarterASP basic Scheduled Tasks issue an HTTP GET and cannot attach a custom
        // authorization header. The header is preferred; the query-string fallback is
        // provided only for that hosting constraint and must always be called over HTTPS.
        [HttpGet, HttpPost, Route("tick")]
        public HttpResponseMessage Tick(string key = null)
        {
            var configuredKey = ConfigurationManager.AppSettings["BangkokDrawSchedulerKey"];
            if (String.IsNullOrWhiteSpace(configuredKey))
                return SchedulerResponse(HttpStatusCode.ServiceUnavailable,
                    new { success = false, message = "The Bangkok scheduler key is not configured." });

            var presentedKey = GetHeader("X-Bangkok-Scheduler-Key");
            if (String.IsNullOrWhiteSpace(presentedKey)) presentedKey = key;
            if (!FixedTimeEquals(configuredKey, presentedKey))
                return SchedulerResponse(HttpStatusCode.Unauthorized,
                    new { success = false, message = "Scheduler authorization failed." });

            try
            {
                var entityConnection = db.Database.Connection as EntityConnection;
                var connection = entityConnection == null
                    ? db.Database.Connection as SqlConnection
                    : entityConnection.StoreConnection as SqlConnection;
                if (connection == null)
                    return SchedulerResponse(HttpStatusCode.InternalServerError,
                        new { success = false, message = "Database connection is unavailable." });

                using (var command = new SqlCommand("dbo.sproc_BangkokDraw_SchedulerTick", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandTimeout = 90;
                    command.Parameters.AddWithValue("@TriggeredBy", "SmarterASP Scheduled Task");
                    if (connection.State != ConnectionState.Open) connection.Open();
                    using (var reader = command.ExecuteReader())
                    {
                        var rows = new List<Dictionary<string, object>>();
                        while (reader.Read())
                        {
                            var row = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                            for (var i = 0; i < reader.FieldCount; i++)
                                row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
                            rows.Add(row);
                        }
                        return SchedulerResponse(HttpStatusCode.OK,
                            new { success = true, serverUtc = DateTime.UtcNow, data = rows });
                    }
                }
            }
            catch (Exception ex)
            {
                var errorId = Guid.NewGuid().ToString("N");
                Trace.TraceError("Bangkok scheduler error {0}: {1}", errorId, ex);
                return SchedulerResponse(HttpStatusCode.InternalServerError,
                    new { success = false, message = "Bangkok scheduler execution failed.", errorId });
            }
            finally
            {
                if (db.Database.Connection.State == ConnectionState.Open)
                    db.Database.Connection.Close();
            }
        }

        private string GetHeader(string name)
        {
            IEnumerable<string> values;
            return Request.Headers.TryGetValues(name, out values) ? values.FirstOrDefault() : null;
        }

        private static bool FixedTimeEquals(string expected, string presented)
        {
            if (expected == null || presented == null) return false;
            using (var sha = SHA256.Create())
            {
                var left = sha.ComputeHash(Encoding.UTF8.GetBytes(expected));
                var right = sha.ComputeHash(Encoding.UTF8.GetBytes(presented));
                var difference = 0;
                for (var i = 0; i < left.Length; i++) difference |= left[i] ^ right[i];
                return difference == 0;
            }
        }

        private HttpResponseMessage SchedulerResponse(HttpStatusCode status, object payload)
        {
            var response = Request.CreateResponse(status, payload);
            response.Headers.CacheControl = new CacheControlHeaderValue { NoCache = true, NoStore = true };
            return response;
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db.Dispose();
            base.Dispose(disposing);
        }
    }

    [Authorize]
    [RoutePrefix("api/admin/bangkok-draw")]
    public class BangkokDrawAdminController : ApiController
    {
        private readonly return_orderEntities1 db = new return_orderEntities1();


        [HttpGet, Route("dashboard")]
        public HttpResponseMessage Dashboard()
        {
            try
            {
                var nowUtc = DateTime.UtcNow;
                var thailandTimeZone = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
                var nowThailand = TimeZoneInfo.ConvertTimeFromUtc(nowUtc, thailandTimeZone);
                var monthStartThailand = new DateTime(nowThailand.Year, nowThailand.Month, 1);
                var nextMonthThailand = monthStartThailand.AddMonths(1);
                var monthStartUtc = TimeZoneInfo.ConvertTimeToUtc(
                    DateTime.SpecifyKind(monthStartThailand, DateTimeKind.Unspecified), thailandTimeZone);
                var nextMonthUtc = TimeZoneInfo.ConvertTimeToUtc(
                    DateTime.SpecifyKind(nextMonthThailand, DateTimeKind.Unspecified), thailandTimeZone);

                var summary = db.Database.SqlQuery<DashboardSummaryDto>(@"
SELECT
    CAST(COUNT(*) AS int) TotalDraws,
    CAST(ISNULL(SUM(CASE WHEN DrawStatus='Completed' THEN 1 ELSE 0 END),0) AS int) CompletedDraws,
    CAST(ISNULL(SUM(CASE WHEN ScheduledStartUTC>@p0
                  AND DrawStatus IN ('Scheduled','Ready') THEN 1 ELSE 0 END),0) AS int) UpcomingDraws,
    CAST(ISNULL(SUM(CASE WHEN DrawStatus IN ('Live','Paused') THEN 1 ELSE 0 END),0) AS int) LiveDraws
FROM dbo.BangkokDraw
WHERE IsDeleted=0
  AND ScheduledStartUTC>=@p1
  AND ScheduledStartUTC<@p2;",
                    nowUtc, monthStartUtc, nextMonthUtc).FirstOrDefault()
                    ?? new DashboardSummaryDto();

                var next = db.Database.SqlQuery<DashboardDrawDto>(@"
SELECT TOP (1)
       D.DrawID,D.DrawCode,D.DrawName,D.DrawStatus,D.IsPublished,
       D.ScheduledStartUTC,D.ActualStartUTC,D.ActualEndUTC,
       CAST(COUNT(CASE WHEN G.IsActive=1 THEN 1 END) AS int) GameCount
FROM dbo.BangkokDraw D
LEFT JOIN dbo.BangkokDrawGame G ON G.DrawID=D.DrawID
WHERE D.IsDeleted=0
  AND D.DrawStatus IN ('Scheduled','Ready','Live','Paused')
GROUP BY D.DrawID,D.DrawCode,D.DrawName,D.DrawStatus,D.IsPublished,
         D.ScheduledStartUTC,D.ActualStartUTC,D.ActualEndUTC
ORDER BY CASE WHEN D.DrawStatus IN ('Live','Paused') THEN 0 ELSE 1 END,
         D.ScheduledStartUTC,D.DrawID;").FirstOrDefault();

                var upcoming = db.Database.SqlQuery<DashboardDrawDto>(@"
SELECT TOP (5)
       D.DrawID,D.DrawCode,D.DrawName,D.DrawStatus,D.IsPublished,
       D.ScheduledStartUTC,D.ActualStartUTC,D.ActualEndUTC,
       CAST(COUNT(CASE WHEN G.IsActive=1 THEN 1 END) AS int) GameCount
FROM dbo.BangkokDraw D
LEFT JOIN dbo.BangkokDrawGame G ON G.DrawID=D.DrawID
WHERE D.IsDeleted=0
  AND D.ScheduledStartUTC>@p0
  AND D.DrawStatus IN ('Scheduled','Ready')
GROUP BY D.DrawID,D.DrawCode,D.DrawName,D.DrawStatus,D.IsPublished,
         D.ScheduledStartUTC,D.ActualStartUTC,D.ActualEndUTC
ORDER BY D.ScheduledStartUTC,D.DrawID;", nowUtc).ToList();

                var lastDraw = db.Database.SqlQuery<DashboardDrawDto>(@"
SELECT TOP (1)
       D.DrawID,D.DrawCode,D.DrawName,D.DrawStatus,D.IsPublished,
       D.ScheduledStartUTC,D.ActualStartUTC,D.ActualEndUTC,
       CAST(COUNT(CASE WHEN G.IsActive=1 THEN 1 END) AS int) GameCount
FROM dbo.BangkokDraw D
LEFT JOIN dbo.BangkokDrawGame G ON G.DrawID=D.DrawID
WHERE D.IsDeleted=0 AND D.DrawStatus='Completed'
GROUP BY D.DrawID,D.DrawCode,D.DrawName,D.DrawStatus,D.IsPublished,
         D.ScheduledStartUTC,D.ActualStartUTC,D.ActualEndUTC
ORDER BY D.ActualEndUTC DESC,D.DrawID DESC;").FirstOrDefault();

                var latestResults = new List<DashboardResultDto>();
                object calculated = null;
                if (lastDraw != null)
                {
                    latestResults = db.Database.SqlQuery<DashboardResultDto>(@"
SELECT G.GameCode,G.GameName,CAST(G.DisplayOrder AS int) DisplayOrder,R.ResultNumber,R.RevealCompletedUTC
FROM dbo.BangkokDrawGame G
JOIN dbo.BangkokDrawResult R ON R.DrawGameID=G.DrawGameID
WHERE G.DrawID=@p0
  AND G.IsActive=1
  AND R.IsConfirmed=1
  AND R.ResultStatus='Revealed'
  AND R.ResultVersion=(
      SELECT MAX(R2.ResultVersion)
      FROM dbo.BangkokDrawResult R2
      WHERE R2.DrawGameID=R.DrawGameID
  )
ORDER BY G.DisplayOrder,G.DrawGameID;", lastDraw.DrawID).ToList();

                    var first = latestResults.FirstOrDefault(x => x.GameCode == "FIRST");
                    var number = first == null ? null : first.ResultNumber;
                    if (!String.IsNullOrWhiteSpace(number) && number.Length >= 6)
                    {
                        calculated = new
                        {
                            threeUpStraight = number.Substring(number.Length - 3, 3),
                            threeUpOpenPair = number.Substring(3, 2),
                            threeUpClosePair = number.Substring(number.Length - 2, 2)
                        };
                    }
                }

                // SQL Server returns DateTime values with Kind=Unspecified.
                // These columns are UTC columns, so explicitly mark them as UTC before
                // Web API / Json.NET serializes them. The JSON will then contain "Z".
                NormalizeDashboardUtc(next);
                foreach (var item in upcoming)
                    NormalizeDashboardUtc(item);
                NormalizeDashboardUtc(lastDraw);

                var total = summary.TotalDraws;
                var completedPercent = total == 0 ? 0 :
                    (int)Math.Round(summary.CompletedDraws * 100.0 / total);
                var upcomingPercent = total == 0 ? 0 :
                    (int)Math.Round(summary.UpcomingDraws * 100.0 / total);
                var otherDraws = Math.Max(0, total - summary.CompletedDraws - summary.UpcomingDraws);
                var otherPercent = total == 0 ? 0 :
                    Math.Max(0, 100 - completedPercent - upcomingPercent);

                return Request.CreateResponse(HttpStatusCode.OK, new
                {
                    success = true,
                    // Canonical time used by the browser countdown.
                    serverUtc = nowUtc,
                    // Display/reference value with an explicit Thailand offset.
                    serverThailand = new DateTimeOffset(
                        DateTime.SpecifyKind(nowThailand, DateTimeKind.Unspecified),
                        TimeSpan.FromHours(7)),
                    data = new
                    {
                        summary = new
                        {
                            totalDraws = summary.TotalDraws,
                            completedDraws = summary.CompletedDraws,
                            upcomingDraws = summary.UpcomingDraws,
                            liveDraws = summary.LiveDraws,
                            completedPercent,
                            upcomingPercent,
                            otherDraws,
                            otherPercent
                        },
                        nextBroadcast = next,
                        upcomingDraws = upcoming,
                        lastDraw,
                        latestResults,
                        calculated,
                        systemStatus = new
                        {
                            database = "Online",
                            apiService = "Online",
                            broadcastService = next != null &&
                                (next.DrawStatus == "Live" || next.DrawStatus == "Paused")
                                    ? next.DrawStatus : "Ready"
                        }
                    }
                });
            }
            catch (Exception ex)
            {
                return Error(HttpStatusCode.InternalServerError,
                    "Dashboard request failed: " + ex.GetBaseException().Message);
            }
        }

        [HttpGet, Route("")]
        public HttpResponseMessage List()
        {
            try
            {
                var rows = db.Database.SqlQuery<AdminDrawListDto>(@"
SELECT D.DrawID,D.DrawCode,D.DrawName,D.DrawDate,D.DrawStatus,D.IsPublished,
       D.ScheduledStartUTC,D.ActualStartUTC,D.ActualEndUTC,
       CAST(COUNT(CASE WHEN G.IsActive=1 THEN 1 END) AS int) GameCount
FROM dbo.BangkokDraw D
LEFT JOIN dbo.BangkokDrawGame G ON G.DrawID=D.DrawID
WHERE D.IsDeleted=0
GROUP BY D.DrawID,D.DrawCode,D.DrawName,D.DrawDate,D.DrawStatus,D.IsPublished,
         D.ScheduledStartUTC,D.ActualStartUTC,D.ActualEndUTC
ORDER BY D.DrawDate DESC,D.DrawID DESC;").ToList();
                return Request.CreateResponse(HttpStatusCode.OK, new { success = true, data = rows });
            }
            catch (Exception ex) { return Error(HttpStatusCode.InternalServerError, ex.GetBaseException().Message); }
        }

        [HttpPost, Route("")]
        public HttpResponseMessage Create(CreateDrawRequest model)
        {
            if (model == null || String.IsNullOrWhiteSpace(model.DrawCode) ||
                String.IsNullOrWhiteSpace(model.DrawName) || model.DrawDate == default(DateTime) ||
                model.ScheduledStartUTC == default(DateTime))
                return Error(HttpStatusCode.BadRequest, "DrawCode, DrawName, DrawDate and ScheduledStartUTC are required.");
            var code = model.DrawCode.Trim();
            if (code.Length < 4 || code.Length > 30 || !code.All(ch => Char.IsLetterOrDigit(ch) || ch == '-'))
                return Error(HttpStatusCode.BadRequest, "DrawCode must contain 4-30 letters, numbers or hyphens.");
            if (model.DrawName.Trim().Length > 200)
                return Error(HttpStatusCode.BadRequest, "DrawName cannot exceed 200 characters.");
            //if (model.DrawDate.Day != 1 && model.DrawDate.Day != 16)
            //    return Error(HttpStatusCode.BadRequest, "Bangkok Lottery draws can only be scheduled for the 1st or 16th of a month.");
            if (model.CountdownMinutes < 1 || model.CountdownMinutes > 1440 ||
                model.DownStartOffsetSeconds < 0 ||
                model.FirstStartOffsetSeconds < 60 || model.FirstStartOffsetSeconds > 3600 ||
                model.DigitRevealIntervalSeconds < 1 || model.DigitRevealIntervalSeconds > 300)
                return Error(HttpStatusCode.BadRequest, "One or more schedule values are outside the allowed range.");

            DateTime scheduledStartUtc;
            try
            {
                var thailandTimeZone = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
                var thailandScheduledTime = DateTime.SpecifyKind(model.ScheduledStartUTC, DateTimeKind.Unspecified);
                if (thailandScheduledTime.Date != model.DrawDate.Date)
                    return Error(HttpStatusCode.BadRequest, "The Thailand scheduled date must match the draw date.");
                scheduledStartUtc = TimeZoneInfo.ConvertTimeToUtc(thailandScheduledTime, thailandTimeZone);
            }
            catch (Exception ex)
            {
                return Error(HttpStatusCode.BadRequest, "Thailand scheduled time is invalid: " + ex.GetBaseException().Message);
            }

            return Execute("dbo.sproc_BangkokDraw_Create", c =>
            {
                c.Parameters.AddWithValue("@DrawCode", model.DrawCode.Trim());
                c.Parameters.AddWithValue("@DrawName", model.DrawName.Trim());
                c.Parameters.AddWithValue("@DrawDate", model.DrawDate.Date);
                c.Parameters.AddWithValue("@ScheduledStartUTC", scheduledStartUtc);
                c.Parameters.AddWithValue("@TimeZoneID", "SE Asia Standard Time");
                c.Parameters.AddWithValue("@CountdownMinutes", model.CountdownMinutes <= 0 ? 45 : model.CountdownMinutes);
                c.Parameters.AddWithValue("@RepeatEveryDays", 15); // Legacy column; recurrence is fixed to the 1st/16th.
                c.Parameters.AddWithValue("@DownStartOffsetSeconds", Math.Max(0, model.DownStartOffsetSeconds));
                c.Parameters.AddWithValue("@FirstStartOffsetSeconds", model.FirstStartOffsetSeconds <= 0 ? 300 : model.FirstStartOffsetSeconds);
                c.Parameters.AddWithValue("@DigitRevealIntervalSeconds", model.DigitRevealIntervalSeconds <= 0 ? 10 : model.DigitRevealIntervalSeconds);
                c.Parameters.AddWithValue("@CreatedBy", CurrentUser());
                c.Parameters.AddWithValue("@Remarks", DbValue(model.Remarks));
                var output = c.Parameters.Add("@NewDrawID", SqlDbType.Int);
                output.Direction = ParameterDirection.Output;
            });
        }

        [HttpPost, Route("{drawId:int}/publish")]
        public HttpResponseMessage Publish(int drawId)
        {
            return Execute("dbo.sproc_BangkokDraw_Publish", c =>
            {
                c.Parameters.AddWithValue("@DrawID", drawId);
                c.Parameters.AddWithValue("@PublishedBy", CurrentUser());
            });
        }

        [HttpPost, Route("auto-process")]
        public HttpResponseMessage AutoProcess()
        {
            return Execute("dbo.sproc_BangkokDraw_SchedulerTick", c =>
                c.Parameters.AddWithValue("@TriggeredBy", CurrentUser() + " (manual recovery)"));
        }

        [HttpGet, Route("scheduler-health")]
        public HttpResponseMessage SchedulerHealth()
        {
            try
            {
                var row = db.Database.SqlQuery<SchedulerHealthDto>(@"
SELECT TOP (1) SchedulerRunID,StartedUTC,CompletedUTC,RunStatus,
       StateChangeCount,TriggeredBy,Message
FROM dbo.BangkokDrawSchedulerRun
ORDER BY SchedulerRunID DESC;").FirstOrDefault();
                if (row != null)
                {
                    row.StartedUTC = DateTime.SpecifyKind(row.StartedUTC, DateTimeKind.Utc);
                    row.CompletedUTC = AsUtcAdmin(row.CompletedUTC);
                }
                return Request.CreateResponse(HttpStatusCode.OK,
                    new { success = true, serverUtc = DateTime.UtcNow, data = row });
            }
            catch (Exception ex)
            {
                return Error(HttpStatusCode.InternalServerError,
                    "Scheduler health request failed: " + ex.GetBaseException().Message);
            }
        }

        [HttpDelete, Route("{drawId:int}/delete")]
        public HttpResponseMessage DeleteDraw(int drawId)
        {
            if (drawId <= 0)
                return Error(HttpStatusCode.BadRequest, "A valid drawId is required.");

            return Execute("dbo.sproc_BangkokDraw_Delete", c =>
            {
                c.Parameters.AddWithValue("@DrawID", drawId);
                c.Parameters.AddWithValue("@DeletedBy", CurrentUser());
            });
        }

        [HttpPost, Route("{drawId:int}/mark-ready")]
        public HttpResponseMessage MarkReady(int drawId)
        {
            return Execute("dbo.sproc_BangkokDraw_MarkReady", c =>
            {
                c.Parameters.AddWithValue("@DrawID", drawId);
                c.Parameters.AddWithValue("@ModifiedBy", CurrentUser());
            });
        }

        [HttpGet, Route("{drawId:int}/control")]
        public HttpResponseMessage Control(int drawId)
        {
            return Execute("dbo.sproc_BangkokDraw_GetAdminControl", c =>
                c.Parameters.AddWithValue("@DrawID", drawId));
        }

        [HttpGet, Route("{drawId:int}/results")]
        public HttpResponseMessage Results(int drawId)
        {
            try
            {
                var rows = db.Database.SqlQuery<AdminResultDto>(@"
SELECT R.ResultID,R.DrawGameID,G.GameCode,G.GameName,G.DigitCount,
       R.ResultNumber,R.ResultStatus,R.ResultSource,R.IsConfirmed,
       R.RevealedDigitCount,R.IsLocked,R.EnteredDateUTC,R.ConfirmedDateUTC,
       R.RevealCompletedUTC,R.ResultVersion,R.IsLateEntry,R.EntryDelaySeconds,R.Remarks
FROM dbo.BangkokDrawResult R
JOIN dbo.BangkokDrawGame G ON G.DrawGameID=R.DrawGameID
WHERE G.DrawID=@p0 AND G.IsActive=1
  AND R.ResultVersion=(SELECT MAX(R2.ResultVersion) FROM dbo.BangkokDrawResult R2 WHERE R2.DrawGameID=R.DrawGameID)
ORDER BY G.DisplayOrder,R.ResultID;", drawId).ToList();
                return Request.CreateResponse(HttpStatusCode.OK, new { success = true, data = rows });
            }
            catch (Exception ex) { return Error(HttpStatusCode.InternalServerError, ex.GetBaseException().Message); }
        }

        [HttpPost, Route("{drawId:int}/enter-result")]
        public HttpResponseMessage EnterResult(int drawId, EnterResultRequest model)
        {
            if (model == null || model.DrawGameID <= 0 || String.IsNullOrWhiteSpace(model.ResultNumber))
                return Error(HttpStatusCode.BadRequest, "DrawGameID and ResultNumber are required.");
            var number = model.ResultNumber.Trim();
            if (!number.All(Char.IsDigit))
                return Error(HttpStatusCode.BadRequest, "ResultNumber must contain digits only.");
            var game = db.Database.SqlQuery<GameValidationDto>(@"
SELECT TOP (1) DrawGameID,DigitCount
FROM dbo.BangkokDrawGame
WHERE DrawGameID=@p0 AND DrawID=@p1 AND IsActive=1;", model.DrawGameID, drawId).FirstOrDefault();
            if (game == null)
                return Error(HttpStatusCode.BadRequest, "The selected game does not belong to this draw.");
            if (number.Length != game.DigitCount)
                return Error(HttpStatusCode.BadRequest, "ResultNumber must contain exactly " + game.DigitCount + " digits.");
            return Execute("dbo.sproc_BangkokDraw_EnterResult", c =>
            {
                c.Parameters.AddWithValue("@DrawGameID", model.DrawGameID);
                c.Parameters.AddWithValue("@ResultNumber", number);
                c.Parameters.AddWithValue("@EnteredBy", CurrentUser());
                c.Parameters.AddWithValue("@ResultSource", String.IsNullOrWhiteSpace(model.ResultSource) ? "Manual" : model.ResultSource.Trim());
                c.Parameters.AddWithValue("@Remarks", DbValue(model.Remarks)); AddAudit(c);
            });
        }

        [HttpPost, Route("results/{resultId:int}/confirm")]
        public HttpResponseMessage Confirm(int resultId) { return Execute("dbo.sproc_BangkokDraw_ConfirmResult", c => { c.Parameters.AddWithValue("@ResultID", resultId); c.Parameters.AddWithValue("@ConfirmedBy", CurrentUser()); AddAudit(c); }); }
        [HttpPost, Route("{drawId:int}/start")]
        public HttpResponseMessage Start(int drawId) { return DrawAction("dbo.sproc_BangkokDraw_StartBroadcast", drawId, "@StartedBy", false); }
        [HttpPost, Route("{drawId:int}/reveal-next")]
        public HttpResponseMessage Reveal(int drawId) { return DrawAction("dbo.sproc_BangkokDraw_RevealNextDigit", drawId, "@RevealedBy", true); }
        [HttpPost, Route("{drawId:int}/pause")]
        public HttpResponseMessage Pause(int drawId, PauseDrawRequest model)
        {
            if (drawId <= 0 || model == null || String.IsNullOrWhiteSpace(model.Reason))
                return Error(HttpStatusCode.BadRequest, "A valid drawId and pause reason are required.");
            return Execute("dbo.sproc_BangkokDraw_Pause", c =>
            {
                c.Parameters.AddWithValue("@DrawID", drawId);
                c.Parameters.AddWithValue("@DrawGameID", model.DrawGameID.HasValue ? (object)model.DrawGameID.Value : DBNull.Value);
                c.Parameters.AddWithValue("@PauseReason", model.Reason.Trim());
                c.Parameters.AddWithValue("@PausedBy", CurrentUser());
                c.Parameters.AddWithValue("@Remarks", DbValue(model.Remarks));
            });
        }
        [HttpPost, Route("{drawId:int}/resume")]
        public HttpResponseMessage Resume(int drawId, ResumeDrawRequest model)
        {
            if (drawId <= 0 || model == null || String.IsNullOrWhiteSpace(model.Reason))
                return Error(HttpStatusCode.BadRequest, "A valid drawId and resume reason are required.");
            var pauseId = model.PauseHistoryID;
            if (pauseId <= 0)
                pauseId = db.Database.SqlQuery<int>(@"
SELECT TOP (1) PauseHistoryID
FROM dbo.BangkokDrawPauseHistory
WHERE DrawID=@p0 AND ResumeDateUTC IS NULL
ORDER BY PauseStartedUTC DESC,PauseHistoryID DESC;", drawId).FirstOrDefault();
            if (pauseId <= 0)
                return Error(HttpStatusCode.BadRequest, "No active pause was found for this draw.");
            return Execute("dbo.sproc_BangkokDraw_Resume", c =>
            {
                c.Parameters.AddWithValue("@PauseHistoryID", pauseId);
                c.Parameters.AddWithValue("@ResumeReason", model.Reason.Trim());
                c.Parameters.AddWithValue("@ResumedBy", CurrentUser());
            });
        }
        [HttpPost, Route("{drawId:int}/complete")]
        public HttpResponseMessage Complete(int drawId) { return DrawAction("dbo.sproc_BangkokDraw_Complete", drawId, "@CompletedBy", false); }

        private HttpResponseMessage DrawAction(string procedure, int drawId, string userParam, bool audit)
        {
            if (drawId <= 0) return Error(HttpStatusCode.BadRequest, "A valid drawId is required.");
            return Execute(procedure, c => { c.Parameters.AddWithValue("@DrawID", drawId); c.Parameters.AddWithValue(userParam, CurrentUser()); if (audit) AddAudit(c); });
        }
        private HttpResponseMessage Execute(string procedure, Action<SqlCommand> setup)
        {
            try
            {
                var entityConnection = db.Database.Connection as EntityConnection;
                var connection = entityConnection == null
                    ? db.Database.Connection as SqlConnection
                    : entityConnection.StoreConnection as SqlConnection;
                if (connection == null) return Error(HttpStatusCode.InternalServerError, "EF is not using SqlConnection.");
                using (var command = new SqlCommand(procedure, connection))
                {
                    command.CommandType = CommandType.StoredProcedure; command.CommandTimeout = 60; setup(command);
                    if (connection.State != ConnectionState.Open) connection.Open();
                    using (var reader = command.ExecuteReader())
                    {
                        var sets = new List<object>();
                        do
                        {
                            var rows = new List<Dictionary<string, object>>();
                            while (reader.Read())
                            {
                                var row = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                                for (var i = 0; i < reader.FieldCount; i++) row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
                                rows.Add(row);
                            }
                            if (reader.FieldCount > 0) sets.Add(rows);
                        } while (reader.NextResult());
                        return Request.CreateResponse(HttpStatusCode.OK, new { success = true, data = sets.Count == 1 ? sets[0] : sets });
                    }
                }
            }
            catch (SqlException ex) { return Request.CreateResponse(HttpStatusCode.BadRequest, new { success = false, sqlErrorNumber = ex.Number, message = ex.Message }); }
            catch (Exception ex) { return Error(HttpStatusCode.InternalServerError, ex.GetBaseException().Message); }
            finally { if (db.Database.Connection.State == ConnectionState.Open) db.Database.Connection.Close(); }
        }
        private void AddAudit(SqlCommand c) { var r = HttpContext.Current == null ? null : HttpContext.Current.Request; c.Parameters.AddWithValue("@IPAddress", DbValue(r == null ? null : r.UserHostAddress)); c.Parameters.AddWithValue("@UserAgent", DbValue(r == null ? null : r.UserAgent)); }
        private string CurrentUser() { return User != null && User.Identity != null && User.Identity.IsAuthenticated && !String.IsNullOrWhiteSpace(User.Identity.Name) ? User.Identity.Name : "Admin"; }
        private static object DbValue(string value) { return String.IsNullOrWhiteSpace(value) ? (object)DBNull.Value : value.Trim(); }
        private HttpResponseMessage Error(HttpStatusCode status, string message) { return Request.CreateResponse(status, new { success = false, message }); }
        protected override void Dispose(bool disposing) { if (disposing) db.Dispose(); base.Dispose(disposing); }
        public class EnterResultRequest { public int DrawGameID { get; set; } public string ResultNumber { get; set; } public string ResultSource { get; set; } public string Remarks { get; set; } }
        public class PauseDrawRequest { public int? DrawGameID { get; set; } public string Reason { get; set; } public string Remarks { get; set; } }
        public class ResumeDrawRequest { public int PauseHistoryID { get; set; } public string Reason { get; set; } }
        private class GameValidationDto { public int DrawGameID { get; set; } public byte DigitCount { get; set; } }
        public class CreateDrawRequest
        {
            public string DrawCode { get; set; }
            public string DrawName { get; set; }
            public DateTime DrawDate { get; set; }
            public DateTime ScheduledStartUTC { get; set; }
            public string TimeZoneID { get; set; }
            public int CountdownMinutes { get; set; }
            public int RepeatEveryDays { get; set; }
            public int DownStartOffsetSeconds { get; set; }
            public int FirstStartOffsetSeconds { get; set; }
            public int DigitRevealIntervalSeconds { get; set; }
            public string Remarks { get; set; }
        }

        private static DateTime? AsUtcAdmin(DateTime? value)
        {
            return value.HasValue ? DateTime.SpecifyKind(value.Value, DateTimeKind.Utc) : value;
        }

        private static void NormalizeDashboardUtc(DashboardDrawDto item)
        {
            if (item == null) return;

            item.ScheduledStartUTC = DateTime.SpecifyKind(
                item.ScheduledStartUTC, DateTimeKind.Utc);

            if (item.ActualStartUTC.HasValue)
                item.ActualStartUTC = DateTime.SpecifyKind(
                    item.ActualStartUTC.Value, DateTimeKind.Utc);

            if (item.ActualEndUTC.HasValue)
                item.ActualEndUTC = DateTime.SpecifyKind(
                    item.ActualEndUTC.Value, DateTimeKind.Utc);
        }

        public class DashboardSummaryDto
        {
            public int TotalDraws { get; set; }
            public int CompletedDraws { get; set; }
            public int UpcomingDraws { get; set; }
            public int LiveDraws { get; set; }
        }

        public class DashboardDrawDto
        {
            public int DrawID { get; set; }
            public string DrawCode { get; set; }
            public string DrawName { get; set; }
            public string DrawStatus { get; set; }
            public bool IsPublished { get; set; }
            public DateTime ScheduledStartUTC { get; set; }
            public DateTime? ActualStartUTC { get; set; }
            public DateTime? ActualEndUTC { get; set; }
            public int GameCount { get; set; }
        }

        public class DashboardResultDto
        {
            public string GameCode { get; set; }
            public string GameName { get; set; }
            public int DisplayOrder { get; set; }
            public string ResultNumber { get; set; }
            public DateTime? RevealCompletedUTC { get; set; }
        }

        public class SchedulerHealthDto
        {
            public long SchedulerRunID { get; set; }
            public DateTime StartedUTC { get; set; }
            public DateTime? CompletedUTC { get; set; }
            public string RunStatus { get; set; }
            public int StateChangeCount { get; set; }
            public string TriggeredBy { get; set; }
            public string Message { get; set; }
        }

        public class AdminDrawListDto
        {
            public int DrawID { get; set; }
            public string DrawCode { get; set; }
            public string DrawName { get; set; }
            public DateTime DrawDate { get; set; }
            public string DrawStatus { get; set; }
            public bool IsPublished { get; set; }
            public DateTime ScheduledStartUTC { get; set; }
            public DateTime? ActualStartUTC { get; set; }
            public DateTime? ActualEndUTC { get; set; }
            public int GameCount { get; set; }
        }
        public class AdminResultDto
        {
            public int ResultID { get; set; }
            public int DrawGameID { get; set; }
            public string GameCode { get; set; }
            public string GameName { get; set; }
            public byte DigitCount { get; set; }
            public string ResultNumber { get; set; }
            public string ResultStatus { get; set; }
            public string ResultSource { get; set; }
            public bool IsConfirmed { get; set; }
            public byte RevealedDigitCount { get; set; }
            public bool IsLocked { get; set; }
            public DateTime? EnteredDateUTC { get; set; }
            public DateTime? ConfirmedDateUTC { get; set; }
            public DateTime? RevealCompletedUTC { get; set; }
            public int ResultVersion { get; set; }
            public bool IsLateEntry { get; set; }
            public int? EntryDelaySeconds { get; set; }
            public string Remarks { get; set; }
        }
    }
}
