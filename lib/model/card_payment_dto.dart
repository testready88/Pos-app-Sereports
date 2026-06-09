class CardPaymentDTO {
  final String cardNumber;
  final String cardType; // VISA CARD, MASTER CARD, AMERICAN EXPRESS, IPAY, OTHER
  final int expMonth;
  final int expYear;
  final String? cardHolderName;
  final String? pin;
  final String paidAmount;
  final String? bankCode;
  final String? bankName;
  final String? branchCode;
  final String? branchName;
  final String? accountType;
  final String? accountNo;

  CardPaymentDTO({
    required this.cardNumber,
    required this.cardType,
    required this.expMonth,
    required this.expYear,
    this.cardHolderName,
    this.pin,
    required this.paidAmount,
    this.bankCode,
    this.bankName,
    this.branchCode,
    this.branchName,
    this.accountType,
    this.accountNo,
  });

  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'cardType': cardType,
        'expMonth': expMonth,
        'expYear': expYear,
        if (cardHolderName != null) 'cardHolderName': cardHolderName,
        if (pin != null) 'pin': pin,
        'paidAmount': paidAmount,
        if (bankCode != null) 'bankCode': bankCode,
        if (bankName != null) 'bankName': bankName,
        if (branchCode != null) 'branchCode': branchCode,
        if (branchName != null) 'branchName': branchName,
        if (accountType != null) 'accountType': accountType,
        if (accountNo != null) 'accountNo': accountNo,
      };
}

