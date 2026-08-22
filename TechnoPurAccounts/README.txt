READY TO PASTE

1) Replace your existing Controllers/BangkokDrawController.cs with the included file.
2) Add Dashboard.aspx, Dashboard.aspx.cs and Dashboard.aspx.designer.cs beside Admin.Master.
3) Add assets/dashboard-modern.css.
4) Rebuild the solution.

New exact API:
GET /api/admin/bangkok-draw/dashboard
Authorization: existing bearer/access token header.

The dashboard now uses this ONE endpoint for:
- current-month totals
- completed/upcoming/live counts and percentages
- next broadcast
- next 5 upcoming draws
- latest completed draw
- FIRST and DOWN results
- calculated 3Up Straight/Open Pair/Close Pair
- database/API/broadcast status
- server UTC/KSA time
