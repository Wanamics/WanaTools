table 87111 "wan Shipping Cost"
{
    Caption = 'Shipping Agent Cost';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipment Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(2; "Shipping Agent Services Code"; Code[10])
        {
            Caption = 'Shipment Agent Services Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
        }
        field(4; "Starting Weight"; Decimal)
        {
            Caption = 'Starting Weight';
            DataClassification = ToBeClassified;
        }
        field(5; "Cost (LCY)"; Decimal)
        {
            Caption = 'Cost (LCY)';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2 : 2;
            BlankZero = true;
        }
    }
    keys
    {
        key(PK; "Shipping Agent Code", "Shipping Agent Services Code", "Starting Weight")
        {
            Clustered = true;
        }
    }
    procedure GetShippingCost(pShippingAgentCode: Code[10]; pShippingAgentServiceCode: Code[10]; pWeight: Decimal): Decimal
    var
        ShippingAgentServices: Record "Shipping Agent Services";
    begin
        if ShippingAgentServices.Get(pShippingAgentCode, pShippingAgentServiceCode) then;
        Rec.SetRange("Shipping Agent Code", pShippingAgentCode);
        Rec.SetRange("Shipping Agent Code", pShippingAgentCode);
        Rec.SetFilter("Starting Weight", '..%1', pWeight / 1000);
        if Rec.FindLast() then
            Rec.TestField("Cost (LCY)");
        exit(Round((ShippingAgentServices."wan Shipping Fixed Cost (LCY)" + Rec."Cost (LCY)") * (1 + ShippingAgentServices."wan Shipping Cost Overhead %" / 100)));
    end;
}
