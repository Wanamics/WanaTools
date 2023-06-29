codeunit 87110 "wan Shipping Agent API Mgt."
{
    // Thanks to https://vld-nav.com/xml-and-soap-in-al
    // The first one is used
    procedure SendRequest(pContentToSend: Variant; pRequestType: enum "Http Request Type"; pRequestUri: Text; pContentType: Text): httpresponsemessage
    var
        DefaultHeaders: Codeunit "Dictionary Wrapper";
        ContentHeaders: Codeunit "Dictionary Wrapper";
    begin
        exit(SendRequest(pContentToSend, pRequestType, pRequestUri, pContentType, 0, ContentHeaders, DefaultHeaders));
    end;

    procedure SendRequest(pRequestType: enum "Http Request Type"; pRequestUri: Text): httpresponsemessage
    var
        DictionaryDefaultHeaders: Codeunit "Dictionary Wrapper";
        DictionaryContentHeaders: Codeunit "Dictionary Wrapper";
        ContentType: Text;
    begin
        exit(SendRequest('', pRequestType, pRequestUri, ContentType, 0, DictionaryContentHeaders, DictionaryDefaultHeaders));
    end;

    procedure SendRequest(pContentToSend: Variant; pRequestType: enum "Http Request Type"; pRequestUri: Text; pContentType: Text; pDefaultHeaders: Codeunit "Dictionary Wrapper"): httpresponsemessage
    var
        ContentHeaders: Codeunit "Dictionary Wrapper";
    begin
        exit(SendRequest(pContentToSend, pRequestType, pRequestUri, pContentType, 0, ContentHeaders, pDefaultHeaders));
    end;

    procedure SendRequest(pContentToSend: Variant; pRequestType: enum "Http Request Type"; pRequestUri: Text; ContentType: Text; pTimeout: integer; pContentHeaders: Codeunit "Dictionary Wrapper"; pDefaultHeaders: Codeunit "Dictionary Wrapper"): httpresponsemessage
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        TextContent: Text;
        InStreamContent: InStream;
        i: Integer;
        KeyVariant: Variant;
        ValueVariant: Variant;
        HasContent: Boolean;
        APIResponseErr: Label 'API Response (StatusCode %1) : %2', Comment = '%1 = HttpCode, %2 = faultstring';
        UnsupportedContentToSendErr: Label 'Unsupported content to send.';
        ContentTypeKeyLbl: Label 'Content-Type', Locked = true;
    begin
        case true of
            pContentToSend.IsText():
                begin
                    TextContent := pContentToSend;
                    if TextContent <> '' then begin
                        Content.WriteFrom(TextContent);
                        HasContent := true;
                    end;
                end;
            pContentToSend.IsInStream():
                begin
                    InStreamContent := pContentToSend;
                    Content.WriteFrom(InStreamContent);
                    HasContent := true;
                end;
            else
                Error(UnsupportedContentToSendErr);
        end;

        if HasContent then
            RequestMessage.Content := Content;

        if ContentType <> '' then begin
            Headers.Clear();
            RequestMessage.Content.GetHeaders(Headers);
            if Headers.Contains(ContentTypeKeyLbl) then
                Headers.Remove(ContentTypeKeyLbl);
            Headers.Add(ContentTypeKeyLbl, ContentType);
        end;

        for i := 0 to pContentHeaders.Count() do
            if pContentHeaders.TryGetKeyValue(i, KeyVariant, ValueVariant) then
                Headers.Add(Format(KeyVariant), Format(ValueVariant));

        RequestMessage.SetRequestUri(pRequestUri);
        RequestMessage.Method := Format(pRequestType);

        for i := 0 to pDefaultHeaders.Count() do
            if pDefaultHeaders.TryGetKeyValue(i, KeyVariant, ValueVariant) then
                Client.DefaultRequestHeaders.Add(Format(KeyVariant), Format(ValueVariant));

        if pTimeout <> 0 then
            Client.Timeout(pTimeout);

        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then
            Error(APIResponseErr, ResponseMessage.HttpStatusCode, GetFaultString(ResponseMessage));

        exit(ResponseMessage);
    end;

    local procedure GetFaultString(pResponse: HttpResponseMessage): Text
    var
        ResponseText: Text;
        XmlDoc: XmlDocument;
        FaultStringPath: Label '/soap:Envelope/soap:Body/soap:Fault/faultstring', Locked = true;
    begin
        pResponse.Content().ReadAs(ResponseText);
        XMLDocument.ReadFrom(ResponseText, XmlDoc);
        exit(Select(XmlDoc, FaultStringPath));
    end;

    local procedure Select(pXMLDoc: XmlDocument; pPath: Text): Text
    var
        Node: XmlNode;
        NameSpaceManager: XmlNamespaceManager;
        LabelNotFoundErr: Label 'Unable to find %1 in http response';
    begin
        NameSpaceManager.AddNamespace('soap', 'http://schemas.xmlsoap.org/soap/envelope/');
        if pXMLDoc.SelectSingleNode(pPath, NameSpaceManager, Node) then
            exit(Node.AsXmlElement().InnerText)
        else
            error(LabelNotFoundErr, pPath);
    end;
}
