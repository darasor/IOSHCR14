tableextension 60001 SalesInvExt extends "Sales Invoice Header"
{
    fields
    {
        // Add changes to table fields here
        field(60000;"Paid Online";Boolean)
        {
            Editable = False;

            trigger OnValidate();
            var

            begin
                
            end;
        }
    }
    
    var
        myInt: Integer;
}