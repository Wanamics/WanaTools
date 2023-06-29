report 87121 "wan Click & Collect Shipments"
{
    Caption = 'Click & Collect Shipments';
    WordLayout = './Layout/ClickCollectShipments.docx';
    DefaultLayout = Word;
    dataset
    {
        dataitem(SalesShipmentHeader; "Sales Shipment Header")
        {
            DataItemTableView = where("wan Delivered" = const(false));
            RequestFilterFields = "Shipping Agent Code", "Shipping Agent Service Code";
            column(No; "No.")
            {
            }
            column(OrderNo; "Order No.")
            {
            }
            column(CampaignNo; "Campaign No.")
            {
            }
            column(ExternalDocumentNo; "External Document No.")
            {
            }
            column(PackageTrackingNo; "Package Tracking No.")
            {
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(SelltoContact; "Sell-to Contact")
            {
            }
            column(SelltoEMail; "Sell-to E-Mail")
            {
            }
            column(SelltoPhoneNo; "Sell-to Phone No.")
            {
            }
            column(ShippingAgentCode; "Shipping Agent Code")
            {
            }
            column(ShippingAgentServiceCode; "Shipping Agent Service Code")
            {
            }
            column(YourReference; "Your Reference")
            {
            }
            column(WMSShelfNo; "wan Shelf No.")
            {
            }
        }
    }
}
