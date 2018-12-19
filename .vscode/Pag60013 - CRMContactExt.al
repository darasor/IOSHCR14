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
        updateItem: Codeunit UpdateItemJobQ;
        createCRMItem: Codeunit IOSH_ItemJobQ;
        CreateSalesOredr: Codeunit iOSH_CRMSalesOrderToSalesOrder;
        IOSH_SalesOrder: Record IOSH_CRMSaleOrder;
        CRMAccount: Record "CRM Account";
        Customer: Record Customer;
        CRMAccountID: GUID;
        //NAVCustomerRecordId : RecordId;
        SalesORderID: RecordId;
        CRMIntegrationRecord: Record "CRM Integration Record";
        Salesorder: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        CustMgt: Codeunit "IOSH_Customer Management";

    begin
        //TEST Script Only
        //Message('CRM page');
        //CreateContact.Run();
        //createCustomer.Run();
        //updateContact.Run();
        //updateItem.Run();
        //createCRMItem.Run();

        CRMAccount.Setfilter(CRMAccount.Name, 'CH Fertility Group');
        if CRMAccount.FindFirst() then

            CustMgt.createCustomerUseCRMAccount(CRMAccount.AccountId, Customer);


        // IOSH_SalesOrder.SetRange(IOSH_SalesOrder.Name, 'DS_Test2');
        // if IOSH_SalesOrder.FindFirst() then begin
        //     if CRMIntegrationRecord.FindRecordIDFromID(IOSH_SalesOrder.SalesOrderId, Database::"Sales Header", SalesORderID) then begin
        //         if Salesorder.get(SalesORderID) then begin
        //             Salesorder.Invoice := true;
        //             Salesorder.Ship := true;
        //             Salesorder.Modify();
        //             Commit();
        //             //Salesorder.get(Salesorder);
        //             //if not CODEUNIT.RUN(CODEUNIT::"Sales-Post", SalesHeader) then
        //             if not SalesPost.Run(Salesorder) then
        //                 Message('Error during post sales order was %1', GetLastErrorText());
        //         end;


        //     end else
        //         // IF CreateSalesOredr.GetCRMAccountOfCRMSalesOrder(IOSH_SalesOrder, CRMAccount) THEN begin
        //         //     CRMAccountId := CRMAccount.AccountId;

        //         //     CRMIntegrationRecord.SETRANGE("CRM ID", CRMAccountId);
        //         //     CRMIntegrationRecord.SETFILTER("Table ID", FORMAT(18));
        //         //     if CRMIntegrationRecord.FINDFIRST then
        //         //         CRMIntegrationRecord.Delete();
        //         // end;
        //         CreateSalesOredr.run(IOSH_SalesOrder);

        //end;
    end;

    trigger OnAfterGetCurrRecord()
    var
    begin

    end;
}