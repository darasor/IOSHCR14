pageextension 60018 CustomerListExt extends "Customer List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        modify(CRMGotoAccount)
        {
            Visible = false;
        }
        modify(CRMSynchronizeNow)
        {
            Visible = false;
        }
        modify(Coupling)
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