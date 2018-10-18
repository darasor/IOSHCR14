table 60007 IOSH_CRMSaleOrder
{
    // Dynamics CRM Version: 9.0.2.189

    Caption = 'IOSH CRM Order';
    Description = 'Quote that has been accepted.';
    TableType = CRM;
    ExternalName = 'salesorder';
    fields
    {
        field(1; SalesOrderId; Guid)
        {
            ExternalName = 'salesorderid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            CaptionML = ENU = 'Order',
                        ENG = 'Order';
            Description = 'Unique identifier of the order.';
        }
        field(2; OpportunityId; Guid)
        {
            ExternalName = 'opportunityid';
            ExternalType = 'Lookup';
            CaptionML = ENU = 'Opportunity',
                        ENG = 'Opportunity';
            Description = 'Choose the related opportunity so that the data for the order and opportunity are linked for reporting and analytics.';
            TableRelation = "CRM Opportunity".OpportunityId;
        }
        field(3; QuoteId; Guid)
        {
            ExternalName = 'quoteid';
            ExternalType = 'Lookup';
            CaptionML = ENU = 'Quote',
                        ENG = 'Quote';
            Description = 'Choose the related quote so that order data and quote data are linked for reporting and analytics.';
            TableRelation = "CRM Quote".QuoteId;
        }
        field(4; PriorityCode; Option)
        {
            ExternalName = 'prioritycode';
            ExternalType = 'Picklist';
            CaptionML = ENU = 'Priority',
                        ENG = 'Priority';
            Description = 'Select the priority so that preferred customers or critical issues are handled quickly.';
            InitValue = DefaultValue;
            OptionCaptionML = ENU = 'Default Value',
                              ENG = 'Default Value';
            OptionMembers = DefaultValue;
        }
        field(5; SubmitStatus; Integer)
        {
            ExternalName = 'submitstatus';
            ExternalType = 'Integer';
            CaptionML = ENU = 'Submitted Status',
                        ENG = 'Submitted Status';
            Description = 'Type the code for the submitted status in the fulfillment or shipping center system.';
            MaxValue = 1000000000;
            MinValue = 0;
        }
        field(6; OwningUser; Guid)
        {
            ExternalName = 'owninguser';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            CaptionML = ENU = 'Owning User',
                        ENG = 'Owning User';
            Description = 'Unique identifier of the user who owns the order.';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(7; SubmitDate; Date)
        {
            ExternalName = 'submitdate';
            ExternalType = 'DateTime';
            CaptionML = ENU = 'Date Submitted',
                        ENG = 'Date Submitted';
            Description = 'Enter the date when the order was submitted to the fulfillment or shipping center.';
        }
        field(8; OwningBusinessUnit; Guid)
        {
            ExternalName = 'owningbusinessunit';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            CaptionML = ENU = 'Owning Business Unit',
                        ENG = 'Owning Business Unit';
            Description = 'Shows the business unit that the record owner belongs to.';
            TableRelation = "CRM Businessunit".BusinessUnitId;
        }
        field(9; SubmitStatusDescription; BLOB)
        {
            ExternalName = 'submitstatusdescription';
            ExternalType = 'Memo';
            CaptionML = ENU = 'Submitted Status Description',
                        ENG = 'Submitted Status Description';
            Description = 'Type additional details or notes about the order for the fulfillment or shipping center.';
            SubType = Memo;
        }
        field(10; PriceLevelId; Guid)
        {
            ExternalName = 'pricelevelid';
            ExternalType = 'Lookup';
            CaptionML = ENU = 'Price List',
                        ENG = 'Price List';
            Description = 'Choose the price list associated with this record to make sure the products associated with the campaign are offered at the correct prices.';
            TableRelation = "CRM Pricelevel".PriceLevelId;
        }
        field(11; LastBackofficeSubmit; Date)
        {
            ExternalName = 'lastbackofficesubmit';
            ExternalType = 'DateTime';
            ExternalAccess = Full;
            CaptionML = ENU = 'Last Submitted to Back Office',
                        ENG = 'Last Submitted to Back Office';
            Description = 'Enter the date and time when the order was last submitted to an accounting or ERP system for processing.';
        }
        field(12; AccountId; Guid)
        {
            ExternalName = 'accountid';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            CaptionML = ENU = 'Account',
                        ENG = 'Account';
            Description = 'Shows the parent account related to the record. This information is used to link the sales order to the account selected in the Customer field for reporting and analytics.';
            TableRelation = "CRM Account".AccountId;
        }
        field(13; ContactId; Guid)
        {
            ExternalName = 'contactid';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            CaptionML = ENU = 'Contact',
                        ENG = 'Contact';
            Description = 'Shows the parent contact related to the record. This information is used to link the contract to the contact selected in the Customer field for reporting and analytics.';
            TableRelation = "CRM Contact".ContactId;
        }
        field(14; OrderNumber; Text[100])
        {
            ExternalName = 'ordernumber';
            ExternalType = 'String';
            ExternalAccess = Insert;
            CaptionML = ENU = 'Order ID',
                        ENG = 'Order ID';
            Description = 'Shows the order number for customer reference and to use in search. The number cannot be modified.';
        }
        field(15; Name; Text[250])
        {
            ExternalName = 'name';
            ExternalType = 'String';
            CaptionML = ENU = 'Name',
                        ENG = 'Name';
            Description = 'Type a descriptive name for the order.';
        }
        field(16; PricingErrorCode; Option)
        {
            ExternalName = 'pricingerrorcode';
            ExternalType = 'Picklist';
            CaptionML = ENU = 'Pricing Error ',
                        ENG = 'Pricing Error ';
            Description = 'Select the type of pricing error, such as a missing or invalid product, or missing quantity.';
            InitValue = "None";
            OptionCaptionML = ENU = 'None,Detail Error,Missing Price Level,Inactive Price Level,Missing Quantity,Missing Unit Price,Missing Product,Invalid Product,Missing Pricing Code,Invalid Pricing Code,Missing UOM,Product Not In Price Level,Missing Price Level Amount,Missing Price Level Percentage,Missing Price,Missing Current Cost,Missing Standard Cost,Invalid Price Level Amount,Invalid Price Level Percentage,Invalid Price,Invalid Current Cost,Invalid Standard Cost,Invalid Rounding Policy,Invalid Rounding Option,Invalid Rounding Amount,Price Calculation Error,Invalid Discount Type,Discount Type Invalid State,Invalid Discount,Invalid Quantity,Invalid Pricing Precision,Missing Product Default UOM,Missing Product UOM Schedule ,Inactive Discount Type,Invalid Price Level Currency,Price Attribute Out Of Range,Base Currency Attribute Overflow,Base Currency Attribute Underflow',
                              ENG = 'None,Detail Error,Missing Price Level,Inactive Price Level,Missing Quantity,Missing Unit Price,Missing Product,Invalid Product,Missing Pricing Code,Invalid Pricing Code,Missing UOM,Product Not In Price Level,Missing Price Level Amount,Missing Price Level Percentage,Missing Price,Missing Current Cost,Missing Standard Cost,Invalid Price Level Amount,Invalid Price Level Percentage,Invalid Price,Invalid Current Cost,Invalid Standard Cost,Invalid Rounding Policy,Invalid Rounding Option,Invalid Rounding Amount,Price Calculation Error,Invalid Discount Type,Discount Type Invalid State,Invalid Discount,Invalid Quantity,Invalid Pricing Precision,Missing Product Default UOM,Missing Product UOM Schedule ,Inactive Discount Type,Invalid Price Level Currency,Price Attribute Out Of Range,Base Currency Attribute Overflow,Base Currency Attribute Underflow';
            OptionMembers = "None",DetailError,MissingPriceLevel,InactivePriceLevel,MissingQuantity,MissingUnitPrice,MissingProduct,InvalidProduct,MissingPricingCode,InvalidPricingCode,MissingUOM,ProductNotInPriceLevel,MissingPriceLevelAmount,MissingPriceLevelPercentage,MissingPrice,MissingCurrentCost,MissingStandardCost,InvalidPriceLevelAmount,InvalidPriceLevelPercentage,InvalidPrice,InvalidCurrentCost,InvalidStandardCost,InvalidRoundingPolicy,InvalidRoundingOption,InvalidRoundingAmount,PriceCalculationError,InvalidDiscountType,DiscountTypeInvalidState,InvalidDiscount,InvalidQuantity,InvalidPricingPrecision,MissingProductDefaultUOM,MissingProductUOMSchedule,InactiveDiscountType,InvalidPriceLevelCurrency,PriceAttributeOutOfRange,BaseCurrencyAttributeOverflow,BaseCurrencyAttributeUnderflow;
        }
        field(17; Description; BLOB)
        {
            ExternalName = 'description';
            ExternalType = 'Memo';
            CaptionML = ENU = 'Description',
                        ENG = 'Description';
            Description = 'Type additional information to describe the order, such as the products or services offered or details about the customer''s product preferences.';
            SubType = Memo;
        }
        field(18; DiscountAmount; Decimal)
        {
            ExternalName = 'discountamount';
            ExternalType = 'Money';
            CaptionML = ENU = 'Order Discount Amount',
                        ENG = 'Order Discount Amount';
            Description = 'Type the discount amount for the order if the customer is eligible for special savings.';
        }
        field(19; FreightAmount; Decimal)
        {
            ExternalName = 'freightamount';
            ExternalType = 'Money';
            CaptionML = ENU = 'Freight Amount',
                        ENG = 'Freight Amount';
            Description = 'Type the cost of freight or shipping for the products included in the order for use in calculating the Total Amount field.';
        }
        field(20; TotalAmount; Decimal)
        {
            ExternalName = 'totalamount';
            ExternalType = 'Money';
            ExternalAccess = Modify;
            CaptionML = ENU = 'Total Amount',
                        ENG = 'Total Amount';
            Description = 'Shows the total amount due, calculated as the sum of the products, discounts, freight, and taxes for the order.';
        }
        field(21; TotalLineItemAmount; Decimal)
        {
            ExternalName = 'totallineitemamount';
            ExternalType = 'Money';
            ExternalAccess = Modify;
            CaptionML = ENU = 'Total Detail Amount',
                        ENG = 'Total Detail Amount';
            Description = 'Shows the sum of all existing and write-in products included on the order, based on the specified price list and quantities.';
        }
        field(22; TotalLineItemDiscountAmount; Decimal)
        {
            ExternalName = 'totallineitemdiscountamount';
            ExternalType = 'Money';
            ExternalAccess = Modify;
            CaptionML = ENU = 'Total Line Item Discount Amount',
                        ENG = 'Total Line Item Discount Amount';
            Description = 'Shows the total of the Manual Discount amounts specified on all products included in the order. This value is reflected in the Detail Amount field on the order and is added to any discount amount or rate specified on the order.';
        }
        field(23; TotalAmountLessFreight; Decimal)
        {
            ExternalName = 'totalamountlessfreight';
            ExternalType = 'Money';
            ExternalAccess = Modify;
            CaptionML = ENU = 'Total Pre-Freight Amount',
                        ENG = 'Total Pre-Freight Amount';
            Description = 'Shows the total product amount for the order, minus any discounts. This value is added to freight and tax amounts in the calculation for the total amount due for the order.';
        }
        field(24; TotalDiscountAmount; Decimal)
        {
            ExternalName = 'totaldiscountamount';
            ExternalType = 'Money';
            ExternalAccess = Modify;
            CaptionML = ENU = 'Total Discount Amount',
                        ENG = 'Total Discount Amount';
            Description = 'Shows the total discount amount, based on the discount price and rate entered on the order.';
        }
        field(25; RequestDeliveryBy; Date)
        {
            ExternalName = 'requestdeliveryby';
            ExternalType = 'DateTime';
            CaptionML = ENU = 'Requested Delivery Date',
                        ENG = 'Requested Delivery Date';
            Description = 'Enter the delivery date requested by the customer for all products in the order.';
        }
        field(26; TotalTax; Decimal)
        {
            ExternalName = 'totaltax';
            ExternalType = 'Money';
            ExternalAccess = Modify;
            CaptionML = ENU = 'Total Tax',
                        ENG = 'Total Tax';
            Description = 'Shows the Tax amounts specified on all products included in the order, included in the Total Amount due calculation for the order.';
        }
        field(27; ShippingMethodCode; Option)
        {
            ExternalName = 'shippingmethodcode';
            ExternalType = 'Picklist';
            CaptionML = ENU = 'Shipping Method',
                        ENG = 'Shipping Method';
            Description = 'Select a shipping method for deliveries sent to this address.';
            InitValue = " ";
            OptionCaptionML = ENU = ' ,Airborne,DHL,FedEx,UPS,Postal Mail,Full Load,Will Call',
                              ENG = ' ,Airborne,DHL,FedEx,UPS,Postal Mail,Full Load,Will Call';
            OptionMembers = " ",Airborne,DHL,FedEx,UPS,PostalMail,FullLoad,WillCall;
        }
        field(28; PaymentTermsCode; Option)
        {
            ExternalName = 'paymenttermscode';
            ExternalType = 'Picklist';
            CaptionML = ENU = 'Payment Terms',
                        ENG = 'Payment Terms';
            Description = 'Select the payment terms to indicate when the customer needs to pay the total amount.';
            InitValue = " ";
            OptionCaptionML = ENU = ' ,Net 30,2% 10; Net 30,Net 45,Net 60',
                              ENG = ' ,Net 30,2% 10; Net 30,Net 45,Net 60';
            OptionMembers = " ",Net30,"2%10Net30",Net45,Net60;
        }
        field(29; FreightTermsCode; Option)
        {
            ExternalName = 'freighttermscode';
            ExternalType = 'Picklist';
            CaptionML = ENU = 'Freight Terms',
                        ENG = 'Freight Terms';
            Description = 'Select the freight terms to make sure shipping charges are processed correctly.';
            InitValue = " ";
            OptionCaptionML = ENU = ' ,FOB,No Charge',
                              ENG = ' ,FOB,No Charge';
            OptionMembers = " ",FOB,NoCharge;
        }
        field(30; CreatedBy; Guid)
        {
            ExternalName = 'createdby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            CaptionML = ENU = 'Created By',
                        ENG = 'Created By';
            Description = 'Shows who created the record.';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(31; CreatedOn; DateTime)
        {
            ExternalName = 'createdon';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            CaptionML = ENU = 'Created On',
                        ENG = 'Created On';
            Description = 'Shows the date and time when the record was created. The date and time are displayed in the time zone selected in Microsoft Dynamics CRM options.';
        }
        field(32; ModifiedBy; Guid)
        {
            ExternalName = 'modifiedby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            CaptionML = ENU = 'Modified By',
                        ENG = 'Modified By';
            Description = 'Shows who last updated the record.';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(33; ModifiedOn; DateTime)
        {
            ExternalName = 'modifiedon';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            CaptionML = ENU = 'Modified On',
                        ENG = 'Modified On';
            Description = 'Shows the date and time when the record was last updated. The date and time are displayed in the time zone selected in Microsoft Dynamics CRM options.';
        }
        field(34; StateCode; Option)
        {
            ExternalName = 'statecode';
            ExternalType = 'State';
            ExternalAccess = Modify;
            CaptionML = ENU = 'Status',
                        ENG = 'Status';
            Description = 'Shows whether the order is active, submitted, fulfilled, canceled, or invoiced. Only active orders can be edited.';
            InitValue = Active;
            OptionCaptionML = ENU = 'Active,Submitted,Canceled,Fulfilled,Invoiced',
                              ENG = 'Active,Submitted,Canceled,Fulfilled,Invoiced';
            OptionMembers = Active,Submitted,Canceled,Fulfilled,Invoiced;
        }
        field(35; StatusCode; Option)
        {
            ExternalName = 'statuscode';
            ExternalType = 'Status';
            CaptionML = ENU = 'Status Reason',
                        ENG = 'Status Reason';
            Description = 'Select the order''s status.';
            InitValue = " ";
            OptionCaptionML = ENU = ' ,In Progress,No Money,New,Pending,Complete,Partial,Invoiced',
                              ENG = ' ,In Progress,No Money,New,Pending,Complete,Partial,Invoiced';
            OptionMembers = " ",InProgress,NoMoney,New,Pending,Complete,Partial,Invoiced;
        }
        field(36; ShipTo_Name; Text[200])
        {
            ExternalName = 'shipto_name';
            ExternalType = 'String';
            CaptionML = ENU = 'Ship To Name',
                        ENG = 'Ship To Name';
            Description = 'Type a name for the customer''s shipping address, such as "Headquarters" or "Field office", to identify the address.';
        }
        field(37; VersionNumber; BigInteger)
        {
            ExternalName = 'versionnumber';
            ExternalType = 'BigInt';
            ExternalAccess = Read;
            CaptionML = ENU = 'Version Number',
                        ENG = 'Version Number';
            Description = 'Version number of the order.';
        }
        field(38; ShipTo_Line1; Text[250])
        {
            ExternalName = 'shipto_line1';
            ExternalType = 'String';
            CaptionML = ENU = 'Ship To Street 1',
                        ENG = 'Ship To Street 1';
            Description = 'Type the first line of the customer''s shipping address.';
        }
        field(39; ShipTo_Line2; Text[250])
        {
            ExternalName = 'shipto_line2';
            ExternalType = 'String';
            CaptionML = ENU = 'Ship To Street 2',
                        ENG = 'Ship To Street 2';
            Description = 'Type the second line of the customer''s shipping address.';
        }
        field(40; ShipTo_Line3; Text[250])
        {
            ExternalName = 'shipto_line3';
            ExternalType = 'String';
            CaptionML = ENU = 'Ship To Street 3',
                        ENG = 'Ship To Street 3';
            Description = 'Type the third line of the shipping address.';
        }
        field(41; ShipTo_City; Text[80])
        {
            ExternalName = 'shipto_city';
            ExternalType = 'String';
            CaptionML = ENU = 'Ship To City',
                        ENG = 'Ship To City';
            Description = 'Type the city for the customer''s shipping address.';
        }
        field(42; ShipTo_StateOrProvince; Text[50])
        {
            ExternalName = 'shipto_stateorprovince';
            ExternalType = 'String';
            CaptionML = ENU = 'Ship To State/Province',
                        ENG = 'Ship To State/Province';
            Description = 'Type the state or province for the shipping address.';
        }
        field(43; ShipTo_Country; Text[80])
        {
            ExternalName = 'shipto_country';
            ExternalType = 'String';
            CaptionML = ENU = 'Ship To Country/Region',
                        ENG = 'Ship To Country/Region';
            Description = 'Type the country or region for the customer''s shipping address.';
        }
        field(44; ShipTo_PostalCode; Text[20])
        {
            ExternalName = 'shipto_postalcode';
            ExternalType = 'String';
            CaptionML = ENU = 'Ship To ZIP/Postal Code',
                        ENG = 'Ship To ZIP/Postal Code';
            Description = 'Type the ZIP Code or postal code for the shipping address.';
        }
        field(45; WillCall; Boolean)
        {
            ExternalName = 'willcall';
            ExternalType = 'Boolean';
            CaptionML = ENU = 'Ship To',
                        ENG = 'Ship To';
            Description = 'Select whether the products included in the order should be shipped to the specified address or held until the customer calls with further pick-up or delivery instructions.';
        }
        field(46; ShipTo_Telephone; Text[50])
        {
            ExternalName = 'shipto_telephone';
            ExternalType = 'String';
            CaptionML = ENU = 'Ship To Phone',
                        ENG = 'Ship To Phone';
            Description = 'Type the phone number for the customer''s shipping address.';
        }
        field(47; BillTo_Name; Text[200])
        {
            ExternalName = 'billto_name';
            ExternalType = 'String';
            CaptionML = ENU = 'Bill To Name',
                        ENG = 'Bill To Name';
            Description = 'Type a name for the customer''s billing address, such as "Headquarters" or "Field office", to identify the address.';
        }
        field(48; ShipTo_FreightTermsCode; Option)
        {
            ExternalName = 'shipto_freighttermscode';
            ExternalType = 'Picklist';
            CaptionML = ENU = 'Ship To Freight Terms',
                        ENG = 'Ship To Freight Terms';
            Description = 'Select the freight terms to make sure shipping orders are processed correctly.';
            InitValue = DefaultValue;
            OptionCaptionML = ENU = 'Default Value',
                              ENG = 'Default Value';
            OptionMembers = DefaultValue;
        }
        field(49; ShipTo_Fax; Text[50])
        {
            ExternalName = 'shipto_fax';
            ExternalType = 'String';
            CaptionML = ENU = 'Ship to Fax',
                        ENG = 'Ship to Fax';
            Description = 'Type the fax number for the customer''s shipping address.';
        }
        field(50; BillTo_Line1; Text[250])
        {
            ExternalName = 'billto_line1';
            ExternalType = 'String';
            CaptionML = ENU = 'Bill To Street 1',
                        ENG = 'Bill To Street 1';
            Description = 'Type the first line of the customer''s billing address.';
        }
        field(51; BillTo_Line2; Text[250])
        {
            ExternalName = 'billto_line2';
            ExternalType = 'String';
            CaptionML = ENU = 'Bill To Street 2',
                        ENG = 'Bill To Street 2';
            Description = 'Type the second line of the customer''s billing address.';
        }
        field(52; BillTo_Line3; Text[250])
        {
            ExternalName = 'billto_line3';
            ExternalType = 'String';
            CaptionML = ENU = 'Bill To Street 3',
                        ENG = 'Bill To Street 3';
            Description = 'Type the third line of the billing address.';
        }
        field(53; BillTo_City; Text[80])
        {
            ExternalName = 'billto_city';
            ExternalType = 'String';
            CaptionML = ENU = 'Bill To City',
                        ENG = 'Bill To City';
            Description = 'Type the city for the customer''s billing address.';
        }
        field(54; BillTo_StateOrProvince; Text[50])
        {
            ExternalName = 'billto_stateorprovince';
            ExternalType = 'String';
            CaptionML = ENU = 'Bill To State/Province',
                        ENG = 'Bill To State/Province';
            Description = 'Type the state or province for the billing address.';
        }
        field(55; BillTo_Country; Text[80])
        {
            ExternalName = 'billto_country';
            ExternalType = 'String';
            CaptionML = ENU = 'Bill To Country/Region',
                        ENG = 'Bill To Country/Region';
            Description = 'Type the country or region for the customer''s billing address.';
        }
        field(56; BillTo_PostalCode; Text[20])
        {
            ExternalName = 'billto_postalcode';
            ExternalType = 'String';
            CaptionML = ENU = 'Bill To ZIP/Postal Code',
                        ENG = 'Bill To ZIP/Postal Code';
            Description = 'Type the ZIP Code or postal code for the billing address.';
        }
        field(57; BillTo_Telephone; Text[50])
        {
            ExternalName = 'billto_telephone';
            ExternalType = 'String';
            CaptionML = ENU = 'Bill To Phone',
                        ENG = 'Bill To Phone';
            Description = 'Type the phone number for the customer''s billing address.';
        }
        field(58; BillTo_Fax; Text[50])
        {
            ExternalName = 'billto_fax';
            ExternalType = 'String';
            CaptionML = ENU = 'Bill To Fax',
                        ENG = 'Bill To Fax';
            Description = 'Type the fax number for the customer''s billing address.';
        }
        field(59; DiscountPercentage; Decimal)
        {
            ExternalName = 'discountpercentage';
            ExternalType = 'Decimal';
            CaptionML = ENU = 'Order Discount (%)',
                        ENG = 'Order Discount (%)';
            Description = 'Type the discount rate that should be applied to the Detail Amount field to include additional savings for the customer in the order.';
        }
        field(60; ContactIdName; Text[160])
        {
            ExternalName = 'contactidname';
            ExternalType = 'String';
            ExternalAccess = Read;
            CalcFormula = Lookup ("CRM Contact".FullName WHERE (ContactId = FIELD (ContactId)));
            CaptionML = ENU = 'ContactIdName',
                        ENG = 'ContactIdName';
            FieldClass = FlowField;
        }
        field(61; AccountIdName; Text[160])
        {
            ExternalName = 'accountidname';
            ExternalType = 'String';
            ExternalAccess = Read;
            CalcFormula = Lookup ("CRM Account".Name WHERE (AccountId = FIELD (AccountId)));
            CaptionML = ENU = 'AccountIdName',
                        ENG = 'AccountIdName';
            FieldClass = FlowField;
        }
        field(62; OpportunityIdName; Text[250])
        {
            ExternalName = 'opportunityidname';
            ExternalType = 'String';
            ExternalAccess = Read;
            CalcFormula = Lookup ("CRM Opportunity".Name WHERE (OpportunityId = FIELD (OpportunityId)));
            CaptionML = ENU = 'OpportunityIdName',
                        ENG = 'OpportunityIdName';
            FieldClass = FlowField;
        }
        field(63; QuoteIdName; Text[250])
        {
            ExternalName = 'quoteidname';
            ExternalType = 'String';
            ExternalAccess = Read;
            CalcFormula = Lookup ("CRM Quote".Name WHERE (QuoteId = FIELD (QuoteId)));
            CaptionML = ENU = 'QuoteIdName',
                        ENG = 'QuoteIdName';
            FieldClass = FlowField;
        }
        field(64; PriceLevelIdName; Text[100])
        {
            ExternalName = 'pricelevelidname';
            ExternalType = 'String';
            ExternalAccess = Read;
            CalcFormula = Lookup ("CRM Pricelevel".Name WHERE (PriceLevelId = FIELD (PriceLevelId)));
            CaptionML = ENU = 'PriceLevelIdName',
                        ENG = 'PriceLevelIdName';
            FieldClass = FlowField;
        }
        field(65; CreatedByName; Text[200])
        {
            ExternalName = 'createdbyname';
            ExternalType = 'String';
            ExternalAccess = Read;
            CalcFormula = Lookup ("CRM Systemuser".FullName WHERE (SystemUserId = FIELD (CreatedBy)));
            CaptionML = ENU = 'CreatedByName',
                        ENG = 'CreatedByName';
            FieldClass = FlowField;
        }
        field(66; ModifiedByName; Text[200])
        {
            ExternalName = 'modifiedbyname';
            ExternalType = 'String';
            ExternalAccess = Read;
            CalcFormula = Lookup ("CRM Systemuser".FullName WHERE (SystemUserId = FIELD (ModifiedBy)));
            CaptionML = ENU = 'ModifiedByName',
                        ENG = 'ModifiedByName';
            FieldClass = FlowField;
        }
        field(67; CustomerId; Guid)
        {
            ExternalName = 'customerid';
            ExternalType = 'Customer';
            CaptionML = ENU = 'Customer',
                        ENG = 'Customer';
            Description = 'Select the customer account or contact to provide a quick link to additional customer details, such as account information, activities, and opportunities.';
            TableRelation = IF (CustomerIdType = CONST (account)) "CRM Account".AccountId
            ELSE
            IF (CustomerIdType = CONST (contact)) "CRM Contact".ContactId;
        }
        field(68; CustomerIdType; Option)
        {
            ExternalName = 'customeridtype';
            ExternalType = 'EntityName';
            CaptionML = ENU = 'Customer Type',
                        ENG = 'Customer Type';
            OptionCaptionML = ENU = ' ,account,contact',
                              ENG = ' ,account,contact';
            OptionMembers = " ",account,contact;
        }
        field(69; OwnerId; Guid)
        {
            ExternalName = 'ownerid';
            ExternalType = 'Owner';
            CaptionML = ENU = 'Owner',
                        ENG = 'Owner';
            Description = 'Enter the user or team who is assigned to manage the record. This field is updated every time the record is assigned to a different user.';
            TableRelation = IF (OwnerIdType = CONST (systemuser)) "CRM Systemuser".SystemUserId
            ELSE
            IF (OwnerIdType = CONST (team)) "CRM Team".TeamId;
        }
        field(70; OwnerIdType; Option)
        {
            ExternalName = 'owneridtype';
            ExternalType = 'EntityName';
            CaptionML = ENU = 'OwnerIdType',
                        ENG = 'OwnerIdType';
            OptionCaptionML = ENU = ' ,systemuser,team',
                              ENG = ' ,systemuser,team';
            OptionMembers = " ",systemuser,team;
        }
        field(71; BillTo_ContactName; Text[150])
        {
            ExternalName = 'billto_contactname';
            ExternalType = 'String';
            CaptionML = ENU = 'Bill To Contact Name',
                        ENG = 'Bill To Contact Name';
            Description = 'Type the primary contact name at the customer''s billing address.';
        }
        field(72; BillTo_AddressId; Guid)
        {
            ExternalName = 'billto_addressid';
            ExternalType = 'Uniqueidentifier';
            CaptionML = ENU = 'Bill To Address ID',
                        ENG = 'Bill To Address ID';
            Description = 'Unique identifier of the billing address.';
        }
        field(73; ShipTo_AddressId; Guid)
        {
            ExternalName = 'shipto_addressid';
            ExternalType = 'Uniqueidentifier';
            CaptionML = ENU = 'Ship To Address ID',
                        ENG = 'Ship To Address ID';
            Description = 'Unique identifier of the shipping address.';
        }
        field(74; IsPriceLocked; Boolean)
        {
            ExternalName = 'ispricelocked';
            ExternalType = 'Boolean';
            ExternalAccess = Modify;
            CaptionML = ENU = 'Prices Locked',
                        ENG = 'Prices Locked';
            Description = 'Select whether prices specified on the invoice are locked from any further updates.';
        }
        field(75; DateFulfilled; Date)
        {
            ExternalName = 'datefulfilled';
            ExternalType = 'DateTime';
            CaptionML = ENU = 'Date Fulfilled',
                        ENG = 'Date Fulfilled';
            Description = 'Enter the date that all or part of the order was shipped to the customer.';
        }
        field(76; ShipTo_ContactName; Text[150])
        {
            ExternalName = 'shipto_contactname';
            ExternalType = 'String';
            CaptionML = ENU = 'Ship To Contact Name',
                        ENG = 'Ship To Contact Name';
            Description = 'Type the primary contact name at the customer''s shipping address.';
        }
        field(77; UTCConversionTimeZoneCode; Integer)
        {
            ExternalName = 'utcconversiontimezonecode';
            ExternalType = 'Integer';
            CaptionML = ENU = 'UTC Conversion Time Zone Code',
                        ENG = 'UTC Conversion Time Zone Code';
            Description = 'Time zone code that was in use when the record was created.';
            MinValue = - 1;
        }
        field(78; TransactionCurrencyId; Guid)
        {
            ExternalName = 'transactioncurrencyid';
            ExternalType = 'Lookup';
            ExternalAccess = Insert;
            CaptionML = ENU = 'Currency',
                        ENG = 'Currency';
            Description = 'Choose the local currency for the record to make sure budgets are reported in the correct currency.';
            TableRelation = "CRM Transactioncurrency".TransactionCurrencyId;
        }
        field(79; TimeZoneRuleVersionNumber; Integer)
        {
            ExternalName = 'timezoneruleversionnumber';
            ExternalType = 'Integer';
            CaptionML = ENU = 'Time Zone Rule Version Number',
                        ENG = 'Time Zone Rule Version Number';
            Description = 'For internal use only.';
            MinValue = - 1;
        }
        field(80; ImportSequenceNumber; Integer)
        {
            ExternalName = 'importsequencenumber';
            ExternalType = 'Integer';
            ExternalAccess = Insert;
            CaptionML = ENU = 'Import Sequence Number',
                        ENG = 'Import Sequence Number';
            Description = 'Unique identifier of the data import or data migration that created this record.';
        }
        field(81; ExchangeRate; Decimal)
        {
            ExternalName = 'exchangerate';
            ExternalType = 'Decimal';
            ExternalAccess = Read;
            CaptionML = ENU = 'Exchange Rate',
                        ENG = 'Exchange Rate';
            Description = 'Shows the conversion rate of the record''s currency. The exchange rate is used to convert all money fields in the record from the local currency to the system''s default currency.';
        }
        field(82; OverriddenCreatedOn; Date)
        {
            ExternalName = 'overriddencreatedon';
            ExternalType = 'DateTime';
            ExternalAccess = Insert;
            CaptionML = ENU = 'Record Created On',
                        ENG = 'Record Created On';
            Description = 'Date and time that the record was migrated.';
        }
        field(83; TotalLineItemAmount_Base; Decimal)
        {
            ExternalName = 'totallineitemamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            CaptionML = ENU = 'Total Detail Amount (Base)',
                        ENG = 'Total Detail Amount (Base)';
            Description = 'Shows the Detail Amount field converted to the system''s default base currency. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(84; TotalDiscountAmount_Base; Decimal)
        {
            ExternalName = 'totaldiscountamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            CaptionML = ENU = 'Total Discount Amount (Base)',
                        ENG = 'Total Discount Amount (Base)';
            Description = 'Shows the Total Discount Amount field converted to the system''s default base currency for reporting purposes. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(85; TotalAmountLessFreight_Base; Decimal)
        {
            ExternalName = 'totalamountlessfreight_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            CaptionML = ENU = 'Total Pre-Freight Amount (Base)',
                        ENG = 'Total Pre-Freight Amount (Base)';
            Description = 'Shows the Pre-Freight Amount field converted to the system''s default base currency for reporting purposes. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(86; TotalAmount_Base; Decimal)
        {
            ExternalName = 'totalamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            CaptionML = ENU = 'Total Amount (Base)',
                        ENG = 'Total Amount (Base)';
            Description = 'Shows the Total Amount field converted to the system''s default base currency for reporting purposes. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(87; TransactionCurrencyIdName; Text[100])
        {
            ExternalName = 'transactioncurrencyidname';
            ExternalType = 'String';
            ExternalAccess = Read;
            CalcFormula = Lookup ("CRM Transactioncurrency".CurrencyName WHERE (TransactionCurrencyId = FIELD (TransactionCurrencyId)));
            CaptionML = ENU = 'TransactionCurrencyIdName',
                        ENG = 'TransactionCurrencyIdName';
            FieldClass = FlowField;
        }
        field(88; DiscountAmount_Base; Decimal)
        {
            ExternalName = 'discountamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            CaptionML = ENU = 'Order Discount Amount (Base)',
                        ENG = 'Order Discount Amount (Base)';
            Description = 'Shows the Order Discount field converted to the system''s default base currency for reporting purposes. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(89; FreightAmount_Base; Decimal)
        {
            ExternalName = 'freightamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            CaptionML = ENU = 'Freight Amount (Base)',
                        ENG = 'Freight Amount (Base)';
            Description = 'Shows the Freight Amount field converted to the system''s default base currency for reporting purposes. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(90; TotalLineItemDiscountAmount_Ba; Decimal)
        {
            ExternalName = 'totallineitemdiscountamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            CaptionML = ENU = 'Total Line Item Discount Amount (Base)',
                        ENG = 'Total Line Item Discount Amount (Base)';
            Description = 'Shows the Total Line Item Discount Amount field converted to the system''s default base currency for reporting purposes. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(91; TotalTax_Base; Decimal)
        {
            ExternalName = 'totaltax_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            CaptionML = ENU = 'Total Tax (Base)',
                        ENG = 'Total Tax (Base)';
            Description = 'Shows the Total Tax field converted to the system''s default base currency for reporting purposes. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(92; CreatedOnBehalfBy; Guid)
        {
            ExternalName = 'createdonbehalfby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            CaptionML = ENU = 'Created By (Delegate)',
                        ENG = 'Created By (Delegate)';
            Description = 'Shows who created the record on behalf of another user.';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(93; CreatedOnBehalfByName; Text[200])
        {
            ExternalName = 'createdonbehalfbyname';
            ExternalType = 'String';
            ExternalAccess = Read;
            CalcFormula = Lookup ("CRM Systemuser".FullName WHERE (SystemUserId = FIELD (CreatedOnBehalfBy)));
            CaptionML = ENU = 'CreatedOnBehalfByName',
                        ENG = 'CreatedOnBehalfByName';
            FieldClass = FlowField;
        }
        field(94; ModifiedOnBehalfBy; Guid)
        {
            ExternalName = 'modifiedonbehalfby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            CaptionML = ENU = 'Modified By (Delegate)',
                        ENG = 'Modified By (Delegate)';
            Description = 'Shows who last updated the record on behalf of another user.';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(95; ModifiedOnBehalfByName; Text[200])
        {
            ExternalName = 'modifiedonbehalfbyname';
            ExternalType = 'String';
            ExternalAccess = Read;
            CalcFormula = Lookup ("CRM Systemuser".FullName WHERE (SystemUserId = FIELD (ModifiedOnBehalfBy)));
            CaptionML = ENU = 'ModifiedOnBehalfByName',
                        ENG = 'ModifiedOnBehalfByName';
            FieldClass = FlowField;
        }
        field(96; OwningTeam; Guid)
        {
            ExternalName = 'owningteam';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            CaptionML = ENU = 'Owning Team',
                        ENG = 'Owning Team';
            Description = 'Unique identifier of the team who owns the order.';
            TableRelation = "CRM Team".TeamId;
        }
        field(97; BillTo_Composite; BLOB)
        {
            ExternalName = 'billto_composite';
            ExternalType = 'Memo';
            ExternalAccess = Read;
            CaptionML = ENU = 'Bill To Address',
                        ENG = 'Bill To Address';
            Description = 'Shows the complete Bill To address.';
            SubType = Memo;
        }
        field(98; ShipTo_Composite; BLOB)
        {
            ExternalName = 'shipto_composite';
            ExternalType = 'Memo';
            ExternalAccess = Read;
            CaptionML = ENU = 'Ship To Address',
                        ENG = 'Ship To Address';
            Description = 'Shows the complete Ship To address.';
            SubType = Memo;
        }
        field(99; ProcessId; Guid)
        {
            ExternalName = 'processid';
            ExternalType = 'Uniqueidentifier';
            CaptionML = ENU = 'Process',
                        ENG = 'Process';
            Description = 'Shows the ID of the process.';
        }
        field(100; StageId; Guid)
        {
            ExternalName = 'stageid';
            ExternalType = 'Uniqueidentifier';
            CaptionML = ENU = 'Process Stage',
                        ENG = 'Process Stage';
            Description = 'Shows the ID of the stage.';
        }
        field(101; EntityImageId; Guid)
        {
            ExternalName = 'entityimageid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Read;
            CaptionML = ENU = 'Entity Image Id',
                        ENG = 'Entity Image Id';
            Description = 'For internal use only.';
        }
        field(102; TraversedPath; Text[250])
        {
            ExternalName = 'traversedpath';
            ExternalType = 'String';
            CaptionML = ENU = 'Traversed Path',
                        ENG = 'Traversed Path';
            Description = 'For internal use only.';
        }
        field(103; iosh_OnlinePayment; Boolean)
        {
            ExternalName = 'iosh_onlinepayment';
            ExternalType = 'Boolean';
            Caption = 'Online Payment';
            Description = '';
        }
        field(50000; IOSH_LegalEntityName; Text[30])
        {
            Caption = 'Legal Entity Name';
            Description = 'Name of Business Central Company.';
            ExternalName = 'iosh_legalentityname';
            ExternalType = 'String';
        }

    }


    keys
    {
        key(Key1; SalesOrderId)
        {
        }
        key(Key2; Name)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name)
        {
        }
    }
}

