codeunit 60001 "IOSH_Customer Management"
{
    trigger OnRun()
    begin

    end;

    procedure applyCustomerTemplate(pCompanyName: code[30]; TemplateCode: Option UK,EU,ROW; pCustomer: record customer)
    var
        CustTemplate: Record "Customer Template";
        DefaultDim: Record "Default Dimension";
        DefaultDim2: Record "Default Dimension";
        Cust: Record customer;
        SalesRecSetup: Record "Sales & Receivables Setup";
    begin
        CustTemplate.ChangeCompany(pCompanyName);
        SalesRecSetup.ChangeCompany(pCompanyName);
        SalesRecSetup.get;
        case TemplateCode of
            Templatecode::EU:
                if custtemplate.get(SalesRecSetup."EU Customer Template Code") then;
            TemplateCode::UK:
                if CustTemplate.get(SalesRecSetup."UK Customer Template Code") then;
            TemplateCode::ROW:
                if CustTemplate.get(SalesRecSetup."ROW Customer Template Code") then;
        end;
        cust.ChangeCompany(pCompanyName);
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

            DefaultDim.ChangeCompany(pCompanyName);
            DefaultDim2.ChangeCompany(pCompanyName);
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


    procedure createCustomerUseCRMAccount(CRMAccountId: Guid; Var Customer: Record customer; pCompanyName: code[30])
    var
        CRMAccount: Record IOSH_CRMAccount;
        NAVContact: Record Contact;
        CRMIntegrationRecord: Record "CRM Integration Record";

    begin
        Customer.ChangeCompany(pCompanyName);
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
            Customer."Primary Contact No." := CRMAccount.PrimaryContactId;
            Customer.Insert(false); //This will create contact for this account
            InsertNewContact(Customer, NAVContact, pCompanyName);

            applyCustomerTemplate(pCompanyName, CRMAccount."BC Template Code", Customer);

            //Create coupling
            CRMIntegrationRecord.ChangeCompany(pCompanyName);
            CRMIntegrationRecord.CoupleRecordIdToCRMID(Customer.RecordId(), CRMAccountId);

        end else
            Error('Cannot find CRM Account %1', CRMAccountId);

    end;

    procedure createCustomerUseCRMContact(CRMContactId: Guid; Var Customer: Record customer; pCompanyName: code[30])
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
        Customer.ChangeCompany(pCompanyName);

        if TisCRMIntegMgt.FindRecordIDFromID(CRMContactId, Database::Contact, RecordID, pCompanyName) then begin
            RecRef.ChangeCompany(pCompanyName);
            NAVContact.ChangeCompany(pCompanyName);
            ContBusRel.ChangeCompany(pCompanyName);
            RecRef.get(RecordID);
            if RecRef.Number() = Database::Contact then begin
                RecRef.SetTable(NAVContact);
                if CheckForExistingRelationships(ContBusRel, ContBusRel."Link to Table"::Customer, NAVContact) then begin
                    Customer.get(ContBusRel."No.");
                    exit;
                end else begin
                    CreateCustomer(Customer, NAVContact, pCompanyName);
                    //Apply template 
                    if IOSH_CRMContact.get(CRMContactId) then
                        applyCustomerTemplate(pCompanyName, IOSH_CRMContact."BC Template Code", Customer);
                end;
            end;

        end else begin

            if IOSH_CRMContact.get(CRMContactId) then begin
                //find integration record id
                Customer.init;
                Customer.Name := IOSH_CRMContact.FullName;
                Customer."Partner Type" := Customer."Partner Type"::Person;
                Customer.Address := IOSH_CRMContact.Address1_Line1;
                Customer."Address 2" := IOSH_CRMContact.Address1_Line2;
                Customer."Address 2" := IOSH_CRMContact.Address1_Line2;
                Customer."Post Code" := IOSH_CRMContact.Address1_PostalCode;
                Customer.City := IOSH_CRMContact.Address1_City;
                Customer."Country/Region Code" := IOSH_CRMContact.Address1_Country;
                Customer.County := IOSH_CRMContact.Address1_StateOrProvince;
                Customer."E-Mail" := IOSH_CRMContact.EMailAddress1;
                Customer."Fax No." := IOSH_CRMContact.Fax;
                Customer."Home Page" := IOSH_CRMContact.WebSiteURL;
                Customer."Phone No." := IOSH_CRMContact.Telephone1;
                Customer."Dynamics 365 Contact Customer" := true;
                Customer.insert(false); //create only customer if the contact already sync
                InsertNewContact(Customer, NAVContact, pCompanyName);

                applyCustomerTemplate(pCompanyName, IOSH_CRMContact."BC Template Code", Customer);

                //Couple contact with CRM contact instead of Customer as it's not going to create account in CRM
                CRMIntegrationRecord.ChangeCompany((pCompanyName));
                CRMIntegrationRecord.CoupleRecordIdToCRMID(NAVContact.RecordId(), CRMContactId);
            end else
                Error('Cannot find CRM Contact %1', CRMContactId);
        end;
    end;
    //Create Customer if CRM Contact has create customer in BC for data migration
    procedure createCustomerFromNAVContact(var Contact: Record Contact; templateCode: code[10])
    var
        CRMContact: Record "CRM Contact";
        NAVContact: Record Contact;
    begin
        //if contact exists just call create customer from that contact
        //else create customer then contact

        //find integration record id
        Contact.CreateCustomer(templateCode);

    end;

    procedure InsertNewContact(VAR Cust: Record Customer; Var Cont: Record Contact; pCompanyName: code[30])
    var
        RMSetup: Record "Marketing Setup";
        //Cont: Record Contact;
        ContBusRel: Record "Contact Business Relation";

    begin
        RMSetup.ChangeCompany(pCompanyName);
        RMSetup.GET;
        IF RMSetup."Bus. Rel. Code for Customers" = '' THEN
            EXIT;

        Cont.ChangeCompany(pCompanyName);
        WITH Cont DO BEGIN
            INIT;
            TRANSFERFIELDS(Cust);
            VALIDATE(Name);
            VALIDATE("E-Mail");
            "No." := '';
            "No. Series" := '';
            RMSetup.TESTFIELD("Contact Nos.");
            TisFunc.InitSeries(RMSetup."Contact Nos.", '', 0D, "No.", "No. Series", pCompanyName);
            Type := Type::Company;
            TypeChange;
            SetSkipDefault;
            INSERT(TRUE);
        END;

        ContBusRel.ChangeCompany(pCompanyName);
        WITH ContBusRel DO BEGIN
            INIT;
            "Contact No." := Cont."No.";
            "Business Relation Code" := RMSetup."Bus. Rel. Code for Customers";
            "Link to Table" := "Link to Table"::Customer;
            "No." := Cust."No.";
            INSERT(TRUE);
        END;
    end;

    

    procedure CreateCustomer(var Cust: Record Customer; NAVContact: Record Contact; pCompany: code[30])
    var
        RMSetup: Record "Marketing Setup";
        ContBusRel: Record "Contact Business Relation";
        NoSeries: code[20];
        VATRegNo: text[20];
    begin
        RMSetup.ChangeCompany(pCompany);
        RMSetup.GET;
        RMSetup.TESTFIELD("Bus. Rel. Code for Customers");
        Cust.ChangeCompany(pCompany); //does this really need when we already change company pre to this call

        Cust.SetInsertFromContact(TRUE);
        Cust."Contact Type" := NavContact.Type;
        Cust.INSERT(TRUE);
        Cust.SetInsertFromContact(FALSE);

        ContBusRel.ChangeCompany(pCompany);
        ContBusRel."Contact No." := Navcontact."No.";
        ContBusRel."Business Relation Code" := RMSetup."Bus. Rel. Code for Customers";
        ContBusRel."Link to Table" := ContBusRel."Link to Table"::Customer;
        ContBusRel."No." := Cust."No.";
        ContBusRel.INSERT(TRUE);

        //UpdateCustVendBank.UpdateCustomer(Rec,ContBusRel);
        Cust.GET(ContBusRel."No.");
        NoSeries := cust."No. Series";
        VATRegNo := cust."VAT Registration No.";
        cust.TRANSFERFIELDS(NAVContact);
        cust."No." := ContBusRel."No.";
        cust."No. Series" := NoSeries;

        IF navcontact.Type = navcontact.Type::Company THEN BEGIN
            Cust.VALIDATE(Name, navcontact."Company Name");
            Cust.VALIDATE("Country/Region Code", navcontact."Country/Region Code");
        END;
        Cust.MODIFY;


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


    var
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        ConfigTemplateHeader: Record "Config. Template Header";
        CustomerRecRef: RecordRef;

        DimensionsTemplate: Record "Dimensions Template";

        TisCRMIntegMgt: Codeunit TIS_CRMIntegrationMgt;

        TisFunc: Codeunit TISFunctions;

}