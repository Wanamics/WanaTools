report 87110 "wan Shipping Agent Label"
// act as a hub to switch to the shipping agent label report
{
    Caption = 'Shipping Label';
    ProcessingOnly = true;
    UseRequestPage = false;
    dataset
    {
        dataitem(SalesShipmentHeader; "Sales Shipment Header")
        {
            trigger OnAfterGetRecord()
            var
                ShippingAgentLabelSetup: Record "wan Shipping Agent Label Setup";
                ConfirmMsg: Label 'Do you want to replace existing "%1" ''%2'' for %3 %4?';
                lRec: Record "Sales Shipment Header";
            begin
                if "Package Tracking No." <> '' then
                    if not Confirm(ConfirmMsg, false, FieldCaption("Package Tracking No."), "Package Tracking No.", TableCaption, "No.") then
                        exit;
                lRec.SetRange("No.", "No.");
                //ShippingAgentSetup.Testfield("Report ID");
                if ShippingAgentLabelSetup.Set(SalesShipmentHeader) then begin
                    if ShippingAgentLabelSetup."Report ID" <> 0 then
                        Report.RunModal(ShippingAgentLabelSetup."Report ID", false, false, lRec);
                    OnAfterShippingLabel(SalesShipmentHeader, ShippingAgentLabelSetup);
                end;
            end;
        }
    }
    [BusinessEvent(false)]
    local procedure OnAfterShippingLabel(var SalesShipmentHeader: Record "Sales Shipment Header"; ShippingAgentLabelSetup: Record "wan Shipping Agent Label Setup");
    begin
    end;
}
