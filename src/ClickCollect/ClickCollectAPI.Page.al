page 87122 "wan Click & Collect API"
{
    Caption = 'Click & Collect API', Locked = true;
    APIPublisher = 'Wanamics';
    APIGroup = 'shipping';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    DelayedInsert = true;
    EntityName = 'salesShipmentHeader';
    EntitySetName = 'salesShipmentHeaders';
    PageType = API;
    SourceTable = "Sales Shipment Header";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(number; Rec."No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(shippingAgentCode; Rec."Shipping Agent Code")
                {
                    Caption = 'shippingAgentCode', Locked = true;
                }
                field(shippingAgentServiceCode; Rec."Shipping Agent Service Code")
                {
                    Caption = 'shippingAgentServiceCode', Locked = true;
                }
                field(shelfNo; Rec."wan Shelf No.")
                {
                    Caption = 'shelfNo', Locked = true;
                }
                field(orderNo; Rec."Order No.")
                {
                    Caption = 'orderNo', Locked = true;
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'externalDocumentNo', Locked = true;
                }
                field(sellToContact; Rec."Sell-to Contact")
                {
                    Caption = 'sellToContact', Locked = true;
                }
                field(shipToContact; Rec."Ship-to Contact")
                {
                    Caption = 'shipToContact', Locked = true;
                }
            }
        }
    }
}
