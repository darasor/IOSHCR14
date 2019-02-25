pageextension 60004 SalesInvPage extends "Posted Sales Invoice"
{
    layout
    {
        // Add changes to page layout here
        addafter(Closed)
        {
            field("Paid Online"; "Paid Online")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {

        addafter("&Invoice")
        {
            action(OpenCRMContact)
            {
                ApplicationArea = Basic, Suit;
                CaptionML = ENU = 'IOSH create CRM Invoice',
                        ENG = 'IOSH create CRM Invoice';

                Image = New;
                Promoted = true;
                ToolTipML = ENU = 'Create a sales Invoice in Dynamics 365 for Sales.',
                        ENG = 'Create a sales Invoice in Dynamics 365 for Sales.';

                trigger OnAction();
                var
                    CRMIntegrationRecord: Record "CRM Integration Record";
                    CRMSalesInvoice: Record "CRM Invoice";
                    CreateCRMSalesInvoice: Codeunit iOSH_CreateCRMSalesInvoice;
                    CRMSalesInvID: Guid;
                begin
                    //if coupled dont create again
                    IF CRMIntegrationRecord.FindIDFromRecordID(Rec.RecordId(), CRMSalesInvID) THEN
                        if not IsNullGuid(CRMSalesInvID) then
                            if CRMSalesInvoice.get(CRMSalesInvID) then begin
                                Message('This sales invoice is already created.');
                                exit;
                            end else
                                CRMIntegrationRecord.RemoveCouplingToRecord(Rec.RecordId());

                    CreateCRMSalesInvoice.Run(Rec);

                end;
            }
        }

    }

    var
        myInt: Integer;
}