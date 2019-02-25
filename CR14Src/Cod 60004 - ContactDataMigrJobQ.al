codeunit 60004 ContactDataMigrationJobQueue
{
    //TableNo = 60009;

    trigger OnRun()
    var
        IOSH_CRMContact: Record IOSH_CRMContact;
        Contact: Record Contact;
        Customer: Record Customer;
        CustMgt: Codeunit "IOSH_Customer Management";
        CustTemplate: Record "Customer Template";
        SalesSetup: Record "Sales & Receivables Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
        pRecordID: RecordId;
        RecRef: RecordRef;
        Tis_CRM_Mgt: Codeunit "TIS CRMIntegrationMgt";
    begin
        CODEUNIT.RUN(CODEUNIT::"CRM Integration Management");
        COMMIT();
        //Uncommented after testing 

        SalesSetup.get();
        SalesSetup.TestField("EU Customer Template Code");
        SalesSetup.TestField("UK Customer Template Code");
        SalesSetup.TestField("ROW Customer Template Code");
        SalesSetup.TestField(CharityLegalEntityName);
        if NOT (CompanyName() = SalesSetup.CharityLegalEntityName) then
            Exit;
        IOSH_CRMContact.SetRange("Create Charity Customer", true);
        //IOSH_CRMContact.setrange(FullName, 'TestContactJQ DS'); //Uncomment this back after testing
        //IOSH_CRMContact.SetRange("Create Contact in BC", true); //Uncomment this back after testing
        if IOSH_CRMContact.findset() then
            repeat
                if NOT CRMIntegrationRecord.FindRecordIDFromID(IOSH_CRMContact.ContactId, Database::Contact, pRecordID) then begin
                    CustMgt.createNAVContact(IOSH_CRMContact.ContactId, Contact);
                    pRecordID := Contact.RecordId();
                    CRMIntegrationRecord.CoupleRecordIdToCRMID(pRecordID, IOSH_CRMContact.ContactId);
                    // case IOSH_CRMContact."BC Template Code" of
                    //     IOSH_CRMContact."BC Template Code"::EU:
                    //         if custtemplate.get(SalesSetup."EU Customer Template Code") then;
                    //     IOSH_CRMContact."BC Template Code"::UK:
                    //         if CustTemplate.get(SalesSetup."UK Customer Template Code") then;
                    //     IOSH_CRMContact."BC Template Code"::ROW:
                    //         if CustTemplate.get(SalesSetup."ROW Customer Template Code") then;
                    // end;
                    if Contact."No." <> '' then
                        CustMgt.createCustomerFromNAVContact(Contact, IOSH_CRMContact."BC Template Code", Customer);
                    Commit();
                end else
                    if NOT RecRef.get(pRecordID) then
                        Tis_CRM_Mgt.DeleteIfRecordDeleted(IOSH_CRMContact.ContactId, Database::Contact);

            until IOSH_CRMContact.next() = 0;
    end;
}