xmlport 87110 "wan DPD CreateShptWithLabelsBc"
{
    Caption = 'DPD CreateShipmentWithLabelsBc';
    Encoding = UTF8;
    Namespaces =
        soapenv = 'http://schemas.xmlsoap.org/soap/envelope/',
        car = 'http://www.cargonet.software';
    schema
    {
        textelement(Envelope)
        {
            NamespacePrefix = 'soapenv';
            tableelement(Header; Integer)
            {
                NamespacePrefix = 'soapenv';
                MaxOccurs = once;
                Tableelement(ShippingAgentSetup; "wan Shipping Agent Label Setup")
                {
                    XmlName = 'UserCredentials';
                    NamespacePrefix = 'car';
                    MaxOccurs = once;
                    Fieldelement(userid; ShippingAgentSetup."Our User Id") { NamespacePrefix = 'car'; }
                    Textelement(password) { NamespacePrefix = 'car'; }
                    trigger OnAfterGetRecord()
                    begin
                        SalesShipmentHeader.FindFirst();
                        ShippingAgentSetup.Set(SalesShipmentHeader);
                        password := ShippingAgentSetup.GetAPIKey();
                        customer_countrycode := ShippingAgentSetup."Our Country Code";
                        customer_centernumber := ShippingAgentSetup."Our Center No.";
                        customer_number := ShippingAgentSetup."Our Account No.";
                    end;
                }
            }
            tableelement(Body; Integer)
            {
                NamespacePrefix = 'soapenv';
                MaxOccurs = once;
                tableelement(SalesShipmentHeader; "Sales Shipment Header")
                {
                    XmlName = 'CreateShipmentWithLabelsBc';
                    NamespacePrefix = 'car';
                    textelement(request)
                    {
                        NamespacePrefix = 'car';
                        textelement(receiveraddress)
                        {
                            NamespacePrefix = 'car';
                            fieldelement(countryPrefix; SalesShipmentHeader."Ship-to Country/Region Code") { NamespacePrefix = 'car'; }
                            fieldelement(zipCode; SalesShipmentHeader."Ship-to Post Code") { NamespacePrefix = 'car'; }
                            fieldelement(city; SalesShipmentHeader."Ship-to City") { NamespacePrefix = 'car'; }
                            fieldelement(street; SalesShipmentHeader."Ship-to Address") { NamespacePrefix = 'car'; }
                            fieldelement(name; SalesShipmentHeader."Ship-to Name") { NamespacePrefix = 'car'; }
                            fieldelement(phoneNumber; SalesShipmentHeader."Sell-to Phone No.") { NamespacePrefix = 'car'; }
                        }
                        tableelement(CompanyInformation; "Company Information")
                        {
                            XmlName = 'shipperaddress';
                            NamespacePrefix = 'car';
                            fieldelement(countryPrefix; CompanyInformation."Country/Region Code") { NamespacePrefix = 'car'; }
                            fieldelement(zipCode; CompanyInformation."Post Code") { NamespacePrefix = 'car'; }
                            fieldelement(city; CompanyInformation."City") { NamespacePrefix = 'car'; }
                            fieldelement(street; CompanyInformation."Address") { NamespacePrefix = 'car'; }
                            fieldelement(name; CompanyInformation."Name") { NamespacePrefix = 'car'; }
                            fieldelement(phoneNumber; CompanyInformation."Phone No.") { NamespacePrefix = 'car'; }
                        }
                        textelement(customer_countrycode) { NamespacePrefix = 'car'; }
                        textelement(customer_centernumber) { NamespacePrefix = 'car'; }
                        textelement(customer_number) { NamespacePrefix = 'car'; }
                        textelement(shippingdate) { NamespacePrefix = 'car'; }
                        textelement(services)
                        {
                            NamespacePrefix = 'car';
                            textelement(contact)
                            {
                                NamespacePrefix = 'car';
                                fieldelement(sms; SalesShipmentHeader."Sell-to Phone No.") { NamespacePrefix = 'car'; }
                                fieldelement(email; SalesShipmentHeader."Sell-to e-mail") { NamespacePrefix = 'car'; }
                                textelement(typeContact) { NamespacePrefix = 'car'; XmlName = 'type'; }
                                textelement(parcelShop)
                                {
                                    NamespacePrefix = 'car';
                                    textelement(shopaddress)
                                    {
                                        NamespacePrefix = 'car';
                                        textelement(shopid) { NamespacePrefix = 'car'; }
                                    }
                                }
                            }
                            /*
                            textelement(reverse)
                            {
                                NamespacePrefix = 'car';
                                textelement(expireOffset) { NamespacePrefix = 'car'; }
                                textelement(typeReverse) { NamespacePrefix = 'car'; XmlName = 'type'; }
                            }
                            */
                        }
                        textelement(weight) { NamespacePrefix = 'car'; }
                        fieldelement(referencenumber; SalesShipmentHeader."External Document No.") { NamespacePrefix = 'car'; }
                        fieldelement(reference2; SalesShipmentHeader."Order No.") { NamespacePrefix = 'car'; }
                        fieldelement(reference3; SalesShipmentHeader."No.") { NamespacePrefix = 'car'; }
                        textelement(labelType)
                        {
                            NamespacePrefix = 'car';
                            textelement(typeLabel) { NamespacePrefix = 'car'; XmlName = 'type'; }
                        }
                    }
                    trigger OnAfterGetRecord()
                    var
                        SalesShipmentLines: Record "Sales Shipment Line";
                        Math: Codeunit Math;
                    begin
                        shippingdate := Format(Today, 0, 9);
                        typeContact := ShippingAgentSetup."Service Type"; // No, Predict, AutomaticSMS, AutomaticMail
                        shopid := SalesShipmentHeader."Ship-to Contact";
                        /*
                        expireOffset := format(ShippingAgentSetup."Expire Offset");
                        typeReverse := ShippingAgentSetup."Reverse Type"; // OnDemand, Prepared
                        */
                        typeLabel := ShippingAgentSetup."Label Type"; // Default (PNG), PDF, PDF_A6, EPL (EPL2 - 203 dpi), ZPL (ZPL2 - 203 dpi), ZPL300 (ZPL2 - 300 dpi)

                        Sum(SalesShipmentLines);
                        if SalesShipmentLines."Gross Weight" <> 0 then
                            weight := format(Math.Max(SalesShipmentLines."Gross Weight", 0.01))
                        else
                            if SalesShipmentLines."Net Weight" <> 0 then
                                weight := format(Math.Max(SalesShipmentLines."Net Weight", 0.01))
                            else
                                weight := '0';
                    end;
                }
            }
        }
    }

    local procedure Sum(var SpalesShipmentLines: Record "Sales Shipment Line")
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        if SalesShipmentLine.FindSet then
            repeat
                SpalesShipmentLines."Net Weight" += SalesShipmentLine.Quantity * SalesShipmentLine."Net Weight" / 1000; //g -> kg
                SpalesShipmentLines."Gross Weight" += SalesShipmentLine.Quantity * SalesShipmentLine."Gross Weight" / 1000; // g -> kg
                SpalesShipmentLines."Unit Volume" += SalesShipmentLine.Quantity * SalesShipmentLine."Unit Volume";
            until SalesShipmentLine.Next() = 0;
    end;
}
