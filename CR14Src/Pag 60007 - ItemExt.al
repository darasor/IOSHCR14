pageextension 60007 ItemExt extends "Item Card" //MyTargetPageId
{
    layout
    {
        addafter("Automatic Ext. Texts")
        {
            field("Legal Entity Name"; "Legal Entity Name")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addafter(CRMSynchronizeNow)
        {
            action(CreateCRMProduct)
            {
                ApplicationArea = Basic, Suit;
                CaptionML = ENU = 'IOSH Create CRM Product',
                        ENG = 'IOSH Create CRM Product';

                Image = New;
                Promoted = true;
                ToolTipML = ENU = 'Create a sales order in Dynamics NAV that is coupled to the Dynamics 365 for Sales entity.',
                        ENG = 'Create a sales order in Dynamics NAV that is coupled to the Dynamics 365 for Sales entity.';

                trigger OnAction();
                var
                    //CRMIntegrationManagement: codeunit "CRM Integration Management";
                    CreateItem: Codeunit IOSH_ItemJobQ;
                begin
                    //CRMIntegrationManagement.UpdateOneNow(RECORDID);
                    //CRMIntegrationManagement.CreateNewRecordInCRM(RecordId, false);
                    CreateItem.CreateCRMItem(Rec);
                end;
            }
        }
        modify(Coupling)
        {
            Visible = false;
        }
        modify(CRMSynchronizeNow)
        {
            Visible = false;
        }
    }
}