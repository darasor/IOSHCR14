codeunit 60012 iOSH_CRMSalesOrderToSalesOrder
{
    TableNo = 60007;
    //Permissions = TableData 60007=rimd;
    
    trigger OnRun();
    var
        SalesHeader : Record 36;
    begin
        CreateInNAV(Rec,SalesHeader);
    end;

    var
        CannotCreateSalesOrderInNAVTxt : TextConst ENU='The sales order cannot be created.',ENG='The sales order cannot be created.';
        CannotFindCRMAccountForOrderErr : TextConst Comment='%1=Dynamics CRM Sales Order Name, %2 - Microsoft Dynamics CRM',ENU='The %2 account for %2 sales order %1 does not exist.',ENG='The %2 account for %2 sales order %1 does not exist.';
        ItemDoesNotExistErr : TextConst Comment='%1= the text: "The sales order cannot be created.", %2=product name',ENU='%1 The item %2 does not exist.',ENG='%1 The item %2 does not exist.';
        NoCustomerErr : TextConst Comment='%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=sales order title, %3 - Microsoft Dynamics CRM',ENU='%1 There is no potential customer defined on the %3 sales order %2.',ENG='%1 There is no potential customer defined on the %3 sales order %2.';
        CRMSynchHelper : Codeunit 5342;
        CRMProductName : Codeunit 5344;
        LastSalesLineNo : Integer;
        NotCoupledCustomerErr : TextConst Comment='%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=account name, %3 - Microsoft Dynamics CRM',ENU='%1 There is no customer coupled to %3 account %2.',ENG='%1 There is no customer coupled to %3 account %2.';
        NotCoupledCRMProductErr : TextConst Comment='%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=product name, %3 - Microsoft Dynamics CRM',ENU='%1 The %3 product %2 is not coupled to an item.',ENG='%1 The %3 product %2 is not coupled to an item.';
        NotCoupledCRMResourceErr : TextConst Comment='%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=resource name, %3 - Microsoft Dynamics CRM',ENU='%1 The %3 resource %2 is not coupled to a resource.',ENG='%1 The %3 resource %2 is not coupled to a resource.';
        NotCoupledCRMSalesOrderErr : TextConst Comment='%1=sales order number, %2 - Microsoft Dynamics CRM',ENU='The %2 sales order %1 is not coupled.',ENG='The %2 sales order %1 is not coupled.';
        NotCoupledSalesHeaderErr : TextConst Comment='%1=sales order number, %2 - Microsoft Dynamics CRM',ENU='The sales order %1 is not coupled to %2.',ENG='The sales order %1 is not coupled to %2.';
        OverwriteCRMDiscountQst : TextConst Comment='%1 - product name, %2 - Microsoft Dynamics CRM',ENU='There is a discount on the %2 sales order, which will be overwritten by %1 settings. You will have the possibility to update the discounts directly on the sales order, after it is created. Do you want to continue?',ENG='There is a discount on the %2 sales order, which will be overwritten by %1 settings. You will have the possibility to update the discounts directly on the sales order, after it is created. Do you want to continue?';
        ResourceDoesNotExistErr : TextConst Comment='%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=product name',ENU='%1 The resource %2 does not exist.',ENG='%1 The resource %2 does not exist.';
        UnexpectedProductTypeErr : TextConst Comment='%1= the text: "The Dynamics CRM Sales Order cannot be created.", %2=product name',ENU='%1 Unexpected value of product type code for product %2. The supported values are: sales inventory, services.',ENG='%1 Unexpected value of product type code for product %2. The supported values are: sales inventory, services.';
        ZombieCouplingErr : TextConst Comment='%1 - product name, %2 - Microsoft Dynamics CRM',ENU='Although the coupling from %2 exists, the sales order had been manually deleted. If needed, please use the menu to create it again in %1.',ENG='Although the coupling from %2 exists, the sales order had been manually deleted. If needed, please use the menu to create it again in %1.';

    local procedure ApplySalesOrderDiscounts(CRMSalesorder : Record 60007;var SalesHeader : Record 36);
    var
        SalesCalcDiscountByType : Codeunit 56;
        CRMDiscountAmount : Decimal ;
    begin
        // No discounts to apply
        IF (CRMSalesorder.DiscountAmount = 0 ) AND (CRMSalesorder.DiscountPercentage = 0) THEN
          EXIT;

        // Attempt to set the discount, if NAV general and customer settings allow it
        // Using CRM discounts
        CRMDiscountAmount := CRMSalesorder.TotalLineItemAmount - CRMSalesorder.TotalAmountLessFreight;
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(CRMDiscountAmount,SalesHeader);

        // NAV settings (in G/L Setup as well as per-customer discounts) did not allow using the CRM discounts
        // Using NAV discounts
        // But the user will be able to manually update the discounts after the order is created in NAV
        IF NOT CONFIRM(STRSUBSTNO(OverwriteCRMDiscountQst,PRODUCTNAME.SHORT,CRMProductName.SHORT),TRUE) THEN
          ERROR('');
    end;

    local procedure CopyCRMOptionFields(CRMSalesorder : Record 60007;var SalesHeader : Record 36);
    var
        CRMAccount : Record "CRM Account";
        CRMOptionMapping : Record "CRM Option Mapping";
    begin
        IF CRMOptionMapping.FindRecordID(
             DATABASE::"CRM Account",CRMAccount.FIELDNO(Address1_ShippingMethodCode),CRMSalesorder.ShippingMethodCode)
        THEN
          SalesHeader.VALIDATE(
            "Shipping Agent Code",
            COPYSTR(CRMOptionMapping.GetRecordKeyValue,1,MAXSTRLEN(SalesHeader."Shipping Agent Code")));

        IF CRMOptionMapping.FindRecordID(
             DATABASE::"CRM Account",CRMAccount.FIELDNO(PaymentTermsCode),CRMSalesorder.PaymentTermsCode)
        THEN
          SalesHeader.VALIDATE(
            "Payment Terms Code",
            COPYSTR(CRMOptionMapping.GetRecordKeyValue,1,MAXSTRLEN(SalesHeader."Payment Terms Code")));

        IF CRMOptionMapping.FindRecordID(
             DATABASE::"CRM Account",CRMAccount.FIELDNO(Address1_FreightTermsCode),CRMSalesorder.FreightTermsCode)
        THEN
          SalesHeader.VALIDATE(
            "Shipment Method Code",
            COPYSTR(CRMOptionMapping.GetRecordKeyValue,1,MAXSTRLEN(SalesHeader."Shipment Method Code")));
    end;

    procedure CopyBillToInformationIfNotEmpty(CRMSalesorder : Record 60007;var SalesHeader : Record 36);
    begin
        // If the Bill-To fields in CRM are all empty, then let NAV keep its standard behavior (takes Bill-To from the Customer information)
        IF ((CRMSalesorder.BillTo_Line1 = '') AND
            (CRMSalesorder.BillTo_Line2 = '') AND
            (CRMSalesorder.BillTo_City = '') AND
            (CRMSalesorder.BillTo_PostalCode = '') AND
            (CRMSalesorder.BillTo_Country = '') AND
            (CRMSalesorder.BillTo_StateOrProvince = ''))
        THEN
          EXIT;

        SalesHeader.VALIDATE("Bill-to Address",FORMAT(CRMSalesorder.BillTo_Line1,MAXSTRLEN(SalesHeader."Bill-to Address")));
        SalesHeader.VALIDATE("Bill-to Address 2",FORMAT(CRMSalesorder.BillTo_Line2,MAXSTRLEN(SalesHeader."Bill-to Address 2")));
        SalesHeader.VALIDATE("Bill-to City",FORMAT(CRMSalesorder.BillTo_City,MAXSTRLEN(SalesHeader."Bill-to City")));
        SalesHeader.VALIDATE("Bill-to Post Code",FORMAT(CRMSalesorder.BillTo_PostalCode,MAXSTRLEN(SalesHeader."Bill-to Post Code")));
        SalesHeader.VALIDATE(
          "Bill-to Country/Region Code",FORMAT(CRMSalesorder.BillTo_Country,MAXSTRLEN(SalesHeader."Bill-to Country/Region Code")));
        SalesHeader.VALIDATE("Bill-to County",FORMAT(CRMSalesorder.BillTo_StateOrProvince,MAXSTRLEN(SalesHeader."Bill-to County")));
    end;

    procedure CopyShipToInformationIfNotEmpty(CRMSalesorder : Record 60007;var SalesHeader : Record 36);
    begin
        // If the Ship-To fields in CRM are all empty, then let NAV keep its standard behavior (takes Bill-To from the Customer information)
        IF ((CRMSalesorder.ShipTo_Line1 = '') AND
            (CRMSalesorder.ShipTo_Line2 = '') AND
            (CRMSalesorder.ShipTo_City = '') AND
            (CRMSalesorder.ShipTo_PostalCode = '') AND
            (CRMSalesorder.ShipTo_Country = '') AND
            (CRMSalesorder.ShipTo_StateOrProvince = ''))
        THEN
          EXIT;

        SalesHeader.VALIDATE("Ship-to Address",FORMAT(CRMSalesorder.ShipTo_Line1,MAXSTRLEN(SalesHeader."Ship-to Address")));
        SalesHeader.VALIDATE("Ship-to Address 2",FORMAT(CRMSalesorder.ShipTo_Line2,MAXSTRLEN(SalesHeader."Ship-to Address 2")));
        SalesHeader.VALIDATE("Ship-to City",FORMAT(CRMSalesorder.ShipTo_City,MAXSTRLEN(SalesHeader."Ship-to City")));
        SalesHeader.VALIDATE("Ship-to Post Code",FORMAT(CRMSalesorder.ShipTo_PostalCode,MAXSTRLEN(SalesHeader."Ship-to Post Code")));
        SalesHeader.VALIDATE(
          "Ship-to Country/Region Code",FORMAT(CRMSalesorder.ShipTo_Country,MAXSTRLEN(SalesHeader."Ship-to Country/Region Code")));
        SalesHeader.VALIDATE("Ship-to County",FORMAT(CRMSalesorder.ShipTo_StateOrProvince,MAXSTRLEN(SalesHeader."Ship-to County")));
    end;

    procedure CopyProductDescription(SalesHeader : Record 36;var SalesLine : Record 37;CRMSalesOrderProductDescription : Text);
    begin
        IF STRLEN(CRMSalesOrderProductDescription) > MAXSTRLEN(SalesLine.Description) THEN BEGIN
          SalesLine.Description := COPYSTR(CRMSalesOrderProductDescription,1,MAXSTRLEN(SalesLine.Description));
          CreateExtendedDescriptionOrderLines(
            SalesHeader,
            COPYSTR(
              CRMSalesOrderProductDescription,
              MAXSTRLEN(SalesLine.Description) + 1));
        END;
    end;

    local procedure CoupledSalesHeaderExists(CRMSalesorder : Record 60007) : Boolean;
    var
        SalesHeader : Record 36;
        CRMIntegrationRecord : Record 5331;
        NAVSalesHeaderRecordId : RecordID;
    begin
        IF NOT ISNULLGUID(CRMSalesorder.SalesOrderId) THEN
          IF CRMIntegrationRecord.FindRecordIDFromID(CRMSalesorder.SalesOrderId,DATABASE::"Sales Header",NAVSalesHeaderRecordId) THEN
            EXIT(SalesHeader.GET(NAVSalesHeaderRecordId));
    end;

    [Scope('Personalization')]
    procedure CreateInNAV(CRMSalesorder : Record 60007;var SalesHeader : Record 36) : Boolean;
    begin
        CRMSalesorder.TESTFIELD(StateCode,CRMSalesorder.StateCode::Submitted);
        EXIT(CreateNAVSalesOrder(CRMSalesorder,SalesHeader));
    end;

    local procedure CreateNAVSalesOrder(CRMSalesorder : Record 60007;var SalesHeader : Record 36) : Boolean;
    var
        CRMIntegrationRecord : Record 5331;
    begin
        IF ISNULLGUID(CRMSalesorder.SalesOrderId) THEN
          EXIT;

        CreateSalesOrderHeader(CRMSalesorder,SalesHeader);
        CreateSalesOrderLines(CRMSalesorder,SalesHeader);
        ApplySalesOrderDiscounts(CRMSalesorder,SalesHeader);
        CRMIntegrationRecord.CoupleRecordIdToCRMID(SalesHeader.RECORDID,CRMSalesorder.SalesOrderId);
        // Flag sales order has been submitted to NAV.
        SetLastBackOfficeSubmit(CRMSalesorder,TODAY);
        EXIT(TRUE);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeDeleteEvent', '', false, false)]
    [Scope('Internal')]
    procedure ClearLastBackOfficeSubmitOnSalesHeaderDelete(var Rec : Record 36;RunTrigger : Boolean);
    var
        CRMSalesorder : Record 60007;
        CRMIntegrationRecord : Record 5331;
        CRMIntegrationManagement : Codeunit 5330;
    begin
        IF CRMIntegrationManagement.IsCRMIntegrationEnabled THEN
          IF CRMIntegrationRecord.FindIDFromRecordID(Rec.RECORDID,CRMSalesorder.SalesOrderId) THEN BEGIN
            CRMSalesorder.FIND;
            SetLastBackOfficeSubmit(CRMSalesorder,0D);
          END;
    end;

    local procedure CreateSalesOrderHeader(CRMSalesorder : Record 60007;var SalesHeader : Record 36);
    var
        Customer : Record 18;
    begin
        SalesHeader.INIT;
        SalesHeader.VALIDATE("Document Type",SalesHeader."Document Type"::Order);
        SalesHeader.VALIDATE(Status,SalesHeader.Status::Open);
        SalesHeader.InitInsert;
        GetCoupledCustomer(CRMSalesorder,Customer);
        SalesHeader.VALIDATE("Sell-to Customer No.",Customer."No.");
        SalesHeader.Validate("Paid Online",CRMSalesorder.iosh_OnlinePayment);
        SalesHeader.VALIDATE("Your Reference",COPYSTR(CRMSalesorder.OrderNumber,1,MAXSTRLEN(SalesHeader."Your Reference")));
        SalesHeader.VALIDATE("Currency Code",CRMSynchHelper.GetNavCurrencyCode(CRMSalesorder.TransactionCurrencyId));
        SalesHeader.VALIDATE("Requested Delivery Date",CRMSalesorder.RequestDeliveryBy);
        CopyBillToInformationIfNotEmpty(CRMSalesorder,SalesHeader);
        CopyShipToInformationIfNotEmpty(CRMSalesorder,SalesHeader);
        CopyCRMOptionFields(CRMSalesorder,SalesHeader);
        SalesHeader.VALIDATE("Payment Discount %",CRMSalesorder.DiscountPercentage);
        SalesHeader.VALIDATE("External Document No.",COPYSTR(CRMSalesorder.Name,1,MAXSTRLEN(SalesHeader."External Document No.")));
        SalesHeader.INSERT;
    end;

    local procedure CreateSalesOrderLines(CRMSalesorder : Record 60007;SalesHeader : Record 36);
    var
        CRMSalesorderdetail : Record 60014;
        SalesLine : Record 37;
    begin
        // If any of the products on the lines are not found in NAV, err
        CRMSalesorderdetail.SETRANGE(SalesOrderId,CRMSalesorder.SalesOrderId); // Get all sales order lines

        IF CRMSalesorderdetail.FINDSET THEN BEGIN
          REPEAT
            InitializeSalesOrderLine(CRMSalesorderdetail,SalesHeader,SalesLine);
            SalesLine.INSERT;
            IF SalesLine."Qty. to Assemble to Order" <> 0 THEN
              SalesLine.VALIDATE("Qty. to Assemble to Order");
          UNTIL CRMSalesorderdetail.NEXT = 0;
        END ELSE BEGIN
          SalesLine.VALIDATE("Document Type",SalesHeader."Document Type");
          SalesLine.VALIDATE("Document No.",SalesHeader."No.");
        END;

        SalesLine.InsertFreightLine(CRMSalesorder.FreightAmount);
    end;

    procedure CreateExtendedDescriptionOrderLines(SalesHeader : Record 36;FullDescription : Text);
    var
        SalesLine : Record 37;
    begin
        WHILE STRLEN(FullDescription) > 0 DO BEGIN
          InitNewSalesLine(SalesHeader,SalesLine);

          SalesLine.VALIDATE(Description,COPYSTR(FullDescription,1,MAXSTRLEN(SalesLine.Description)));
          SalesLine.INSERT;
          FullDescription := COPYSTR(FullDescription,MAXSTRLEN(SalesLine.Description) + 1);
        END;
    end;

   
    procedure CRMIsCoupledToValidRecord(CRMSalesorder : Record 60007;NAVTableID : Integer) : Boolean;
    var
        CRMIntegrationManagement : Codeunit 5330;
        CRMCouplingManagement : Codeunit 5331;
    begin
        EXIT(CRMIntegrationManagement.IsCRMIntegrationEnabled AND
          CRMCouplingManagement.IsRecordCoupledToNAV(CRMSalesorder.SalesOrderId,NAVTableID) AND
          CoupledSalesHeaderExists(CRMSalesorder));
    end;

    [Scope('Personalization')]
    procedure GetCRMSalesOrder(var CRMSalesorder : Record 60007;YourReference : Text[35]) : Boolean;
    begin
        CRMSalesorder.SETRANGE(OrderNumber,YourReference);
        EXIT(CRMSalesorder.FINDFIRST)
    end;

    [Scope('Personalization')]
    procedure GetCoupledCRMSalesorder(SalesHeader : Record 36;var CRMSalesorder : Record 60007);
    var
        CRMIntegrationRecord : Record 5331;
        CoupledCRMId : Guid;
    begin
        IF SalesHeader.ISEMPTY THEN
          ERROR(NotCoupledSalesHeaderErr,SalesHeader."No.",CRMProductName.SHORT);

        IF NOT CRMIntegrationRecord.FindIDFromRecordID(SalesHeader.RECORDID,CoupledCRMId) THEN
          ERROR(NotCoupledSalesHeaderErr,SalesHeader."No.",CRMProductName.SHORT);

        IF CRMSalesorder.GET(CoupledCRMId) THEN
          EXIT;

        // If we reached this point, a zombie coupling exists but the sales order most probably was deleted manually by the user.
        CRMIntegrationRecord.RemoveCouplingToCRMID(CoupledCRMId,DATABASE::"Sales Header");
        ERROR(ZombieCouplingErr,PRODUCTNAME.SHORT,CRMProductName.SHORT);
    end;

    [Scope('Personalization')]
    procedure GetCoupledCustomer(CRMSalesorder : Record 60007;var Customer : Record 18) : Boolean;
    var
        CRMAccount : Record 5341;
        CRMIntegrationRecord : Record 5331;
        NAVCustomerRecordId : RecordID;
        CRMAccountId : Guid;
    begin
        IF ISNULLGUID(CRMSalesorder.CustomerId) THEN
          ERROR(NoCustomerErr,CannotCreateSalesOrderInNAVTxt,CRMSalesorder.Description,CRMProductName.SHORT);

        // Get the ID of the CRM Account associated to the sales order. Works for both CustomerType(s): account, contact
        IF NOT GetCRMAccountOfCRMSalesOrder(CRMSalesorder,CRMAccount) THEN
          ERROR(CannotFindCRMAccountForOrderErr,CRMSalesorder.Name,CRMProductName.SHORT);
        CRMAccountId := CRMAccount.AccountId;

        IF NOT CRMIntegrationRecord.FindRecordIDFromID(CRMAccountId,DATABASE::Customer,NAVCustomerRecordId) THEN
          ERROR(NotCoupledCustomerErr,CannotCreateSalesOrderInNAVTxt,CRMAccount.Name,CRMProductName.SHORT);

        EXIT(Customer.GET(NAVCustomerRecordId));
    end;

    [Scope('Personalization')]
    procedure GetCoupledSalesHeader(CRMSalesorder : Record 60007;var SalesHeader : Record 36) : Boolean;
    var
        CRMIntegrationRecord : Record 5331;
        NAVSalesHeaderRecordId : RecordID;
    begin
        IF ISNULLGUID(CRMSalesorder.SalesOrderId) THEN
          ERROR(NotCoupledCRMSalesOrderErr,CRMSalesorder.OrderNumber,CRMProductName.SHORT);

        // Attempt to find the coupled sales header
        IF NOT CRMIntegrationRecord.FindRecordIDFromID(CRMSalesorder.SalesOrderId,DATABASE::"Sales Header",NAVSalesHeaderRecordId) THEN
          ERROR(NotCoupledCRMSalesOrderErr,CRMSalesorder.OrderNumber,CRMProductName.SHORT);

        IF SalesHeader.GET(NAVSalesHeaderRecordId) THEN
          EXIT(TRUE);

        // If we reached this point, a zombie coupling exists but the sales order most probably was deleted manually by the user.
        CRMIntegrationRecord.RemoveCouplingToCRMID(CRMSalesorder.SalesOrderId,DATABASE::"Sales Header");
        ERROR(ZombieCouplingErr,PRODUCTNAME.SHORT,CRMProductName.SHORT);
    end;

    [Scope('Personalization')]
    procedure GetCRMAccountOfCRMSalesOrder(CRMSalesorder : Record 60007;var CRMAccount : Record 5341) : Boolean;
    var
        CRMContact : Record 5342;
    begin
        IF CRMSalesorder.CustomerIdType = CRMSalesorder.CustomerIdType::account THEN
          EXIT(CRMAccount.GET(CRMSalesorder.CustomerId));

        IF CRMSalesorder.CustomerIdType = CRMSalesorder.CustomerIdType::contact THEN
          IF CRMContact.GET(CRMSalesorder.CustomerId) THEN
            EXIT(CRMAccount.GET(CRMContact.ParentCustomerId));
        EXIT(FALSE);
    end;

    [Scope('Personalization')]
    procedure GetCRMContactOfCRMSalesOrder(CRMSalesorder : Record 60007;var CRMContact : Record 5342) : Boolean;
    begin
        IF CRMSalesorder.CustomerIdType = CRMSalesorder.CustomerIdType::contact THEN
          EXIT(CRMContact.GET(CRMSalesorder.CustomerId));
    end;

    local procedure InitNewSalesLine(SalesHeader : Record 36;var SalesLine : Record 37);
    begin
        SalesLine.INIT;
        SalesLine.VALIDATE("Document Type",SalesHeader."Document Type");
        SalesLine.VALIDATE("Document No.",SalesHeader."No.");
        LastSalesLineNo := LastSalesLineNo + 10000;
        SalesLine.VALIDATE("Line No.",LastSalesLineNo);
    end;

    local procedure InitializeSalesOrderLine(CRMSalesorderdetail : Record 60014;SalesHeader : Record 36;var SalesLine : Record 37);
    var
        CRMProduct : Record 5348;
    begin
        InitNewSalesLine(SalesHeader,SalesLine);

        IF ISNULLGUID(CRMSalesorderdetail.ProductId) THEN
          InitializeWriteInOrderLine(SalesLine)
        ELSE BEGIN
          CRMProduct.GET(CRMSalesorderdetail.ProductId);
          CRMProduct.TESTFIELD(StateCode,CRMProduct.StateCode::Active);
          CASE CRMProduct.ProductTypeCode OF
            CRMProduct.ProductTypeCode::SalesInventory:
              InitializeSalesOrderLineFromItem(CRMProduct,SalesLine);
            CRMProduct.ProductTypeCode::Services:
              InitializeSalesOrderLineFromResource(CRMProduct,SalesLine);
            ELSE
              ERROR(UnexpectedProductTypeErr,CannotCreateSalesOrderInNAVTxt,CRMProduct.ProductNumber);
          END;
        END;

        CopyProductDescription(SalesHeader,SalesLine,CRMSalesorderdetail.ProductDescription);

        SalesLine.VALIDATE(Quantity,CRMSalesorderdetail.Quantity);
        SalesLine.VALIDATE("Unit Price",CRMSalesorderdetail.PricePerUnit);
        SalesLine.VALIDATE(Amount,CRMSalesorderdetail.BaseAmount);
        SalesLine.VALIDATE(
          "Line Discount Amount",
          CRMSalesorderdetail.Quantity * CRMSalesorderdetail.VolumeDiscountAmount +
          CRMSalesorderdetail.ManualDiscountAmount);
    end;

    local procedure InitializeSalesOrderLineFromItem(CRMProduct : Record 5348;var SalesLine : Record 37);
    var
        CRMIntegrationRecord : Record 5331;
        Item : Record 27;
        NAVItemRecordID : RecordID;
    begin
        // Attempt to find the coupled item
        IF NOT CRMIntegrationRecord.FindRecordIDFromID(CRMProduct.ProductId,DATABASE::Item,NAVItemRecordID) THEN
          ERROR(NotCoupledCRMProductErr,CannotCreateSalesOrderInNAVTxt,CRMProduct.Name,CRMProductName.SHORT);

        IF NOT Item.GET(NAVItemRecordID) THEN
          ERROR(ItemDoesNotExistErr,CannotCreateSalesOrderInNAVTxt,CRMProduct.ProductNumber);
        SalesLine.VALIDATE(Type,SalesLine.Type::Item);
        SalesLine.VALIDATE("No.",Item."No.");
    end;

    local procedure InitializeSalesOrderLineFromResource(CRMProduct : Record 5348;var SalesLine : Record 37);
    var
        CRMIntegrationRecord : Record 5331;
        Resource : Record 156;
        NAVResourceRecordID : RecordID;
    begin
        // Attempt to find the coupled resource
        IF NOT CRMIntegrationRecord.FindRecordIDFromID(CRMProduct.ProductId,DATABASE::Resource,NAVResourceRecordID) THEN
          ERROR(NotCoupledCRMResourceErr,CannotCreateSalesOrderInNAVTxt,CRMProduct.Name,CRMProductName.SHORT);

        IF NOT Resource.GET(NAVResourceRecordID) THEN
          ERROR(ResourceDoesNotExistErr,CannotCreateSalesOrderInNAVTxt,CRMProduct.ProductNumber);
        SalesLine.VALIDATE(Type,SalesLine.Type::Resource);
        SalesLine.VALIDATE("No.",Resource."No.");
    end;

    local procedure InitializeWriteInOrderLine(var SalesLine : Record 37);
    var
        SalesSetup : Record 311;
    begin
        SalesSetup.GET;
        SalesSetup.TESTFIELD("Write-in Product No.");
        SalesSetup.VALIDATE("Write-in Product No.");
        CASE SalesSetup."Write-in Product Type" OF
          SalesSetup."Write-in Product Type"::Item:
            SalesLine.VALIDATE(Type,SalesLine.Type::Item);
          SalesSetup."Write-in Product Type"::Resource:
            SalesLine.VALIDATE(Type,SalesLine.Type::Resource);
        END;
        SalesLine.VALIDATE("No.",SalesSetup."Write-in Product No.");
    end;

    local procedure SetLastBackOfficeSubmit(var CRMSO : Record 60007;NewDate : Date);
    var 
        CRMSalesorder :Record "CRM Salesorder";
    begin
        if CRMSalesOrder.get(CRMSO.SalesOrderId) then 
        IF CRMSalesOrder.LastBackofficeSubmit <> NewDate THEN BEGIN
          CRMSalesorder.StateCode := CRMSalesorder.StateCode::Active;
          CRMSalesorder.MODIFY(TRUE);
          CRMSalesOrder.LastBackofficeSubmit := NewDate;
          CRMSalesorder.MODIFY(TRUE);
          CRMSalesOrder.StateCode := CRMSalesorder.StateCode::Submitted;
          CRMSalesorder.MODIFY(TRUE);
        
        END;
    end;

// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Management", 'OnIsIntegrationRecord', '', true, true)]
// local procedure IsintegrationRecord(TableID : Integer;VAR isIntegrationRecord : Boolean)
// begin
//     if TableID = Database::IOSH_CRMSaleOrder then
//     isIntegrationRecord := true;
// end;

// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Management", 'OnIsIntegrationRecordChild', '', true, true)]
// local procedure IsintegrationChildRecord(TableID : Integer;VAR isIntegrationRecordChild : Boolean)
// begin
//     if TableID = Database::IOSH_CRMSaleOrder then
//     isIntegrationRecordChild := true;
// end;
}