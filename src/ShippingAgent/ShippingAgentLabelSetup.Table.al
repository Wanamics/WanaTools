table 87110 "wan Shipping Agent Label Setup"
{
    Caption = 'Shipping Agent Label Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            NotBlank = true;
            TableRelation = "Shipping Agent";
        }
        field(2; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
        }
        field(3; "EndPoint"; Text[100])
        {
            Caption = 'EndPoint';
            DataClassification = CustomerContent;
        }
        field(5; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
            BlankZero = true;
        }
        field(10; "Our User Id"; Text[30])
        {
            Caption = 'Our User ID';
            DataClassification = ToBeClassified;
        }
        field(11; "Our Account No."; Code[20])
        {
            Caption = 'Our Account No.';
            DataClassification = ToBeClassified;
        }
        field(12; "Our Center No."; Code[10])
        {
            Caption = 'Our Center No.';
            DataClassification = ToBeClassified;
        }
        field(13; "Our Country Code"; Code[10])
        {
            Caption = 'Our Country Code';
            DataClassification = ToBeClassified;
        }
        field(20; "Service Type"; Text[20])
        {
            Caption = 'Service Type';
            DataClassification = ToBeClassified;
        }
        field(21; "Label Type"; Text[20])
        {
            Caption = 'Label Type';
            DataClassification = ToBeClassified;
        }
        field(22; "Reverse Type"; Text[20])
        {
            Caption = 'Reverse Type';
            DataClassification = ToBeClassified;
        }
        field(23; "Expire Offset"; Integer)
        {
            Caption = 'Expire Offset';
            DataClassification = ToBeClassified;
            BlankZero = true;
        }
    }
    keys
    {
        key(PK; "Shipping Agent Code", "Shipping Agent Service Code")
        {
            Clustered = true;
        }
    }
    procedure Set(var pSalesShipmentHeader: Record "Sales Shipment Header"): Boolean
    begin
        if pSalesShipmentHeader."Shipping Agent Code" = '' then
            exit(false);
        pSalesShipmentHeader.TestField("Shipping Agent Code");
        if not Get(pSalesShipmentHeader."Shipping Agent Code", pSalesShipmentHeader."Shipping Agent Service Code") then
            if not Get(pSalesShipmentHeader."Shipping Agent Code", '') then
                exit(false);
        SetRecFilter();
        exit(true);
    end;

    procedure SetAPIKey(pAPIKey: Text)
    var
        EncryptionManagement: Codeunit "Cryptography Management";
    begin
        if IsolatedStorage.Contains(SystemId, DataScope::Module) then
            IsolatedStorage.Delete((SystemId));
        if EncryptionManagement.IsEncryptionEnabled() and EncryptionManagement.IsEncryptionPossible() then
            IsolatedStorage.Set(SystemId, EncryptionManagement.EncryptText(pAPIKey), DataScope::Module);
    end;

    procedure GetAPIKey() ReturnValue: Text
    var
        EncryptionManagement: Codeunit "Cryptography Management";
        EncryptedValue: Text;
        APIKeyErr: Label 'Get API key error for %1 %2';
    begin
        if not IsolatedStorage.Contains(SystemId, DataScope::Module) then
            exit;
        if IsolatedStorage.Get(SystemId, DataScope::Module, EncryptedValue) and
           EncryptionManagement.IsEncryptionEnabled() and
           EncryptionManagement.IsEncryptionPossible() then
            exit(EncryptionManagement.Decrypt(EncryptedValue))
        else
            Error(APIKeyErr, TableCaption, SystemId);
    end;
}
