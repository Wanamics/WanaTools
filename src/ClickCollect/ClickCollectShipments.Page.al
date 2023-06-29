page 87121 "wan Click & Collect Shipments"
{
    ApplicationArea = All;
    Caption = 'Click & Collect';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    Permissions = TableData "Sales Shipment Header" = rm;
    SourceTable = "Sales Shipment Header";
    SourceTableView = sorting("wan Delivered");
    CardPageID = "Posted Sales Shipment";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Search)
            {
                Caption = 'Search';

                field(ExternalDocumentNoFilter; ExternalDocumentNoFilter)
                {
                    Caption = 'External Document No.';
                    trigger OnValidate()
                    begin
                        ApplyFilters();
                    end;
                }
                field(SellToContactFilter; SellToContactFilter)
                {
                    Caption = 'Sell-to Contact';
                    trigger OnValidate()
                    begin
                        ApplyFilters();
                    end;
                }
            }
            repeater(Lines)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"Posted Sales Shipment", Rec); // CardPageID not active on a Worksheet page
                    end;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        ShippingAgent: Record "Shipping Agent";
                    begin
                        if ShippingAgent.Get(Rec."Shipping Agent Code") and (ShippingAgent."wan Tracking Codeunit ID" <> 0) then
                            Codeunit.Run(ShippingAgent."wan Tracking Codeunit ID", Rec)
                        else
                            Rec.StartTrackingSite();
                    end;
                }
                field("Package Tracking No."; Rec."Package Tracking No.")
                {
                    Visible = false;
                    Editable = false;
                }
                field("wan Shelf No."; Rec."wan Shelf No.")
                {
                    Editable = true;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    Visible = false;
                    Editable = false;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    Visible = false;
                    Editable = false;
                }
                field("Sell-to Contact"; Rec."Sell-to Contact")
                {
                    Editable = false;
                }
                field("Sell-to E-Mail"; Rec."Sell-to E-Mail")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Sell-to Phone No."; Rec."Sell-to Phone No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    Visible = false;
                    Editable = false;
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    Visible = false;
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Visible = false;
                    Editable = false;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    Visible = false;
                    Editable = false;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    Visible = false;
                    Editable = false;
                }
                field("wan Delivered"; Rec."wan Delivered")
                {
                    Visible = false;
                }
                field("wan Delivered by Resource No."; Rec."wan Delivered by Resource No.")
                {
                    Visible = false;
                }
                field("wan Delivery Date Time"; Rec."wan Delivery Date Time")
                {
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(PostDelivery)
            {
                Caption = 'Post Delivery';
                Image = SalesShipment;
                ShortcutKey = F9;

                trigger OnAction()
                var
                    ConfirmMsg: Label 'Do you confirm delivery below?\  - %1\  - %2\  - %3';
                begin
                    if not Confirm(ConfirmMsg, false, Rec."External Document No.", Rec."Sell-to Contact", Rec."Ship-to Contact") then
                        exit;
                    Rec."wan Delivered" := true;
                    Rec."wan Delivered by Resource No." := ClickCollectEmployee."Resource No.";
                    Rec."wan Delivery Date Time" := CurrentDateTime;
                    Rec.Modify(true);
                    //TODO Trigger update PS order_state (4)

                    ExternalDocumentNoFilter := '';
                    SellToContactFilter := '';
                    ApplyFilters();
                end;
            }
            action(PostSelection)
            {
                Caption = 'Post Selection';
                Visible = false;
                Image = PostBatch;
                trigger OnAction()
                var
                    ConfirmMsg: Label 'Do you want to set %1 for %2 "%3"?';
                    lRec: Record "Sales Shipment Header";
                begin
                    CurrPage.SetSelectionFilter(lRec);
                    if not Confirm(ConfirmMsg, false, lRec."wan Delivered", lRec.Count, lRec.TableCaption) then
                        exit;
                    lRec.ModifyAll("wan Delivered", true);
                end;
            }
            action(Print)
            {
                Caption = 'Print';
                Image = Print;
                trigger OnAction()
                // var
                //     lRec: Record "Sales Shipment Header";
                begin
                    // CurrPage.SetSelectionFilter(lRec);
                    Report.Run(Report::"wan Click & Collect Shipments", true, true, Rec);
                end;
            }
        }
        area(Promoted)
        {
            actionref(PostDeliveryPromoted; PostDelivery) { }
            actionref(PrintPromoted; Print) { }
        }
    }

    trigger OnOpenPage()
    begin
        ClickCollectEmployee.Get(UserId);
        Rec.SetRange("Shipping Agent Code", ClickCollectEmployee."Shipping Agent Code");
        Rec.SetRange("Shipping Agent Service Code", ClickCollectEmployee."Shipping Agent Service Code");
        Rec.SetRange("wan Delivered", false);
    end;

    var
        ClickCollectEmployee: Record "wan Click & Collect Employee";
        ExternalDocumentNoFilter: Text;
        SellToContactFilter: Text;

    local procedure ApplyFilters()
    begin
        if ExternalDocumentNoFilter <> '' then
            Rec.SetFilter("External Document No.", '@*' + ExternalDocumentNoFilter + '*')
        else
            Rec.SetRange("External Document No.");
        if SellToContactFilter <> '' then
            Rec.SetFilter("Sell-to Contact", '@*' + SellToContactFilter + '*')
        else
            Rec.SetRange("Sell-to Contact");
        Rec.FindFirst();
        CurrPage.Update(false);
    end;
}

