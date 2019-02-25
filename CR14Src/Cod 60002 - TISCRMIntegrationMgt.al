codeunit 60002 "TIS CRMIntegrationMgt"
{
    trigger OnRun()
    begin
    end;


    [EventSubscriber(ObjectType::Table, 5050, 'OnAfterModifyEvent', '', true, true)]
    local procedure AfterModifyNAVContact(var Rec: Record Contact; RunTrigger: Boolean)
    var
        IntegrationRecord: Record "Integration Record";
        lastDateTime: DateTime;
    begin
        if NOT RunTrigger then
            exit;
        IntegrationRecord.SetRange("Table ID", 5050);
        IntegrationRecord.SetRange("Record ID", Rec.RecordId());
        if IntegrationRecord.FindFirst() then begin
            CustMgt.updateCRMContact(Rec);
            //IntegrationRecord."Modified On" := CurrentDateTime();
            //IntegrationRecord.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnAfterModifyEvent', '', true, true)]
    local procedure AfterModifyNAVCustomer(var Rec: Record Customer; RunTrigger: Boolean)
    var
        IntegrationRecord: Record "Integration Record";
        lastDateTime: DateTime;
    begin
        if NOT RunTrigger then
            exit;
        IntegrationRecord.SetRange("Table ID", 18);
        IntegrationRecord.SetRange("Record ID", Rec.RecordId());
        if IntegrationRecord.FindFirst() then begin
            CustMgt.UpdateCRMAccount(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 60009, 'OnAfterModifyEvent', '', true, true)]
    local procedure AfterModifyCRMContact(var Rec: Record IOSH_CRMContact)
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        RecordID: RecordId;
        RecRef: RecordRef;
        lastDateTime: DateTime;
        NAVContact: Record Contact;
    begin
        /*   CRMIntegrationRecord.SetRange("CRM ID", Rec.ContactId);
          if CRMIntegrationRecord.FindFirst() then begin
              //lastDateTime := CREATEDATETIME(Rec."Last Date Modified", Rec."Last Time Modified");
              if CRMIntegrationRecord.FindRecordIDFromID(Rec.ContactId, Database::Contact, RecordID) then begin
                  RecRef.get(RecordID);
                  if RecRef.Number() = Database::Contact then begin
                      RecRef.SetTable(NAVContact);

                      CustMgt.updateNAVContact(Rec.ContactId, NAVContact);
                      CRMIntegrationRecord."Last Synch. CRM Modified On" := rec.ModifiedOn;
                      CRMIntegrationRecord."Last Synch. Modified On" := CurrentDateTime();
                      CRMIntegrationRecord.Modify();

                  end;
              end;
          end; */
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Management", 'OnIsIntegrationRecord', '', true, true)]
    local procedure CheckCustomIntTables(TableID: Integer; VAR isIntegrationRecord: Boolean)
    begin
        // case TableID of
        //     database::contact:
        //         isIntegrationRecord := true;
        //     Database::customer:
        //         isIntegrationRecord := true;
        // end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5340, 'OnQueryPostFilterIgnoreRecord', '', true, true)]
    local procedure CRMDataHandlingSkipRecord(SourceRecordRef: RecordRef;
    VAR IgnoreRecord: Boolean)
    var
        SynchActionType: Option "None",Insert,Modify,ForceModify,IgnoreUnchanged,Fail,Skip;
        Cust: Record Customer;
        CRMAccount: Record "CRM Account";
        CRMContact: Record "CRM Contact";
        Contact: Record Contact;
        IOSH_CRMContact: Record IOSH_CRMContact;
        SalesSetup: Record "Sales & Receivables Setup";
        Item: record item;
        CRMProduct: Record "CRM Product";
        IOSH_CRMProduct: Record IOSH_CRM_Product;
    begin
        //Uncommmeted late

        if (SourceRecordRef.NUMBER = DATABASE::"CRM Product") then begin
            //SourceRecordRef.SETTABLE(CRMProduct);
            //if IOSH_CRMProduct.get(CRMProduct.ProductId) then
            //    if NOT (CompanyName() = IOSH_CRMProduct.IOSH_LegalEntityName) then
            IgnoreRecord := true;
        end;
        //Probably need the above code for IOSH_CRM_Product

        // if (SourceRecordRef.Number() = Database::Customer) then begin
        //     SourceRecordRef.SetTable(Cust);
        //     //Customer 
        //     if cust."Dynamics 365 Contact Customer" then
        //         IgnoreRecord := true;
        // end;
        //Message('Job Queue');
        //Create contact data migration for charity company
        // if (SourceRecordRef.Number() = Database::"CRM Contact") then begin
        //     SourceRecordRef.settable(CRMContact);
        //     if IOSH_CRMContact.get(CRMContact.AccountId) then
        //if Not (IOSH_CRMContact."Create Charity Customer" and (CompanyName() = SalesSetup.CharityLegalEntityName)) then
        //        if Not (IOSH_CRMContact."Create Contact in BC") then

        //if they havent created yet then ignore,otherwise allow to update
        //if NOT IntegrationRecord.FindByIntegrationId(CRMAccount.AccountId) then
        //            IgnoreRecord := true
        //end;

        // if (SourceRecordRef.Number() = Database::Contact) then begin
        //     SourceRecordRef.settable(Contact);
        //     //if they havent created yet then ignore,otherwise allow to update
        //     if NOT IntegrationRecord.FindByRecordId(Contact.RecordId()) then
        //         IgnoreRecord := true
        // end;
    end;

    [EventSubscriber(ObjectType::table, 5348, 'OnAfterInsertEvent', '', true, true)]
    procedure afterInsertCRMProduct(var Rec: Record "CRM Product"; RunTrigger: Boolean);
    var

        IOSH_CRMProduct: Record IOSH_CRM_Product;
    begin
        // update CRM legal entity name,
        if IOSH_CRMProduct.get(Rec.ProductId) then begin
            if IOSH_CRMProduct.IOSH_LegalEntityName = '' then begin //
                IOSH_CRMProduct.IOSH_LegalEntityName := CompanyName();
                IOSH_CRMProduct.MODIFY(false);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::table, 27, 'OnAfterModifyEvent', '', true, true)]
    procedure afterModifyItem(var Rec: Record Item; RunTrigger: Boolean);
    var
        IOSH_CRMProduct: Record IOSH_CRM_Product;
        IntegrationRecord: Record "Integration Record";
        CRMIntegration: Record "CRM Integration Record";
        CRMID: Guid;
        CRMUOMSchedule: Record "CRM Uomschedule";
    begin
        // update CRM Product when Item is updated 
        // if CRMIntegration.FindIDFromRecordID(Rec.RecordId(), CRMID) then begin
        //     if IOSH_CRMProduct.get(CRMID) then begin
        //         IOSH_CRMProduct.Name := Rec.Description;
        //         IOSH_CRMProduct.Price := Rec."Unit Price";
        //         IOSH_CRMProduct.StandardCost := Rec."Unit Cost";
        //         IOSH_CRMProduct.CurrentCost := Rec."Unit Cost";
        //         IOSH_CRMProduct.StockVolume := Rec."Unit Volume";
        //         IOSH_CRMProduct.StockWeight := Rec."Gross Weight";
        //         IOSH_CRMProduct.QuantityOnHand := Rec.Inventory;
        //         IOSH_CRMProduct.VendorID := Rec."Vendor No.";
        //         IOSH_CRMProduct.VendorName := Rec."Vendor Item No.";
        //         CRMUOMSchedule.SetRange(BaseUoMName, Rec."Base Unit of Measure");
        //         if CRMUOMSchedule.FindFirst() then
        //             IOSH_CRMProduct.DefaultUoMScheduleId := CRMUOMSchedule.UoMScheduleId;
        //         IOSH_CRMProduct.Modify();
        //     end;

        // end;

    end;

    [EventSubscriber(ObjectType::table, 27, 'OnbeforeInsertEvent', '', true, true)]
    procedure beforeInsertItem(var Rec: Record Item; RunTrigger: Boolean);
    var
        IOSH_CRMProduct: Record IOSH_CRM_Product;
        IntegrationRecord: Record "Integration Record";
        CRMIntegration: Record "CRM Integration Record";
        CRMID: Guid;
        CRMUOMSchedule: Record "CRM Uomschedule";
    begin
        // if Rec."Legal Entity Name" <> '' then
        //     if (Rec."Legal Entity Name" <> CompanyName()) then
        //         error('Error DS %1 CompanyName: %2', Rec."Legal Entity Name", CompanyName());
    end;

    [EventSubscriber(ObjectType::Codeunit, 5345, 'OnAfterInsertRecord', '', true, true)]
    procedure CRMDataHandlingAfterInsert(IntegrationTableMapping: Record "Integration Table Mapping";
    var SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef);
    var
        CRMProduct: Record "CRM Product";
        IOSH_CRMProduct: Record IOSH_CRM_Product;
        Item: Record item;
        CRMContact: Record "CRM Contact";
        IOSH_CRMContact: Record IOSH_CRMContact;
        Contact: Record Contact;
        Cust: Record Customer;
        CustTemplate: Record "Customer Template";

    begin
        // update CRM legal entity name,
        // if (SourceRecordRef.NUMBER = DATABASE::Item) and (DestinationRecordRef.NUMBER = DATABASE::"CRM Product") then begin
        //     SourceRecordRef.SETTABLE(Item);
        //     DestinationRecordRef.SETTABLE(CRMProduct);
        //     if IOSH_CRMProduct.get(CRMProduct.ProductId) then begin
        //         IOSH_CRMProduct.IOSH_LegalEntityName := Item."Legal Entity Name";
        //         IOSH_CRMProduct.MODIFY(false);
        //     end;
        // end;

    end;

    procedure FindRecordIDFromID(SourceCRMID: GUID; DestinationTableID: Integer; VAR DestinationRecordId: RecordID): Boolean
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        IF FindRowFromCRMID(SourceCRMID, DestinationTableID, CRMIntegrationRecord) THEN
            IF FindByIntegrationId(CRMIntegrationRecord."Integration ID", IntegrationRecord) THEN BEGIN
                DestinationRecordId := IntegrationRecord."Record ID";
                EXIT(TRUE);
            END;
    end;

    procedure FindRowFromCRMID(CRMID: GUID; DestinationTableID: Integer; VAR CRMIntegrationRecord: Record "CRM Integration Record"): Boolean
    var
    begin

        CRMIntegrationRecord.SETRANGE("CRM ID", CRMID);
        CRMIntegrationRecord.SETFILTER("Table ID", FORMAT(DestinationTableID));
        EXIT(CRMIntegrationRecord.FINDFIRST);
    end;

    procedure FindByIntegrationId(IntegrationId: GUID; Var IntegrationRecord: Record "Integration Record"): Boolean
    var
    begin
        IF ISNULLGUID(IntegrationId) THEN
            EXIT(FALSE);

        IntegrationRecord.RESET;
        IntegrationRecord.SETRANGE("Integration ID", IntegrationId);
        EXIT(IntegrationRecord.FINDFIRST);
    end;

    LOCAL procedure UncoupleCRMIDIfRecordDeleted(IntegrationID: GUID): Boolean
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        IntegrationRecord.FindByIntegrationId(IntegrationID);
        //IF IntegrationRecord."Deleted On" <> 0DT THEN BEGIN
        IF FindRowFromIntegrationID(IntegrationID, CRMIntegrationRecord) THEN
            CRMIntegrationRecord.DELETE;
        EXIT(TRUE);
        //END;
    end;

    procedure DeleteIfRecordDeleted(CRMID: GUID; DestinationTableID: Integer): Boolean
    var
        IntegrationID: Guid;
    begin
        IF FindIntegrationIDFromCRMID(CRMID, DestinationTableID, IntegrationID) THEN
            EXIT(UncoupleCRMIDIfRecordDeleted(IntegrationID));
    end;

    procedure FindIntegrationIDFromCRMID(SourceCRMID: GUID; DestinationTableID: Integer; VAR DestinationIntegrationID: GUID): Boolean
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        IF FindRowFromCRMID(SourceCRMID, DestinationTableID, CRMIntegrationRecord) THEN BEGIN
            DestinationIntegrationID := CRMIntegrationRecord."Integration ID";
            EXIT(TRUE);
        END;
    end;

    procedure FindRowFromIntegrationID(IntegrationID: GUID; VAR CRMIntegrationRecord: Record "CRM Integration Record"): Boolean
    var
    begin
        CRMIntegrationRecord.SETCURRENTKEY("Integration ID");
        CRMIntegrationRecord.SETFILTER("Integration ID", IntegrationID);
        EXIT(CRMIntegrationRecord.FINDFIRST);
    end;

    var
        IntegrationRecord: Record "Integration Record";
        CustMgt: Codeunit "IOSH_Customer Management";
        jobQueue: Codeunit "Job Queue Start Codeunit";
}