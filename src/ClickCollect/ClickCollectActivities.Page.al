page 87129 "wan Click & Collect Activities"
{
    Caption = 'Click & Collect Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            cuegroup("Click & Collect")
            {
                Caption = 'Click & Collect';
                field(ToReceive; GetSalesShipmentCount(true))
                {
                    Caption = 'To receive';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending Click & Collect to receive assigned to you as a Shipping Agent.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"wan Click & Collect Shipments");
                    end;
                }
                field(ToShip; GetSalesShipmentCount(false))
                {
                    Caption = 'To ship';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending Click & Collect to ship assigned to you as a Shipping Agent.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"wan Click & Collect Shipments");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if ClickCollectEmployee.Get(UserId) then;
    end;

    local procedure GetSalesShipmentCount(pToReceiveOnly: Boolean): Integer
    var
        SalesShimentsHeader: Record "Sales Shipment Header";
    begin
        SalesShimentsHeader.SetRange("Shipping Agent Code", ClickCollectEmployee."Shipping Agent Code");
        SalesShimentsHeader.SetRange("Shipping Agent Service Code", ClickCollectEmployee."Shipping Agent Service Code");
        SalesShimentsHeader.SetRange("wan Delivered", false);
        if pToReceiveOnly then
            SalesShimentsHeader.SetRange("wan Shelf No.", '')
        else
            SalesShimentsHeader.SetFilter("wan Shelf No.", '<>%1', '');
        exit(SalesShimentsHeader.Count);
    end;

    var
        ClickCollectEmployee: Record "wan Click & Collect Employee";
}

