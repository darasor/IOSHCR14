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
                field("EU Customer Template"; "EU Customer Template Code")
                {
                    ApplicationArea = all;
                }
                field("ROW Customer Template"; "ROW Customer Template Code")
                {
                    ApplicationArea = all;
                }
                field("CRM Charity Legal Entity Name"; CRMCharityLegalEntityName)
                {
                    ApplicationArea = all;
                }
                field("CRM Services Legal Entity Name"; CRMServiceLegalEntityName)
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