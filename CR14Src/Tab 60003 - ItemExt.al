tableextension 60003 ItemExt extends Item //MyTargetTableId
{
    fields
    {
        field(60000; "Legal Entity Name"; text[30])
        {
            Editable = False;
            DataClassification = SystemMetadata;

            trigger OnValidate();
            begin

            end;
        }
    }

    trigger OnInsert()
    begin
        "Legal Entity Name" := CompanyName();
    end;

}