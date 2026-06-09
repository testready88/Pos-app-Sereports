// ignore_for_file: avoid_print

class UserPermissions {
  final String? locaCode;
  final String? userCode;
  final String? cName;
  final String? userName;
  final String? userType;
  final String? pinnumber;
  final String? loginLocaCode;

  final bool chkAddItem;
  final bool chkEditItem;
  final bool chkDelItem;
  final bool chkAddCat;
  final bool chkEditCat;
  final bool chkDelCat;
  final bool chkAddSup;
  final bool chkEditSup;
  final bool chkDelSup;
  final bool chkAddCus;
  final bool chkEditCus;
  final bool chkDelCus;
  final bool chkAddEmp;
  final bool chkEditEmp;
  final bool chkDelEmp;
  final bool chkAddUser;
  final bool chkEditUser;
  final bool chkDelUser;
  final bool chkUserControl;
  final bool chkUserControlOption;
  final bool chkPurchase;
  final bool chkPurchaseR;
  final bool chkClearPurchase;
  final bool chkCancelPurchase;
  final bool chkEditPurchase;
  final bool chkHoldPurchase;
  final bool chkProceedGRN;
  final bool chkInvoice;
  final bool chkInvoiceR;
  final bool chkPrintInvoice;
  final bool chkClearInvoice;
  final bool chkCancelInvoice;
  final bool chkEditInvoice;
  final bool chkHoldInvoice;
  final bool chkMakeQuotation;
  final bool chkMakeDNote;
  final bool chkMakeReceipt;
  final bool chkDeleteHoldInv;
  final bool chkCreditSales;
  final bool chkPrintDaySummery;
  final bool chkPayDue;
  final bool chkQtyAdjust;
  final bool chkCashDenomination;
  final bool chkCashDiscount;
  final bool chkEmpDiscount;
  final bool chkUpdateCashDenomination;
  final bool chkViewCashDenominationRpt;
  final bool chkPaidOut;
  final bool chkSalaryPayment;
  final bool chkAddIncome;
  final bool chkAddExpenses;
  final bool chkProceedIncome;
  final bool chkProceedExpenses;
  final bool chkAccountDet;
  final bool chkEmpRpt;
  final bool chkCusRpt;
  final bool chkCatRpt;
  final bool chkSupRpt;
  final bool chkItemRpt;
  final bool chkStockRpt;
  final bool chkViewHome;
  final bool chkPriceChange;
  final bool chkChangeDate;
  final bool chkAddDCat;
  final bool chkEditDCat;
  final bool chkVenUpdate;
  final bool chkDescUpdate;
  final bool chkAddVatDet;
  final bool chkShowUPrice;
  final bool chkShowCost;
  final bool chkAddJBN;
  final bool chkUpdateJBN;
  final bool chkDeleteJBN;
  final bool chkEditChqDetails;
  final bool chkStockReplace;
  final bool chkStockeTransfer;
  final bool chkAddBank;
  final bool chkEditBank;
  final bool chkDelBank;
  final bool chkAddDeposit;
  final bool chkAddWithdraw;
  final bool chkWebAccess;
  final bool chkUpdateItemPrice;
  final bool chkDeleteItemPrice;
  final bool chkDataSync;
  final bool chkTOGReceived;

  UserPermissions({
    this.locaCode,
    this.userCode,
    this.cName,
    this.userName,
    this.userType,
    this.pinnumber,
    this.loginLocaCode,
    this.chkAddItem = false,
    this.chkEditItem = false,
    this.chkDelItem = false,
    this.chkAddCat = false,
    this.chkEditCat = false,
    this.chkDelCat = false,
    this.chkAddSup = false,
    this.chkEditSup = false,
    this.chkDelSup = false,
    this.chkAddCus = false,
    this.chkEditCus = false,
    this.chkDelCus = false,
    this.chkAddEmp = false,
    this.chkEditEmp = false,
    this.chkDelEmp = false,
    this.chkAddUser = false,
    this.chkEditUser = false,
    this.chkDelUser = false,
    this.chkUserControl = false,
    this.chkUserControlOption = false,
    this.chkPurchase = false,
    this.chkPurchaseR = false,
    this.chkClearPurchase = false,
    this.chkCancelPurchase = false,
    this.chkEditPurchase = false,
    this.chkHoldPurchase = false,
    this.chkProceedGRN = false,
    this.chkInvoice = false,
    this.chkInvoiceR = false,
    this.chkPrintInvoice = false,
    this.chkClearInvoice = false,
    this.chkCancelInvoice = false,
    this.chkEditInvoice = false,
    this.chkHoldInvoice = false,
    this.chkMakeQuotation = false,
    this.chkMakeDNote = false,
    this.chkMakeReceipt = false,
    this.chkDeleteHoldInv = false,
    this.chkCreditSales = false,
    this.chkPrintDaySummery = false,
    this.chkPayDue = false,
    this.chkQtyAdjust = false,
    this.chkCashDenomination = false,
    this.chkCashDiscount = false,
    this.chkEmpDiscount = false,
    this.chkUpdateCashDenomination = false,
    this.chkViewCashDenominationRpt = false,
    this.chkPaidOut = false,
    this.chkSalaryPayment = false,
    this.chkAddIncome = false,
    this.chkAddExpenses = false,
    this.chkProceedIncome = false,
    this.chkProceedExpenses = false,
    this.chkAccountDet = false,
    this.chkEmpRpt = false,
    this.chkCusRpt = false,
    this.chkCatRpt = false,
    this.chkSupRpt = false,
    this.chkItemRpt = false,
    this.chkStockRpt = false,
    this.chkViewHome = false,
    this.chkPriceChange = false,
    this.chkChangeDate = false,
    this.chkAddDCat = false,
    this.chkEditDCat = false,
    this.chkVenUpdate = false,
    this.chkDescUpdate = false,
    this.chkAddVatDet = false,
    this.chkShowUPrice = false,
    this.chkShowCost = false,
    this.chkAddJBN = false,
    this.chkUpdateJBN = false,
    this.chkDeleteJBN = false,
    this.chkEditChqDetails = false,
    this.chkStockReplace = false,
    this.chkStockeTransfer = false,
    this.chkAddBank = false,
    this.chkEditBank = false,
    this.chkDelBank = false,
    this.chkAddDeposit = false,
    this.chkAddWithdraw = false,
    this.chkWebAccess = false,
    this.chkUpdateItemPrice = false,
    this.chkDeleteItemPrice = false,
    this.chkDataSync = false,
    this.chkTOGReceived = false,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    bool flag(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.trim().isNotEmpty && value.trim() != "0";
      return false;
    }

    return UserPermissions(
      locaCode: json['locaCode']?.toString(),
      userCode: json['userCode']?.toString(),
      cName: json['cName']?.toString(),
      userName: json['userName']?.toString(),
      userType: json['userType']?.toString(),
      pinnumber: json['pinnumber']?.toString(),
      loginLocaCode: json['loginLocaCode']?.toString(),
      chkAddItem: flag(json['chkAddItem']),
      chkEditItem: flag(json['chkEditItem']),
      chkDelItem: flag(json['chkDelItem']),
      chkAddCat: flag(json['chkAddCat']),
      chkEditCat: flag(json['chkEditCat']),
      chkDelCat: flag(json['chkDelCat']),
      chkAddSup: flag(json['chkAddSup']),
      chkEditSup: flag(json['chkEditSup']),
      chkDelSup: flag(json['chkDelSup']),
      chkAddCus: flag(json['chkAddCus']),
      chkEditCus: flag(json['chkEditCus']),
      chkDelCus: flag(json['chkDelCus']),
      chkAddEmp: flag(json['chkAddEmp']),
      chkEditEmp: flag(json['chkEditEmp']),
      chkDelEmp: flag(json['chkDelEmp']),
      chkAddUser: flag(json['chkAddUser']),
      chkEditUser: flag(json['chkEditUser']),
      chkDelUser: flag(json['chkDelUser']),
      chkUserControl: flag(json['chkUserControl']),
      chkUserControlOption: flag(json['chkUserControlOption']),
      chkPurchase: flag(json['chkPurchase']),
      chkPurchaseR: flag(json['chkPurchaseR']),
      chkClearPurchase: flag(json['chkClearPurchase']),
      chkCancelPurchase: flag(json['chkCancelPurchase']),
      chkEditPurchase: flag(json['chkEditPurchase']),
      chkHoldPurchase: flag(json['chkHoldPurchase']),
      chkProceedGRN: flag(json['chkProceedGRN']),
      chkInvoice: flag(json['chkInvoice']),
      chkInvoiceR: flag(json['chkInvoiceR']),
      chkPrintInvoice: flag(json['chkPrintInvoice']),
      chkClearInvoice: flag(json['chkClearInvoice']),
      chkCancelInvoice: flag(json['chkCancelInvoice']),
      chkEditInvoice: flag(json['chkEditInvoice']),
      chkHoldInvoice: flag(json['chkHoldInvoice']),
      chkMakeQuotation: flag(json['chkMakeQuotation']),
      chkMakeDNote: flag(json['chkMakeDNote']),
      chkMakeReceipt: flag(json['chkMakeReceipt']),
      chkDeleteHoldInv: flag(json['chkDeleteHoldInv']),
      chkCreditSales: flag(json['chkCreditSales']),
      chkPrintDaySummery: flag(json['chkPrintDaySummery']),
      chkPayDue: flag(json['chkPayDue']),
      chkQtyAdjust: flag(json['chkQtyAdjust']),
      chkCashDenomination: flag(json['chkCashDenomination']),
      chkCashDiscount: flag(json['chkCashDiscount']),
      chkEmpDiscount: flag(json['chkEmpDiscount']),
      chkUpdateCashDenomination: flag(json['chkUpdateCashDenomination']),
      chkViewCashDenominationRpt: flag(json['chkViewCashDenominationRpt']),
      chkPaidOut: flag(json['chkPaidOut']),
      chkSalaryPayment: flag(json['chkSalaryPayment']),
      chkAddIncome: flag(json['chkAddIncome']),
      chkAddExpenses: flag(json['chkAddExpenses']),
      chkProceedIncome: flag(json['chkProceedIncome']),
      chkProceedExpenses: flag(json['chkProceedExpenses']),
      chkAccountDet: flag(json['chkAccountDet']),
      chkEmpRpt: flag(json['chkEmpRpt']),
      chkCusRpt: flag(json['chkCusRpt']),
      chkCatRpt: flag(json['chkCatRpt']),
      chkSupRpt: flag(json['chkSupRpt']),
      chkItemRpt: flag(json['chkItemRpt']),
      chkStockRpt: flag(json['chkStockRpt']),
      chkViewHome: flag(json['chkViewHome']),
      chkPriceChange: flag(json['chkPriceChange']),
      chkChangeDate: flag(json['chkChangeDate']),
      chkAddDCat: flag(json['chkAddDCat']),
      chkEditDCat: flag(json['chkEditDCat']),
      chkVenUpdate: flag(json['chkVenUpdate']),
      chkDescUpdate: flag(json['chkDescUpdate']),
      chkAddVatDet: flag(json['chkAddVatDet']),
      chkShowUPrice: flag(json['chkShowUPrice']),
      chkShowCost: flag(json['chkShowCost']),
      chkAddJBN: flag(json['chkAddJBN']),
      chkUpdateJBN: flag(json['chkUpdateJBN']),
      chkDeleteJBN: flag(json['chkDeleteJBN']),
      chkEditChqDetails: flag(json['chkEditChqDetails']),
      chkStockReplace: flag(json['chkStockReplace']),
      chkStockeTransfer: flag(json['chkStockeTransfer']),
      chkAddBank: flag(json['chkAddBank']),
      chkEditBank: flag(json['chkEditBank']),
      chkDelBank: flag(json['chkDelBank']),
      chkAddDeposit: flag(json['chkAddDeposit']),
      chkAddWithdraw: flag(json['chkAddWithdraw']),
      chkWebAccess: flag(json['chkWebAccess']),
      chkUpdateItemPrice: flag(json['chkUpdateItemPrice']),
      chkDeleteItemPrice: flag(json['chkDeleteItemPrice']),
      chkDataSync: flag(json['chkDataSync']),
      chkTOGReceived: flag(json['chkTOGReceived']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locaCode': locaCode,
      'userCode': userCode,
      'cName': cName,
      'userName': userName,
      'userType': userType,
      'pinnumber': pinnumber,
      'loginLocaCode': loginLocaCode,
      'chkAddItem': chkAddItem,
      'chkEditItem': chkEditItem,
      'chkDelItem': chkDelItem,
      'chkAddCat': chkAddCat,
      'chkEditCat': chkEditCat,
      'chkDelCat': chkDelCat,
      'chkAddSup': chkAddSup,
      'chkEditSup': chkEditSup,
      'chkDelSup': chkDelSup,
      'chkAddCus': chkAddCus,
      'chkEditCus': chkEditCus,
      'chkDelCus': chkDelCus,
      'chkAddEmp': chkAddEmp,
      'chkEditEmp': chkEditEmp,
      'chkDelEmp': chkDelEmp,
      'chkAddUser': chkAddUser,
      'chkEditUser': chkEditUser,
      'chkDelUser': chkDelUser,
      'chkUserControl': chkUserControl,
      'chkUserControlOption': chkUserControlOption,
      'chkPurchase': chkPurchase,
      'chkPurchaseR': chkPurchaseR,
      'chkClearPurchase': chkClearPurchase,
      'chkCancelPurchase': chkCancelPurchase,
      'chkEditPurchase': chkEditPurchase,
      'chkHoldPurchase': chkHoldPurchase,
      'chkProceedGRN': chkProceedGRN,
      'chkInvoice': chkInvoice,
      'chkInvoiceR': chkInvoiceR,
      'chkPrintInvoice': chkPrintInvoice,
      'chkClearInvoice': chkClearInvoice,
      'chkCancelInvoice': chkCancelInvoice,
      'chkEditInvoice': chkEditInvoice,
      'chkHoldInvoice': chkHoldInvoice,
      'chkMakeQuotation': chkMakeQuotation,
      'chkMakeDNote': chkMakeDNote,
      'chkMakeReceipt': chkMakeReceipt,
      'chkDeleteHoldInv': chkDeleteHoldInv,
      'chkCreditSales': chkCreditSales,
      'chkPrintDaySummery': chkPrintDaySummery,
      'chkPayDue': chkPayDue,
      'chkQtyAdjust': chkQtyAdjust,
      'chkCashDenomination': chkCashDenomination,
      'chkCashDiscount': chkCashDiscount,
      'chkEmpDiscount': chkEmpDiscount,
      'chkUpdateCashDenomination': chkUpdateCashDenomination,
      'chkViewCashDenominationRpt': chkViewCashDenominationRpt,
      'chkPaidOut': chkPaidOut,
      'chkSalaryPayment': chkSalaryPayment,
      'chkAddIncome': chkAddIncome,
      'chkAddExpenses': chkAddExpenses,
      'chkProceedIncome': chkProceedIncome,
      'chkProceedExpenses': chkProceedExpenses,
      'chkAccountDet': chkAccountDet,
      'chkEmpRpt': chkEmpRpt,
      'chkCusRpt': chkCusRpt,
      'chkCatRpt': chkCatRpt,
      'chkSupRpt': chkSupRpt,
      'chkItemRpt': chkItemRpt,
      'chkStockRpt': chkStockRpt,
      'chkViewHome': chkViewHome,
      'chkPriceChange': chkPriceChange,
      'chkChangeDate': chkChangeDate,
      'chkAddDCat': chkAddDCat,
      'chkEditDCat': chkEditDCat,
      'chkVenUpdate': chkVenUpdate,
      'chkDescUpdate': chkDescUpdate,
      'chkAddVatDet': chkAddVatDet,
      'chkShowUPrice': chkShowUPrice,
      'chkShowCost': chkShowCost,
      'chkAddJBN': chkAddJBN,
      'chkUpdateJBN': chkUpdateJBN,
      'chkDeleteJBN': chkDeleteJBN,
      'chkEditChqDetails': chkEditChqDetails,
      'chkStockReplace': chkStockReplace,
      'chkStockeTransfer': chkStockeTransfer,
      'chkAddBank': chkAddBank,
      'chkEditBank': chkEditBank,
      'chkDelBank': chkDelBank,
      'chkAddDeposit': chkAddDeposit,
      'chkAddWithdraw': chkAddWithdraw,
      'chkWebAccess': chkWebAccess,
      'chkUpdateItemPrice': chkUpdateItemPrice,
      'chkDeleteItemPrice': chkDeleteItemPrice,
      'chkDataSync': chkDataSync,
      'chkTOGReceived': chkTOGReceived,
    };
  }
}