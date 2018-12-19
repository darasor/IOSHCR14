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
        if "Legal Entity Name" <> '' then
            Error('Item already Exists in %1', "Legal Entity Name");

        if "Legal Entity Name" = '' then
            "Legal Entity Name" := CompanyName();

    end;

}