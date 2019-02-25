tableextension 60000 SalesOrderExt extends "Sales Header"
{
    fields
    {
        field(60000; "Paid Online"; Boolean)
        {
            Editable = False;

            trigger OnValidate();
            begin
                if "Paid Online" and ((Rec."Document Type" = Rec."Document Type"::Order)
                Or (Rec."Document Type" = Rec."Document Type"::Invoice)) then begin
                    PaymentMethod.SetRange("Online Payment", true);
                    if PaymentMethod.findfirst() then begin
                        ;
                        PaymentCode := PaymentMethod.Code;
                        Validate("Payment Method Code", PaymentCode);
                    end;
                end;
            end;
        }
    }

    var
        myInt: Integer;
        PaymentMethod: Record "Payment Method";
        PaymentCode: Code[10];




}