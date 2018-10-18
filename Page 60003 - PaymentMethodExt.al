pageextension 60003 PaymentMethodExt extends "Payment Methods"
{
    layout
    {
        // Add changes to page layout here
       addafter("Direct Debit")
       {
        field("Online Payment";"Online Payment")
            {
             Enabled = true;   
             ApplicationArea = all;
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