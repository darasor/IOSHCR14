codeunit 60015 TIS_CRMHelper
{
    trigger OnRun()
    begin
    end;

    procedure GetCRMTransactioncurrency(CurrencyCode: Text): GUID
    var
        CRMTransactioncurrency: Record "CRM Transactioncurrency";
        NAVLCYCode: Code[20];

    begin
        // In NAV, an empty currency means local currency (LCY)
        NAVLCYCode := GetNavLCYCode();
        IF DELCHR(CurrencyCode) = '' THEN
            CurrencyCode := NAVLCYCode;

        IF CurrencyCode = NAVLCYCode THEN
            FindNAVLocalCurrencyInCRM(CRMTransactioncurrency)
        ELSE BEGIN
            CRMTransactioncurrency.SETRANGE(ISOCurrencyCode, CurrencyCode);
            //IF NOT FindCachedCRMTransactionCurrency(CRMTransactioncurrency) THEN
            //    ERROR(DynamicsCRMTransactionCurrencyRecordNotFoundErr,CurrencyCode,CRMProductName.SHORT);
            //END;
            EXIT(CRMTransactioncurrency.TransactionCurrencyId)
        end;
    end;

    procedure FindNAVLocalCurrencyInCRM(VAR CRMTransactioncurrency: Record "CRM Transactioncurrency"): GUID
    var
        NAVLCYCode: Code[20];

    begin
        NAVLCYCode := GetNavLCYCode();
        CRMTransactioncurrency.SETRANGE(ISOCurrencyCode, NAVLCYCode);
        IF NOT FindCachedCRMTransactionCurrency(CRMTransactioncurrency) THEN BEGIN
            CreateCRMTransactioncurrency(CRMTransactioncurrency, NAVLCYCode);
            AddToCacheCRMTransactionCurrency(CRMTransactioncurrency);
        END;
        EXIT(CRMTransactioncurrency.TransactionCurrencyId);

    end;

    local procedure FindCachedCRMTransactionCurrency(VAR CRMTransactioncurrency: Record "CRM Transactioncurrency"): Boolean
    var
    begin
        IF NOT CacheCRMTransactionCurrency() THEN
            EXIT(FALSE);
        TempCRMTransactioncurrency.COPY(CRMTransactioncurrency);
        IF TempCRMTransactioncurrency.FINDFIRST() THEN BEGIN
            CRMTransactioncurrency.COPY(TempCRMTransactioncurrency);
            EXIT(TRUE);
        END;
    end;

    LOCAL procedure CacheCRMTransactionCurrency(): Boolean
    var
        CRMTransactioncurrency: Record "CRM Transactioncurrency";
    begin
        TempCRMTransactioncurrency.RESET();
        IF TempCRMTransactioncurrency.ISEMPTY() THEN
            IF CRMTransactioncurrency.FINDSET() THEN
                REPEAT
                    AddToCacheCRMTransactionCurrency(CRMTransactioncurrency)
                UNTIL CRMTransactioncurrency.NEXT() = 0;
        EXIT(NOT TempCRMTransactioncurrency.ISEMPTY());
    end;

    procedure GetNavLCYCode(): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.GET();
        GeneralLedgerSetup.TESTFIELD("LCY Code");
        EXIT(GeneralLedgerSetup."LCY Code");
    end;

    LOCAL procedure AddToCacheCRMTransactionCurrency(CRMTransactioncurrency: Record "CRM Transactioncurrency")
    var
    begin
        TempCRMTransactioncurrency := CRMTransactioncurrency;
        TempCRMTransactioncurrency.INSERT();
    end;

    LOCAL procedure CreateCRMTransactioncurrency(VAR CRMTransactioncurrency: Record "CRM Transactioncurrency"; CurrencyCode: Code[10])
    var
    begin
        WITH CRMTransactioncurrency DO BEGIN
            INIT;
            ISOCurrencyCode := COPYSTR(CurrencyCode, 1, MAXSTRLEN(ISOCurrencyCode));
            CurrencyName := ISOCurrencyCode;
            CurrencySymbol := ISOCurrencyCode;
            CurrencyPrecision := CRMTypeHelper.GetCRMCurrencyDefaultPrecision();
            ExchangeRate := GetCRMLCYToFCYExchangeRate(ISOCurrencyCode);
            INSERT;
        END;
    end;

    procedure GetCRMLCYToFCYExchangeRate(ToCurrencyISOCode: Text[10]): Decimal
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
        CRMTransactioncurrency: Record "CRM Transactioncurrency";
    begin
        CRMConnectionSetup.GET();
        IF ISNULLGUID(CRMConnectionSetup.BaseCurrencyId) THEN
            ERROR(BaseCurrencyIsNullErr);
        IF ToCurrencyISOCode = DELCHR(CRMConnectionSetup.BaseCurrencySymbol) THEN
            EXIT(1.0);

        CRMTransactioncurrency.SETRANGE(TransactionCurrencyId, CRMConnectionSetup.BaseCurrencyId);
        IF NOT FindCachedCRMTransactionCurrency(CRMTransactioncurrency) THEN
            ERROR(DynamicsCRMTransactionCurrencyRecordNotFoundErr, CRMConnectionSetup.BaseCurrencySymbol, CRMProductName.SHORT);
        EXIT(GetFCYtoFCYExchangeRate(CRMTransactioncurrency.ISOCurrencyCode, ToCurrencyISOCode));
    end;

    procedure GetFCYtoFCYExchangeRate(FromFCY: Code[10]; ToFCY: Code[10]): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
        NAVLCYCode: Code[10];

        CalculatedExchangeRate: Decimal;
    begin
        FromFCY := DELCHR(FromFCY);
        ToFCY := DELCHR(ToFCY);
        IF (FromFCY = '') OR (ToFCY = '') THEN
            ERROR(CRMBaseCurrencyNotFoundInNAVErr, '', ToFCY, FromFCY);

        IF ToFCY = FromFCY THEN
            EXIT(1.0);

        NavLCYCode := GetNavLCYCode();
        IF ToFCY = NavLCYCode THEN
            ToFCY := '';

        IF FromFCY = NavLCYCode THEN
            EXIT(CurrencyExchangeRate.GetCurrentCurrencyFactor(ToFCY));

        IF NOT Currency.GET(FromFCY) THEN
            ERROR(CRMBaseCurrencyNotFoundInNAVErr, FromFCY, ToFCY, FromFCY);


        // In CRM exchange rate is inverted, so ExchangeAmtFCYToFCY takes (ToFCY,FromFCY) instead of (FromFCY,ToFCY)
        CalculatedExchangeRate := CurrencyExchangeRate.ExchangeAmtFCYToFCY(WORKDATE, ToFCY, FromFCY, 1);
        CalculatedExchangeRate := ROUND(CalculatedExchangeRate, GetCRMExchangeRateRoundingPrecision, '=');
        EXIT(CalculatedExchangeRate);
    end;

    LOCAL procedure GetCRMExchangeRateRoundingPrecision(): Decimal
    begin
        EXIT(0.0000000001);
    end;
    //for Product/Item
    procedure UpdateCRMProductAfterInsertRecord(VAR CRMProduct: Record "CRM Product")
    var
    begin
        //DestinationRecordRef.SETTABLE(CRMProduct);
        UpdateCRMPriceListItem(CRMProduct);
        CRMTypeHelper.SetCRMProductStateToActive(CRMProduct);
        CRMProduct.MODIFY();
        //DestinationRecordRef.GETTABLE(CRMProduct);
    end;

    LOCAL procedure UpdateCRMProductBeforeInsertRecord(VAR CRMProduct: Record "CRM Product")
    var
    begin
        //DestinationRecordRef.SETTABLE(CRMProduct);
        CRMTypeHelper.SetCRMDecimalsSupportedValue(CRMProduct);
        //DestinationRecordRef.GETTABLE(CRMProduct);
    end;

    LOCAL procedure UpdateItemAfterTransferRecordFields(CRMProduct: Record "CRM Product"; VAR Item: Record Item) AdditionalFieldsWereModified: Boolean
    var
        Blocked: Boolean;
    begin
        //SourceRecordRef.SETTABLE(CRMProduct);
        //DestinationRecordRef.SETTABLE(Item);

        Blocked := CRMProduct.StateCode <> CRMProduct.StateCode::Active;
        IF CRMTypeHelper.UpdateItemBlockedIfChanged(Item, Blocked) THEN
            //DestinationRecordRef.GETTABLE(Item);
            AdditionalFieldsWereModified := TRUE;

    end;

    procedure UpdateCRMPriceListItem(VAR CRMProduct: Record "CRM Product") AdditionalFieldsWereModified: Boolean
    var
        CRMProductpricelevel: Record "CRM Productpricelevel";
    begin
        IF ISNULLGUID(CRMProduct.ProductId) THEN
            EXIT(FALSE);

        AdditionalFieldsWereModified := SetCRMDefaultPriceListOnProduct(CRMProduct);
        CRMProductpricelevel.SETRANGE(ProductId, CRMProduct.ProductId);
        IF CRMProductpricelevel.FINDFIRST() THEN
            EXIT(UpdateCRMProductpricelevel(CRMProductpricelevel, CRMProduct) OR AdditionalFieldsWereModified);

        CreateCRMProductpricelevelForProduct(CRMProduct, CRMProduct.PriceLevelId);
        EXIT(TRUE);
    end;

    LOCAL procedure CreateCRMProductpricelevelForProduct(CRMProduct: Record "CRM Product"; NewPriceLevelId: GUID)
    var
        CRMProductpricelevel: Record "CRM Productpricelevel";
    begin
        WITH CRMProductpricelevel DO BEGIN
            INIT();
            PriceLevelId := NewPriceLevelId;
            UoMId := CRMProduct.DefaultUoMId;
            UoMScheduleId := CRMProduct.DefaultUoMScheduleId;
            ProductId := CRMProduct.ProductId;
            Amount := CRMProduct.Price;
            TransactionCurrencyId := CRMProduct.TransactionCurrencyId;
            ProductNumber := CRMProduct.ProductNumber;
            INSERT();
        END;
    end;

    LOCAL procedure UpdateCRMProductpricelevel(VAR CRMProductpricelevel: Record "CRM Productpricelevel"; CRMProduct: Record "CRM Product") AdditionalFieldsWereModified: Boolean
    var
    begin
        WITH CRMProductpricelevel DO BEGIN
            IF PriceLevelId <> CRMProduct.PriceLevelId THEN BEGIN
                PriceLevelId := CRMProduct.PriceLevelId;
                AdditionalFieldsWereModified := TRUE;
            END;

            IF UoMId <> CRMProduct.DefaultUoMId THEN BEGIN
                UoMId := CRMProduct.DefaultUoMId;
                AdditionalFieldsWereModified := TRUE;
            END;

            IF UoMScheduleId <> CRMProduct.DefaultUoMScheduleId THEN BEGIN
                UoMScheduleId := CRMProduct.DefaultUoMScheduleId;
                AdditionalFieldsWereModified := TRUE;
            END;

            IF Amount <> CRMProduct.Price THEN BEGIN
                Amount := CRMProduct.Price;
                AdditionalFieldsWereModified := TRUE;
            END;

            IF TransactionCurrencyId <> CRMProduct.TransactionCurrencyId THEN BEGIN
                TransactionCurrencyId := CRMProduct.TransactionCurrencyId;
                AdditionalFieldsWereModified := TRUE;
            END;

            IF ProductNumber <> CRMProduct.ProductNumber THEN BEGIN
                ProductNumber := CRMProduct.ProductNumber;
                AdditionalFieldsWereModified := TRUE;
            END;

            IF AdditionalFieldsWereModified THEN
                MODIFY();
        END;
    end;

    local procedure SetCRMDefaultPriceListOnProduct(VAR CRMProduct: Record "CRM Product") AdditionalFieldsWereModified: Boolean
    var
        CRMPricelevel: Record "CRM Pricelevel";
    begin
        FindCRMDefaultPriceList(CRMPricelevel);

        IF CRMProduct.PriceLevelId <> CRMPricelevel.PriceLevelId THEN BEGIN
            CRMProduct.PriceLevelId := CRMPricelevel.PriceLevelId;
            AdditionalFieldsWereModified := TRUE;
        END;
    end;

    procedure FindCRMDefaultPriceList(VAR CRMPricelevel: Record "CRM Pricelevel")
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
    begin
        WITH CRMConnectionSetup DO BEGIN
            GET;
            IF NOT FindCRMPriceList(CRMPricelevel, "Default CRM Price List ID") THEN BEGIN
                CreateCRMDefaultPriceList(CRMPricelevel);
                VALIDATE("Default CRM Price List ID", CRMPricelevel.PriceLevelId);
                MODIFY;
            END;
        END;
    end;

    LOCAL procedure FindCRMPriceList(VAR CRMPricelevel: Record "CRM Pricelevel"; PriceListId: GUID): Boolean
    var
    begin
        IF NOT ISNULLGUID(PriceListId) THEN BEGIN
            CRMPricelevel.RESET();
            CRMPricelevel.SETRANGE(PriceLevelId, PriceListId);
            EXIT(FindCachedCRMPriceLevel(CRMPricelevel));
        END;
    end;

    LOCAL procedure FindCachedCRMPriceLevel(VAR CRMPricelevel: Record "CRM Pricelevel"): Boolean
    var
    begin
        IF NOT CacheCRMPriceLevel THEN
            EXIT(FALSE);
        TempCRMPricelevel.COPY(CRMPricelevel);
        IF TempCRMPricelevel.FINDFIRST() THEN BEGIN
            CRMPricelevel.COPY(TempCRMPricelevel);
            EXIT(TRUE);
        END;
    end;


    LOCAL procedure CacheCRMPriceLevel(): Boolean
    var
        CRMPricelevel: Record "CRM Pricelevel";
    begin
        TempCRMPricelevel.RESET();
        IF TempCRMPricelevel.ISEMPTY() THEN
            IF CRMPricelevel.FINDSET() THEN
                REPEAT
                    AddToCacheCRMPriceLevel(CRMPricelevel)
                UNTIL CRMPricelevel.NEXT() = 0;
        EXIT(NOT TempCRMPricelevel.ISEMPTY());
    end;

    LOCAL procedure CreateCRMDefaultPriceList(VAR CRMPricelevel: Record "CRM Pricelevel")
    var
        CRMTransactioncurrency: Record "CRM Transactioncurrency";
    begin
        WITH CRMPricelevel DO BEGIN
            RESET();
            SETRANGE(Name, GetDefaultNAVPriceListName());
            IF NOT FINDFIRST() THEN BEGIN
                INIT();
                Name := GetDefaultNAVPriceListName();
                FindNAVLocalCurrencyInCRM(CRMTransactioncurrency);
                TransactionCurrencyId := CRMTransactioncurrency.TransactionCurrencyId;
                TransactionCurrencyIdName := CRMTransactioncurrency.CurrencyName;
                INSERT;

                AddToCacheCRMPriceLevel(CRMPricelevel);
            END;
        END;
    end;

    LOCAL procedure AddToCacheCRMPriceLevel(CRMPricelevel: Record "CRM Pricelevel")
    begin
        TempCRMPricelevel := CRMPricelevel;
        TempCRMPricelevel.INSERT();
    end;

    LOCAL procedure GetDefaultNAVPriceListName(): Text[50]
    begin
        EXIT(STRSUBSTNO(DefaultNAVPriceListNameTxt, PRODUCTNAME.SHORT));
    end;

    var
        TempCRMPricelevel: Record "CRM Pricelevel" temporary;
        TempCRMTransactioncurrency: record "CRM Transactioncurrency" temporary;
        CRMProductName: Codeunit "CRM Product Name";
        CRMTypeHelper: Codeunit "CRM Synch. Helper";

        CRMBaseCurrencyNotFoundInNAVErr: TextConst comment = 'The currency with the ISO code %1 cannot be found. Therefore, the exchange rate between %2 and %3 cannot be calculated.',
                                ENU = 'The currency with the ISO code %1 cannot be found. Therefore, the exchange rate between %2 and %3 cannot be calculated.';
        DynamicsCRMTransactionCurrencyRecordNotFoundErr: TextConst Comment = 'Cannot find the currency with the value %1 in %2.', ENU = 'Cannot find the currency with the value %1 in %2.';
        DefaultNAVPriceListNameTxt: TextConst comment = '%1 Default Price List', ENU = '%1 Default Price List';
        BaseCurrencyIsNullErr: TextConst comment = 'The base currency is not defined. Disable and enable CRM connection to initialize setup properly.', ENU = 'The base currency is not defined. Disable and enable CRM connection to initialize setup properly.';
}
