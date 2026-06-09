class BankTransferDTO {
  final String referenceNo;
  final DateTime createDate;
  final String paidAmount;
  final String serviceCharge;
  final String? bankCode;
  final String bankName;
  final String? branchCode;
  final String? branchName;
  final String? accountType;
  final String accountNo;

  BankTransferDTO({
    required this.referenceNo,
    required this.createDate,
    required this.paidAmount,
    required this.serviceCharge,
    this.bankCode,
    required this.bankName,
    this.branchCode,
    this.branchName,
    this.accountType,
    required this.accountNo,
  });

  Map<String, dynamic> toJson() => {
        'referenceNo': referenceNo,
        'createDate': createDate.toIso8601String().split('T')[0],
        'paidAmount': paidAmount,
        'serviceCharge': serviceCharge,
        if (bankCode != null) 'bankCode': bankCode,
        'bankName': bankName,
        if (branchCode != null) 'branchCode': branchCode,
        if (branchName != null) 'branchName': branchName,
        if (accountType != null) 'accountType': accountType,
        'accountNo': accountNo,
      };
}

