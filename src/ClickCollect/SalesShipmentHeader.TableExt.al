tableextension 87121 "wan Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(50400; "wan Shelf No."; Code[10])
        {
            Caption = 'Shelf No.';
            DataClassification = ToBeClassified;
        }
        field(50401; "wan Delivered"; Boolean)
        {
            Caption = 'Delivered';
            DataClassification = ToBeClassified;
        }
        field(50402; "wan Delivery Date Time"; DateTime)
        {
            Caption = 'Delivery Date Time';
            DataClassification = ToBeClassified;
        }
        field(50403; "wan Delivered by Resource No."; Code[20])
        {
            Caption = 'Delivered by Resource No.';
            DataClassification = ToBeClassified;
            TableRelation = Resource;
        }
    }
    keys
    {
        key(_WMS; "wan Delivered") { }
    }

    procedure GetCustomDocumentNo() ReturnValue: Text
    var
        Handled: Boolean;
        i: Integer;
    begin
        OnBeforeGetCustomDocumentNo(Rec, ReturnValue, Handled);
        if Handled then
            exit;
        while i <= StrLen("External Document No.") do begin
            i += 1;
            if "External Document No."[i] in ['0' .. '9'] then
                ReturnValue += "External Document No."[i]
            else
                exit;
        end;
    end;

    [BusinessEvent(false)]
    local procedure OnBeforeGetCustomDocumentNo(Rec: Record "Sales Shipment Header"; var ReturnValue: Text; var Handled: Boolean)
    begin
    end;
}
