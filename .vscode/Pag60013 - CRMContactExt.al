pageextension 60013 CRMCOntactExt extends "CRM Contact List" //MyTargetPageId
{
    layout
    {

    }


    trigger OnOpenPage()
    var
        CreateContact: Codeunit ContactDataMigrationJobQueue;
        createCustomer: Codeunit UpdateCustomerJobQ;
        updateContact: Codeunit UpdateContactJobQ;

    begin
        Message('CRM page');
        //CreateContact.Run();
        //createCustomer.Run();
        updateContact.Run();
    end;

    trigger OnAfterGetCurrRecord()
    var
    begin

    end;
}