table 60014 iOSH_SaleOrderLine
{
    // Dynamics CRM Version: 9.0.2.189

    Caption = 'IOSH CRM Order Line';
    Description = 'Line item in a sales order.';
    TableType = CRM;
    ExternalName = 'salesorderdetail';

    fields
    {
        field(1;SalesOrderDetailId;Guid)
        {
            ExternalName='salesorderdetailid';
                                                   ExternalType='Uniqueidentifier';
                                                   ExternalAccess=Insert;
            CaptionML = ENU='Order Product',
                        ENG='Order Product';
            Description = 'Unique identifier of the product specified in the order.';
        }
        field(2;SalesOrderId;Guid)
        {
             ExternalName='salesorderid';
                                                   ExternalType='Lookup';
            CaptionML = ENU='Order',
                        ENG='Order';
            Description = 'Shows the order for the product. The ID is used to link product pricing and other details to the total amounts and other information on the order.';
            TableRelation = "CRM Salesorder".SalesOrderId;
        }
        field(3;SalesRepId;Guid)
        {
               ExternalName='salesrepid';
                                                   ExternalType='Lookup';
            CaptionML = ENU='Salesperson',
                        ENG='Salesperson';
            Description = 'Choose the user responsible for the sale of the order product.';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(4;IsProductOverridden;Boolean)
        {
            ExternalName='isproductoverridden';
                                                   ExternalType='Boolean';
                                                   ExternalAccess=Insert;
            CaptionML = ENU='Select Product',
                        ENG='Select Product';
            Description = 'Select whether the product exists in the Microsoft Dynamics CRM product catalog or is a write-in product specific to the order.';
        }
        field(5;IsCopied;Boolean)
        {
            ExternalName='iscopied';
                                                   ExternalType='Boolean';
            CaptionML = ENU='Copied',
                        ENG='Copied';
            Description = 'Select whether the invoice line item is copied from another item or data source.';
        }
        field(6;QuantityShipped;Decimal)
        {
            ExternalName='quantityshipped';
                                                   ExternalType='Decimal';
            CaptionML = ENU='Quantity Shipped',
                        ENG='Quantity Shipped';
            Description = 'Type the amount or quantity of the product that was shipped for the order.';
        }
        field(7;LineItemNumber;Integer)
        {
            ExternalName='lineitemnumber';
                                                   ExternalType='Integer';
            CaptionML = ENU='Line Item Number',
                        ENG='Line Item Number';
            Description = 'Type the line item number for the order product to easily identify the product in the order and make sure it''s listed in the correct sequence.';
            MaxValue = 1000000000;
            MinValue = 0;
        }
        field(8;QuantityBackordered;Decimal)
        {
            ExternalName='quantitybackordered';
                                                   ExternalType='Decimal';
            CaptionML = ENU='Quantity Back Ordered',
                        ENG='Quantity Back Ordered';
            Description = 'Type the amount or quantity of the product that is back ordered for the order.';
        }
        field(9;UoMId;Guid)
        {
            ExternalName='uomid';
                                                   ExternalType='Lookup';
            CaptionML = ENU='Unit',
                        ENG='Unit';
            Description = 'Choose the unit of measurement for the base unit quantity for this purchase, such as each or dozen.';
            TableRelation = "CRM Uom".UoMId;
        }
        field(10;QuantityCancelled;Decimal)
        {
            ExternalName='quantitycancelled';
                                                   ExternalType='Decimal';
            CaptionML = ENU='Quantity Canceled',
                        ENG='Quantity Canceled';
            Description = 'Type the amount or quantity of the product that was canceled.';
        }
        field(11;ProductId;Guid)
        {
            ExternalName='productid';
                                                   ExternalType='Lookup';
            CaptionML = ENU='Existing Product',
                        ENG='Existing Product';
            Description = 'Choose the product to include on the order to link the product''s pricing and other information to the parent order.';
            TableRelation = "CRM Product".ProductId;
        }
        field(12;RequestDeliveryBy;Date)
        {
            ExternalName='requestdeliveryby';
                                                   ExternalType='DateTime';
            CaptionML = ENU='Requested Delivery Date',
                        ENG='Requested Delivery Date';
            Description = 'Enter the delivery date requested by the customer for the order product.';
        }
        field(13;Quantity;Decimal)
        {
            ExternalName='quantity';
                                                   ExternalType='Decimal';
            CaptionML = ENU='Quantity',
                        ENG='Quantity';
            Description = 'Type the amount or quantity of the product ordered by the customer.';
        }
        field(14;PricingErrorCode;Option)
        {
            ExternalName='pricingerrorcode';
                                                   ExternalType='Picklist';
            CaptionML = ENU='Pricing Error ',
                        ENG='Pricing Error ';
            Description = 'Select the type of pricing error, such as a missing or invalid product, or missing quantity.';
            InitValue = "None";
            OptionCaptionML = ENU='None,Detail Error,Missing Price Level,Inactive Price Level,Missing Quantity,Missing Unit Price,Missing Product,Invalid Product,Missing Pricing Code,Invalid Pricing Code,Missing UOM,Product Not In Price Level,Missing Price Level Amount,Missing Price Level Percentage,Missing Price,Missing Current Cost,Missing Standard Cost,Invalid Price Level Amount,Invalid Price Level Percentage,Invalid Price,Invalid Current Cost,Invalid Standard Cost,Invalid Rounding Policy,Invalid Rounding Option,Invalid Rounding Amount,Price Calculation Error,Invalid Discount Type,Discount Type Invalid State,Invalid Discount,Invalid Quantity,Invalid Pricing Precision,Missing Product Default UOM,Missing Product UOM Schedule ,Inactive Discount Type,Invalid Price Level Currency,Price Attribute Out Of Range,Base Currency Attribute Overflow,Base Currency Attribute Underflow',
                              ENG='None,Detail Error,Missing Price Level,Inactive Price Level,Missing Quantity,Missing Unit Price,Missing Product,Invalid Product,Missing Pricing Code,Invalid Pricing Code,Missing UOM,Product Not In Price Level,Missing Price Level Amount,Missing Price Level Percentage,Missing Price,Missing Current Cost,Missing Standard Cost,Invalid Price Level Amount,Invalid Price Level Percentage,Invalid Price,Invalid Current Cost,Invalid Standard Cost,Invalid Rounding Policy,Invalid Rounding Option,Invalid Rounding Amount,Price Calculation Error,Invalid Discount Type,Discount Type Invalid State,Invalid Discount,Invalid Quantity,Invalid Pricing Precision,Missing Product Default UOM,Missing Product UOM Schedule ,Inactive Discount Type,Invalid Price Level Currency,Price Attribute Out Of Range,Base Currency Attribute Overflow,Base Currency Attribute Underflow';
            OptionMembers = "None",DetailError,MissingPriceLevel,InactivePriceLevel,MissingQuantity,MissingUnitPrice,MissingProduct,InvalidProduct,MissingPricingCode,InvalidPricingCode,MissingUOM,ProductNotInPriceLevel,MissingPriceLevelAmount,MissingPriceLevelPercentage,MissingPrice,MissingCurrentCost,MissingStandardCost,InvalidPriceLevelAmount,InvalidPriceLevelPercentage,InvalidPrice,InvalidCurrentCost,InvalidStandardCost,InvalidRoundingPolicy,InvalidRoundingOption,InvalidRoundingAmount,PriceCalculationError,InvalidDiscountType,DiscountTypeInvalidState,InvalidDiscount,InvalidQuantity,InvalidPricingPrecision,MissingProductDefaultUOM,MissingProductUOMSchedule,InactiveDiscountType,InvalidPriceLevelCurrency,PriceAttributeOutOfRange,BaseCurrencyAttributeOverflow,BaseCurrencyAttributeUnderflow;
        }
        field(15;ManualDiscountAmount;Decimal)
        {
            ExternalName='manualdiscountamount';
                                                   ExternalType='Money';
            CaptionML = ENU='Manual Discount',
                        ENG='Manual Discount';
            Description = 'Type the manual discount amount for the order product to deduct any negotiated or other savings from the product total on the order.';
        }
        field(16;ProductDescription;Text[250])
        {
            ExternalName='productdescription';
                                                   ExternalType='String';
            CaptionML = ENU='Write-In Product',
                        ENG='Write-In Product';
            Description = 'Type a name or description to identify the type of write-in product included in the order.';
        }
        field(17;VolumeDiscountAmount;Decimal)
        {
            ExternalName='volumediscountamount';
                                                   ExternalType='Money';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Volume Discount',
                        ENG='Volume Discount';
            Description = 'Shows the discount amount per unit if a specified volume is purchased. Configure volume discounts in the Product Catalog in the Settings area.';
        }
        field(18;PricePerUnit;Decimal)
        {
            ExternalName='priceperunit';
                                                   ExternalType='Money';
            CaptionML = ENU='Price Per Unit',
                        ENG='Price Per Unit';
            Description = 'Type the price per unit of the order product. The default is the value in the price list specified on the order for existing products.';
        }
        field(19;BaseAmount;Decimal)
        {
            ExternalName='baseamount';
                                                   ExternalType='Money';
                                                   ExternalAccess=Modify;
            CaptionML = ENU='Amount',
                        ENG='Amount';
            Description = 'Shows the total price of the order product, based on the price per unit, volume discount, and quantity.';
        }
        field(20;ExtendedAmount;Decimal)
        {
            ExternalName='extendedamount';
                                                   ExternalType='Money';
                                                   ExternalAccess=Modify;
            CaptionML = ENU='Extended Amount',
                        ENG='Extended Amount';
            Description = 'Shows the total amount due for the order product, based on the sum of the unit price, quantity, discounts, and tax.';
        }
        field(21;Description;BLOB)
        {
            ExternalName='description';
                                                   ExternalType='Memo';
            CaptionML = ENU='Description',
                        ENG='Description';
            Description = 'Type additional information to describe the order product, such as manufacturing details or acceptable substitutions.';
            SubType = Memo;
        }
        field(22;IsPriceOverridden;Boolean)
        {
            ExternalName='ispriceoverridden';
                                                   ExternalType='Boolean';
            CaptionML = ENU='Pricing',
                        ENG='Pricing';
            Description = 'Select whether the price per unit is fixed at the value in the specified price list or can be overridden by users who have edit rights to the order product.';
        }
        field(23;ShipTo_Name;Text[200])
        {
            ExternalName='shipto_name';
                                                   ExternalType='String';
            CaptionML = ENU='Ship To Name',
                        ENG='Ship To Name';
            Description = 'Type a name for the customer''s shipping address, such as "Headquarters" or "Field office", to identify the address.';
        }
        field(24;Tax;Decimal)
        {
            ExternalName='tax';
                                                   ExternalType='Money';
            CaptionML = ENU='Tax',
                        ENG='Tax';
            Description = 'Type the tax amount for the order product.';
        }
        field(25;CreatedOn;DateTime)
        {
            ExternalName='createdon';
                                                   ExternalType='DateTime';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Created On',
                        ENG='Created On';
            Description = 'Shows the date and time when the record was created. The date and time are displayed in the time zone selected in Microsoft Dynamics CRM options.';
        }
        field(26;ShipTo_Line1;Text[250])
        {
            ExternalName='shipto_line1';
                                                   ExternalType='String';
            CaptionML = ENU='Ship To Street 1',
                        ENG='Ship To Street 1';
            Description = 'Type the first line of the customer''s shipping address.';
        }
        field(27;CreatedBy;Guid)
        {
            ExternalName='createdby';
                                                   ExternalType='Lookup';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Created By',
                        ENG='Created By';
            Description = 'Shows who created the record.';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(28;ModifiedBy;Guid)
        {
            ExternalName='modifiedby';
                                                   ExternalType='Lookup';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Modified By',
                        ENG='Modified By';
            Description = 'Shows who last updated the record.';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(29;ShipTo_Line2;Text[250])
        {
            ExternalName='shipto_line2';
                                                   ExternalType='String';
            CaptionML = ENU='Ship To Street 2',
                        ENG='Ship To Street 2';
            Description = 'Type the second line of the customer''s shipping address.';
        }
        field(30;ShipTo_Line3;Text[250])
        {
            ExternalName='shipto_line3';
                                                   ExternalType='String';
            CaptionML = ENU='Ship To Street 3',
                        ENG='Ship To Street 3';
            Description = 'Type the third line of the shipping address.';
        }
        field(31;ModifiedOn;DateTime)
        {
            ExternalName='modifiedon';
                                                   ExternalType='DateTime';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Modified On',
                        ENG='Modified On';
            Description = 'Shows the date and time when the record was last updated. The date and time are displayed in the time zone selected in Microsoft Dynamics CRM options.';
        }
        field(32;ShipTo_City;Text[80])
        {
            ExternalName='shipto_city';
                                                   ExternalType='String';
            CaptionML = ENU='Ship To City',
                        ENG='Ship To City';
            Description = 'Type the city for the customer''s shipping address.';
        }
        field(33;ShipTo_StateOrProvince;Text[50])
        {
            ExternalName='shipto_stateorprovince';
                                                   ExternalType='String';
            CaptionML = ENU='Ship To State/Province',
                        ENG='Ship To State/Province';
            Description = 'Type the state or province for the shipping address.';
        }
        field(34;ShipTo_Country;Text[80])
        {
            ExternalName='shipto_country';
                                                   ExternalType='String';
            CaptionML = ENU='Ship To Country/Region',
                        ENG='Ship To Country/Region';
            Description = 'Type the country or region for the customer''s shipping address.';
        }
        field(35;ShipTo_PostalCode;Text[20])
        {
            ExternalName='shipto_postalcode';
                                                   ExternalType='String';
            CaptionML = ENU='Ship To ZIP/Postal Code',
                        ENG='Ship To ZIP/Postal Code';
            Description = 'Type the ZIP Code or postal code for the shipping address.';
        }
        field(36;WillCall;Boolean)
        {
            ExternalName='willcall';
                                                   ExternalType='Boolean';
            CaptionML = ENU='Ship To',
                        ENG='Ship To';
            Description = 'Select whether the order product should be shipped to the specified address or held until the customer calls with further pick up or delivery instructions.';
        }
        field(37;ShipTo_Telephone;Text[50])
        {
            ExternalName='shipto_telephone';
                                                   ExternalType='String';
            CaptionML = ENU='Ship To Phone',
                        ENG='Ship To Phone';
            Description = 'Type the phone number for the customer''s shipping address.';
        }
        field(38;ShipTo_Fax;Text[50])
        {
            ExternalName='shipto_fax';
                                                   ExternalType='String';
            CaptionML = ENU='Ship To Fax',
                        ENG='Ship To Fax';
            Description = 'Type the fax number for the customer''s shipping address.';
        }
        field(39;ShipTo_FreightTermsCode;Option)
        {
            ExternalName='shipto_freighttermscode';
                                                   ExternalType='Picklist';
            CaptionML = ENU='Freight Terms',
                        ENG='Freight Terms';
            Description = 'Select the freight terms to make sure shipping orders are processed correctly.';
            InitValue = " ";
            OptionCaptionML = ENU=' ,FOB,No Charge',
                              ENG=' ,FOB,No Charge';
            OptionMembers = " ",FOB,NoCharge;
        }
        field(40;ProductIdName;Text[100])
        {
            ExternalName='productidname';
                                                   ExternalType='String';
                                                   ExternalAccess=Read;
            CalcFormula = Lookup("CRM Product".Name WHERE (ProductId=FIELD(ProductId)));
            CaptionML = ENU='ProductIdName',
                        ENG='ProductIdName';
            FieldClass = FlowField;
        }
        field(41;UoMIdName;Text[100])
        {
            ExternalName='uomidname';
                                                   ExternalType='String';
                                                   ExternalAccess=Read;
            CalcFormula = Lookup("CRM Uom".Name WHERE (UoMId=FIELD(UoMId)));
            CaptionML = ENU='UoMIdName',
                        ENG='UoMIdName';
            FieldClass = FlowField;
        }
        field(42;SalesRepIdName;Text[200])
        {
            ExternalName='salesrepidname';
                                                   ExternalType='String';
                                                   ExternalAccess=Read;
            CalcFormula = Lookup("CRM Systemuser".FullName WHERE (SystemUserId=FIELD(SalesRepId)));
            CaptionML = ENU='SalesRepIdName',
                        ENG='SalesRepIdName';
            FieldClass = FlowField;
        }
        field(43;SalesOrderStateCode;Option)
        {
             ExternalName='salesorderstatecode';
                                                   ExternalType='Picklist';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Order Status',
                        ENG='Order Status';
            Description = 'Shows the status of the order that the order detail is associated with.';
            InitValue = " ";
            OptionCaptionML = ENU=' ',
                              ENG=' ';
            OptionMembers = " ";
        }
        field(44;CreatedByName;Text[200])
        {
            ExternalName='createdbyname';
                                                   ExternalType='String';
                                                   ExternalAccess=Read;
            CalcFormula = Lookup("CRM Systemuser".FullName WHERE (SystemUserId=FIELD(CreatedBy)));
            CaptionML = ENU='CreatedByName',
                        ENG='CreatedByName';
            FieldClass = FlowField;
        }
        field(45;ModifiedByName;Text[200])
        {
            ExternalName='modifiedbyname';
                                                   ExternalType='String';
                                                   ExternalAccess=Read;
            CalcFormula = Lookup("CRM Systemuser".FullName WHERE (SystemUserId=FIELD(ModifiedBy)));
            CaptionML = ENU='ModifiedByName',
                        ENG='ModifiedByName';
            FieldClass = FlowField;
        }
        field(46;ShipTo_ContactName;Text[150])
        {
            ExternalName='shipto_contactname';
                                                   ExternalType='String';
            CaptionML = ENU='Ship To Contact Name',
                        ENG='Ship To Contact Name';
            Description = 'Type the primary contact name at the customer''s shipping address.';
        }
        field(47;VersionNumber;BigInteger)
        {
            ExternalName='versionnumber';
                                                   ExternalType='BigInt';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Version Number',
                        ENG='Version Number';
            Description = 'Version number of the sales order detail.';
        }
        field(50;SalesOrderIsPriceLocked;Boolean)
        {
            ExternalName='salesorderispricelocked';
                                                   ExternalType='Boolean';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Order Is Price Locked',
                        ENG='Order Is Price Locked';
            Description = 'Tells whether product pricing is locked for the order.';
        }
        field(51;ShipTo_AddressId;Guid)
        {
            ExternalName='shipto_addressid';
                                                   ExternalType='Uniqueidentifier';
            CaptionML = ENU='Ship To Address ID',
                        ENG='Ship To Address ID';
            Description = 'Unique identifier of the shipping address.';
        }
        field(52;TimeZoneRuleVersionNumber;Integer)
        {
            ExternalName='timezoneruleversionnumber';
                                                   ExternalType='Integer';
            CaptionML = ENU='Time Zone Rule Version Number',
                        ENG='Time Zone Rule Version Number';
            Description = 'For internal use only.';
            MinValue = -1;
        }
        field(53;ImportSequenceNumber;Integer)
        {
            ExternalName='importsequencenumber';
                                                   ExternalType='Integer';
                                                   ExternalAccess=Insert;
            CaptionML = ENU='Import Sequence Number',
                        ENG='Import Sequence Number';
            Description = 'Unique identifier of the data import or data migration that created this record.';
        }
        field(54;UTCConversionTimeZoneCode;Integer)
        {
            ExternalName='utcconversiontimezonecode';
                                                   ExternalType='Integer';
            CaptionML = ENU='UTC Conversion Time Zone Code',
                        ENG='UTC Conversion Time Zone Code';
            Description = 'Time zone code that was in use when the record was created.';
            MinValue = -1;
        }
        field(55;ExchangeRate;Decimal)
        {
            ExternalName='exchangerate';
                                                   ExternalType='Decimal';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Exchange Rate',
                        ENG='Exchange Rate';
            Description = 'Shows the conversion rate of the record''s currency. The exchange rate is used to convert all money fields in the record from the local currency to the system''s default currency.';
        }
        field(56;OverriddenCreatedOn;Date)
        {
            ExternalName='overriddencreatedon';
                                                   ExternalType='DateTime';
                                                   ExternalAccess=Insert;
            CaptionML = ENU='Record Created On',
                        ENG='Record Created On';
            Description = 'Date and time that the record was migrated.';
        }
        field(57;TransactionCurrencyId;Guid)
        {
             ExternalName='transactioncurrencyid';
                                                   ExternalType='Lookup';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Currency',
                        ENG='Currency';
            Description = 'Choose the local currency for the record to make sure budgets are reported in the correct currency.';
            TableRelation = "CRM Transactioncurrency".TransactionCurrencyId;
        }
        field(58;BaseAmount_Base;Decimal)
        {
            ExternalName='baseamount_base';
                                                   ExternalType='Money';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Amount (Base)',
                        ENG='Amount (Base)';
            Description = 'Shows the Amount field converted to the system''s default base currency. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(59;PricePerUnit_Base;Decimal)
        {
            ExternalName='priceperunit_base';
                                                   ExternalType='Money';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Price Per Unit (Base)',
                        ENG='Price Per Unit (Base)';
            Description = 'Shows the Price Per Unit field converted to the system''s default base currency for reporting purposes. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(60;TransactionCurrencyIdName;Text[100])
        {
            ExternalName='transactioncurrencyidname';
                                                   ExternalType='String';
                                                   ExternalAccess=Read;
            CalcFormula = Lookup("CRM Transactioncurrency".CurrencyName WHERE (TransactionCurrencyId=FIELD(TransactionCurrencyId)));
            CaptionML = ENU='TransactionCurrencyIdName',
                        ENG='TransactionCurrencyIdName';
            FieldClass = FlowField;
        }
        field(61;VolumeDiscountAmount_Base;Decimal)
        {
            ExternalName='volumediscountamount_base';
                                                   ExternalType='Money';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Volume Discount (Base)',
                        ENG='Volume Discount (Base)';
            Description = 'Shows the Volume Discount field converted to the system''s default base currency for reporting purposes. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(62;ExtendedAmount_Base;Decimal)
        {
            ExternalName='extendedamount_base';
                                                   ExternalType='Money';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Extended Amount (Base)',
                        ENG='Extended Amount (Base)';
            Description = 'Shows the Extended Amount field converted to the system''s default base currency. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(63;Tax_Base;Decimal)
        {
            ExternalName='tax_base';
                                                   ExternalType='Money';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Tax (Base)',
                        ENG='Tax (Base)';
            Description = 'Shows the Tax field converted to the system''s default base currency for reporting purposes. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(64;ManualDiscountAmount_Base;Decimal)
        {
            ExternalName='manualdiscountamount_base';
                                                   ExternalType='Money';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Manual Discount (Base)',
                        ENG='Manual Discount (Base)';
            Description = 'Shows the Manual Discount field converted to the system''s default base currency for reporting purposes. The calculation uses the exchange rate specified in the Currencies area.';
        }
        field(65;OwnerId;Guid)
        {
            ExternalName='ownerid';
                                                   ExternalType='Owner';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Owner',
                        ENG='Owner';
            Description = 'Enter the user or team who is assigned to manage the record. This field is updated every time the record is assigned to a different user.';
            TableRelation = IF (OwnerIdType=CONST(systemuser)) "CRM Systemuser".SystemUserId
                            ELSE IF (OwnerIdType=CONST(team)) "CRM Team".TeamId;
        }
        field(66;OwnerIdType;Option)
        {
            ExternalName='owneridtype';
                                                   ExternalType='EntityName';
                                                   ExternalAccess=Read;
            CaptionML = ENU='OwnerIdType',
                        ENG='OwnerIdType';
            OptionCaptionML = ENU=' ,systemuser,team',
                              ENG=' ,systemuser,team';
            OptionMembers = " ",systemuser,team;
        }
        field(67;CreatedOnBehalfBy;Guid)
        {
            ExternalName='createdonbehalfby';
                                                   ExternalType='Lookup';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Created By (Delegate)',
                        ENG='Created By (Delegate)';
            Description = 'Shows who created the record on behalf of another user.';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(68;CreatedOnBehalfByName;Text[200])
        {
            ExternalName='createdonbehalfbyname';
                                                   ExternalType='String';
                                                   ExternalAccess=Read;
            CalcFormula = Lookup("CRM Systemuser".FullName WHERE (SystemUserId=FIELD(CreatedOnBehalfBy)));
            CaptionML = ENU='CreatedOnBehalfByName',
                        ENG='CreatedOnBehalfByName';
            FieldClass = FlowField;
        }
        field(69;ModifiedOnBehalfBy;Guid)
        {
             ExternalName='modifiedonbehalfby';
                                                   ExternalType='Lookup';
                                                   ExternalAccess=Read;
            CaptionML = ENU='Modified By (Delegate)',
                        ENG='Modified By (Delegate)';
            Description = 'Shows who last updated the record on behalf of another user.';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(70;ModifiedOnBehalfByName;Text[200])
        {
            ExternalName='modifiedonbehalfbyname';
                                                   ExternalType='String';
                                                   ExternalAccess=Read;
            CalcFormula = Lookup("CRM Systemuser".FullName WHERE (SystemUserId=FIELD(ModifiedOnBehalfBy)));
            CaptionML = ENU='ModifiedOnBehalfByName',
                        ENG='ModifiedOnBehalfByName';
            FieldClass = FlowField;
        }
        field(71;SequenceNumber;Integer)
        {
            ExternalName='sequencenumber';
                                                   ExternalType='Integer';
            CaptionML = ENU='Sequence Number',
                        ENG='Sequence Number';
            Description = 'Shows the ID of the data that maintains the sequence.';
        }
        field(72;ParentBundleId;Guid)
        {
            ExternalName='parentbundleid';
                                                   ExternalType='Uniqueidentifier';
                                                   ExternalAccess=Insert;
            CaptionML = ENU='Parent Bundle',
                        ENG='Parent Bundle';
            Description = 'Choose the parent bundle associated with this product';
        }
        field(73;ProductTypeCode;Option)
        {
            ExternalName='producttypecode';
                                                   ExternalType='Picklist';
                                                   ExternalAccess=Insert;
            CaptionML = ENU='Product type',
                        ENG='Product type';
            Description = 'Product Type';
            InitValue = Product;
            OptionCaptionML = ENU='Product,Bundle,Required Bundle Product,Optional Bundle Product',
                              ENG='Product,Bundle,Required Bundle Product,Optional Bundle Product';
            OptionMembers = Product,Bundle,RequiredBundleProduct,OptionalBundleProduct;
        }
        field(74;PropertyConfigurationStatus;Option)
        {
             ExternalName='propertyconfigurationstatus';
                                                   ExternalType='Picklist';
            CaptionML = ENU='Property Configuration',
                        ENG='Property Configuration';
            Description = 'Status of the property configuration.';
            InitValue = NotConfigured;
            OptionCaptionML = ENU='Edit,Rectify,NotConfigured',
                              ENG='Edit,Rectify,NotConfigured';
            OptionMembers = Edit,Rectify,NotConfigured;
        }
        field(75;ProductAssociationId;Guid)
        {
            ExternalName='productassociationid';
                                                   ExternalType='Uniqueidentifier';
                                                   ExternalAccess=Insert;
            CaptionML = ENU='Bundle Item Association',
                        ENG='Bundle Item Association';
            Description = 'Unique identifier of the product line item association with bundle in the sales order';
        }
       
    }
    keys
    {
        key(Key1;SalesOrderDetailId)
        {
        }
    }

    fieldgroups
    {
 
    }
}

