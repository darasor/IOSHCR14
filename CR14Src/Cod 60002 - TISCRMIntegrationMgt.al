codeunit 60002 TIS_CRMIntegrationMgt
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Management", 'OnIsIntegrationRecord', '', true, true)]
    local procedure CheckCustomIntTables(TableID: Integer; VAR isIntegrationRecord: Boolean)
    begin
        case TableID of
            database::Job:
                isIntegrationRecord := true;
            Database::"Job Journal Line":
                isIntegrationRecord := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5340, 'OnQueryPostFilterIgnoreRecord', '', true, true)]
    local procedure CRMDataHandlingSkipRecord(SourceRecordRef: RecordRef;
    VAR IgnoreRecord: Boolean)
    var
        SynchActionType: Option "None",Insert,Modify,ForceModify,IgnoreUnchanged,Fail,Skip;
        Cust: Record Customer;
        CRMAccount: Record "CRM Account";
        IOSH_CRMContact: Record IOSH_CRMContact;
        SalesSetup: Record "Sales & Receivables Setup";
    begin

        if (SourceRecordRef.Number() = Database::Customer) then begin
            SourceRecordRef.SetTable(Cust);
            if cust."Dynamics 365 Contact Customer" then
                IgnoreRecord := true;
        end;

        //Create contact data migration for charity company
        if (SourceRecordRef.Number() = Database::"CRM Contact") then begin
            SourceRecordRef.settable(CRMAccount);
            if IOSH_CRMContact.get(CRMAccount.AccountId) then
                if Not (IOSH_CRMContact."Create Charity Customer" and (CompanyName() = SalesSetup.CharityLegalEntityName)) then
                    IgnoreRecord := true;
        end;



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
        if (SourceRecordRef.NUMBER = DATABASE::Item) and (DestinationRecordRef.NUMBER = DATABASE::"CRM Product") then begin
            SourceRecordRef.SETTABLE(Item);
            DestinationRecordRef.SETTABLE(CRMProduct);
            if IOSH_CRMProduct.get(CRMProduct.ProductId) then begin
                IOSH_CRMProduct.IOSH_LegalEntityName := Item."Legal Entity Name";
                IOSH_CRMProduct.MODIFY;
            end;
        end;
        //create customer after contact is inserted
        if (SourceRecordRef.Number() = Database::"CRM Contact") and (DestinationRecordRef.Number() = Database::Contact) then begin
            SourceRecordRef.SetTable(CRMContact);
            DestinationRecordRef.SetTable(Contact);
            if IOSH_CRMContact.get(CRMContact.AccountId) then
                if IOSH_CRMContact."Create Charity Customer" then begin
                    if CustTemplate.get(IOSH_CRMContact."BC Template Code") then
                        CustMgt.createCustomerFromNAVContact(Contact, CustTemplate.Code);
                end;

        end;
    end;

    procedure FindRecordIDFromID(SourceCRMID: GUID; DestinationTableID: Integer; VAR DestinationRecordId: RecordID; pCompanyName: code[30]): Boolean
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        IF FindRowFromCRMID(SourceCRMID, DestinationTableID, CRMIntegrationRecord, pCompanyName) THEN
            IF FindByIntegrationId(CRMIntegrationRecord."Integration ID", IntegrationRecord, pCompanyName) THEN BEGIN
                DestinationRecordId := IntegrationRecord."Record ID";
                EXIT(TRUE);
            END;
    end;

    procedure FindRowFromCRMID(CRMID: GUID; DestinationTableID: Integer; VAR CRMIntegrationRecord: Record "CRM Integration Record";
    pCompanyName: code[30]): Boolean
    var
    begin
        CRMIntegrationRecord.ChangeCompany(pCompanyName);
        CRMIntegrationRecord.SETRANGE("CRM ID", CRMID);
        CRMIntegrationRecord.SETFILTER("Table ID", FORMAT(DestinationTableID));
        EXIT(CRMIntegrationRecord.FINDFIRST);
    end;

    procedure FindByIntegrationId(IntegrationId: GUID; Var IntegrationRecord: Record "Integration Record";
    pCompanyName: code[30]): Boolean
    var

    begin
        IF ISNULLGUID(IntegrationId) THEN
            EXIT(FALSE);

        IntegrationRecord.ChangeCompany(pCompanyName);
        IntegrationRecord.RESET;
        IntegrationRecord.SETRANGE("Integration ID", IntegrationId);
        EXIT(IntegrationRecord.FINDFIRST);
    end;

    var
        IntegrationRecord: Record "Integration Record";
        CRMIntegrationMgt: Codeunit TIS_CRMIntegrationMgt;
        CustMgt: Codeunit "IOSH_Customer Management";
}