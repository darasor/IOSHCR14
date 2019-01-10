codeunit 60011 iOSH_CreateCRMSalesInvoice
{
    TableNo = 112;

    trigger OnRun();
    var
        CRMSalesInv: Record "CRM Invoice";

    begin

        if NOT CreateInCRM(Rec, CRMSalesInv) then
            Message('Error during creating Sales Invoice was %1', GetLastErrorText());

    end;

    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        CustMgt: Codeunit "IOSH_Customer Management";
        TIS_CRMTypeHelper: Codeunit TIS_CRMHelper;
        ItemDoesNotExistErr: TextConst Comment = '%1= the text: "The sales order cannot be created.", %2=product name', ENU = '%1 The item %2 does not exist.', ENG = '%1 The item %2 does not exist.';
        NoCustomerErr: TextConst Comment = '%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=sales order title, %3 - Microsoft Dynamics CRM', ENU = '%1 There is no potential customer defined on the %3 sales order %2.', ENG = '%1 There is no potential customer defined on the %3 sales order %2.';
        CRMSynchHelper: Codeunit 5342;
        CRMProductName: Codeunit 5344;
        LastSalesLineNo: Integer;
        NotCoupledCustomerErr: TextConst Comment = '%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=account name, %3 - Microsoft Dynamics CRM', ENU = '%1 There is no customer coupled to %3 account %2.', ENG = '%1 There is no customer coupled to %3 account %2.';
        NotCoupledCRMProductErr: TextConst Comment = '%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=product name, %3 - Microsoft Dynamics CRM', ENU = '%1 The %3 product %2 is not coupled to an item.', ENG = '%1 The %3 product %2 is not coupled to an item.';
        NotCoupledCRMResourceErr: TextConst Comment = '%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=resource name, %3 - Microsoft Dynamics CRM', ENU = '%1 The %3 resource %2 is not coupled to a resource.', ENG = '%1 The %3 resource %2 is not coupled to a resource.';
        NotCoupledCRMSalesOrderErr: TextConst Comment = '%1=sales order number, %2 - Microsoft Dynamics CRM', ENU = 'The %2 sales order %1 is not coupled.', ENG = 'The %2 sales order %1 is not coupled.';
        NotCoupledSalesHeaderErr: TextConst Comment = '%1=sales order number, %2 - Microsoft Dynamics CRM', ENU = 'The sales order %1 is not coupled to %2.', ENG = 'The sales order %1 is not coupled to %2.';
        OverwriteCRMDiscountQst: TextConst Comment = '%1 - product name, %2 - Microsoft Dynamics CRM', ENU = 'There is a discount on the %2 sales order, which will be overwritten by %1 settings. You will have the possibility to update the discounts directly on the sales order, after it is created. Do you want to continue?', ENG = 'There is a discount on the %2 sales order, which will be overwritten by %1 settings. You will have the possibility to update the discounts directly on the sales order, after it is created. Do you want to continue?';
        ResourceDoesNotExistErr: TextConst Comment = '%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=product name', ENU = '%1 The resource %2 does not exist.', ENG = '%1 The resource %2 does not exist.';
        UnexpectedProductTypeErr: TextConst Comment = '%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=product name', ENU = '%1 Unexpected value of product type code for product %2. The supported values are: sales inventory, services.', ENG = '%1 Unexpected value of product type code for product %2. The supported values are: sales inventory, services.';
        ZombieCouplingErr: TextConst Comment = '%1 - product name, %2 - Microsoft Dynamics CRM', ENU = 'Although the coupling from %2 exists, the sales order had been manually deleted. If needed, please use the menu to create it again in %1.', ENG = 'Although the coupling from %2 exists, the sales order had been manually deleted. If needed, please use the menu to create it again in %1.';
        CustomerHasChangedErr: TextConst Comment = 'Cannot create the invoice in %2. The customer from the original %2 sales order %1 was changed or is no longer coupled.', ENU = 'Cannot create the invoice in %2. The customer from the original %2 sales order %1 was changed or is no longer coupled.';
        NoCoupledSalesInvoiceHeaderErr: TextConst Comment = 'Cannot find the coupled %1 invoice header.', ENU = 'Cannot find the coupled %1 invoice header.';
        CannotFindSyncedProductErr: TextConst Comment = 'Cannot find synchronize the product %1.', ENU = 'Cannot find synchronize the product %1.';

    local procedure ApplySalesOrderDiscounts(CRMSalesorder: Record 60007; var SalesHeader: Record 36);
    var
        SalesCalcDiscountByType: Codeunit 56;
        CRMDiscountAmount: Decimal;
    begin
        // No discounts to apply
        IF (CRMSalesorder.DiscountAmount = 0) AND (CRMSalesorder.DiscountPercentage = 0) THEN
            EXIT;

        // Attempt to set the discount, if NAV general and customer settings allow it
        // Using CRM discounts
        CRMDiscountAmount := CRMSalesorder.TotalLineItemAmount - CRMSalesorder.TotalAmountLessFreight;
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(CRMDiscountAmount, SalesHeader);

        // NAV settings (in G/L Setup as well as per-customer discounts) did not allow using the CRM discounts
        // Using NAV discounts
        // But the user will be able to manually update the discounts after the order is created in NAV
        IF NOT CONFIRM(STRSUBSTNO(OverwriteCRMDiscountQst, PRODUCTNAME.SHORT, CRMProductName.SHORT), TRUE) THEN
            ERROR('');
    end;

    local procedure CopyCRMOptionFields(var CRMSalesInv: Record 5355; SalesHeader: Record 112);
    var
        CRMAccount: Record "CRM Account";
        CRMOptionMapping: Record "CRM Option Mapping";
    begin
        case SalesHeader."Shipping Agent Code" of
            'Airborne':
                CRMSalesInv.ShippingMethodCode := CRMSalesInv.ShippingMethodCode::Airborne;
            'DHL':
                CRMSalesInv.ShippingMethodCode := CRMSalesInv.ShippingMethodCode::DHL;
            'FedEx':
                CRMSalesInv.ShippingMethodCode := CRMSalesInv.ShippingMethodCode::FedEx;
            'FullLoad':
                CRMSalesInv.ShippingMethodCode := CRMSalesInv.ShippingMethodCode::FullLoad;
            'PostalMail':
                CRMSalesInv.ShippingMethodCode := CRMSalesInv.ShippingMethodCode::PostalMail;
            'UPS':
                CRMSalesInv.ShippingMethodCode := CRMSalesInv.ShippingMethodCode::UPS;
            'WillCall':
                CRMSalesInv.ShippingMethodCode := CRMSalesInv.ShippingMethodCode::WillCall;
            else
                CRMSalesInv.ShippingMethodCode := CRMSalesInv.ShippingMethodCode::" ";
        end;

        case SalesHeader."Payment Terms Code" of
            '2%10Net30':
                CRMSalesInv.PaymentTermsCode := CRMSalesInv.PaymentTermsCode::"2%10Net30";
            'Net30':
                CRMSalesInv.PaymentTermsCode := CRMSalesInv.PaymentTermsCode::Net30;
            'Net45':
                CRMSalesInv.PaymentTermsCode := CRMSalesInv.PaymentTermsCode::Net45;
            'Net60':
                CRMSalesInv.PaymentTermsCode := CRMSalesInv.PaymentTermsCode::Net60;
            else
                CRMSalesInv.PaymentTermsCode := CRMSalesInv.PaymentTermsCode::" ";
        end;



    end;

    procedure CopyBillToInformationIfNotEmpty(var CRMSalesInv: Record 5355; SalesHeader: Record 112);
    begin
        // If the Bill-To fields in CRM are all empty, then let NAV keep its standard behavior (takes Bill-To from the Customer information)
        CRMSalesInv.BillTo_Name := SalesHeader."Bill-to Name";
        CRMSalesInv.BillTo_Line1 := SalesHeader."Bill-to Address";
        CRMSalesInv.BillTo_Line2 := SalesHeader."Bill-to Address 2";
        CRMSalesInv.BillTo_City := SalesHeader."Bill-to City";
        CRMSalesInv.BillTo_PostalCode := SalesHeader."Bill-to Post Code";
        CRMSalesInv.BillTo_Country := SalesHeader."Bill-to Country/Region Code";
        CRMSalesInv.BillTo_StateOrProvince := SalesHeader."Bill-to County";
    end;

    procedure CopyShipToInformationIfNotEmpty(var CRMSalesInv: Record 5355; SalesHeader: Record 112);
    begin
        CRMSalesInv.ShipTo_Name := SalesHeader."Ship-to Name";
        CRMSalesInv.ShipTo_Line1 := SalesHeader."Ship-to Address";
        CRMSalesInv.ShipTo_Line2 := SalesHeader."Ship-to Address 2";
        CRMSalesInv.ShipTo_City := SalesHeader."Ship-to City";
        CRMSalesInv.ShipTo_PostalCode := SalesHeader."Ship-to Post Code";
        CRMSalesInv.ShipTo_Country := SalesHeader."Ship-to Country/Region Code";
        CRMSalesInv.ShipTo_StateOrProvince := SalesHeader."Ship-to County";
    end;

    [Scope('Personalization')]
    procedure CreateInCRM(SalesHeader: Record 112; var CRMSaleInvoice: Record 5355): Boolean;
    var
        CRMIntegrationRecord: Record 5331;
        CRMSalesInvID: Guid;
    begin
        //if it's already couple then
        IF CRMIntegrationRecord.FindIDFromRecordID(SalesHeader.RecordId(), CRMSalesInvID) THEN
            if not IsNullGuid(CRMSalesInvID) then
                EXIT(true)
            else
                CRMIntegrationRecord.RemoveCouplingToRecord(SalesHeader.RecordId());

        CreateSalesInvoiceHeader(CRMSaleInvoice, SalesHeader);
        //CreateSalesInvoiceLines(CRMSaleInvoice, SalesHeader); //TODO
        CRMIntegrationRecord.CoupleRecordIdToCRMID(SalesHeader.RECORDID(), CRMSaleInvoice.InvoiceId);
        CreateSalesInvoiceLines(CRMSaleInvoice, SalesHeader); //TODO
        // // Flag sales order has been submitted to NAV.
        SetLastBackOfficeSubmit(CRMSaleInvoice, TODAY);
        EXIT(TRUE);
    end;

    local procedure CreateSalesInvoiceHeader(var CRMSaleInvoice: Record 5355; SalesHeader: Record 112);
    var
        Customer: Record 18;
        CRMTransactioncurrency: Record "CRM Transactioncurrency";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SourceRecRef: RecordRef;
        DestinationRecRef: RecordRef;
        OwnerGuid: Guid;
    begin
        CRMSaleInvoice.INIT();
        CRMSaleInvoice.VALIDATE(InvoiceNumber, SalesHeader."No.");
        CRMSaleInvoice.VALIDATE(OwnerIdType, CRMSaleInvoice.OwnerIdType::systemuser);
        //CRMSaleInvoice.Validate(CustomerIdType, CRMSaleInvoice.CustomerIdType::contact);

        SalespersonPurchaser.SETFILTER(Code, SalesHeader."Salesperson Code");
        if SalespersonPurchaser.FindFirst() then
            if CRMIntegrationRecord.FindIDFromRecordID(SalespersonPurchaser.RecordId(), OwnerGuid) then
                CRMSaleInvoice.Validate(CRMSaleInvoice.OwnerId, OwnerGuid); //Need to convert this to GUID

        CRMTransactioncurrency.SetRange(CurrencyName, SalesHeader."Currency Code");
        if CRMTransactioncurrency.FindFirst() then
            CRMSaleInvoice.TransactionCurrencyId := CRMTransactioncurrency.TransactionCurrencyId; //Need to covnert to GUID

        CRMSaleInvoice.DueDate := SalesHeader."Due Date";
        CRMSaleInvoice.DateDelivered := SalesHeader."Shipment Date";
        CopyBillToInformationIfNotEmpty(CRMSaleInvoice, SalesHeader);
        CopyShipToInformationIfNotEmpty(CRMSaleInvoice, SalesHeader);

        CRMSaleInvoice.TotalAmountLessFreight := SalesHeader.amount;
        CRMSaleInvoice.TotalAmount := SalesHeader."Amount Including VAT";
        CRMSaleInvoice.DiscountAmount := SalesHeader."Invoice Discount Amount";

        CopyCRMOptionFields(CRMSaleInvoice, SalesHeader);
        //RecordRef.GET(SalesHeader.RecordID);
        UpdateCRMInvoiceBeforeInsertRecord(SalesHeader, CRMSaleInvoice);
        CRMSaleInvoice.INSERT();
        UpdateCRMInvoiceAfterInsertRecord(SalesHeader, CRMSaleInvoice);
    end;

    local procedure CreateSalesInvoiceLines(var CRMSaleInvoice: Record 5355; SalesHeader: Record 112);
    var
        CRMSalesInvdetail: Record 5356;
        SalesLine: Record 113;
    begin
        // If any of the products on the lines are not found in NAV, err
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        IF SalesLine.FINDSET() THEN
            REPEAT
                InitializeSalesInvLine(CRMSalesInvdetail, SalesHeader, SalesLine);
                UpdateCRMInvoiceDetailsBeforeInsertRecord(SalesLine, CRMSalesInvdetail);
                CRMSalesInvdetail.INSERT();
                UpdateCRMInvoiceDetailsAfterInsertRecord(SalesLine, CRMSalesInvdetail);

            UNTIL SalesLine.NEXT() = 0;
    end;

    procedure UpdateCRMInvoiceAfterInsertRecord(SalesInvoiceHeader: Record 112; var CRMInvoice: Record 5355);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SourceLinesRecordRef: RecordRef;
        CRMIntegrationTableSynch: Codeunit "CRM Integration Table Synch.";
    begin
        //SourceRecordRef.SETTABLE(SalesInvoiceHeader);
        //DestinationRecordRef.SETTABLE(CRMInvoice);

        SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        IF NOT SalesInvoiceLine.ISEMPTY() THEN BEGIN
            SourceLinesRecordRef.GETTABLE(SalesInvoiceLine);
            //CRMIntegrationTableSynch.SynchRecordsToIntegrationTable(SourceLinesRecordRef,FALSE,FALSE);
            SalesInvoiceLine.CALCSUMS("Line Discount Amount");
            CRMInvoice.TotalLineItemDiscountAmount := SalesInvoiceLine."Line Discount Amount";
        END;

        CRMInvoice.FreightAmount := 0;
        CRMInvoice.DiscountPercentage := 0;
        CRMInvoice.TotalTax := CRMInvoice.TotalAmount - CRMInvoice.TotalAmountLessFreight;
        CRMInvoice.TotalDiscountAmount := CRMInvoice.DiscountAmount + CRMInvoice.TotalLineItemDiscountAmount;
        CRMInvoice.MODIFY();
        CRMSynchHelper.UpdateCRMInvoiceStatus(CRMInvoice, SalesInvoiceHeader);

        CRMSynchHelper.SetSalesInvoiceHeaderCoupledToCRM(SalesInvoiceHeader);
    end;

    procedure UpdateCRMInvoiceBeforeInsertRecord(SalesInvoiceHeader: Record 112; var CRMInvoice: Record 5355);
    var
        ShipmentMethod: Record "Shipment Method";
        CRMSalesOrder: Record IOSH_CRMSaleOrder;
        CRMContact: Record "CRM Contact";
        Customer: Record Customer;
        Contact: Record contact;
        TypeHelper: Codeunit "Type Helper";
        CRMSalesOrderToSalesOrder: Codeunit "CRM Sales Order to Sales Order";
        IOSH_CRMSalesOrderToSalesOrder: Codeunit iOSH_CRMSalesOrderToSalesOrder;
        DestinationFieldRef: FieldRef;
        DestinationRecordRef: RecordRef;
        AccountId: Guid;
    begin

        //SourceRecordRef.SETTABLE(SalesInvoiceHeader);
        // Shipment Method Code -> go to table Shipment Method, and from there extract the description and add it to
        // IF ShipmentMethod.GET(SalesInvoiceHeader."Shipment Method Code") THEN BEGIN
        //     DestinationFieldRef := DestinationRecordRef.FIELD(CRMInvoice.FIELDNO(Description));
        //     TypeHelper.WriteTextToBlobIfChanged(DestinationFieldRef, ShipmentMethod.Description, TEXTENCODING::UTF16);
        // END;

        //DestinationRecordRef.SETTABLE(CRMInvoice);
        IF IOSH_CRMSalesOrderToSalesOrder.GetCRMSalesOrder(CRMSalesorder, SalesInvoiceHeader."Your Reference") THEN BEGIN
            CRMInvoice.OpportunityId := CRMSalesorder.OpportunityId;
            CRMInvoice.SalesOrderId := CRMSalesorder.SalesOrderId;
            CRMInvoice.PriceLevelId := CRMSalesorder.PriceLevelId;
            CRMInvoice.Name := CRMSalesorder.Name;


            IF NOT IOSH_CRMSalesOrderToSalesOrder.GetCRMContactOfCRMSalesOrder(CRMSalesorder, CRMContact) THEN
                ERROR(CustomerHasChangedErr, CRMSalesorder.OrderNumber, CRMProductName.SHORT);
            // IF NOT CRMSynchHelper.SynchRecordIfMappingExists(DATABASE::"CRM Contact",CRMContact.AccountId) THEN
            // ERROR(CustomerHasChangedErr,CRMSalesorder.OrderNumber,CRMProductName.SHORT);

            // IF Customer."No." <> SalesInvoiceHeader."Sell-to Customer No." THEN
            //     ERROR(CustomerHasChangedErr,CRMSalesorder.OrderNumber,CRMProductName.SHORT);
            CRMInvoice.CustomerId := CRMSalesorder.CustomerId;
            CRMInvoice.CustomerIdType := CRMSalesorder.CustomerIdType;
        END ELSE BEGIN
            CRMInvoice.Name := SalesInvoiceHeader."No.";
            Customer.GET(SalesInvoiceHeader."Sell-to Customer No.");
            Contact.SetRange("No.", Customer."Contact No");
            if Contact.FindFirst() then
                IF NOT CRMIntegrationRecord.FindIDFromRecordID(Contact.RECORDID, AccountId) THEN
                    //IF NOT CRMSynchHelper.SynchRecordIfMappingExists(DATABASE::Customer,Customer.RECORDID) THEN
                    ERROR(CustomerHasChangedErr, CRMSalesorder.OrderNumber, CRMProductName.SHORT);

            CRMInvoice.CustomerId := AccountId;
            CRMInvoice.CustomerIdType := CRMInvoice.CustomerIdType::contact;
            // IF NOT CRMSynchHelper.FindCRMPriceListByCurrencyCode(CRMPricelevel,SalesInvoiceHeader."Currency Code") THEN
            //     CRMSynchHelper.CreateCRMPricelevelInCurrency(
            //     CRMPricelevel,SalesInvoiceHeader."Currency Code",SalesInvoiceHeader."Currency Factor");
            // CRMInvoice.PriceLevelId := CRMPricelevel.PriceLevelId;
        END;
        DestinationRecordRef.GETTABLE(CRMInvoice);
    end;

    procedure UpdateCRMInvoiceDetailsBeforeInsertRecord(SalesInvoiceLine: Record "Sales Invoice Line"; VAR CRMInvoicedetail: Record "CRM Invoicedetail");
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CRMSalesInvoiceHeaderId: Guid;
    begin

        //SourceRecordRef.SETTABLE(SalesInvoiceLine);
        //DestinationRecordRef.SETTABLE(CRMInvoicedetail);

        // Get the NAV and CRM invoice headers
        SalesInvoiceHeader.GET(SalesInvoiceLine."Document No.");
        IF NOT CRMIntegrationRecord.FindIDFromRecordID(SalesInvoiceHeader.RECORDID, CRMSalesInvoiceHeaderId) THEN
            ERROR(NoCoupledSalesInvoiceHeaderErr, CRMProductName.SHORT);

        // Initialize the CRM invoice lines
        InitializeCRMInvoiceLineFromCRMHeader(CRMInvoicedetail, CRMSalesInvoiceHeaderId);
        InitializeCRMInvoiceLineFromSalesInvoiceHeader(CRMInvoicedetail, SalesInvoiceHeader);
        InitializeCRMInvoiceLineFromSalesInvoiceLine(CRMInvoicedetail, SalesInvoiceLine);
        InitializeCRMInvoiceLineWithProductDetails(CRMInvoicedetail, SalesInvoiceLine);

        //CRMSynchHelper.CreateCRMProductpriceIfAbsent(CRMInvoicedetail);
        //DestinationRecordRef.GETTABLE(CRMInvoicedetail);
    end;

    procedure UpdateCRMInvoiceDetailsAfterInsertRecord(SalesInvoiceLine: Record "Sales Invoice Line"; VAR CRMInvoicedetail: Record "CRM Invoicedetail")
    var
    begin
        //SourceRecordRef.SETTABLE(SalesInvoiceLine);
        //DestinationRecordRef.SETTABLE(CRMInvoicedetail);

        CRMInvoicedetail.VolumeDiscountAmount := 0;
        CRMInvoicedetail.ManualDiscountAmount := SalesInvoiceLine."Line Discount Amount";
        CRMInvoicedetail.Tax := SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine.Amount;
        CRMInvoicedetail.BaseAmount :=
          SalesInvoiceLine.Amount + SalesInvoiceLine."Inv. Discount Amount" + SalesInvoiceLine."Line Discount Amount";
        CRMInvoicedetail.ExtendedAmount :=
          SalesInvoiceLine."Amount Including VAT" + SalesInvoiceLine."Inv. Discount Amount";
        CRMInvoicedetail.MODIFY();

        //DestinationRecordRef.GETTABLE(CRMInvoicedetail);
    end;

    procedure InitializeCRMInvoiceLineFromCRMHeader(VAR CRMInvoicedetail: Record "CRM Invoicedetail"; CRMInvoiceId: GUID);
    var
        CRMInvoice: Record "CRM Invoice";
    begin
        CRMInvoice.GET(CRMInvoiceId);
        CRMInvoicedetail.ActualDeliveryOn := CRMInvoice.DateDelivered;
        CRMInvoicedetail.TransactionCurrencyId := CRMInvoice.TransactionCurrencyId;
        CRMInvoicedetail.ExchangeRate := CRMInvoice.ExchangeRate;
        CRMInvoicedetail.InvoiceId := CRMInvoice.InvoiceId;
        CRMInvoicedetail.ShipTo_City := CRMInvoice.ShipTo_City;
        CRMInvoicedetail.ShipTo_Country := CRMInvoice.ShipTo_Country;
        CRMInvoicedetail.ShipTo_Line1 := CRMInvoice.ShipTo_Line1;
        CRMInvoicedetail.ShipTo_Line2 := CRMInvoice.ShipTo_Line2;
        CRMInvoicedetail.ShipTo_Line3 := CRMInvoice.ShipTo_Line3;
        CRMInvoicedetail.ShipTo_Name := CRMInvoice.ShipTo_Name;
        CRMInvoicedetail.ShipTo_PostalCode := CRMInvoice.ShipTo_PostalCode;
        CRMInvoicedetail.ShipTo_StateOrProvince := CRMInvoice.ShipTo_StateOrProvince;
        CRMInvoicedetail.ShipTo_Fax := CRMInvoice.ShipTo_Fax;
        CRMInvoicedetail.ShipTo_Telephone := CRMInvoice.ShipTo_Telephone;
    end;

    procedure InitializeCRMInvoiceLineFromSalesInvoiceHeader(VAR CRMInvoicedetail: Record "CRM Invoicedetail"; SalesInvoiceHeader: Record "Sales Invoice Header");
    var
    begin
        CRMInvoicedetail.TransactionCurrencyId := TIS_CRMTypeHelper.GetCRMTransactioncurrency(SalesInvoiceHeader."Currency Code");
        IF SalesInvoiceHeader."Currency Factor" = 0 THEN
            CRMInvoicedetail.ExchangeRate := 1
        ELSE
            CRMInvoicedetail.ExchangeRate := ROUND(1 / SalesInvoiceHeader."Currency Factor");
    end;

    procedure InitializeCRMInvoiceLineFromSalesInvoiceLine(VAR CRMInvoicedetail: Record "CRM Invoicedetail"; SalesInvoiceLine: Record "Sales Invoice Line");
    var
    begin
        CRMInvoicedetail.LineItemNumber := SalesInvoiceLine."Line No.";
        CRMInvoicedetail.Tax := SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine.Amount;
    end;

    procedure InitializeCRMInvoiceLineWithProductDetails(VAR CRMInvoicedetail: Record "CRM Invoicedetail"; SalesInvoiceLine: Record "Sales Invoice Line");
    var
        CRMProduct: Record "CRM Product";
        CRMProductId: Guid;
    begin
        CRMProductId := FindCRMProductId(SalesInvoiceLine);
        IF ISNULLGUID(CRMProductId) THEN BEGIN
            // This will be created as a CRM write-in product
            CRMInvoicedetail.IsProductOverridden := TRUE;
            CRMInvoicedetail.ProductDescription :=
                STRSUBSTNO('%1 %2.', FORMAT(SalesInvoiceLine."No."), FORMAT(SalesInvoiceLine.Description));
        END ELSE BEGIN
            // There is a coupled product or resource in CRM, transfer data from there
            CRMProduct.GET(CRMProductId);
            CRMInvoicedetail.ProductId := CRMProduct.ProductId;
            CRMInvoicedetail.UoMId := CRMProduct.DefaultUoMId;
        END;
    end;

    procedure FindCRMProductId(SalesInvoiceLine: Record "Sales Invoice Line") CRMID: GUID;
    var
        Resource: Record Resource;
    begin
        CLEAR(CRMID);
        CASE SalesInvoiceLine.Type OF
            SalesInvoiceLine.Type::Item:
                CRMID := FindCRMProductIdForItem(SalesInvoiceLine."No.");
            SalesInvoiceLine.Type::Resource:
                BEGIN
                    Resource.GET(SalesInvoiceLine."No.");
                    IF NOT CRMIntegrationRecord.FindIDFromRecordID(Resource.RECORDID, CRMID) THEN BEGIN
                        //IF NOT CRMSynchHelper.SynchRecordIfMappingExists(DATABASE::Resource,Resource.RECORDID) THEN
                        //ERROR(CannotSynchProductErr,Resource."No.");
                        IF NOT CRMIntegrationRecord.FindIDFromRecordID(Resource.RECORDID, CRMID) THEN
                            ERROR(CannotFindSyncedProductErr);
                    END;
                END;
        END;
    end;

    procedure FindCRMProductIdForItem(ItemNo: Code[20]) CRMID: GUID;
    var
        Item: Record Item;
    begin
        Item.GET(ItemNo);
        //IF NOT CRMIntegrationRecord.FindIDFromRecordID(Item.RECORDID,CRMID) THEN BEGIN
        //IF NOT CRMSynchHelper.SynchRecordIfMappingExists(DATABASE::Item,Item.RECORDID) THEN
        //   ERROR(CannotSynchProductErr,Item."No.");
        IF NOT CRMIntegrationRecord.FindIDFromRecordID(Item.RECORDID, CRMID) THEN
            ERROR(CannotFindSyncedProductErr);
        //END;
    end;

    [Scope('Personalization')]
    procedure GetCoupledCRMSalesorder(SalesHeader: Record 36; var CRMSalesorder: Record 60007);
    var
        CRMIntegrationRecord: Record 5331;
        CoupledCRMId: Guid;
    begin
        IF SalesHeader.ISEMPTY THEN
            ERROR(NotCoupledSalesHeaderErr, SalesHeader."No.", CRMProductName.SHORT);

        IF NOT CRMIntegrationRecord.FindIDFromRecordID(SalesHeader.RECORDID, CoupledCRMId) THEN
            ERROR(NotCoupledSalesHeaderErr, SalesHeader."No.", CRMProductName.SHORT);

        IF CRMSalesorder.GET(CoupledCRMId) THEN
            EXIT;

        // If we reached this point, a zombie coupling exists but the sales order most probably was deleted manually by the user.
        CRMIntegrationRecord.RemoveCouplingToCRMID(CoupledCRMId, DATABASE::"Sales Header");
        ERROR(ZombieCouplingErr, PRODUCTNAME.SHORT, CRMProductName.SHORT);
    end;

    [Scope('Personalization')]
    procedure GetCoupledSalesHeader(CRMSalesorder: Record 60007; var SalesHeader: Record 36): Boolean;
    var
        CRMIntegrationRecord: Record 5331;
        NAVSalesHeaderRecordId: RecordID;
    begin
        IF ISNULLGUID(CRMSalesorder.SalesOrderId) THEN
            ERROR(NotCoupledCRMSalesOrderErr, CRMSalesorder.OrderNumber, CRMProductName.SHORT);

        // Attempt to find the coupled sales header
        IF NOT CRMIntegrationRecord.FindRecordIDFromID(CRMSalesorder.SalesOrderId, DATABASE::"Sales Header", NAVSalesHeaderRecordId) THEN
            ERROR(NotCoupledCRMSalesOrderErr, CRMSalesorder.OrderNumber, CRMProductName.SHORT);

        IF SalesHeader.GET(NAVSalesHeaderRecordId) THEN
            EXIT(TRUE);

        // If we reached this point, a zombie coupling exists but the sales order most probably was deleted manually by the user.
        CRMIntegrationRecord.RemoveCouplingToCRMID(CRMSalesorder.SalesOrderId, DATABASE::"Sales Header");
        ERROR(ZombieCouplingErr, PRODUCTNAME.SHORT, CRMProductName.SHORT);
    end;

    local procedure InitializeSalesInvLine(var CRMSalesInvdetail: Record 5356; SalesHeader: Record 112; SalesLine: Record 113);
    var

    begin
        CRMSalesInvdetail.Init();
        CRMSalesInvdetail.Quantity := SalesLine.Quantity;
        //CRMSalesInvdetail.ManualDiscountAmount := SalesLine."Line Discount Amount";
        CRMSalesInvdetail.PricePerUnit := SalesLine."Unit Price";
        CRMSalesInvdetail.IsPriceOverridden := true;
        //CRMSalesInvdetail.BaseAmount := SalesLine.Amount;
        //CRMSalesInvdetail.ExtendedAmount := SalesLine."Amount Including VAT";
        // SalesLine.VALIDATE(
        //   "Line Discount Amount",
        //   CRMSalesorderdetail.Quantity * CRMSalesorderdetail.VolumeDiscountAmount +
        //   CRMSalesorderdetail.ManualDiscountAmount);
    end;

    local procedure SetLastBackOfficeSubmit(var CRMInv: Record 5355; NewDate: Date);
    var
        CRMSalesInvoice: Record "CRM Invoice";
    begin
        if CRMSalesInvoice.get(CRMInv.InvoiceId) then
            IF CRMSalesInvoice.LastBackofficeSubmit <> NewDate THEN BEGIN
                CRMSalesInvoice.LastBackofficeSubmit := NewDate;
                CRMSalesInvoice.MODIFY(TRUE);
            END;
    end;

}