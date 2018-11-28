pageextension 60017 ContListExt extends "Contact List"
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
        modify(Create)
        {
            Visible = false;
        }
    }

    var
        myInt: Integer;
}