pageextension 60008 CustomerCardEx extends "Customer Card" //MyTargetPageId
{
    layout
    {
        addafter("Last Date Modified")
        {
            field("Dynamics 365 Contact Customer"; "Dynamics 365 Contact Customer")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {

        modify(CRMSynchronizeNow)
        {
            Visible = false;
        }
        modify(Coupling)
        {
            Visible = false;
        }
    }
}