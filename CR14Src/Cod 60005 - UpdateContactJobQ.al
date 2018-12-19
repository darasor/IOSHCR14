codeunit 60005 UpdateContactJobQ
{
    //TableNo = 472;

    trigger OnRun()
    var
        IOSH_CRMContact: Record IOSH_CRMContact;
        Contact: Record Contact;
        CustMgt: Codeunit "IOSH_Customer Management";
        CRMIntegrationRecord: Record "CRM Integration Record";
        Loc_RecordID: RecordId;
        RecRef: RecordRef;
        NAVModifiedOn: DateTime;
    begin
        CODEUNIT.RUN(CODEUNIT::"CRM Integration Management");
        COMMIT();
        //Uncommented after testing 
        //if CompanyName() = SalesSetup.CharityLegalEntityName then 
        //IOSH_CRMContact.SetRange("Create Charity Customer",true); 
        IOSH_CRMContact.SetRange(StatusCode, IOSH_CRMContact.StatusCode::Active);
        IOSH_CRMContact.SetRange("Create Contact in BC", true); //Remove this after testing need to create a new CU for update contact
        if IOSH_CRMContact.findset() then
            repeat
                if CRMIntegrationRecord.FindRecordIDFromID(IOSH_CRMContact.ContactId, Database::Contact, Loc_RecordID) then begin
                    if RecRef.get(Loc_RecordID) then
                        if RecRef.Number() = Database::Contact then begin
                            RecRef.SetTable(Contact);
                            NAVModifiedOn := CreateDateTime(Contact."Last Date Modified", Contact."Last Time Modified");
                            CRMIntegrationRecord.SetRange("CRM ID", IOSH_CRMContact.ContactId);
                            if CRMIntegrationRecord.findfirst() then
                                //if IOSH_CRMContact.ModifiedOn > CRMIntegrationRecord."Last Synch. Modified On" then begin //Cant use
                                if IOSH_CRMContact.ModifiedOn > NAVModifiedOn then
                                    CustMgt.updateNAVContact(IOSH_CRMContact.ContactId, Contact);
                            /*        CRMIntegrationRecord."Last Synch. Modified On" := CurrentDateTime();
                                   CRMIntegrationRecord."Last Synch. CRM Modified On" := IOSH_CRMContact.ModifiedOn;
                                   CRMIntegrationRecord.Modify(); */
                            //exit;
                        end;
                end;
            until IOSH_CRMContact.next() = 0;
    end;
}