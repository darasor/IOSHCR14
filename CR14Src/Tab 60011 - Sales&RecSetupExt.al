tableextension 60011 SalesSetupExt extends "Sales & Receivables Setup" //MyTargetTableId
{
    fields
    {
        field(50000; "UK Customer Template Code"; Code[10])
        {
            Caption = 'UK Customer Template Code';
            Description = 'Template use to create UK Customer.';
            TableRelation = "Customer Template".Code;
        }
        field(50001; "EU Customer Template Code"; Code[10])
        {
            Caption = 'EU Customer Template Code';
            Description = 'Template use to create EU Customer.';
            TableRelation = "Customer Template".Code;
        }
        field(50002; "ROW Customer Template Code"; Code[10])
        {
            Caption = 'ROW Customer Template Code';
            Description = 'Template use to create customer outside UK and EU.';
            TableRelation = "Customer Template".Code;
        }
        field(50003; "CRMCharityLegalEntityName"; Code[10])
        {
            Caption = 'CRM Charity Legal Entity Name';
            Description = 'Legal Entity Name use in CRM Sales order for IOSH Charity.';
            TableRelation = "Customer Template".Code;
        }
        field(50004; "CRMServiceLegalEntityName"; Code[10])
        {
            Caption = 'CRM Services Legal Entity Name';
            Description = 'Legal Entity Name use in CRM Sales order for IOSH Services Ltd.';
            TableRelation = "Customer Template".Code;
        }


    }

}