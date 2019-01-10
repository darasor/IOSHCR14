pageextension 60013 CRMCOntactExt extends "CRM Contact List" //MyTargetPageId
{
    layout
    {

    }
    actions
    {
        addafter(CreateFromCRM)
        {
            action(CreatInNAV2)
            {
                ApplicationArea = Basic, Suit;
                CaptionML = ENU = 'IOSH Create Contact in Dynamics NAV',
                        ENG = 'IOSH Create Contact in Dynamics NAV';

                Image = New;
                Promoted = true;
                ToolTipML = ENU = 'Create a sales order in Dynamics NAV that is coupled to the Dynamics 365 for Sales entity.',
                        ENG = 'Create a sales order in Dynamics NAV that is coupled to the Dynamics 365 for Sales entity.';

                trigger OnAction();
                var
                    CRMIntegrationRecord: Record "CRM Integration Record";
                    CRMCouplingManagement: Codeunit "CRM Coupling Management";
                    NAVContact: Record Contact;
                    CustMgt: Codeunit "IOSH_Customer Management";
                    RecordID: RecordId;
                begin
                    //if coupled dont create again
                    if CRMIntegrationRecord.FindRecordIDFromID(Rec.AccountId, Database::Contact, RecordID) then
                        CustMgt.createNAVContact(Rec.AccountId, NAVContact);
                end;
            }
        }
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
        Tis_CRM_Mgt: Codeunit TIS_CRMIntegrationMgt;
        CRMSalesInvoice: Codeunit iOSH_CreateCRMSalesInvoice;
        SalesInv: Record "Sales Invoice Header";
        RecRef: RecordRef;

    begin
        //TEST Script Only
        //Message('CRM page');
        //CreateContact.Run();
        //createCustomer.Run();
        //updateContact.Run();
        //updateItem.Run();
        //createCRMItem.Run();

        //CRMAccount.Setfilter(CRMAccount.Name, 'CH Fertility Group');
        //if CRMAccount.FindFirst() then

        //    CustMgt.createCustomerUseCRMAccount(CRMAccount.AccountId, Customer);


        // IOSH_SalesOrder.SetRange(IOSH_SalesOrder.OrderNumber, 'ORD-02228-Q1P4X1');
        // if IOSH_SalesOrder.FindFirst() then begin
        //     if CRMIntegrationRecord.FindRecordIDFromID(IOSH_SalesOrder.SalesOrderId, Database::"Sales Header", SalesORderID) then begin
        //         if NOT RecRef.get(SalesORderID) then
        //             Tis_CRM_Mgt.DeleteIfRecordDeleted(IOSH_SalesOrder.SalesOrderId, Database::"Sales Header");

        //         // if Salesorder.get(SalesORderID) then begin
        //         //     Salesorder.Invoice := true;
        //         //     Salesorder.Ship := true;
        //         //     Salesorder.Modify();
        //         //     Commit();
        //         //     //Salesorder.get(Salesorder);
        //         //     //if not CODEUNIT.RUN(CODEUNIT::"Sales-Post", SalesHeader) then
        //         //     if not SalesPost.Run(Salesorder) then
        //         //         Message('Error during post sales order was %1', GetLastErrorText());
        //         // end;


        //     end else
        //         // IF CreateSalesOredr.GetCRMAccountOfCRMSalesOrder(IOSH_SalesOrder, CRMAccount) THEN begin
        //         //     CRMAccountId := CRMAccount.AccountId;

        //         //     CRMIntegrationRecord.SETRANGE("CRM ID", CRMAccountId);
        //         //     CRMIntegrationRecord.SETFILTER("Table ID", FORMAT(18));
        //         //     if CRMIntegrationRecord.FINDFIRST then
        //         //         CRMIntegrationRecord.Delete();
        //         // end;
        //         CreateSalesOredr.run(IOSH_SalesOrder);
        // end;

        //TEST POSTED SALES INVOICE
        SalesInv.SetRange("No.", 'ISL-SI020');
        if SalesInv.FindFirst() then
            // if Customer.get(SalesInv."Sell-to Customer No.") then
            //     if Customer."Dynamics 365 Contact Customer" then
            CRMSalesInvoice.Run(SalesInv);
    end;

    trigger OnAfterGetCurrRecord()
    var
    begin

    end;
}