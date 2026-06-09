package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.customerdto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;
import java.util.Date;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ResponseCustomerDetailsDTO {
    private String customerCode;
    private String customerNic;
    private String customerName;
    private String contactDetails;
    private String addressDetails;
    private Date lastInvoiceDate;
    private Double lastInvoiceAmount;
    private Integer invoiceGap;
    private Date lastPaymentDate;
    private Double lastPaymentAmount;
    private Integer paymentGap;
    private Double outstandingAmount;
    private Integer numberOfCheques;
    private Double chequeAmount;
    private Double totalPurchase;
    private Double discountAmount;
    private Double creditLimit;
    private String createdBy;
    private Timestamp createdDate;
    private String priceCategory; // RETAIL, WHOLESALE, CATEGORY1-5, LOYALTY DISCOUNT
}