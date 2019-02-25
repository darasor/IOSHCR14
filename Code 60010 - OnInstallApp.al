codeunit 60010 OnInstallApp
{

    Subtype = Install;

    trigger OnInstallAppPerCompany();
    var
        IntegrationMappingTable: Record "Integration Table Mapping";
        CRMConSetup: Record "CRM Connection Setup";
        EnqueueJobQueEntries: Boolean;

        AutoCreateSalesOrdersTxt: TextConst ENU = 'Automatically create sales orders from sales orders that are submitted in %1.',
                                                ENG = 'Automatically create sales orders from sales orders that are submitted in %1.';
        CRMProductName: Codeunit "CRM Product Name";

    begin
        //Set auto to false
        if CRMConSetup.get() then begin
            if CRMConSetup."Auto Create Sales Orders" then begin
                CRMConSetup."Auto Create Sales Orders" := false;
                CRMConSetup.Modify();
            END;
            if CRMConSetup."Is S.Order Integration Enabled" then begin
                CRMConSetup."Is S.Order Integration Enabled" := false;
                CRMConSetup.Modify();
            end;
        end;

        EnqueueJobQueEntries := true;

        RecreateJobQueueEntry(
            EnqueueJobQueEntries,
            CODEUNIT::IOSH_Auto_CreateSalesOrders,
            2,
            STRSUBSTNO(AutoCreateSalesOrdersTxt, CRMProductName.SHORT),
            FALSE);

        RecreateJobQueueEntry(
            EnqueueJobQueEntries,
            CODEUNIT::ContactDataMigrationJobQueue,
            2,
            STRSUBSTNO('Auto create contact for data migration from CRM', CRMProductName.SHORT),
            FALSE);
        RecreateJobQueueEntry(
            EnqueueJobQueEntries,
            CODEUNIT::IOSH_CreateContactSalesInvoice,
            60,
            STRSUBSTNO('Auto create CRM Invoice for Contact', CRMProductName.SHORT),
            FALSE);
        RecreateJobQueueEntry(
           EnqueueJobQueEntries,
           CODEUNIT::UpdateContactJobQ,
           2,
           STRSUBSTNO('Update contact from CRM Contact', CRMProductName.SHORT),
           FALSE);
        RecreateJobQueueEntry(
            EnqueueJobQueEntries,
            CODEUNIT::UpdateContactJobQ,
            2,
            STRSUBSTNO('Update contact from CRM Contact', CRMProductName.SHORT),
            FALSE);
        RecreateJobQueueEntry(
            EnqueueJobQueEntries,
            CODEUNIT::UpdateCustomerJobQ,
            2,
            STRSUBSTNO('Update customer from CRM Account', CRMProductName.SHORT),
            FALSE);
        RecreateJobQueueEntry(
        EnqueueJobQueEntries,
        CODEUNIT::UpdateItemJobQ,
        2,
        STRSUBSTNO('Update Item from CRM Product', CRMProductName.SHORT),
        FALSE);
        RecreateJobQueueEntry(
            EnqueueJobQueEntries,
            CODEUNIT::IOSH_ItemJobQ,
            2,
            STRSUBSTNO('Create CRM Product', CRMProductName.SHORT),
            FALSE);
    end;

    procedure RecreateJobQueueEntry(EnqueueJobQueEntry: Boolean; CodeunitId: Integer; MinutesBetweenRun: Integer; EntryDescription: Text; StatusReady: Boolean);
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        WITH JobQueueEntry DO BEGIN
            SETRANGE("Object Type to Run", "Object Type to Run"::Codeunit);
            SETRANGE("Object ID to Run", CodeunitId);

            DeleteTasks;

            InitRecurringJob(MinutesBetweenRun);
            "Object Type to Run" := "Object Type to Run"::Codeunit;
            "Object ID to Run" := CodeunitId;
            Priority := 1000;
            Description := COPYSTR(EntryDescription, 1, MAXSTRLEN(Description));
            "Maximum No. of Attempts to Run" := 2;
            // IF StatusReady THEN
            //     Status := Status::Ready
            // ELSE
            Status := Status::"On Hold";
            "Rerun Delay (sec.)" := 30;
            IF EnqueueJobQueEntry THEN
                CODEUNIT.RUN(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry)
            ELSE
                INSERT(TRUE);
        END;
    end;

}