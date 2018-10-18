codeunit 60017 IOSH_Auto_CreateSalesOrders
{   
    TableNo = 472;
    trigger OnRun()
    begin
        CODEUNIT.RUN(CODEUNIT::"CRM Integration Management");
        COMMIT;
        CreateNAVSalesOrdersFromSubmittedCRMSalesorders;
    end;
    procedure CreateNAVSalesOrdersFromSubmittedCRMSalesorders();
    var
        CRMSalesorder : Record "CRM Salesorder";
        IOSH_CRMSalesOrder : Record IOSH_CRMSaleOrder;
      
    begin
    CRMSalesorder.SETRANGE(StateCode,CRMSalesorder.StateCode::Submitted);
    CRMSalesorder.SETRANGE(LastBackofficeSubmit,0D);
    //CRMSalesorder.SetRange(Name,'DSTEST4');
    IF CRMSalesorder.FINDSET(TRUE) THEN
    REPEAT
        if IOSH_CRMSalesOrder.get(CRMSalesorder.SalesOrderId) then
        IF CODEUNIT.RUN(CODEUNIT::iOSH_CRMSalesOrderToSalesOrder,IOSH_CRMSalesOrder) THEN
        COMMIT;
    UNTIL CRMSalesorder.NEXT = 0;
    end;
    var
        myInt: Integer;
}