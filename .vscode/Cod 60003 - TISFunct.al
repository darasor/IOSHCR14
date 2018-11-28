codeunit 60003 TISFunctions

{
procedure SetDefaultSeries(VAR NewNoSeriesCode : Code[20];NoSeriesCode : Code[20];pCompanyName: Text[30])
var
begin
    NoSeries.ChangeCompany(pCompanyName);
    IF NoSeriesCode <> '' THEN BEGIN
        NoSeries.GET(NoSeriesCode);
        IF NoSeries."Default Nos." THEN
            NewNoSeriesCode := NoSeries.Code;
    END;
end;
procedure InitSeries(DefaultNoSeriesCode: Code[20]; OldNoSeriesCode: Code[20]; NewDate: Date; VAR NewNo: Code[20];
    VAR NewNoSeriesCode: Code[20]; pCompanyName: code[30])
    var
        NoSerieMgt: Codeunit NoSeriesManagement;
    begin
        NoSeries.ChangeCompany(pCompanyName);
        IF NewNo = '' THEN BEGIN
            NoSeries.GET(DefaultNoSeriesCode);
            IF NOT NoSeries."Default Nos." THEN
                ERROR(
                Text002 +
                Text003,
                NoSeries.FIELDCAPTION("Default Nos."), NoSeries.TABLECAPTION, NoSeries.Code);
            /* IF OldNoSeriesCode <> '' THEN BEGIN
                NoSeriesCode := DefaultNoSeriesCode;
                FilterSeries;
                NoSeries.Code := OldNoSeriesCode;
                IF NOT NoSeries.FIND THEN
                NoSeries.GET(DefaultNoSeriesCode);
            END; */
            NewNo := NoSerieMgt.GetNextNo(NoSeries.Code, NewDate, TRUE);
            NewNoSeriesCode := NoSeries.Code;
        END;
    end;    

procedure GetLocation(AccLocation : Code[10];RespCenterCode : Code[10];pCompanyName: Text[30]) : Code[10]
var
    UserMgt :Codeunit "User Setup Management";
    UserRespCenter: Code[10];
    UserLocation: code[10];
    Companyinfo: Record "Company Information";
    RespCenter: Record "Responsibility Center";
begin
    Companyinfo.ChangeCompany(pCompanyName);
    CompanyInfo.GET;
    UserLocation := CompanyInfo."Location Code";
    RespCenter.ChangeCompany(pCompanyName);
    IF RespCenter.GET(RespCenterCode) THEN
        IF RespCenter."Location Code" <> '' THEN
            UserLocation := RespCenter."Location Code";

    IF AccLocation <> '' THEN
        EXIT(AccLocation);

    EXIT(UserLocation);
end;

procedure GetNextOccurrenceNo(TableId : Integer;DocType : Option Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order";
    DocNo : Code[20];pCompanyName: text[30]) : Integer
var
    SalesHeaderArchive: record "Sales Header Archive";
    PurchHeaderArchive: Record "Purchase Header Archive";
begin
    CASE TableId OF
    DATABASE::"Sales Header":
        BEGIN
        SalesHeaderArchive.ChangeCompany(pCompanyName);
        SalesHeaderArchive.LOCKTABLE;
        SalesHeaderArchive.SETRANGE("Document Type",DocType);
        SalesHeaderArchive.SETRANGE("No.",DocNo);
        IF SalesHeaderArchive.FINDLAST THEN
            EXIT(SalesHeaderArchive."Doc. No. Occurrence" + 1);

        EXIT(1);
        END;
    DATABASE::"Purchase Header":
        BEGIN
        PurchHeaderArchive.ChangeCompany(pCompanyName);
        PurchHeaderArchive.LOCKTABLE;
        PurchHeaderArchive.SETRANGE("Document Type",DocType);
        PurchHeaderArchive.SETRANGE("No.",DocNo);
        IF PurchHeaderArchive.FINDLAST THEN
            EXIT(PurchHeaderArchive."Doc. No. Occurrence" + 1);

        EXIT(1);
        END;
    END;
end;
procedure GetRespCenter(DocType : Option Sales,Purchase,Service;AccRespCenter : Code[10];pCompanyName:Text[30]) : Code[10]
var
AccType : Text[50]; 
Text000 : Label	'customer';
Text001 : Label 'Vendor';
Text002	: label 'This %1 is related to %2 %3. Your identification is setup to process from %2 %4.';
Text003	: label 'This document will be processed in your %2.';
UserRespCenter: Code[10];

Companyinfo: Record "Company Information";
RespCenter: Record "Responsibility Center";
begin
    CASE DocType OF
    DocType::Sales:
        BEGIN
        AccType := Text000;
        Companyinfo.ChangeCompany(pCompanyName);
        CompanyInfo.GET;
        UserRespCenter := CompanyInfo."Responsibility Center";
        END;
    /* DocType::Purchase:
        BEGIN
        AccType := Text001;
        UserRespCenter := GetPurchasesFilter;
        END;
    DocType::Service:
        BEGIN
        AccType := Text000;
        UserRespCenter := GetServiceFilter;
        END; */
    END;
    IF (AccRespCenter <> '') AND
    (UserRespCenter <> '') AND
    (AccRespCenter <> UserRespCenter)
    THEN
    MESSAGE(
        Text002 +
        Text003,
        AccType,RespCenter.TABLECAPTION,AccRespCenter,UserRespCenter);
    IF UserRespCenter = '' THEN
    EXIT(AccRespCenter);

    EXIT(UserRespCenter);
end;
procedure GetNoSeriesWithCheck(NewNoSeriesCode : Code[20];SelectNoSeriesAllowed : Boolean;CurrentNoSeriesCode : Code[20];
pCompanyName: code[30]) : Code[20]
var 
    NoSeries : Record "No. Series";
begin
    IF NOT SelectNoSeriesAllowed THEN
    EXIT(NewNoSeriesCode);

    NoSeries.ChangeCompany(pCompanyName);
    NoSeries.GET(NewNoSeriesCode);
    IF NoSeries."Default Nos." THEN
    EXIT(NewNoSeriesCode);

    IF SeriesHasRelations(NewNoSeriesCode,pCompanyName) THEN
    IF SelectSeries(NewNoSeriesCode,'',CurrentNoSeriesCode,pCompanyName) THEN
        EXIT(CurrentNoSeriesCode);
    EXIT(NewNoSeriesCode);
end;
procedure SelectSeries(DefaultNoSeriesCode : Code[20];OldNoSeriesCode : Code[20];VAR NewNoSeriesCode : Code[20];
pCompanyName: Text[30]) : Boolean
var
NoSeriesCode : Code[20];

begin

    NoSeriesCode := DefaultNoSeriesCode;
    FilterSeries(NoSeriesCode,pCompanyName);
    IF NewNoSeriesCode = '' THEN BEGIN
        IF OldNoSeriesCode <> '' THEN
            NoSeries.Code := OldNoSeriesCode;
    END ELSE
    NoSeries.Code := NewNoSeriesCode;
end;

LOCAL procedure FilterSeries(NoSeriesCode: Code[20];pCompanyName : Text[30])
var
    NoSeriesRelationship: Record "No. Series Relationship";
begin
    NoSeries.ChangeCompany(pCompanyName);
    NoSeriesRelationship.ChangeCompany(pCompanyName);
    NoSeries.RESET;
    NoSeriesRelationship.SETRANGE(Code,NoSeriesCode);
    IF NoSeriesRelationship.FINDSET THEN
    REPEAT
        NoSeries.Code := NoSeriesRelationship."Series Code";
        NoSeries.MARK := TRUE;
    UNTIL NoSeriesRelationship.NEXT = 0;
    NoSeries.GET(NoSeriesCode);
    NoSeries.MARK := TRUE;
    NoSeries.MARKEDONLY := TRUE;
end;

procedure SeriesHasRelations(DefaultNoSeriesCode : Code[20];pCompanyName : text[30]) : Boolean
var
    NoSeriesRelationship : Record "No. Series Relationship";
begin
    NoSeriesRelationship.ChangeCompany(pCompanyName);
    NoSeriesRelationship.RESET;
    NoSeriesRelationship.SETRANGE(Code,DefaultNoSeriesCode);
    EXIT(NOT NoSeriesRelationship.ISEMPTY);
end;
    var
        Text002: Label 'It is not possible to assign numbers automatically.';
        Text003: label 'If you want the program to assign numbers automatically, please activate %1 in %2 %3.';
        NoSeries: Record "No. Series";

}
