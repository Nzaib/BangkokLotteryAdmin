using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace TechnoPurAccounts.Models
{
    public class PagingParameterModel
    {
        public int pageNumber { get; set; } 

        public int pageSize { get; set; }
        public string QuerySearch { get; set; }
        public string QuerySearchColumn { get; set; }
    }
}