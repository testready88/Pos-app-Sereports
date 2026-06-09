package com.ms.semicolans.sereportapi.sereportapi.entity.main;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@RequiredArgsConstructor
@AllArgsConstructor
@Table(name = "tbl_UserAccounts")
public class UserAccounts {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RowNo")
    private Long rowNo;

    @Column(name = "LocaCode")
    private String locaCode;

    @Column(name = "UserCode")
    private String userCode;

    @Column(name = "CName")
    private String cName;

    @Column(name = "UserName")
    private String userName;

    @Column(name = "UserPassword")
    private String userPassword;

    @Column(name = "UserPinCode")
    private String userPinCode;

    @Column(name = "UserType")
    private String userType;

    @Column(name = "CreateBy")
    private String createBy;

    @Column(name = "CreateDate")
    private String createDate;

    @Column(name = "pinnumber")
    private String pinnumber;

    @Column(name = "SeReportsLogin")
    private String seReportsLogin;

    // ---------- Item ----------
    @Column(name = "chkAddItem")        private String chkAddItem;
    @Column(name = "chkEditItem")       private String chkEditItem;
    @Column(name = "chkDelItem")        private String chkDelItem;

    // ---------- Category ----------
    @Column(name = "chkAddCat")         private String chkAddCat;
    @Column(name = "chkEditCat")        private String chkEditCat;
    @Column(name = "chkDelCat")         private String chkDelCat;

    // ---------- Supplier ----------
    @Column(name = "chkAddSup")         private String chkAddSup;
    @Column(name = "chkEditSup")        private String chkEditSup;
    @Column(name = "chkDelSup")         private String chkDelSup;

    // ---------- Customer ----------
    @Column(name = "chkAddCus")         private String chkAddCus;
    @Column(name = "chkEditCus")        private String chkEditCus;
    @Column(name = "chkDelCus")         private String chkDelCus;

    // ---------- Employee ----------
    @Column(name = "chkAddEmp")         private String chkAddEmp;
    @Column(name = "chkEditEmp")        private String chkEditEmp;
    @Column(name = "chkDelEmp")         private String chkDelEmp;

    // ---------- User Management ----------
    @Column(name = "chkAddUser")        private String chkAddUser;
    @Column(name = "chkEditUser")       private String chkEditUser;
    @Column(name = "chkDelUser")        private String chkDelUser;
    @Column(name = "chkUserControl")    private String chkUserControl;
    @Column(name = "chkUserControlOption") private String chkUserControlOption;

    // ---------- Purchase ----------
    @Column(name = "chkPurchase")       private String chkPurchase;
    @Column(name = "chkPurchaseR")      private String chkPurchaseR;
    @Column(name = "chkClearPurchase")  private String chkClearPurchase;
    @Column(name = "chkCancelPurchase") private String chkCancelPurchase;
    @Column(name = "chkEditPurchase")   private String chkEditPurchase;
    @Column(name = "chkHoldPurchase")   private String chkHoldPurchase;
    @Column(name = "chkProceedGRN")     private String chkProceedGRN;

    // ---------- Invoice ----------
    @Column(name = "chkInvoice")        private String chkInvoice;
    @Column(name = "chkInvoiceR")       private String chkInvoiceR;
    @Column(name = "chkPrintInvoice")   private String chkPrintInvoice;
    @Column(name = "chkClearInvoice")   private String chkClearInvoice;
    @Column(name = "chkCancelInvoice")  private String chkCancelInvoice;
    @Column(name = "chkEditInvoice")    private String chkEditInvoice;
    @Column(name = "chkHoldInvoice")    private String chkHoldInvoice;
    @Column(name = "chkMakeQuotation")  private String chkMakeQuotation;
    @Column(name = "chkMakeDNote")      private String chkMakeDNote;
    @Column(name = "chkMakeReceipt")    private String chkMakeReceipt;
    @Column(name = "chkDeleteHoldInv")  private String chkDeleteHoldInv;
    @Column(name = "chkCreditSales")    private String chkCreditSales;
    @Column(name = "chkPrintDaySummery") private String chkPrintDaySummery;

    // ---------- Financial ----------
    @Column(name = "chkPayDue")         private String chkPayDue;
    @Column(name = "chkQtyAdjust")      private String chkQtyAdjust;
    @Column(name = "chkCashDenomination") private String chkCashDenomination;
    @Column(name = "chkCashDiscount")   private String chkCashDiscount;
    @Column(name = "chkEmpDiscount")    private String chkEmpDiscount;
    @Column(name = "chkUpdateCashDenomination") private String chkUpdateCashDenomination;
    @Column(name = "chkViewCashDenominationRpt") private String chkViewCashDenominationRpt;
    @Column(name = "chkPaidOut")        private String chkPaidOut;
    @Column(name = "chkSalaryPayment")  private String chkSalaryPayment;
    @Column(name = "chkAddIncome")      private String chkAddIncome;
    @Column(name = "chkAddExpenses")    private String chkAddExpenses;
    @Column(name = "chkProceedIncome")  private String chkProceedIncome;
    @Column(name = "chkProceedExpenses") private String chkProceedExpenses;
    @Column(name = "chkAccountDet")     private String chkAccountDet;

    // ---------- Reports ----------
    @Column(name = "chkEmpRpt")         private String chkEmpRpt;
    @Column(name = "chkCusRpt")         private String chkCusRpt;
    @Column(name = "chkCatRpt")         private String chkCatRpt;
    @Column(name = "chkSupRpt")         private String chkSupRpt;
    @Column(name = "chkItemRpt")        private String chkItemRpt;
    @Column(name = "chkStockRpt")       private String chkStockRpt;

    // ---------- Misc ----------
    @Column(name = "chkViewHome")       private String chkViewHome;
    @Column(name = "chkPriceChange")    private String chkPriceChange;
    @Column(name = "chkChangeDate")     private String chkChangeDate;
    @Column(name = "chkAddDCat")        private String chkAddDCat;
    @Column(name = "chkEditDCat")       private String chkEditDCat;
    @Column(name = "chkVenUpdate")      private String chkVenUpdate;
    @Column(name = "chkDescUpdate")     private String chkDescUpdate;
    @Column(name = "chkAddVatDet")      private String chkAddVatDet;
    @Column(name = "chkShowUPrice")     private String chkShowUPrice;
    @Column(name = "chkShowCost")       private String chkShowCost;
    @Column(name = "chkAddJBN")         private String chkAddJBN;
    @Column(name = "chkUpdateJBN")      private String chkUpdateJBN;
    @Column(name = "chkDeleteJBN")      private String chkDeleteJBN;
    @Column(name = "chkEditChqDetails") private String chkEditChqDetails;
    @Column(name = "chkStockReplace")   private String chkStockReplace;
    @Column(name = "chkStockeTransfer") private String chkStockeTransfer;
    @Column(name = "chkAddBank")        private String chkAddBank;
    @Column(name = "chkEditBank")       private String chkEditBank;
    @Column(name = "chkDelBank")        private String chkDelBank;
    @Column(name = "chkAddDeposit")     private String chkAddDeposit;
    @Column(name = "chkAddWithdraw")    private String chkAddWithdraw;
    @Column(name = "chkWebAccess")      private String chkWebAccess;
    @Column(name = "chkUpdateItemPrice") private String chkUpdateItemPrice;
    @Column(name = "chkDeleteItemPrice") private String chkDeleteItemPrice;
    @Column(name = "chkDataSync")       private String chkDataSync;
    @Column(name = "chkTOGReceived")    private String chkTOGReceived;
}