using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace TechnoPurAccounts.Models
{
    public class DigitalRecipt
    {
        public string senderName { get; set; }

        public int debit_account_id { get; set; }
        public int credit_account_id { get; set; }
        public int voucher_type_id { get; set; }
        public int digital_receipt_id { get; set; }
        public int club_id { get; set; }
        public int manaual_journal_info_id { get; set; }
        public decimal  amount { get; set; }
        public string note { get; set; }
        public string attachment  { get; set; }
        public string verfication_no  { get; set; }
    }
}