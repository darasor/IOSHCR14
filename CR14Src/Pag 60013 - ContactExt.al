pageextension 60014 ContactExt extends "Contact Card"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        modify(Coupling)
        {
            Visible = false;
        }
        modify(CRMSynchronizeNow)
        {
            Visible = false;
        }
        addafter("Related Information")
        {
            action(OpenCRMContact)
            {
                ApplicationArea = Basic, Suit;
                CaptionML = ENU = 'IOSH Open CRM',
                        ENG = 'IOSH Open CRM';

                Image = New;
                Promoted = true;
                ToolTipML = ENU = 'Create a sales order in Dynamics NAV that is coupled to the Dynamics 365 for Sales entity.',
                        ENG = 'Create a sales order in Dynamics NAV that is coupled to the Dynamics 365 for Sales entity.';

                trigger OnAction();
                var
                    CRMIntegrationManagement: Codeunit "CRM Integration Management";
                begin
                    //if coupled dont create again
                    CRMIntegrationManagement.ShowCRMEntityFromRecordID(Rec.RECORDID);
                end;
            }
        }

    }

    var
        myInt: Integer;
}