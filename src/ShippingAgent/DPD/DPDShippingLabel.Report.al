report 87111 "wan DPD Shipping Label"
{
    Caption = 'DPD Shipping Label';
    ProcessingOnly = true;
    Permissions = tabledata "Sales Shipment Header" = m;

    dataset
    {
        dataitem(SalesShipmentHeader; "Sales Shipment Header")
        {
            trigger OnAfterGetRecord()
            var
                oStream: OutStream;
                iStream: InStream;
                TempBlob: Codeunit "Temp Blob";
                String: Text;
                ShippingAgentSetup: Record "wan Shipping Agent Label Setup";
                ShippingAgentAPIMgt: Codeunit "wan Shipping Agent API Mgt.";
                ResponseMessage: HttpResponseMessage;
                TempBlobResponse: Codeunit "Temp Blob";
                iStreamResponse: InStream;
                XMLDoc: XmlDocument;
                ContentType: Label 'text/xml', Locked = true;
                LabelPath: Label '/soap:Envelope/soap:Body/car:CreateShipmentWithLabelsBcResponse/car:CreateShipmentWithLabelsBcResult/car:labels/car:Label/car:label', Locked = true;
                TrackingPath: Label '/soap:Envelope/soap:Body/car:CreateShipmentWithLabelsBcResponse/car:CreateShipmentWithLabelsBcResult/car:shipments/car:ShipmentBc/car:Shipment/car:BarcodeId', Locked = true;
                RequestErr: Label 'API Request Error : "%1" for %2';
                isaPTS_PrintJobMgt: Codeunit isaPTS_PrintJobMgt;

            begin
                ShippingAgentSetup.Set(SalesShipmentHeader);
                TempBlob.CreateOutStream(oStream);
                Xmlport.Export(XmlPort::"wan DPD CreateShptWithLabelsBc", oStream, SalesShipmentHeader);
                TempBlob.CreateInStream(iStream);
                CopyStream(oStream, iStream);
                iStream.Position := 1;
                iStream.ReadText(String); // skip <?xml version="1.0" encoding="UTF-8" standalone="no"?>

                ResponseMessage := ShippingAgentAPIMgt.SendRequest(iStream, Enum::"Http Request Type"::POST, ShippingAgentSetup.EndPoint, ContentType);

                if ResponseMessage.IsSuccessStatusCode then begin
                    TempBlobResponse.CreateInStream(iStreamResponse);
                    ResponseMessage.Content.ReadAs(iStreamResponse);
                    XMLDocument.ReadFrom(iStreamResponse, XmlDoc);

                    if not isaPTS_PrintJobMgt.NewPrintJobBase64(GetPrinter(), CurrReport.ObjectId(true).Substring(8), Select(XmlDoc, LabelPath)) then
                        Error('isaPTS_PrintJobMgt.NewPrintJobBase64');

                    "Package Tracking No." := Select(XMLDoc, TrackingPath);
                    Modify(true);
                end else
                    if GuiAllowed then
                        Error(RequestErr, ResponseMessage.ReasonPhrase, ShippingAgentSetup);
            end;
        }
    }
    local procedure Select(pXMLDoc: XmlDocument; pPath: Text) ReturnValue: Text
    var
        Node: XmlNode;
        NameSpaceManager: XmlNamespaceManager;
        LabelNotFoundErr: Label 'Unable to find %1 in http response';
    begin
        NameSpaceManager.AddNamespace('soap', 'http://schemas.xmlsoap.org/soap/envelope/');
        NameSpaceManager.AddNamespace('car', 'http://www.cargonet.software');
        if pXMLDoc.SelectSingleNode(pPath, NameSpaceManager, Node) then
            ReturnValue := Node.AsXmlElement().InnerText
        else
            error(LabelNotFoundErr, pPath);
    end;

    local procedure GetPrinter(): Text;
    var
        ReportID: Integer;
        PrinterSelection: Record "Printer Selection";
    begin
        Evaluate(ReportID, CurrReport.ObjectId(false).Substring(8));
        if not PrinterSelection.Get(UserId, ReportId) then
            if not PrinterSelection.Get('', ReportId) then
                if not PrinterSelection.Get(UserId, 0) then
                    PrinterSelection.Get('', 0);
        exit(PrinterSelection."Printer Name");
    end;
}
