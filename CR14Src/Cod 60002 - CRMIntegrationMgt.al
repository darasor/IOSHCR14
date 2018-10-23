codeunit 60002 TIS_CRMIntegrationMgt
{
    trigger OnRun()
    begin

    end;

    procedure FindRecordIDFromID(SourceCRMID: GUID; DestinationTableID: Integer; VAR DestinationRecordId: RecordID; pCompanyName: code[30]): Boolean
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        IF FindRowFromCRMID(SourceCRMID, DestinationTableID, CRMIntegrationRecord, pCompanyName) THEN
            IF FindByIntegrationId(CRMIntegrationRecord."Integration ID", IntegrationRecord, pCompanyName) THEN BEGIN
                DestinationRecordId := IntegrationRecord."Record ID";
                EXIT(TRUE);
            END;
    end;

    procedure FindRowFromCRMID(CRMID: GUID; DestinationTableID: Integer; VAR CRMIntegrationRecord: Record "CRM Integration Record";
    pCompanyName: code[30]): Boolean
    var
    begin
        CRMIntegrationRecord.ChangeCompany(pCompanyName);
        CRMIntegrationRecord.SETRANGE("CRM ID", CRMID);
        CRMIntegrationRecord.SETFILTER("Table ID", FORMAT(DestinationTableID));
        EXIT(CRMIntegrationRecord.FINDFIRST);
    end;

    procedure FindByIntegrationId(IntegrationId: GUID; Var IntegrationRecord: Record "Integration Record";
    pCompanyName: code[30]): Boolean
    var

    begin
        IF ISNULLGUID(IntegrationId) THEN
            EXIT(FALSE);

        IntegrationRecord.ChangeCompany(pCompanyName);
        IntegrationRecord.RESET;
        IntegrationRecord.SETRANGE("Integration ID", IntegrationId);
        EXIT(IntegrationRecord.FINDFIRST);
    end;

    var
        IntegrationRecord: Record "Integration Record";
}