pageextension 60007 ItemExt extends "Item Card" //MyTargetPageId
{
    layout
    {
        addafter("Automatic Ext. Texts")
        {
            field("Legal Entity Name"; "Legal Entity Name")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
    }
}