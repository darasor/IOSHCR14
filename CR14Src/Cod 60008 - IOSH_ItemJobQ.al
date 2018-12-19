codeunit 60008 IOSH_ItemJobQ
{
    //TableNo = 27;

    trigger OnRun()
    var

        Item: Record item;

    begin
        CODEUNIT.RUN(CODEUNIT::"CRM Integration Management");
        COMMIT();
        //Uncommented after testing 
        // if item.get('ICH-1046') then
        //CreateCRMItem(Item);


        if Item.findset() then
            repeat
                CreateCRMItem(Item);
            until Item.Next() = 0;
    end;

    procedure CreateCRMItem(Item: Record Item)
    var
        CRMProduct: Record "CRM Product";
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMUOM: Record "CRM Uom";
        IOSH_CRMProduct: Record IOSH_CRM_Product;
        CRMUOMSchedule: Record "CRM Uomschedule";
        CRMID: Guid;
        OutLooktypeHelper: Codeunit "Outlook Synch. Type Conv";
        FieldRefvar: FieldRef;
        ParameterDestinationRecordRef: Recordref;
        TiS_Intgration: Codeunit TIS_CRMIntegrationMgt;
    begin
        // update CRM Product when Item is updated 
        //Cann't call this
        if NOT CRMIntegrationRecord.FindIDFromRecordID(item.RecordId(), CRMID) then begin
            //Check if item already exists
            CRMProduct.SetRange(ProductNumber, Item."No.");
            if CRMProduct.FindFirst() then
                exit;

            IOSH_CRMProduct.Init();
            // ParameterDestinationRecordRef := IOSH_CRMProduct.RecordId().GetRecord();
            // FieldRefvar := ParameterDestinationRecordRef.FIELD(2);
            // if OutLooktypeHelper.EvaluateTextToFieldRef(Item."No.", FieldRefvar, true) then
            //     IOSH_CRMProduct.ProductId := FieldRefvar.Value();

            IOSH_CRMProduct.ProductNumber := Item."No.";
            IOSH_CRMProduct.Name := Item.Description;
            IOSH_CRMProduct.Price := Item."Unit Price";
            IOSH_CRMProduct.StandardCost := Item."Unit Cost";
            IOSH_CRMProduct.CurrentCost := Item."Unit Cost";
            IOSH_CRMProduct.StockVolume := Item."Unit Volume";
            IOSH_CRMProduct.StockWeight := Item."Gross Weight";
            IOSH_CRMProduct.QuantityOnHand := Item.Inventory;
            IOSH_CRMProduct.VendorID := Item."Vendor No.";
            IOSH_CRMProduct.VendorName := Item."Vendor Item No.";
            CRMUOMSchedule.SetRange(BaseUoMName, Item."Base Unit of Measure");
            if CRMUOMSchedule.FindFirst() then
                IOSH_CRMProduct.DefaultUoMScheduleId := CRMUOMSchedule.UoMScheduleId;
            CRMUOM.SetRange(UoMScheduleId, IOSH_CRMProduct.DefaultUoMScheduleId);
            if CRMUOM.FindFirst() then
                IOSH_CRMProduct.DefaultUoMId := CRMUOM.UoMId;

            IOSH_CRMProduct.IOSH_LegalEntityName := Item."Legal Entity Name";

            IOSH_CRMProduct.Insert(false);

            CRMIntegrationRecord.CoupleRecordIdToCRMID(Item.RecordId(), IOSH_CRMProduct.ProductId);
        end else begin
            if NOT CRMProduct.get(CRMID) then
                TiS_Intgration.DeleteIfRecordDeleted(CRMID, Database::Item);
        end;




    End;
}