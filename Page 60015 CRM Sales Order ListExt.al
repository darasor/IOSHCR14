pageextension 60015 CRMSalesOrderListExt extends "CRM Sales Order List"
{
    layout
    {
        // addafter(StateCode)
        // {
        //     field(LastBackofficeSubmit;LastBackofficeSubmit)
        //     {
        //         ApplicationArea = all;
        //     }
        // }

    }
    actions
    {
         addafter(CRMGoToSalesOrder)
        {
            action(CreatInNAV2)
            {
            ApplicationArea = Basic,Suit;
            CaptionML = ENU='IOSH Create in Dynamics NAV',
                        ENG='IOSH Create in Dynamics NAV';
            
            Image = New;
            Promoted = true;
            ToolTipML = ENU='Create a sales order in Dynamics NAV that is coupled to the Dynamics 365 for Sales entity.',
                        ENG='Create a sales order in Dynamics NAV that is coupled to the Dynamics 365 for Sales entity.';

            trigger OnAction();
            var
                SalesHeader : Record "Sales Header";
                CRMCouplingManagement : Codeunit "CRM Coupling Management";
                CRMSalesOrderToSalesOrder : Codeunit iOSH_CRMSalesOrderToSalesOrder;
                CRMSalesOrder : Record 60007;
            begin
                if CRMSalesOrder.get(Rec.SalesOrderId) then begin
                    CurrPage.Close();
                    IF CRMSalesOrderToSalesOrder.CreateInNAV(CRMSalesOrder,SalesHeader) THEN BEGIN
                        COMMIT;
                        CRMIsCoupledToRecord :=
                        CRMCouplingManagement.IsRecordCoupledToNAV(SalesOrderId,DATABASE::"Sales Header") AND CRMIntegrationEnabled;
                        PAGE.RUNMODAL(PAGE::"Sales Order",SalesHeader);
                    END;
                end;
                RecalculateRecordCouplingStatus;
            end;
            }
        }
        modify(CreateInNAV)
        {
            Visible = false;
        }
    }
       var
        CRMIntegrationEnabled : Boolean;
        CRMIsCoupledToRecord : Boolean;
        HasRecords : Boolean;
    local procedure RecalculateRecordCouplingStatus();
    var
        CRMSalesOrderToSalesOrder : Codeunit iOSH_CRMSalesOrderToSalesOrder;
         CRMSalesOrder : Record 60007;
    begin
        CRMIsCoupledToRecord := FALSE;
        if CRMSalesOrder.get(Rec.SalesOrderId) then 
        IF CRMIntegrationEnabled THEN
          CRMIsCoupledToRecord := CRMSalesOrderToSalesOrder.CRMIsCoupledToValidRecord(CRMSalesOrder,DATABASE::"Sales Header")
    end;
}