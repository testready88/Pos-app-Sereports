-- Performance indexes for account-related queries
-- Run this on your SQL Server database to speed up ledger/account queries

-- Asset details: filtered by CompID, ID='AST', AccountDate, AcName, etc.
CREATE INDEX IX_tbl_AssetDet_CompID_ID_AccountDate
  ON tbl_AssetDet (CompID, ID, AccountDate DESC)
  INCLUDE (AcName, AcCode, AcMethod, Status, CreditAmount, DebitAmount, BalanceAmount, InvoiceNo, AcDescription);

-- Liability details: filtered by CompID, ID='LIB', AccountDate, AcName, etc.
CREATE INDEX IX_tbl_LiabilityDet_CompID_ID_AccountDate
  ON tbl_LiabilityDet (CompID, ID, AccountDate DESC)
  INCLUDE (AcName, AcCode, AcMethod, Status, CreditAmount, DebitAmount, BalanceAmount, InvoiceNo, AcDescription);

-- Capital account details: filtered by CompID, ID, AccountDate
CREATE INDEX IX_tbl_CapitalACDet_CompID_ID_AccountDate
  ON tbl_CapitalACDet (CompID, ID, AccountDate DESC)
  INCLUDE (AcName, AcCode, AcMethod, Status, CreditAmount, DebitAmount, BalanceAmount, InvoiceNo, AcDescription);

-- Cheques: filtered by CompID, ChqDate, Status, ChqType; ordered by ChqDate DESC
CREATE INDEX IX_tbl_ChqDet_CompID_ChqDate
  ON tbl_ChqDet (CompID, ChqDate DESC)
  INCLUDE (ChqNo, ChqType, Status, PaymentType, TransactionType, PaidAmount, VenName, BnkName, InvoiceNo, ReferenceNo, LocaCode, RowNo);

-- Cash account ledger: filtered by CompID, AcCode, dates
CREATE INDEX IX_tbl_CashAccountLedger_CompID_AcCode_CreateDate
  ON tbl_CashAccountLedger (CompID, AcCode, CreateDate DESC)
  INCLUDE (CreditAmount, DebitAmount, BalanceAmount, InvoiceDescription);

-- Card account: filtered by CompID, AcName; joined on AcCode
CREATE INDEX IX_tbl_CardAccount_CompID_AcCode
  ON tbl_CardAccount (CompID, AcCode)
  INCLUDE (AcName);

-- Card account ledger: filtered by CompID, AcCode, CreateDate
CREATE INDEX IX_tbl_CardAccountLedger_CompID_AcCode_CreateDate
  ON tbl_CardAccountLedger (CompID, AcCode, CreateDate DESC)
  INCLUDE (CreditAmount, DebitAmount, BalanceAmount, InvoiceDescription);

-- Cash account list: filtered by CompID
CREATE INDEX IX_tbl_CashAccount_CompID
  ON tbl_CashAccount (CompID)
  INCLUDE (AcCode, AcName, BalanceAmount);
