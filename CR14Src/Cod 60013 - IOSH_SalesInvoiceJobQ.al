codeunit 60013 IOSH_CreateContactSalesInvoice
{
    TableNo = 472;
    trigger OnRun()
    begin
        CODEUNIT.RUN(CODEUNIT::"CRM Integration Management");
        COMMIT;
        CreateCRMContactSalesInvoice;
    end;

    procedure CreateCRMContactSalesInvoice();
    var
        SalesInvoice: Record "Sales Invoice Header";
        Customer: Record Customer;
    begin

        if SalesInvoice.FindSet() then
            REPEAT
                if Customer.get(SalesInvoice."Sell-to Customer No.") then
                    if Customer."Dynamics 365 Contact Customer" then
                        IF CODEUNIT.RUN(CODEUNIT::iOSH_CreateCRMSalesInvoice, SalesInvoice) THEN;
                //    COMMIT;
            UNTIL SalesInvoice.next() = 0;

    end;

    var
        myInt: Integer;
}
