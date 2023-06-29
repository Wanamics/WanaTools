tableextension 87111 "wan Shipping Agent Services" extends "Shipping Agent Services"
{
    fields
    {
        field(87110; "wan Shipping Fixed Cost (LCY)"; Decimal)
        {
            Caption = 'Shipping Fixed Cost (LCY)';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2 : 2;
            BlankZero = true;
        }
        field(87111; "wan Shipping Cost Overhead %"; Decimal)
        {
            Caption = 'Shipping Cost Overhead %';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2 : 2;
            BlankZero = true;
        }
    }
    trigger OnAfterDelete()
    var
        ShippingAgentSetup: Record "wan Shipping Agent Label Setup";
    begin
        ShippingAgentSetup.SetRange("Shipping Agent Code", "Shipping Agent Code");
        ShippingAgentSetup.SetRange("Shipping Agent Service Code", "Code");
        ShippingAgentSetup.DeleteAll(true);
    end;
}
