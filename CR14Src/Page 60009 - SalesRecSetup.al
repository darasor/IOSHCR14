pageextension 60009 IOSH_SalesRecSetupExt extends "Sales & Receivables Setup" //MyTargetPageId
{
    layout
    {
        addafter(General)
        {
            group("Customer Template")
            {
                field("UK Customer Template"; "UK Customer Template Code")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
    }
}