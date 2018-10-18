tableextension 60002 PaymentMethodExt extends "Payment Method"
{
    fields
    {
        // Add changes to table fields here
        field(60000;"Online Payment";Boolean)
        {
            CaptionML = ENG = 'Online Payment';
            trigger OnValidate();
            var
                PayMethodExt : Record "Payment Method";

            begin
                if "Online Payment" and xRec."online payment" <> Rec."Online payment" then begin
                    PayMethodExt.setrange("Online Payment",true);
                    if PayMethodExt.findfirst then
                    begin
                        error ('Online payment has been already selected. Only one Online payment is allowed');
                    end;
                end;
            end;
        }
    }
    
    var
        myInt: Integer;
        
    
}