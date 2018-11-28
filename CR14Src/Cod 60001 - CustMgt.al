codeunit 60001 "IOSH_Customer Management"
{
    trigger OnRun()
    begin

    end;

    //procedure applyCustomerTemplate(pCompanyName: code[30]; TemplateCode: Option UK,EU,ROW; pCustomer: record customer)
    procedure applyCustomerTemplate(TemplateCode: Option UK,EU,ROW; pCustomer: record customer)
    var
        CustTemplate: Record "Customer Template";
        DefaultDim: Record "Default Dimension";
        DefaultDim2: Record "Default Dimension";
        Cust: Record customer;
        SalesRecSetup: Record "Sales & Receivables Setup";
    begin
        //CustTemplate.ChangeCompany(pCompanyName);
        //SalesRecSetup.ChangeCompany(pCompanyName);
        SalesRecSetup.get;
        case TemplateCode of
            Templatecode::EU:
                if custtemplate.get(SalesRecSetup."EU Customer Template Code") then;
            TemplateCode::UK:
                if CustTemplate.get(SalesRecSetup."UK Customer Template Code") then;
            TemplateCode::ROW:
                if CustTemplate.get(SalesRecSetup."ROW Customer Template Code") then;
        end;
        //cust.ChangeCompany(pCompanyName);
        if cust.get(pCustomer."No.") then;

        IF CustTemplate.Code <> '' THEN BEGIN
            IF Cust."Territory Code" = '' THEN
                Cust."Territory Code" := CustTemplate."Territory Code";

            IF cust."Currency Code" = '' THEN
                Cust."Currency Code" := CustTemplate."Currency Code";

            IF cust."Country/Region Code" = '' THEN
                Cust."Country/Region Code" := CustTemplate."Country/Region Code";

            Cust."Customer Posting Group" := CustTemplate."Customer Posting Group";
            Cust."Customer Price Group" := CustTemplate."Customer Price Group";
            IF CustTemplate."Invoice Disc. Code" <> '' THEN
                Cust."Invoice Disc. Code" := CustTemplate."Invoice Disc. Code";
            Cust."Customer Disc. Group" := CustTemplate."Customer Disc. Group";
            Cust."Allow Line Disc." := CustTemplate."Allow Line Disc.";
            Cust."Gen. Bus. Posting Group" := CustTemplate."Gen. Bus. Posting Group";
            Cust."VAT Bus. Posting Group" := CustTemplate."VAT Bus. Posting Group";
            Cust."Payment Terms Code" := CustTemplate."Payment Terms Code";
            Cust."Payment Method Code" := CustTemplate."Payment Method Code";
            Cust."Prices Including VAT" := CustTemplate."Prices Including VAT";
            Cust."Shipment Method Code" := CustTemplate."Shipment Method Code";
            Cust.MODIFY;

            //DefaultDim.ChangeCompany(pCompanyName);
            //DefaultDim2.ChangeCompany(pCompanyName);
            DefaultDim.SETRANGE("Table ID", DATABASE::"Customer Template");
            DefaultDim.SETRANGE("No.", CustTemplate.Code);
            IF DefaultDim.FIND('-') THEN
                REPEAT
                    CLEAR(DefaultDim2);
                    DefaultDim2.INIT;
                    DefaultDim2.VALIDATE("Table ID", DATABASE::Customer);
                    DefaultDim2."No." := Cust."No.";
                    DefaultDim2.VALIDATE("Dimension Code", DefaultDim."Dimension Code");
                    DefaultDim2.VALIDATE("Dimension Value Code", DefaultDim."Dimension Value Code");
                    DefaultDim2."Value Posting" := DefaultDim."Value Posting";
                    DefaultDim2.INSERT(TRUE);
                UNTIL DefaultDim.NEXT = 0;
        END;
    END;


    //procedure createCustomerUseCRMAccount(CRMAccountId: Guid; Var Customer: Record customer; pCompanyName: code[30])
    procedure createCustomerUseCRMAccount(CRMAccountId: Guid; Var Customer: Record customer)
    var
        CRMAccount: Record IOSH_CRMAccount;
        NAVContact: Record Contact;
        CRMIntegrationRecord: Record "CRM Integration Record";
        DestinationRecRef: RecordRef;
        SourceRecRef: RecordRef;
        RecRef: RecordRef;
        RecordID: RecordId;
    begin

        if CRMAccount.get(CRMAccountId) then begin
            Customer.init;
            Customer.Name := CRMAccount.Name;
            Customer.Contact := CRMAccount.Address1_PrimaryContactName;
            customer.Address := CRMAccount.Address1_Line1;
            Customer."Address 2" := CRMAccount.Address1_Line2;
            Customer."Post Code" := CRMAccount.Address1_PostalCode;
            Customer.City := CRMAccount.Address1_City;
            Customer."Country/Region Code" := CRMAccount.Address1_Country;
            Customer.County := CRMAccount.Address1_StateOrProvince;
            Customer."E-Mail" := CRMAccount.EMailAddress1;
            Customer."Fax No." := CRMAccount.Fax;
            Customer."Home Page" := CRMAccount.WebSiteURL;
            Customer."Phone No." := CRMAccount.Telephone1;
            //Need to write code to convert GUID to text
            //Transferfield
            //Customer."Primary Contact No." := CRMAccount.PrimaryContactId;
            Customer.Insert(true); //This will create contact for this account

            /*  DestinationRecRef.GetTable(Customer);
             SourceRecRef.GetTable(CRMAccount);
             ParameterSourceRecordRef := SourceRecRef;
             ParameterDestinationRecordRef := DestinationRecRef;
             TransferField(CRMAccount.FieldNo(CRMAccount.PrimaryContactId), Customer.FieldNo(Customer."Primary Contact No."), '', true); */
            if CRMIntegrationRecord.FindRecordIDFromID(CRMAccount.PrimaryContactId, Database::Contact, RecordID) then begin
                RecRef.get(RecordID);
                if RecRef.Number() = Database::Contact then begin
                    RecRef.SetTable(NAVContact);
                    Customer."Primary Contact No." := NAVContact."No.";
                    Customer.Modify();
                end;
            end;
            //applyCustomerTemplate(pCompanyName, CRMAccount."BC Template Code", Customer);
            applyCustomerTemplate(CRMAccount."BC Template Code", Customer);

            //Create coupling
            //CRMIntegrationRecord.ChangeCompany(pCompanyName);
            CRMIntegrationRecord.CoupleRecordIdToCRMID(Customer.RecordId(), CRMAccountId);
        end else
            Error('Cannot find CRM Account %1', CRMAccountId);

    end;

    //procedure createCustomerUseCRMContact(CRMContactId: Guid; Var Customer: Record customer; pCompanyName: code[30])
    procedure createCustomerUseCRMContact(CRMContactId: Guid; Var Customer: Record customer)
    var
        IOSH_CRMContact: Record IOSH_CRMContact;
        NAVContact: Record Contact;
        CRMIntegrationRecord: Record "CRM Integration Record";
        RecordID: RecordId;
        RecRef: RecordRef;
        ContBusRel: Record "Contact Business Relation";
    begin
        //if contact exists just call create customer from that contact
        //else create customer then contact type company
        //if find crmcontact in contact then create customer from NAV contact
        //Customer.ChangeCompany(pCompanyName);

        if CRMIntegrationRecord.FindRecordIDFromID(CRMContactId, Database::Contact, RecordID) then begin
            //RecRef.ChangeCompany(pCompanyName);
            //NAVContact.ChangeCompany(pCompanyName);
            //ContBusRel.ChangeCompany(pCompanyName);
            RecRef.get(RecordID);
            if RecRef.Number() = Database::Contact then begin
                RecRef.SetTable(NAVContact);
                if CheckForExistingRelationships(ContBusRel, ContBusRel."Link to Table"::Customer, NAVContact) then begin
                    Customer.get(ContBusRel."No.");
                    exit;
                end else begin
                    //CreateCustomer(Customer, NAVContact, pCompanyName);
                    if IOSH_CRMContact.get(CRMContactId) then
                        createCustomerFromNAVContact(NAVContact, IOSH_CRMContact."BC Template Code");
                    //Apply template 
                    //applyCustomerTemplate(pCompanyName, IOSH_CRMContact."BC Template Code", Customer);     
                end;
            end;

        end else begin

            if IOSH_CRMContact.get(CRMContactId) then begin
                createNAVContact(CRMContactId, NAVContact);
                createCustomerFromNAVContact(NAVContact, IOSH_CRMContact."BC Template Code");
                //find integration record id
                // Customer.init;
                // Customer.Name := IOSH_CRMContact.FullName;
                // Customer."Partner Type" := Customer."Partner Type"::Person;
                // Customer.Address := IOSH_CRMContact.Address1_Line1;
                // Customer."Address 2" := IOSH_CRMContact.Address1_Line2;
                // Customer."Address 2" := IOSH_CRMContact.Address1_Line2;
                // Customer."Post Code" := IOSH_CRMContact.Address1_PostalCode;
                // Customer.City := IOSH_CRMContact.Address1_City;
                // Customer."Country/Region Code" := IOSH_CRMContact.Address1_Country;
                // Customer.County := IOSH_CRMContact.Address1_StateOrProvince;
                // Customer."E-Mail" := IOSH_CRMContact.EMailAddress1;
                // Customer."Fax No." := IOSH_CRMContact.Fax;
                // Customer."Home Page" := IOSH_CRMContact.WebSiteURL;
                // Customer."Phone No." := IOSH_CRMContact.Telephone1;
                // Customer."Dynamics 365 Contact Customer" := true;
                // Customer.insert(True); 

                // //applyCustomerTemplate(pCompanyName, IOSH_CRMContact."BC Template Code", Customer);
                // applyCustomerTemplate(IOSH_CRMContact."BC Template Code", Customer);

                //Couple contact with CRM contact instead of Customer as it's not going to create account in CRM
                //CRMIntegrationRecord.ChangeCompany((pCompanyName));
                CRMIntegrationRecord.CoupleRecordIdToCRMID(NAVContact.RecordId(), CRMContactId);
            end else
                Error('Cannot find CRM Contact %1', CRMContactId);
        end;
    end;

    procedure UpdateNavCustomer(CRMAccountId: Guid; Var Customer: Record customer)
    var
        CRMAccount: Record IOSH_CRMAccount;
    begin
        if CRMAccount.get(CRMAccountId) then begin
            Customer.Name := CRMAccount.Name;
            Customer.Contact := CRMAccount.Address1_PrimaryContactName;
            customer.Address := CRMAccount.Address1_Line1;
            Customer."Address 2" := CRMAccount.Address1_Line2;
            Customer."Post Code" := CRMAccount.Address1_PostalCode;
            Customer.City := CRMAccount.Address1_City;
            Customer."Country/Region Code" := CRMAccount.Address1_Country;
            Customer.County := CRMAccount.Address1_StateOrProvince;
            Customer."E-Mail" := CRMAccount.EMailAddress1;
            Customer."Fax No." := CRMAccount.Fax;
            Customer."Home Page" := CRMAccount.WebSiteURL;
            Customer."Phone No." := CRMAccount.Telephone1;
            Customer."Primary Contact No." := CRMAccount.PrimaryContactId;
            Customer.Modify(true) //This will create contact for this account
            //InsertNewContact(Customer, NAVContact, pCompanyName);
        end else
            Error('Cannot find CRM Account %1', CRMAccountId);
    end;

    procedure UpdateCRMAccount(Cust: Record customer)
    var
        CRMAccount: Record IOSH_CRMAccount;
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMAccountId: Guid;

    begin
        if CRMIntegrationRecord.FindIDFromRecordID(Cust.RecordId(), CRMAccountId) then
            if CRMAccount.get(CRMAccountId) then begin
                if Cust."Last Modified Date Time" > CRMAccount.ModifiedOn then begin
                    CRMAccount.Name := Cust.Name;
                    CRMAccount.Address1_PrimaryContactName := Cust.Contact;
                    CRMAccount.Address1_Line1 := Cust.Address;
                    CRMAccount.Address1_Line2 := Cust."Address 2";
                    CRMAccount.Address1_PostalCode := Cust."Post Code";
                    CRMAccount.Address1_City := Cust.City;
                    CRMAccount.Address1_Country := Cust."Country/Region Code";
                    CRMAccount.Address1_StateOrProvince := Cust.County;
                    CRMAccount.EMailAddress1 := Cust."E-Mail";
                    CRMAccount.Fax := Cust."Fax No.";
                    CRMAccount.WebSiteURL := Cust."Home Page";
                    CRMAccount.Telephone1 := Cust."Phone No.";
                    CRMAccount.PrimaryContactId := Cust."Primary Contact No.";
                    CRMAccount.Modify();
                end;
            end else
                Error('Cannot find CRM Account %1', CRMAccountId);
    end;

    procedure updateCRMContact(NavContact: Record Contact)
    var
        IOSH_CRMContact: Record IOSH_CRMContact;
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMContactID: Guid;
        NAVModifiedOn: DateTime;
    begin
        NAVModifiedOn := CREATEDATETIME(NavContact."Last Date Modified", NavContact."Last Time Modified");
        //Need to check is this the correct table to get crm rec
        if CRMIntegrationRecord.FindIDFromRecordID(NavContact.RecordId(), CRMContactID) then
            if IOSH_CRMContact.get(CRMContactID) then begin
                //find integration record id
                if NAVModifiedOn > IOSH_CRMContact.ModifiedOn then begin
                    IOSH_CRMContact.FullName := NavContact.Name;
                    IOSH_CRMContact.Address1_Line1 := NavContact.Address;
                    IOSH_CRMContact.Address1_Line2 := NavContact."Address 2";
                    IOSH_CRMContact.Address1_PostalCode := NavContact."Post Code";
                    IOSH_CRMContact.Address1_City := NavContact.City;
                    IOSH_CRMContact.Address1_Country := NavContact."Country/Region Code";
                    IOSH_CRMContact.Address1_StateOrProvince := NavContact.County;
                    IOSH_CRMContact.EMailAddress1 := NavContact."E-Mail";
                    IOSH_CRMContact.Fax := NavContact."Fax No.";
                    IOSH_CRMContact.FirstName := NavContact."First Name";
                    IOSH_CRMContact.MiddleName := NavContact."Middle Name";
                    IOSH_CRMContact.LastName := NavContact.Surname;
                    IOSH_CRMContact.MobilePhone := NavContact."Mobile Phone No.";
                    IOSH_CRMContact.WebSiteUrl := NavContact."Home Page";
                    IOSH_CRMContact.Telephone1 := NavContact."Phone No.";
                    IOSH_CRMContact.ModifiedOn := CreateDateTime(NavContact."Last Date Modified", NavContact."Last Time Modified");
                    IOSH_CRMContact.modify;
                end;
            end else
                Error('Cannot find CRM Contact %1', CRMContactId);
    end;

    procedure updateNAVContact(CRMContactId: Guid; NavContact: Record Contact)
    var
        IOSH_CRMContact: Record IOSH_CRMContact;
        lastDateTime: DateTime;
        CRMIntegrationRecord: Record "CRM Integration Record";
        xRec: Record Contact;
    begin
        lastDateTime := CREATEDATETIME(NavContact."Last Date Modified", NavContact."Last Time Modified");
        xRec := NavContact;
        if IOSH_CRMContact.get(CRMContactId) then begin
            if lastDateTime < IOSH_CRMContact.ModifiedOn then begin
                //find integration record id
                NavContact.Name := IOSH_CRMContact.FullName;
                NavContact.Type := NavContact.Type::Person;
                NavContact.Address := IOSH_CRMContact.Address1_Line1;
                NavContact."Address 2" := IOSH_CRMContact.Address1_Line2;
                NavContact."Address 2" := IOSH_CRMContact.Address1_Line2;
                NavContact."Post Code" := IOSH_CRMContact.Address1_PostalCode;
                NavContact.City := IOSH_CRMContact.Address1_City;
                NavContact."Country/Region Code" := IOSH_CRMContact.Address1_Country;
                NavContact.County := IOSH_CRMContact.Address1_StateOrProvince;
                NavContact."E-Mail" := IOSH_CRMContact.EMailAddress1;
                NavContact."Fax No." := IOSH_CRMContact.Fax;
                NavContact."First Name" := IOSH_CRMContact.FirstName;
                NavContact."Middle Name" := IOSH_CRMContact.MiddleName;
                NavContact.Surname := IOSH_CRMContact.LastName;
                NavContact."Mobile Phone No." := IOSH_CRMContact.MobilePhone;
                NavContact."Home Page" := IOSH_CRMContact.WebSiteUrl;
                NavContact."Phone No." := IOSH_CRMContact.Telephone1;
                NavContact.OnModify(xRec);
                NavContact.Modify(true);

                /* NavContact."Last Date Modified" := DT2Date(IOSH_CRMContact.ModifiedOn);
                NavContact."Last Time Modified" := DT2Time(IOSH_CRMContact.ModifiedOn);
                NavContact.Modify(false); */
            end;
        end else
            Error('Cannot find CRM Contact %1', CRMContactId);


    end;
    //Create Customer if CRM Contact has create customer in BC for data migration
    procedure createCustomerFromNAVContact(var Contact: Record Contact; BCTemplateCode: Option UK,EU,ROW)
    var
        CRMContact: Record "CRM Contact";
        NAVContact: Record Contact;
        Cust: Record Customer;
        ContBusRel: Record "Contact Business Relation";
        RMSetup: Record "Marketing Setup";
        TemplateCode: code[10];
        SalesRecSetup: Record "Sales & Receivables Setup";
    begin
        //if contact exists just call create customer from that contact
        //else create customer then contact

        //find integration record id
        SalesRecSetup.get;
        case BCTemplateCode of
            BCTemplatecode::EU:
                TemplateCode := SalesRecSetup."EU Customer Template Code";
            BCTemplateCode::UK:
                TemplateCode := SalesRecSetup."UK Customer Template Code";
            BCTemplateCode::ROW:
                TemplateCode := SalesRecSetup."ROW Customer Template Code";
        end;
        Contact.CreateCustomer(templateCode);
        //updateCustomer
        RMSetup.GET;
        RMSetup.TESTFIELD("Bus. Rel. Code for Customers");
        if ContBusRel.get(Contact."No.", RMSetup."Bus. Rel. Code for Customers") then
            if cust.get(ContBusRel."No.") then begin
                Cust."Dynamics 365 Contact Customer" := true;
                Cust.Modify();
            end;
    end;

    procedure createNAVContact(CRMContactId: Guid; var NavContact: Record Contact)
    var
        IOSH_CRMContact: Record IOSH_CRMContact;
        CRMIntegrationRecord: Record "CRM Integration Record";
        ContBusRel: Record "Contact Business Relation";
        RecRef: RecordRef;
        RecordID: RecordId;
    begin
        //if contact exists just call create customer from that contact
        //else create customer then contact type company
        if IOSH_CRMContact.get(CRMContactId) then begin
            //find integration record id
            NavContact.init;
            NavContact.Name := IOSH_CRMContact.FullName;
            NavContact.Type := NavContact.Type::Person;
            NavContact.Address := IOSH_CRMContact.Address1_Line1;
            NavContact."Address 2" := IOSH_CRMContact.Address1_Line2;
            NavContact."Address 2" := IOSH_CRMContact.Address1_Line2;
            NavContact."Post Code" := IOSH_CRMContact.Address1_PostalCode;
            NavContact.City := IOSH_CRMContact.Address1_City;
            NavContact."Country/Region Code" := IOSH_CRMContact.Address1_Country;
            NavContact.County := IOSH_CRMContact.Address1_StateOrProvince;
            NavContact."E-Mail" := IOSH_CRMContact.EMailAddress1;
            NavContact."Fax No." := IOSH_CRMContact.Fax;
            NavContact."First Name" := IOSH_CRMContact.FirstName;
            NavContact."Middle Name" := IOSH_CRMContact.MiddleName;
            NavContact.Surname := IOSH_CRMContact.LastName;
            NavContact."Mobile Phone No." := IOSH_CRMContact.MobilePhone;
            NavContact."Home Page" := IOSH_CRMContact.WebSiteUrl;
            NavContact."Phone No." := IOSH_CRMContact.Telephone1;
            NavContact.insert(True); //create only customer if the contact already sync
            CRMIntegrationRecord.CoupleRecordIdToCRMID(NAVContact.RecordId(), CRMContactId);
        end else
            Error('Cannot find CRM Contact %1', CRMContactId);

    end;

    procedure CheckForExistingRelationships(Var ContBusRel: Record "Contact Business Relation"; LinkToTable: Option;
    Contact: Record Contact): Boolean
    var

    begin
        IF Contact."No." <> '' THEN BEGIN
            IF FindByContact(ContBusRel, LinkToTable, Contact."No.") THEN
                exit(true);

            IF FindByRelation(ContbusRel, LinkToTable, ContBusRel."No.") THEN
                exit(true);
        END;
    end;

    procedure FindByContact(Var ContBusRel: record "Contact Business Relation"; LinkType: Option; ContactNo: Code[20]): Boolean
    begin
        ContBusRel.RESET;
        ContBusRel.SETCURRENTKEY("Link to Table", "Contact No.");
        ContBusRel.SETRANGE("Link to Table", LinkType);
        ContBusRel.SETRANGE("Contact No.", ContactNo);
        EXIT(ContBusRel.FINDFIRST);
    end;

    procedure FindByRelation(Var ContBusRel: record "Contact Business Relation"; LinkType: Option; LinkNo: Code[20]): Boolean
    begin
        ContBusRel.RESET;
        ContBusRel.SETCURRENTKEY("Link to Table", "No.");
        ContBusRel.SETRANGE("Link to Table", LinkType);
        ContBusRel.SETRANGE("No.", LinkNo);
        EXIT(ContBusRel.FINDFIRST);
    end;

    // procedure TransferField(SourceFieldNo: Integer; DestinationFieldNo: Integer; ConstantValue: Text; ValidateDestinationField: Boolean): Boolean
    // var
    //     DestinationFieldRef: FieldRef;
    //     SourceFieldRef: FieldRef;

    // begin
    //     DestinationFieldRef := ParameterDestinationRecordRef.FIELD(DestinationFieldNo);

    //     SourceFieldRef := ParameterSourceRecordRef.FIELD(SourceFieldNo);

    //     //IF IsFieldModified(SourceFieldRef,DestinationFieldRef) THEN
    //     EXIT(TransferFieldData(SourceFieldRef, DestinationFieldRef, ValidateDestinationField));

    //     EXIT(FALSE);
    // end;

    // procedure TransferFieldData(VAR SourceFieldRef: FieldRef; VAR DestinationFieldRef: FieldRef; ValidateDestinationField: Boolean): Boolean
    // var
    //     NewValue: Variant;
    //     OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
    // begin
    //     // OnTransferFieldData is an event for handling an exceptional mapping that is not implemented by integration records
    //     // OnTransferFieldData(SourceFieldRef,DestinationFieldRef,NewValue,IsValueFound,NeedsConversion);
    //     /*     IF IsValueFound THEN BEGIN
    //         IF NOT NeedsConversion THEN
    //             EXIT(SetDestinationValue(DestinationFieldRef,NewValue,ValidateDestinationField));
    //         END ELSE */
    //     NewValue := SourceFieldRef.VALUE;

    //     /* 
    //         IF NOT NeedsConversion AND
    //         (SourceFieldRef.TYPE = DestinationFieldRef.TYPE) AND (DestinationFieldRef.LENGTH >= SourceFieldRef.LENGTH)
    //         THEN
    //         EXIT(SetDestinationValue(DestinationFieldRef,SourceFieldRef.VALUE,ValidateDestinationField)); */
    //     //EXIT(OutlookSynchTypeConv.EvaluateTextToFieldRef(FORMAT(NewValue), DestinationFieldRef, ValidateDestinationField));
    //     EXIT(SetDestinationValue(DestinationFieldRef, SourceFieldRef.VALUE, ValidateDestinationField));

    // end;

    // procedure SetDestinationValue(VAR DestinationFieldRef: FieldRef; NewValue: Variant; ValidateDestinationField: Boolean): Boolean
    // var
    //     currValue: Variant;
    //     IsModified: boolean;
    // begin
    //     CurrValue := FORMAT(DestinationFieldRef.VALUE);
    //     IsModified := (FORMAT(CurrValue) <> FORMAT(NewValue));
    //     DestinationFieldRef.VALUE := NewValue;
    //     IF IsModified AND ValidateDestinationField THEN
    //         DestinationFieldRef.VALIDATE;
    //     EXIT(IsModified);
    // end;
    // procedure InsertNewContact(VAR Cust: Record Customer; Var Cont: Record Contact; pCompanyName: code[30])
    // var
    //     RMSetup: Record "Marketing Setup";
    //     //Cont: Record Contact;
    //     ContBusRel: Record "Contact Business Relation";

    // begin
    //     RMSetup.ChangeCompany(pCompanyName);
    //     RMSetup.GET;
    //     IF RMSetup."Bus. Rel. Code for Customers" = '' THEN
    //         EXIT;

    //     Cont.ChangeCompany(pCompanyName);
    //     WITH Cont DO BEGIN
    //         INIT;
    //         TRANSFERFIELDS(Cust);
    //         VALIDATE(Name);
    //         VALIDATE("E-Mail");
    //         "No." := '';
    //         "No. Series" := '';
    //         RMSetup.TESTFIELD("Contact Nos.");
    //         TisFunc.InitSeries(RMSetup."Contact Nos.", '', 0D, "No.", "No. Series", pCompanyName);
    //         Type := Type::Company;
    //         TypeChange;
    //         SetSkipDefault;
    //         INSERT(TRUE);
    //     END;

    //     ContBusRel.ChangeCompany(pCompanyName);
    //     WITH ContBusRel DO BEGIN
    //         INIT;
    //         "Contact No." := Cont."No.";
    //         "Business Relation Code" := RMSetup."Bus. Rel. Code for Customers";
    //         "Link to Table" := "Link to Table"::Customer;
    //         "No." := Cust."No.";
    //         INSERT(TRUE);
    //     END;
    // end;

    // procedure CreateCustomer(var Cust: Record Customer; NAVContact: Record Contact; pCompany: code[30])
    // var
    //     RMSetup: Record "Marketing Setup";
    //     ContBusRel: Record "Contact Business Relation";
    //     NoSeries: code[20];
    //     VATRegNo: text[20];
    // begin
    //     RMSetup.ChangeCompany(pCompany);
    //     RMSetup.GET;
    //     RMSetup.TESTFIELD("Bus. Rel. Code for Customers");
    //     Cust.ChangeCompany(pCompany); //does this really need when we already change company pre to this call

    //     Cust.SetInsertFromContact(TRUE);
    //     Cust."Contact Type" := NavContact.Type;
    //     Cust.INSERT(TRUE);
    //     Cust.SetInsertFromContact(FALSE);

    //     ContBusRel.ChangeCompany(pCompany);
    //     ContBusRel."Contact No." := Navcontact."No.";
    //     ContBusRel."Business Relation Code" := RMSetup."Bus. Rel. Code for Customers";
    //     ContBusRel."Link to Table" := ContBusRel."Link to Table"::Customer;
    //     ContBusRel."No." := Cust."No.";
    //     ContBusRel.INSERT(TRUE);

    //     //UpdateCustVendBank.UpdateCustomer(Rec,ContBusRel);
    //     Cust.GET(ContBusRel."No.");
    //     NoSeries := cust."No. Series";
    //     VATRegNo := cust."VAT Registration No.";
    //     cust.TRANSFERFIELDS(NAVContact);
    //     cust."No." := ContBusRel."No.";
    //     cust."No. Series" := NoSeries;

    //     IF navcontact.Type = navcontact.Type::Company THEN BEGIN
    //         Cust.VALIDATE(Name, navcontact."Company Name");
    //         Cust.VALIDATE("Country/Region Code", navcontact."Country/Region Code");
    //     END;
    //     Cust.MODIFY;
    // end;
    var
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        ConfigTemplateHeader: Record "Config. Template Header";
        CustomerRecRef: RecordRef;
        DimensionsTemplate: Record "Dimensions Template";
        TisCRMIntegMgt: Codeunit TIS_CRMIntegrationMgt;
        TisFunc: Codeunit TISFunctions;
        ParameterDestinationRecordRef: Recordref;
        ParameterSourceRecordRef: RecordRef;

}