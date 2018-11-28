codeunit 60006 UpdateCustomerJobQ
{
    //TableNo = 60009;

    trigger OnRun()
    var
        IOSH_CRMAccount: Record IOSH_CRMAccount;
        Cust: Record Customer;
        CustMgt: Codeunit "IOSH_Customer Management";
        SalesSetup: Record "Sales & Receivables Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
        RecordID: RecordId;
        RecRef: RecordRef;
        NAVModifiedOn: DateTime;
    begin
        CODEUNIT.RUN(CODEUNIT::"CRM Integration Management");
        COMMIT;
        //Uncommented after testing 

        IOSH_CRMAccount.SetRange(CustomerTypeCode, IOSH_CRMAccount.CustomerTypeCode::Customer);
        IOSH_CRMAccount.SetRange(StatusCode, IOSH_CRMAccount.StatusCode::Active);
        IOSH_CRMAccount.SetRange("BC Template Code", IOSH_CRMAccount."BC Template Code"::UK);
        if IOSH_CRMAccount.findset then
            repeat
                if CRMIntegrationRecord.FindRecordIDFromID(IOSH_CRMAccount.AccountId, Database::Customer, RecordID) then begin
                    if RecRef.get(RecordID) then
                        if RecRef.Number() = Database::Customer then begin
                            RecRef.SetTable(Cust);

                            CRMIntegrationRecord.SetRange("CRM ID", IOSH_CRMAccount.AccountId);
                            if CRMIntegrationRecord.findfirst then
                                //if IOSH_CRMContact.ModifiedOn > CRMIntegrationRecord."Last Synch. Modified On" then begin //Cant use
                                if IOSH_CRMAccount.ModifiedOn > cust."Last Modified Date Time" then
                                    CustMgt.updateNAVCustomer(IOSH_CRMAccount.AccountId, Cust);
                            /*        CRMIntegrationRecord."Last Synch. Modified On" := CurrentDateTime();
                                   CRMIntegrationRecord."Last Synch. CRM Modified On" := IOSH_CRMContact.ModifiedOn;
                                   CRMIntegrationRecord.Modify(); */
                            exit;
                        end;
                end else
                    CustMgt.createCustomerUseCRMAccount(IOSH_CRMAccount.AccountId, Cust);
            until IOSH_CRMAccount.next = 0;
    end;
}