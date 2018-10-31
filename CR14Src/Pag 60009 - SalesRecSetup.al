pageextension 60009 IOSH_SalesRecSetupExt extends "Sales & Receivables Setup" //MyTargetPageId
{
    layout
    {
        addafter(General)
        {
            group("IOSH Setup")
            {
                field("UK Customer Template"; "UK Customer Template Code")
                {
                    ApplicationArea = all;
                }
                field("EU Customer Template"; "EU Customer Template Code")
                {
                    ApplicationArea = all;
                }
                field("ROW Customer Template"; "ROW Customer Template Code")
                {
                    ApplicationArea = all;
                }
                field("Charity Legal Entity Name"; CharityLegalEntityName)
                {
                    ApplicationArea = all;
                }
                field("Services Legal Entity Name"; ServiceLegalEntityName)
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