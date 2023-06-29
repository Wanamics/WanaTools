table 87120 "wan Click & Collect Employee"
{
    Caption = 'Click & Collect Employee';
    LookupPageID = "wan Click & Collect Employees";
    ReplicateData = true;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(2; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(3; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
        }
        field(4; "Resource No."; Code[20])
        {
            Caption = 'Resource No.';
            DataClassification = ToBeClassified;
            TableRelation = Resource;
        }
        field(5; "Resource Name"; Text[100])
        {
            Caption = 'Resource Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Resource.Name where("No." = field("Resource No.")));
        }
    }

    keys
    {
        key(Key1; "User ID")
        {
            Clustered = true;
        }
        key(Key2; "Shipping Agent Code", "Shipping Agent Service Code")
        {
        }
    }
}
