report 87120 "wan ClickCollect Label"
{
    ApplicationArea = Warehouse;
    DefaultLayout = RDLC;
    RDLCLayout = './Layout/ClickCollectLabel.rdl';
    Caption = 'Click & Collect Label';

    dataset
    {
        dataitem(SalesShipmentHeader; "Sales Shipment Header")
        {
            DataItemTableView = sorting("No.");

            column(No; SalesShipmentHeader."No.")
            {
                IncludeCaption = true;
            }
            column(SourceNo; SalesShipmentHeader."Order No.")
            {
                IncludeCaption = true;
            }
            column(OrderDate; SalesShipmentHeader."Order Date")
            {
                IncludeCaption = true;
            }
            column(SellToCustomerNo; SalesShipmentHeader."Sell-to Customer No.")
            {
                IncludeCaption = true;
            }
            column(SellToCustomerName; SalesShipmentHeader."Sell-to Customer Name")
            {
                IncludeCaption = true;
            }
            column(SellToCity; SalesShipmentHeader."Sell-to City")
            {
                IncludeCaption = true;
            }
            column(SellToContact; SalesShipmentHeader."Sell-to Contact")
            {
                IncludeCaption = true;
            }
            column(SellToPhoneNo; SalesShipmentHeader."Sell-to Phone No.")
            {
                IncludeCaption = true;
            }
            column(ShipToContact; SalesShipmentHeader."Ship-to Contact")
            {
                IncludeCaption = true;
            }
            column(YourReference; SalesShipmentHeader."Your Reference")
            {
                IncludeCaption = true;
            }
            column(ExternalDocumentNo; SalesShipmentHeader."External Document No.")
            {
                IncludeCaption = true;
            }
            column(CustomDocumentNo; SalesShipmentHeader.GetCustomDocumentNo())
            {
            }
            column(ShippingAgentName; ShippingAgent.Name)
            {
            }
            column(ShippingAgentServiceDescription; ShippingAgentServices.Description)
            {
            }
            column(WorkDate; WorkDate())
            {
            }
            column(ShipmentNumber_Code128; Encode1D(SalesShipmentHeader."No.", "Barcode Symbology"::Code128)) { }

            column(ShipmentNumber_QRCode; Encode1D(SalesShipmentHeader."Package Tracking No.", "Barcode Symbology"::Code128)) { }
            column(PackageTracking_Code128; Encode2D(SalesShipmentHeader."Package Tracking No.", "Barcode Symbology 2D"::"QR-Code")) { }

            column(PackageTracking_QRCode; Encode2D(SalesShipmentHeader."No.", "Barcode Symbology 2D"::"QR-Code")) { }
            column(CustomNumber_Code128; Encode2D(SalesShipmentHeader."Package Tracking No.", "Barcode Symbology 2D"::"QR-Code")) { }
            column(CustomNumber_QRCode; Encode2D(SalesShipmentHeader."No.", "Barcode Symbology 2D"::"QR-Code")) { }
            trigger OnAfterGetRecord()
            begin
                if not ShippingAgent.Get("Shipping Agent Code") then
                    ShippingAgent.Init();
                if not ShippingAgentServices.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                    ShippingAgentServices.Init();
            end;
        }
    }
    var
        ShippingAgent: Record "Shipping Agent";
        ShippingAgentServices: Record "Shipping Agent Services";

    local procedure Encode1D(pText: Text; pBarCodeSymbology: Enum "Barcode Symbology"): Text
    var
        BarcodeFontProvider: Interface "Barcode Font Provider";
    begin
        if pText = '' then
            exit;

        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
        pBarCodeSymbology := Enum::"Barcode Symbology"::Code128;
        BarcodeFontProvider.ValidateInput(pText, pBarCodeSymbology);
        Exit(BarcodeFontProvider.EncodeFont(pText, pBarCodeSymbology));
    end;

    local procedure Encode2D(pText: Text; pBarCodeSymbology: Enum "Barcode Symbology 2D"): Text
    var
        BarcodeFontProvider: Interface "Barcode Font Provider 2D";
    begin
        if pText = '' then
            exit;
        BarcodeFontProvider := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
        exit(BarcodeFontProvider.EncodeFont(pText, pBarCodeSymbology));
    end;
}
