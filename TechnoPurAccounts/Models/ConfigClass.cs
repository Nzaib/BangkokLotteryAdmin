using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace TechnoPurAccounts.Models
{
    public class ConfigClass
    {

        


        public class ClsInsertAddAccounts
        {
            public int type_id { get; set; }
            public int cat1_id { get; set; }
            public string account_name { get; set; }
            public string account_code { get; set; }
            public decimal opening_balance_amount { get; set; }
            public string account_description { get; set; }
            public string opening_balance_type { get; set; }
            public int chart_id { get; set; }


        }

        public class ClsUpdateAddAccounts
        {
            public int type_id { get; set; }
            public int cat1_id { get; set; }
            public string account_name { get; set; }
            public string account_code { get; set; }
            public decimal opening_balance_amount { get; set; }
            public string account_description { get; set; }
            public string opening_balance_type { get; set; }
            public int chart_id { get; set; }

        }


        public class ClAddOpeningBalance
        {


            public decimal opening_balance { get; set; }
            public string balance_type { get; set; }

            
            public int chart_id { get; set; }

        }

        public class ClsInsertVoucher
        {

            
            
            

            public int voucher_type_id { get; set; }
            

            public DateTime vocuherDate { get; set; }
            public string voucher_discription { get; set; }
            

            public int debit_account_id { get; set; }
            

            public int credit_account_id { get; set; }
            
            public decimal amount { get; set; }


            
            public string created_by { get; set; }

            
            public string creatd_date { get; set; }
            
            public string userip { get; set; }

        }

        public class ClSingleMultipleVoucherInsertVoucher
        {
            public int manual_journal_info_id { get; set; }
            
            public int voucher_id { get; set; }
            
            public DateTime vocuherDate { get; set; }
            public string voucher_discription { get; set; }
            public int single_chart_id { get; set; }
            public IEnumerable<ClsInsertVoucherentires> Entirs { get; set; }
        }


        public class ClsInsertVoucherentires
        {
            
            public int chart_id { get; set; }
            public string description { get; set; }
            public decimal debit { get; set; }
            public decimal credit { get; set; }
        }


        public class ClsUpdateVoucher
        {
            

            public int voucher_id { get; set; }
            public int manual_journal_info_id { get; set; }

            
            
            

            public DateTime vocuherDate { get; set; }
            public string voucher_discription { get; set; }
            

            public int debit_account_id { get; set; }
            

            public int credit_account_id { get; set; }
            
            public decimal amount { get; set; }
            
            public string creatd_date { get; set; }
            
            public string userip { get; set; }

        }
        public class ClsGetVoucherHistory
        {
            
            public int voucher_type_id { get; set; }
            public DateTime from_date { get; set; }
            public DateTime to_date { get; set; }
        }
        public class ClsGetBillHistory
        {
            
            public DateTime from_date { get; set; }
            public DateTime to_date { get; set; }
        }

        public class ClsGetBalanceSheetReport
        {
            
            public DateTime from_date { get; set; }
        }
        public class ClsTransactions_Report
        {
            
            public int type_id { get; set; }
            public int chart_id { get; set; }
            public DateTime from_date { get; set; }
            public DateTime to_date { get; set; }
        }

        public class Clstypewiseaccount
        {
            
            public int type_id { get; set; }
        }
        public class ClsPurchaseMainInfo
        {
            
            public int manual_journal_info_id { get; set; }

            public int chart_id { get; set; }
            public string bill_type { get; set; }

            public DateTime Date { get; set; }
            public string notes { get; set; }
            public string creatd_date { get; set; }
            public string userip { get; set; }

            public decimal subTotal { get; set; }
            public decimal discount { get; set; }
            public decimal grandTotal { get; set; }
            public decimal sale_tax { get; set; }
            public decimal further_tax_amount { get; set; }
            public decimal further_tax_percentage { get; set; }

            public string sale_tax_inculde_status { get; set; }
            public string driver_name { get; set; }
            public string driver_contact_no { get; set; }
            public string vehicle_no { get; set; }
            public string gate_pass_check_status { get; set; }

            public IEnumerable<ClsPurchaseEntirsInfo> Entirs { get; set; }

        }
        public class ClsPurchaseEntirsInfo
        {
            public int chart_id { get; set; }
            public string stock_type { get; set; }
            public string description { get; set; }
            public string stock_condition { get; set; }
            public string Particular { get; set; }
            public int stock_units_id { get; set; }
            public decimal rate { get; set; }
            public decimal quantity { get; set; }
            public decimal total_amount { get; set; }
            public decimal item_sale_tax { get; set; }
            public decimal item_further_tax { get; set; }
            public decimal sale_tax_percentage { get; set; }
            public decimal further_tax_percentage { get; set; }
            public decimal item_sub_total { get; set; }
            public decimal item_discount_percentage { get; set; }
            public decimal item_discount_amount { get; set; }

        }



        public class getaccount_type
        {
            public string account_type1 { get; set; }

            public List<getcategories1> catagory1 = new List<getcategories1>();
        }
        public class getcategories1
        {
            public string category1_name { get; set; }
            public List<getChartOfAccount> accounts = new List<getChartOfAccount>();
            public List<getcategories2> catagory2 = new List<getcategories2>();

        }
        public class getcategories2
        {
            public string category1_name { get; set; }
            public List<getChartOfAccount> accounts = new List<getChartOfAccount>();
            public List<getcategories3> catagory3 = new List<getcategories3>();

        }
        public class getcategories3
        {
            public string category1_name { get; set; }
            public List<getChartOfAccount> accounts = new List<getChartOfAccount>();
            public List<getcategories4> catagory4 = new List<getcategories4>();
        }
        public class getcategories4
        {
            public string category1_name { get; set; }
            public List<getChartOfAccount> accounts = new List<getChartOfAccount>();
            public List<getcategories5> catagory5 = new List<getcategories5>();

        }
        public class getcategories5
        {
            public string category1_name { get; set; }
            public List<getChartOfAccount> accounts = new List<getChartOfAccount>();
        }
        public class getChartOfAccount
        {
            public int chart_id { get; set; }
            public string account_name { get; set; }
            public decimal opening_balance { get; set; }
            public decimal current_balance { get; set; }
            public string editable { get; set; }
            public string balance_type { get; set; }

            public decimal opening_balance_debit { get; set; }
            public decimal opening_balance_credit { get; set; }
            public decimal current_balance_debit { get; set; }
            public decimal current_balance_credit { get; set; }
            public decimal Closing_Balance { get; set; }


        }


        public class ClsGetUserPaymentHistory
        {
            public DateTime from_date { get; set; }
            public DateTime from_to { get; set; }
        }
        public class ClsGetPaymentHistory
        {
            
            public DateTime from_date { get; set; }
            public DateTime from_to { get; set; }
        }
        public class Clssendsms
        {
            public string subject { get; set; }
            public string body { get; set; }
        }

        public class Clsspallaccounts
        {
            public int chart_id { get; set; }
            public int cat1_id { get; set; }
            public int type_id { get; set; }
            public string account_name { get; set; }
            public double? opening_balance { get; set; }
            public string balance_type { get; set; }
        }


        public class ClsGetDashboardReport
        {

            public double? total_register_user { get; set; }
            public double? total_free_trial_user { get; set; }
            public double? total_subscribe { get; set; }
            public double? total_invoice_amount { get; set; }
            public double? total_pending_invoices { get; set; }
        }

        public class Clsspatrial
        {
            public int chart_id { get; set; }
            public int cat1_id { get; set; }
            public int account_type_id { get; set; }
            public string account_name { get; set; }
            public string account_code { get; set; }
            public double? account_opening_balance_debit { get; set; }
            public double? account_opening_balance_credit { get; set; }
            public double? opening_balance_debit { get; set; }
            public double? opening_balance_credit { get; set; }
            public double? current_balance_debit { get; set; }
            public double? current_balance_credit { get; set; }
        }

        public class ClsPLpatrial
        {
            public int chart_id { get; set; }
            public int cat1_id { get; set; }
            public int account_type_id { get; set; }
            public string account_name { get; set; }
            public string account_code { get; set; }
            public double? current_balance { get; set; }
            public double? opening_balance { get; set; }
        }
        public class ClsPLAmountpatrial
        {
   
            public double? PLAmount { get; set; }
        }

        public class ClssPlAmount
        {
            public double? PLAmount { get; set; }
        }
            public class Clsaddmodules
        {
            public int module_id { get; set; }
        }
        public class ClsGetDefectedStockItemWiseReport
        {
            public int chart_id { get; set; }
            public string account_name { get; set; }
            public string datefrom { get; set; }
            public string dateto { get; set; }
            public double? defected_sale_return_in { get; set; }
            public double? defected_sale_return_debit { get; set; }
            public double? defected_sale_return_quantity { get; set; }
            public double? defected_purchase_retrun_out { get; set; }
            public double? defected_purchase_retrun_credit { get; set; }
            public double? defected_purchase_retrun_quantity { get; set; }
        }
        public class ClsGetStockAccountsReport
        {
            public string chart_id { get; set; }
            public string account_name { get; set; }
        }

        public class ClsCoTablesData
        {
            public List<ClsGetStockAccountsReport> AccountList = new List<ClsGetStockAccountsReport>();
            public List<ClsAvailableStockReport> AccountEntires = new List<ClsAvailableStockReport>();
        }

        public class ClsCoTablesDataDefected
        {
            public List<ClsGetStockAccountsReport> AccountList = new List<ClsGetStockAccountsReport>();
            public List<ClsGetDefectedStockItemWiseReport> AccountEntires = new List<ClsGetDefectedStockItemWiseReport>();
        }

        public class ClsStockItemWiseReport
        {

            public int chart_id { get; set; }
            public string account_name { get; set; }
            public decimal sale_amount { get; set; }
            public decimal sale_quantity { get; set; }
            public decimal purchase_sale_amount { get; set; }
            public decimal purchase_quantity { get; set; }
            public decimal total_sale_return__amount { get; set; }
            public decimal sale_return_quantity { get; set; }
            public decimal purchase_return_sale_amount { get; set; }
            public decimal purchase_return_quantity { get; set; }
            public string datefrom { get; set; }
            public string dateto { get; set; }
            //public double? defected_sale_return_in { get; set; }
            public double? defected_sale_return_debit { get; set; }
            public double? defected_sale_return_quantity { get; set; }
            //public double? defected_purchase_retrun_out { get; set; }
            public double? defected_purchase_retrun_credit { get; set; }
            public double? defected_purchase_retrun_quantity { get; set; }


        }
        public class ClsCoTablesStockItemWiseReport
        {
            public List<ClsGetStockAccountsReport> AccountList = new List<ClsGetStockAccountsReport>();
            public List<ClsStockItemWiseReport> AccountEntires = new List<ClsStockItemWiseReport>();
        }
        public class ClsCoTablesDefectedStockItemWiseReport
        {
            public List<ClsGetStockAccountsReport> AccountList = new List<ClsGetStockAccountsReport>();
            public List<ClsGetDefectedStockItemWiseReport> AccountEntires = new List<ClsGetDefectedStockItemWiseReport>();
        }
        public class Clsavailable_stock
        {
            public DateTime from_date { get; set; }
            public DateTime to_date { get; set; }
        }
        public class ClsGetStockItemWiseReport
        {
            public string datefrom { get; set; }
        }
        public class clsDefected_stock
        {
            public string account_name { get; set; }
            public string account_code { get; set; }
            public int chart_id { get; set; }
            
            public string stock_unit_name { get; set; }
            public double? pr_defected_quantity { get; set; }
            public double? pr_defected_amount { get; set; }
            public double? sr_defected_quantity { get; set; }
            public double? sr_defected_amount { get; set; }
        }
        public class clsavailable_stock
        {
            public string account_name { get; set; }
            public string account_code { get; set; }
            public int chart_id { get; set; }
            
            public string stock_unit_name { get; set; }

            public double? purchase_quantity { get; set; }
            public double? purchase_return_quantity { get; set; }
            public double? pr_defected_quantity { get; set; }
            public double? sale_quantity { get; set; }
            public double? sale_return_quantity { get; set; }
            public double? sr_defected_quantity { get; set; }
            public double? opening_qty { get; set; }
            public double? prv_opening_qty { get; set; }
            public double? prv_opening_qty_defected { get; set; }

        }
        public class clsavailable_GetStockItemWiseReport
        {
            public string account_name { get; set; }
            public string account_code { get; set; }
            public int chart_id { get; set; }
            
            public string stock_unit_name { get; set; }

            public double? purchase_quantity { get; set; }
            public double? purchase_amount { get; set; }
            public double? purchase_return_quantity { get; set; }
            public double? purchase_return_amount { get; set; }
            public double? pr_defected_quantity { get; set; }
            public double? pr_defected_amount { get; set; }
            public double? sale_quantity { get; set; }
            public double? sale_amount { get; set; }
            public double? sale_return_quantity { get; set; }
            public double? sale_return_amount { get; set; }
            public double? sr_defected_quantity { get; set; }
            public double? sr_defected_amount { get; set; }
        }
        public class Cls_stock_report
        {
            public int stock_id { get; set; }
            public int party_id { get; set; }
            public DateTime from_date { get; set; }
            public DateTime from_to { get; set; }
        }
        public class ClsStock_detail
        {
            public int chart_id { get; set; }
            public decimal OpeningBalance { get; set; }
            public decimal OpeningQty { get; set; }
            public string account_name { get; set; }
            public string account_code { get; set; }
            public string stock_unit_name { get; set; }

        }
        public class GetStockJournalEntriesrecord
        {
            public DateTime Date { get; set; }
            public string party_name { get; set; }
            public string account_name { get; set; }
            public int chart_id { get; set; }
            public decimal quantity_debit { get; set; }
            public decimal quantity_credit { get; set; }
            public decimal debit { get; set; }
            public decimal credit { get; set; }
            public string voucher_invoice { get; set; }
            public int manual_journal_info_id { get; set; }
            public string description { get; set; }
            public string account_code { get; set; }
            public decimal quantity { get; set; }
            public string trade_type { get; set; }
            public string Reference { get; set; }
            public string notes { get; set; }
            public string rate { get; set; }


        }

        public class ClsAvailableStockReport
        {
            public int chart_id { get; set; }
            public string account_name { get; set; }
            public string account_code { get; set; }
            public decimal sale_amount { get; set; }
            public decimal sale_quantity { get; set; }
            public decimal purchase_sale_amount { get; set; }
            public decimal purchase_quantity { get; set; }
            public decimal defected_quantity { get; set; }
            public decimal fresh_qty { get; set; }
            public decimal net_qty { get; set; }
            public decimal average { get; set; }
            public decimal averageweight { get; set; }
            public decimal avl_kg { get; set; }
            public decimal opening_qty { get; set; }
        }
        public class ClsUpdateStockTariff
        {
            public int chart_id { get; set; }
            public int product_entires_id { get; set; }
            public decimal sale_tax_percentage { get; set; }
            public decimal further_tax_percentage { get; set; }
            public decimal discount_percentage { get; set; }
            public decimal sale_amount { get; set; }
            public decimal purchase_amount { get; set; }
            public decimal sale_discount_rate { get; set; }
            public decimal discounted_amount { get; set; }
            public decimal duplicate_sale_rate { get; set; }
            public decimal duplicate_discounted_amount { get; set; }


        }


        public class ClsUpdateGatePassInfo
        {
            public int manual_journal_info_id { get; set; }
            public string driver_name { get; set; }
            public string driver_contact_no { get; set; }
            public string vehicle_no { get; set; }
            public string gate_pass_check_status { get; set; }
            public string bill_type { get; set; }
        }

        public class ClsPOSSaleMainInfo
        {
            public int manual_journal_info_id { get; set; }
            public int chart_id { get; set; }
            public DateTime Date { get; set; }
            public string creatd_date { get; set; }
            public string userip { get; set; }

            public decimal subTotal { get; set; }
            public decimal grandTotal { get; set; }
            public decimal sale_tax { get; set; }
            public decimal further_tax_amount { get; set; }
            public decimal further_tax_percentage { get; set; }

            public string sale_tax_inculde_status { get; set; }
            public string remaning_balance_add { get; set; }

            public string payment_type { get; set; }
            public decimal partial_cash { get; set; }
            public decimal partial_credit { get; set; }
            public decimal discount_amount { get; set; }
            public decimal pay_amount { get; set; }
            public decimal remaining_due { get; set; }
            public string order_status { get; set; }
            public string order_type { get; set; }
            public int return_invoice_id { get; set; }
            public string driver_name { get; set; }
            public string driver_contact_no { get; set; }
            public string vehicle_no { get; set; }
            public string gate_pass_check_status { get; set; }
            public IEnumerable<ClsPOSSaleEntirsInfo> Entirs { get; set; }

        }
        public class ClsPOSSaleEntirsInfo
        {
            public int chart_id { get; set; }
            public string description { get; set; }
            public int stock_units_id { get; set; }
            public decimal rate { get; set; }
            public decimal quantity { get; set; }
            public decimal total_amount { get; set; }
            public decimal item_sale_tax { get; set; }
            public decimal item_further_tax { get; set; }
            public decimal sale_tax_percentage { get; set; }
            public decimal further_tax_percentage { get; set; }
            public decimal item_sub_total { get; set; }
            public decimal item_discount_percentage { get; set; }
            public decimal item_discount_amount { get; set; }

        }
        public class ClsOnlineSaleMainInfo
        {
            public int shipping_billing_address_id { get; set; }
            public string discount_voucher_code { get; set; }
            public IEnumerable<ClsOnlineSaleEntirsInfo> order_item_details { get; set; }
        }
        public class ClsOnlineSaleEntirsInfo
        {
            public int cart_id { get; set; }
            public int chart_id { get; set; }
            public decimal quantity { get; set; }
        }
        public class ClsCheckStock
        {
            public string stock_unit_name { get; set; }
            public string account_name { get; set; }
            public int chart_id { get; set; }
            public double? openingQty { get; set; }
            public double? current_qty { get; set; }
            public double? ac_opening_Qty { get; set; }
        }

    }
}