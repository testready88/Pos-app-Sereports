class ChequePaymentDTO {
  final String chequeNumber;
  final DateTime createDate;
  final DateTime chequeDate;
  final String status; // PENDING, CLEARED, BOUNCED
  final String transactionType; // IN HAND, RECEIVED
  final String chequeType; // OWN CHQ, RECEIVED CHQ, PARTY CHQ
  final String paymentType; // CROSS CHQ, CASH CHQ
  final String? bankCode;
  final String bankName;
  final String? branchCode;
  final String? branchName;
  final String? accountType;
  final String accountNo;
  final String paidAmount;
  final String? remark;
  final String? serialNoChqFrom;
  final String? venCodeChqFrom;
  final String? venNameChqFrom;

  ChequePaymentDTO({
    required this.chequeNumber,
    required this.createDate,
    required this.chequeDate,
    required this.status,
    required this.transactionType,
    required this.chequeType,
    required this.paymentType,
    this.bankCode,
    required this.bankName,
    this.branchCode,
    this.branchName,
    this.accountType,
    required this.accountNo,
    required this.paidAmount,
    this.remark,
    this.serialNoChqFrom,
    this.venCodeChqFrom,
    this.venNameChqFrom,
  });

  Map<String, dynamic> toJson() => {
        'chequeNumber': chequeNumber,
        'createDate': createDate.toIso8601String().split('T')[0],
        'chequeDate': chequeDate.toIso8601String().split('T')[0],
        'status': status,
        'transactionType': transactionType,
        'chequeType': chequeType,
        'paymentType': paymentType,
        if (bankCode != null) 'bankCode': bankCode,
        'bankName': bankName,
        if (branchCode != null) 'branchCode': branchCode,
        if (branchName != null) 'branchName': branchName,
        if (accountType != null) 'accountType': accountType,
        'accountNo': accountNo,
        'paidAmount': paidAmount,
        if (remark != null) 'remark': remark,
        if (serialNoChqFrom != null) 'serialNoChqFrom': serialNoChqFrom,
        if (venCodeChqFrom != null) 'venCodeChqFrom': venCodeChqFrom,
        if (venNameChqFrom != null) 'venNameChqFrom': venNameChqFrom,
      };
}

