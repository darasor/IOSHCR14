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
        SalesRecSetup.get();
        case TemplateCode of
            Templatecode::EU:
                if custtemplate.get(SalesRecSetup."EU Customer Template Code") then;
            TemplateCode::UK:
                if CustTemplate.get(SalesRecSetup."UK Customer Template Code") then;
            TemplateCode::ROW:
                if CustTemplate.get(SalesRecSetup."ROW Customer Template Code") then;
        end;

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
            Cust.MODIFY();

            DefaultDim.SETRANGE("Table ID", DATABASE::"Customer Template");
            DefaultDim.SETRANGE("No.", CustTemplate.Code);
            IF DefaultDim.FIND('-') THEN
                REPEAT
                    CLEAR(DefaultDim2);
                    DefaultDim2.INIT();
                    DefaultDim2.VALIDATE("Table ID", DATABASE::Customer);
                    DefaultDim2."No." := Cust."No.";
                    DefaultDim2.VALIDATE("Dimension Code", DefaultDim."Dimension Code");
                    DefaultDim2.VALIDATE("Dimension Value Code", DefaultDim."Dimension Value Code");
                    DefaultDim2."Value Posting" := DefaultDim."Value Posting";
                    DefaultDim2.INSERT(TRUE);
                UNTIL DefaultDim.NEXT() = 0;
        END;
    END;

    //procedure createCustomerUseCRMAccount(CRMAccountId: Guid; Var Customer: Record customer; pCompanyName: code[30])
    procedure createCustomerUseCRMAccount(CRMAccountId: Guid; Var Customer: Record customer)
    var
        CRMAccount: Record IOSH_CRMAccount;
        NAVContact: Record Contact;
        CRMIntegrationRecord: Record "CRM Integration Record";
        ContBusRel: Record "Contact Business Relation";
        RMSetup: Record "Marketing Setup";
        contact: Record Contact;
        RecRef: RecordRef;
        RecordID: RecordId;
    begin

        if CRMAccount.get(CRMAccountId) then begin
            Customer.init();
            Customer.validate(Name, Format(CRMAccount.Name, MaxStrLen(Customer.Name)));
            Customer.Contact := Format(CRMAccount.Address1_PrimaryContactName, MaxStrLen(Customer.Contact));
            Customer.address := Format(CRMAccount.Address1_Line1, MaxStrLen(Customer.Address));
            Customer."address 2" := Format(CRMAccount.Address1_Line2, MaxStrLen(Customer."Address 2"));
            Customer."Post Code" := CRMAccount.Address1_PostalCode;
            Customer.city := Format(CRMAccount.Address1_City, MaxStrLen(Customer.city));
            Customer."Country/Region Code" := Format(CRMAccount.Address1_Country, MaxStrLen(Customer."Country/Region Code"));
            Customer.County := Format(CRMAccount.Address1_StateOrProvince, MaxStrLen(Customer.County));
            Customer."E-Mail" := Format(CRMAccount.EMailAddress1, MaxStrLen(Customer."E-Mail"));
            Customer."Fax No." := Format(CRMAccount.Fax, MaxStrLen(Customer."Fax No."));
            Customer."Home Page" := Format(CRMAccount.WebSiteURL, MaxStrLen(Customer."Home Page"));
            Customer."Phone No." := Format(CRMAccount.Telephone1, MaxStrLen(Customer."Phone No."));

            //Need to write code to convert GUID to text
            if not Customer.Insert(false) then //22/02/19 
                                               //if not Customer.Insert(true) then
                                               //Error('Error during create customer was %1', GetLastErrorText()); //22/02/19
                Error('Error during create customer was %1-CRMAccount name: %2', GetLastErrorText(), CRMAccount.Name); //This will create contact for this account
                                                                                                                       //Commit(); //to get Customer No.

            if CRMIntegrationRecord.FindRecordIDFromID(CRMAccount.PrimaryContactId, Database::Contact, RecordID) then begin
                if Contact.get(RecordID) then
                    Customer."Primary Contact No." := Contact."No.";
                Customer.Contact := contact.Name;
                Customer.Modify();
            end else begin
                createCustomerPrimaryContact(CRMAccount.PrimaryContactId, NAVContact, Customer);
                if NOT (NAVContact."No." = '') then begin
                    Customer."Primary Contact No." := NAVContact."No.";
                    Customer.Contact := NAVContact.Name;
                    Customer.Modify();
                end;
            end;
            applyCustomerTemplate(CRMAccount."BC Template Code", Customer);

            //Create coupling
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
            RecRef.get(RecordID);
            if RecRef.Number() = Database::Contact then begin
                RecRef.SetTable(NAVContact);
                if CheckForExistingRelationships(ContBusRel, ContBusRel."Link to Table"::Customer, NAVContact) then begin
                    Customer.get(ContBusRel."No.");
                    exit;
                end else begin
                    if IOSH_CRMContact.get(CRMContactId) then
                        createCustomerFromNAVContact(NAVContact, IOSH_CRMContact."BC Template Code", Customer);
                end;
            end;
        end else begin
            if IOSH_CRMContact.get(CRMContactId) then begin
                createNAVContact(CRMContactId, NAVContact);
                createCustomerFromNAVContact(NAVContact, IOSH_CRMContact."BC Template Code", Customer);
            end else
                Error('Cannot find CRM Contact %1', CRMContactId);
        end;
    end;

    procedure UpdateNavCustomer(CRMAccountId: Guid; Var Customer: Record customer)
    var
        CRMAccount: Record IOSH_CRMAccount;
        Contact: Record Contact;

        RecID: RecordId;

    begin
        if CRMAccount.get(CRMAccountId) then begin

            Customer.validate(Name, Format(CRMAccount.Name, MaxStrLen(Customer.Name)));
            Customer.validate(Name, Format(CRMAccount.Name, MaxStrLen(Customer.Name)));
            Customer.Contact := Format(CRMAccount.Address1_PrimaryContactName, MaxStrLen(Customer.Contact));
            Customer.address := Format(CRMAccount.Address1_Line1, MaxStrLen(Customer.Address));
            Customer."address 2" := Format(CRMAccount.Address1_Line2, MaxStrLen(Customer."Address 2"));
            Customer."Post Code" := CRMAccount.Address1_PostalCode;
            Customer.city := Format(CRMAccount.Address1_City, MaxStrLen(Customer.city));
            Customer."Country/Region Code" := Format(CRMAccount.Address1_Country, MaxStrLen(Customer."Country/Region Code"));
            Customer.County := Format(CRMAccount.Address1_StateOrProvince, MaxStrLen(Customer.County));
            Customer."E-Mail" := Format(CRMAccount.EMailAddress1, MaxStrLen(Customer."E-Mail"));
            Customer."Fax No." := Format(CRMAccount.Fax, MaxStrLen(Customer."Fax No."));
            Customer."Home Page" := Format(CRMAccount.WebSiteURL, MaxStrLen(Customer."Home Page"));
            Customer."Phone No." := Format(CRMAccount.Telephone1, MaxStrLen(Customer."Phone No."));
            if CRMIntegrationRecord.FindRecordIDFromID(CRMAccount.PrimaryContactId, Database::Contact, RecID) then
                if Contact.get(RecID) then
                    Customer."Primary Contact No." := Contact."No.";


            Customer.Modify(true); //This will create contact for this account
            //InsertNewContact(Customer, NAVContact, pCompanyName);
        end else
            Error('Cannot find CRM Account %1', CRMAccountId);
    end;

    procedure UpdateCRMAccount(Cust: Record customer)
    var
        CRMAccount: Record IOSH_CRMAccount;
        CRMIntegrationRecord: Record "CRM Integration Record";
        Contact: Record Contact;
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
                    //25/02/19 b
                    //CRMAccount.PrimaryContactId :=Cust."Primary Contact No." ;
                    if Contact.get(Cust."Primary Contact No.") then
                        if CRMIntegrationRecord.FindIDFromRecordID(Contact.RecordId(), CRMAccountId) then
                            CRMAccount.PrimaryContactId := CRMAccountId;
                    //25/02/19
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
                    IOSH_CRMContact.modify();
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
                NavContact.Address := Format(IOSH_CRMContact.Address1_Line1, MaxStrLen(NavContact.Address));
                NavContact."Address 2" := Format(IOSH_CRMContact.Address1_Line2, MaxStrLen(NavContact."Address 2"));
                NavContact."Post Code" := IOSH_CRMContact.Address1_PostalCode;
                NavContact.City := Format(IOSH_CRMContact.Address1_City, MaxStrLen(NavContact.City));
                //NavContact."Country/Region Code" := IOSH_CRMContact.Address1_Country;
                NavContact."Country/Region Code" := FORMAT(IOSH_CRMContact.Address1_Country, MAXSTRLEN(NavContact."Country/Region Code"));
                NavContact.County := Format(IOSH_CRMContact.Address1_StateOrProvince, MaxStrLen(NavContact.County));
                NavContact."E-Mail" := Format(IOSH_CRMContact.EMailAddress1, MaxStrLen(NavContact."E-Mail"));
                NavContact."Fax No." := IOSH_CRMContact.Fax;
                NavContact."First Name" := Format(IOSH_CRMContact.FirstName, MaxStrLen(NavContact."First Name"));
                NavContact."Middle Name" := Format(IOSH_CRMContact.MiddleName, MaxStrLen(NavContact."Middle Name"));
                NavContact.Surname := Format(IOSH_CRMContact.LastName, MaxStrLen(NavContact.Surname));

                NavContact."Mobile Phone No." := Format(IOSH_CRMContact.MobilePhone, MaxStrLen(NavContact."Mobile Phone No."));
                NavContact."Home Page" := Format(IOSH_CRMContact.WebSiteUrl, MaxStrLen(NavContact."Home Page"));
                NavContact."Phone No." := Format(IOSH_CRMContact.Telephone1, MaxStrLen(NavContact."Phone No."));

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
    procedure createCustomerFromNAVContact(var Contact: Record Contact; BCTemplateCode: Option UK,EU,ROW; Var Cust: record Customer)
    var
        CRMContact: Record "CRM Contact";
        NAVContact: Record Contact;
        SalesRecSetup: Record "Sales & Receivables Setup";
        //Cust: Record Customer;
        ContBusRel: Record "Contact Business Relation";
        RMSetup: Record "Marketing Setup";
        TemplateCode: code[10];

    begin
        //if contact exists just call create customer from that contact
        //else create customer then contact

        //find integration record id
        SalesRecSetup.get();
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
        RMSetup.GET();
        RMSetup.TESTFIELD("Bus. Rel. Code for Customers");
        if ContBusRel.get(Contact."No.", RMSetup."Bus. Rel. Code for Customers") then
            if cust.get(ContBusRel."No.") then begin
                Cust."Dynamics 365 Contact Customer" := true;
                Cust."Contact No" := Contact."No.";
                Cust."Partner Type" := Cust."Partner Type"::Person;
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
            NavContact.init();
            NavContact.Name := IOSH_CRMContact.FullName;
            NavContact.Type := NavContact.Type::Person;
            NavContact.Address := Format(IOSH_CRMContact.Address1_Line1, MaxStrLen(NavContact.Address));
            NavContact."Address 2" := Format(IOSH_CRMContact.Address1_Line2, MaxStrLen(NavContact."Address 2"));
            NavContact."Post Code" := IOSH_CRMContact.Address1_PostalCode;
            NavContact.City := Format(IOSH_CRMContact.Address1_City, MaxStrLen(NavContact.City));
            //NavContact."Country/Region Code" := IOSH_CRMContact.Address1_Country;
            NavContact."Country/Region Code" := FORMAT(IOSH_CRMContact.Address1_Country, MAXSTRLEN(NavContact."Country/Region Code"));
            NavContact.County := Format(IOSH_CRMContact.Address1_StateOrProvince, MaxStrLen(NavContact.County));
            NavContact."E-Mail" := Format(IOSH_CRMContact.EMailAddress1, MaxStrLen(NavContact."E-Mail"));
            NavContact."Fax No." := IOSH_CRMContact.Fax;
            NavContact."First Name" := Format(IOSH_CRMContact.FirstName, MaxStrLen(NavContact."First Name"));
            NavContact."Middle Name" := Format(IOSH_CRMContact.MiddleName, MaxStrLen(NavContact."Middle Name"));
            NavContact.Surname := Format(IOSH_CRMContact.LastName, MaxStrLen(NavContact.Surname));

            NavContact."Mobile Phone No." := Format(IOSH_CRMContact.MobilePhone, MaxStrLen(NavContact."Mobile Phone No."));
            NavContact."Home Page" := Format(IOSH_CRMContact.WebSiteUrl, MaxStrLen(NavContact."Home Page"));
            NavContact."Phone No." := Format(IOSH_CRMContact.Telephone1, MaxStrLen(NavContact."Phone No."));

            NavContact.insert(True); //create only customer if the contact already sync
            //Commit();

            CRMIntegrationRecord.CoupleRecordIdToCRMID(NAVContact.RecordId, CRMContactId);
        end else
            Error('Cannot find CRM Contact %1', CRMContactId);

    end;

    procedure createCustomerPrimaryContact(CRMContactId: Guid; var NavContact: Record Contact; Customer: Record Customer)
    var
        IOSH_CRMContact: Record IOSH_CRMContact;
        CRMIntegrationRecord: Record "CRM Integration Record";
        ContBusRel: Record "Contact Business Relation";
        RMSetup: Record "Marketing Setup";
        ContComp: Record Contact;
        RecRef: RecordRef;
        RecordID: RecordId;
    begin
        //if contact exists just call create customer from that contact
        //else create customer then contact type company
        //Begin 22/02/19 fixing updateCustomerJobQ
        if CRMContactId = '{00000000-0000-0000-0000-000000000000}' then
            exit;
        //End 22/02/19

        if IOSH_CRMContact.get(CRMContactId) then begin
            //find integration record id
            NavContact.init();
            NavContact.Name := IOSH_CRMContact.FullName;
            NavContact.Type := NavContact.Type::Person;
            NavContact.Address := Format(IOSH_CRMContact.Address1_Line1, MaxStrLen(NavContact.Address));
            NavContact."Address 2" := Format(IOSH_CRMContact.Address1_Line2, MaxStrLen(NavContact."Address 2"));
            NavContact."Post Code" := IOSH_CRMContact.Address1_PostalCode;
            NavContact.City := Format(IOSH_CRMContact.Address1_City, MaxStrLen(NavContact.City));
            //NavContact."Country/Region Code" := IOSH_CRMContact.Address1_Country;
            NavContact."Country/Region Code" := FORMAT(IOSH_CRMContact.Address1_Country, MAXSTRLEN(NavContact."Country/Region Code"));
            NavContact.County := Format(IOSH_CRMContact.Address1_StateOrProvince, MaxStrLen(NavContact.County));
            NavContact."E-Mail" := Format(IOSH_CRMContact.EMailAddress1, MaxStrLen(NavContact."E-Mail"));
            NavContact."Fax No." := IOSH_CRMContact.Fax;
            NavContact."First Name" := Format(IOSH_CRMContact.FirstName, MaxStrLen(NavContact."First Name"));
            NavContact."Middle Name" := Format(IOSH_CRMContact.MiddleName, MaxStrLen(NavContact."Middle Name"));
            NavContact.Surname := Format(IOSH_CRMContact.LastName, MaxStrLen(NavContact.Surname));

            NavContact."Mobile Phone No." := Format(IOSH_CRMContact.MobilePhone, MaxStrLen(NavContact."Mobile Phone No."));
            NavContact."Home Page" := Format(IOSH_CRMContact.WebSiteUrl, MaxStrLen(NavContact."Home Page"));
            NavContact."Phone No." := Format(IOSH_CRMContact.Telephone1, MaxStrLen(NavContact."Phone No."));


            ContBusRel.SETCURRENTKEY("Link to Table", "No.");
            ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Customer);
            ContBusRel.SETRANGE("No.", Customer."No.");
            if ContBusRel.FINDFIRST() then
                IF ContComp.GET(ContBusRel."Contact No.") THEN
                    NavContact.validate("Company No.", ContComp."No.");

            NavContact.insert(True); //create only customer if the contact already sync
            //Commit();
            CRMIntegrationRecord.CoupleRecordIdToCRMID(NAVContact.RecordId, CRMContactId);
            // WITH ContBusRel DO BEGIN
            //     INIT;
            //     "Contact No." := NavContact."No.";
            //     "Business Relation Code" := RMSetup."Bus. Rel. Code for Customers";
            //     "Link to Table" := "Link to Table"::Customer;
            //     "No." := Customer."No.";
            //     INSERT(TRUE);
            // END;
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
        CRMIntegrationRecord: Record "CRM Integration Record";
        //ConfigTemplateManagement: Codeunit "Config. Template Management";
        ConfigTemplateHeader: Record "Config. Template Header";
        CustomerRecRef: RecordRef;
        DimensionsTemplate: Record "Dimensions Template";
        TisCRMIntegMgt: Codeunit "TIS CRMIntegrationMgt";
        TisFunc: Codeunit TIS_Functions;
        ParameterDestinationRecordRef: Recordref;
        ParameterSourceRecordRef: RecordRef;
}
