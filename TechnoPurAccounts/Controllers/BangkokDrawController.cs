using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Core.EntityClient;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using DataAccessLayer;

namespace TechnoPurAccounts.Controllers
{
    [AllowAnonymous]
    [RoutePrefix("api/bangkok-draw")]
    public class BangkokDrawController : ApiController
    {
        private readonly return_orderEntities1 db = new return_orderEntities1();

        [HttpGet, Route("next-broadcast")]
        public HttpResponseMessage NextBroadcast()
        {
            try
            {
                var data = db.Database.SqlQuery<NextBroadcastDto>(@"
SELECT TOP (1) D.DrawID,D.DrawCode,D.DrawStatus,
       MIN(G.ScheduledStartUTC) ScheduledStartUTC,
       CAST(COUNT(*) AS int) GameCount
FROM dbo.BangkokDraw D
JOIN dbo.BangkokDrawGame G ON G.DrawID=D.DrawID AND G.IsActive=1
WHERE D.IsDeleted=0 AND D.DrawStatus IN ('Scheduled','Ready','Live','Paused')
GROUP BY D.DrawID,D.DrawCode,D.DrawStatus
ORDER BY CASE WHEN D.DrawStatus IN ('Live','Paused') THEN 0 ELSE 1 END,
         MIN(G.ScheduledStartUTC);").FirstOrDefault();
                if (data == null) return ApiError(HttpStatusCode.NotFound, "No upcoming broadcast was found.");
                return OkResponse(data);
            }
            catch (Exception ex) { return ExceptionResponse(ex); }
        }

        [HttpGet, Route("{drawId:int}/live-state")]
        public HttpResponseMessage LiveState(int drawId)
        {
            if (drawId <= 0) return ApiError(HttpStatusCode.BadRequest, "A valid drawId is required.");
            try
            {
                var draw = db.Database.SqlQuery<DrawDto>(@"
SELECT TOP (1) DrawID,DrawCode,DrawStatus,ActualStartUTC,ActualEndUTC
FROM dbo.BangkokDraw WHERE DrawID=@p0 AND IsDeleted=0;", drawId).FirstOrDefault();
                if (draw == null) return ApiError(HttpStatusCode.NotFound, "Draw was not found.");

                var games = db.Database.SqlQuery<GameStateDto>(@"
SELECT G.DrawGameID,G.GameCode,G.GameName,G.DisplayOrder,G.DigitCount,
       G.GameStatus,G.ScheduledStartUTC,G.ActualStartUTC,G.ActualEndUTC,
       R.ResultID,
       CASE WHEN R.IsConfirmed=1 THEN LEFT(R.ResultNumber,R.RevealedDigitCount) ELSE '' END RevealedNumber,
       ISNULL(R.ResultStatus,'') ResultStatus,
       CONVERT(bit,ISNULL(R.IsConfirmed,0)) IsConfirmed,
       CONVERT(tinyint,ISNULL(R.RevealedDigitCount,0)) RevealedDigitCount
FROM dbo.BangkokDrawGame G
OUTER APPLY (SELECT TOP (1) R1.* FROM dbo.BangkokDrawResult R1
             WHERE R1.DrawGameID=G.DrawGameID
             ORDER BY R1.ResultVersion DESC,R1.ResultID DESC) R
WHERE G.DrawID=@p0 AND G.IsActive=1
ORDER BY G.DisplayOrder,G.DrawGameID;", drawId).ToList();
                return OkResponse(new { draw, games });
            }
            catch (Exception ex) { return ExceptionResponse(ex); }
        }

        [HttpGet, Route("latest-results")]
        public HttpResponseMessage LatestResults()
        {
            try
            {
                var draw = db.Database.SqlQuery<DrawDto>(@"
SELECT TOP (1) DrawID,DrawCode,DrawStatus,ActualStartUTC,ActualEndUTC
FROM dbo.BangkokDraw
WHERE IsDeleted=0 AND DrawStatus='Completed'
ORDER BY ActualEndUTC DESC,DrawID DESC;").FirstOrDefault();
                if (draw == null) return ApiError(HttpStatusCode.NotFound, "No completed draw was found.");

                var results = db.Database.SqlQuery<ResultDto>(@"
SELECT G.GameCode,G.GameName,CAST(G.DisplayOrder AS int) DisplayOrder,R.ResultNumber,R.RevealCompletedUTC
FROM dbo.BangkokDrawGame G
JOIN dbo.BangkokDrawResult R ON R.DrawGameID=G.DrawGameID
WHERE G.DrawID=@p0 AND G.IsActive=1 AND R.IsConfirmed=1 AND R.ResultStatus='Revealed'
ORDER BY G.DisplayOrder;", draw.DrawID).ToList();
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
                return OkResponse(new { draw, results, calculated });
            }
            catch (Exception ex) { return ExceptionResponse(ex); }
        }

        private HttpResponseMessage OkResponse(object data)
        {
            return Request.CreateResponse(HttpStatusCode.OK,
                new { success = true, serverUtc = DateTime.UtcNow, data });
        }
        private HttpResponseMessage ApiError(HttpStatusCode status, string message)
        {
            return Request.CreateResponse(status, new { success = false, message });
        }
        private HttpResponseMessage ExceptionResponse(Exception ex)
        {
            return Request.CreateResponse(HttpStatusCode.InternalServerError,
                new { success = false, message = "Bangkok draw request failed.", detail = ex.GetBaseException().Message });
        }
        protected override void Dispose(bool disposing) { if (disposing) db.Dispose(); base.Dispose(disposing); }

        public class NextBroadcastDto { public int DrawID { get; set; } public string DrawCode { get; set; } public string DrawStatus { get; set; } public DateTime? ScheduledStartUTC { get; set; } public int GameCount { get; set; } }
        public class DrawDto { public int DrawID { get; set; } public string DrawCode { get; set; } public string DrawStatus { get; set; } public DateTime? ActualStartUTC { get; set; } public DateTime? ActualEndUTC { get; set; } }
        public class GameStateDto { public int DrawGameID { get; set; } public string GameCode { get; set; } public string GameName { get; set; } public int DisplayOrder { get; set; } public byte DigitCount { get; set; } public string GameStatus { get; set; } public DateTime? ScheduledStartUTC { get; set; } public DateTime? ActualStartUTC { get; set; } public DateTime? ActualEndUTC { get; set; } public int? ResultID { get; set; } public string RevealedNumber { get; set; } public string ResultStatus { get; set; } public bool IsConfirmed { get; set; } public byte RevealedDigitCount { get; set; } }
        public class ResultDto { public string GameCode { get; set; } public string GameName { get; set; } public int DisplayOrder { get; set; } public string ResultNumber { get; set; } public DateTime? RevealCompletedUTC { get; set; } }
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
                var saudiTimeZone = TimeZoneInfo.FindSystemTimeZoneById("Arab Standard Time");
                var nowKsa = TimeZoneInfo.ConvertTimeFromUtc(nowUtc, saudiTimeZone);
                var monthStartKsa = new DateTime(nowKsa.Year, nowKsa.Month, 1);
                var nextMonthKsa = monthStartKsa.AddMonths(1);
                var monthStartUtc = TimeZoneInfo.ConvertTimeToUtc(
                    DateTime.SpecifyKind(monthStartKsa, DateTimeKind.Unspecified), saudiTimeZone);
                var nextMonthUtc = TimeZoneInfo.ConvertTimeToUtc(
                    DateTime.SpecifyKind(nextMonthKsa, DateTimeKind.Unspecified), saudiTimeZone);

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
                    // Display/reference value with an explicit Saudi Arabia offset.
                    serverKsa = new DateTimeOffset(
                        DateTime.SpecifyKind(nowKsa, DateTimeKind.Unspecified),
                        TimeSpan.FromHours(3)),
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
            if (model.CountdownMinutes < 1 || model.CountdownMinutes > 1440 ||
                model.RepeatEveryDays < 1 || model.RepeatEveryDays > 365 ||
                model.DownStartOffsetSeconds < 0 ||
                model.FirstStartOffsetSeconds <= model.DownStartOffsetSeconds ||
                model.DigitRevealIntervalSeconds < 1 || model.DigitRevealIntervalSeconds > 300)
                return Error(HttpStatusCode.BadRequest, "One or more schedule values are outside the allowed range.");

            DateTime scheduledStartUtc;
            try
            {
                var saudiTimeZone = TimeZoneInfo.FindSystemTimeZoneById("Arab Standard Time");
                var saudiScheduledTime = DateTime.SpecifyKind(model.ScheduledStartUTC, DateTimeKind.Unspecified);
                scheduledStartUtc = TimeZoneInfo.ConvertTimeToUtc(saudiScheduledTime, saudiTimeZone);
            }
            catch (Exception ex)
            {
                return Error(HttpStatusCode.BadRequest, "Saudi scheduled time is invalid: " + ex.GetBaseException().Message);
            }

            return Execute("dbo.sproc_BangkokDraw_Create", c =>
            {
                c.Parameters.AddWithValue("@DrawCode", model.DrawCode.Trim());
                c.Parameters.AddWithValue("@DrawName", model.DrawName.Trim());
                c.Parameters.AddWithValue("@DrawDate", model.DrawDate.Date);
                c.Parameters.AddWithValue("@ScheduledStartUTC", scheduledStartUtc);
                c.Parameters.AddWithValue("@TimeZoneID", "Arab Standard Time");
                c.Parameters.AddWithValue("@CountdownMinutes", model.CountdownMinutes <= 0 ? 45 : model.CountdownMinutes);
                c.Parameters.AddWithValue("@RepeatEveryDays", model.RepeatEveryDays <= 0 ? 15 : model.RepeatEveryDays);
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
            return Execute("dbo.sproc_BangkokDraw_AutoProcess", c => { });
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
        public HttpResponseMessage Pause(int drawId) { return DrawAction("dbo.sproc_BangkokDraw_Pause", drawId, "@PausedBy", false); }
        [HttpPost, Route("{drawId:int}/resume")]
        public HttpResponseMessage Resume(int drawId) { return DrawAction("dbo.sproc_BangkokDraw_Resume", drawId, "@ResumedBy", false); }
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
