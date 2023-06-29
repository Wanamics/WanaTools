tableextension 87110 "wan Shipping Agent" extends "Shipping Agent"
{
    fields
    {
        field(87110; "wan Tracking Codeunit ID"; Integer)
        {
            Caption = 'Tracking Codeunit Id';
            DataClassification = ToBeClassified;
            BlankZero = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Codeunit));
        }
    }
    trigger OnAfterDelete()
    var
        ShippingAgentSetup: Record "wan Shipping Agent Label Setup";
    begin
        ShippingAgentSetup.SetRange("Shipping Agent Code", Code);
        ShippingAgentSetup.DeleteAll(true);
    end;
}
