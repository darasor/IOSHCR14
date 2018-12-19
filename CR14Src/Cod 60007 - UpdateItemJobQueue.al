codeunit 60007 UpdateItemJobQ
{
    //TableNo = 472;

    trigger OnRun()
    var
        IOSH_CRMProduct: Record IOSH_CRM_Product;
        CRMIntegrationRecord: Record "CRM Integration Record";
        Item: Record item;
        Loc_RecordID: RecordId;
        RecRef: RecordRef;
        NAVModifiedOn: DateTime;
        IntegrationRecord: Record "Integration Record";
    begin
        CODEUNIT.RUN(CODEUNIT::"CRM Integration Management");
        COMMIT();
        //Uncommented after testing 
        IOSH_CRMProduct.SetRange(IOSH_LegalEntityName, CompanyName());
        if IOSH_CRMProduct.findset() then
            repeat
                // if CRMIntegrationRecord.FindRecordIDFromID(IOSH_CRMProduct.ProductId, Database::Item, Loc_RecordID) then begin
                //     if RecRef.get(Loc_RecordID) then

                CRMIntegrationRecord.SetRange("CRM ID", IOSH_CRMProduct.ProductId);
                if CRMIntegrationRecord.findfirst() then
                    if IntegrationRecord.get(CRMIntegrationRecord."Integration ID") then
                        if RecRef.get(IntegrationRecord."Record ID") then
                            if RecRef.Number() = Database::item then begin
                                RecRef.SetTable(Item);
                                NAVModifiedOn := CreateDateTime(Item."Last Date Modified", item."Last Time Modified");
                                //if IOSH_CRMContact.ModifiedOn > CRMIntegrationRecord."Last Synch. Modified On" then begin //Cant use
                                if IOSH_CRMProduct.ModifiedOn > NAVModifiedOn then begin
                                    UpdateNAVItem(IOSH_CRMProduct.ProductId, Item);
                                    CRMIntegrationRecord."Last Synch. Modified On" := CurrentDateTime();
                                    CRMIntegrationRecord."Last Synch. CRM Modified On" := IOSH_CRMProduct.ModifiedOn;
                                    CRMIntegrationRecord.Modify();
                                end;
                            end;
                //exit;
            until IOSH_CRMProduct.next() = 0;
    end;

    procedure UpdateNAVItem(ProductID: Guid; Item: Record Item)
    var
        CRMProduct: Record "CRM Product";
        lastDateTime: DateTime;
        CRMIntegrationRecord: Record "CRM Integration Record";
        xRec: Record Contact;
        CRMUOM: Record "CRM Uom";
        CRMUOMSchedule: Record "CRM Uomschedule";
    begin
        // lastDateTime := CREATEDATETIME(Item."Last Date Modified", Item."Last Time Modified");
        // //xRec := NavContact;
        if CRMProduct.get(ProductID) then begin
            //find integration record id
            item.Description := CRMProduct.Name;

            CRMUOMSchedule.SetRange(UoMScheduleId, CRMProduct.DefaultUoMScheduleId);
            if CRMUOMSchedule.FindFirst() then
                Item."Base Unit of Measure" := CRMUOMSchedule.BaseUoMName;
            Item.Modify();

            //     /* NavContact."Last Date Modified" := DT2Date(IOSH_CRMContact.ModifiedOn);
            //     NavContact."Last Time Modified" := DT2Time(IOSH_CRMContact.ModifiedOn);
            //     NavContact.Modify(false); */
        end else
            Error('Cannot find CRM Contact %1', CRMProduct);

    End;
}