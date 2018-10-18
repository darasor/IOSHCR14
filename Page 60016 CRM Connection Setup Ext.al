pageextension 60016 CRMConnectionSetupExt extends "CRM Connection Setup" //MyTargetPageId
{
    layout
    {
        modify("Auto Create Sales Orders")
        {
            Visible = false;
            
        }
        modify("Is S.Order Integration Enabled")
        {
            Visible = false;
        }
    }
    
    actions
    {
    }
}