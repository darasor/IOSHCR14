tableextension 60005 CustomerExt extends Customer //MyTargetTableId
{
    fields
    {
        field(50000; "Dynamics 365 Contact Customer"; Boolean)
        {
            CaptionML = ENU = 'Dynamics 365 Contact Customer',
                        ENG = 'Dynamics 365 Contact Customer';
            Editable = false;
        }

    }

}