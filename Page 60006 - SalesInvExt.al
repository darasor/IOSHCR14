pageextension 60006 SalesInvExtPage extends "Sales Invoice"
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {
            field("Paid Online";"Paid Online")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    
    var
        myInt : Integer;
}