page 87110 "wan Shipping Agent Label Setup"
{
    ApplicationArea = All;
    Caption = 'Shipping Agent Label Setup';
    PageType = List;
    SourceTable = "wan Shipping Agent Label Setup";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ToolTip = 'Specifies the value of the Shipping Agent Code field.';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field.';
                }
                field(EndPoint; Rec.EndPoint)
                {
                    ToolTip = 'Specifies the value of the EndPoint field.';
                }
                field("Report ID"; Rec."Report ID")
                {
                    ToolTip = 'Specifies the value of the Report ID field.';
                }
                field("Our User ID"; Rec."Our User ID")
                {
                    ToolTip = 'Specifies the value of the Our User ID field.';
                }
                field(APIKey; APIKey)
                {
                    ApplicationArea = All;
                    Caption = 'API Key';
                    ToolTip = 'Specifies the value of API Key';
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        Rec.SetAPIKey(APIKey);
                    end;
                }
                field("Our Account No."; Rec."Our Account No.")
                {
                    ToolTip = 'Specifies the value of the Our Account No. field.';
                }
                field("Our Center No."; Rec."Our Center No.")
                {
                    ToolTip = 'Specifies the value of the Our Center No. field.';
                }
                field("Our Country Code"; Rec."Our Country Code")
                {
                    ToolTip = 'Specifies the value of the Our Country Code field.';
                }
                field("Service Type"; Rec."Service Type")
                {
                    ToolTip = 'Specifies the value of the Service Type field.';
                }
                field("Label Type"; Rec."Label Type")
                {
                    ToolTip = 'Specifies the value of the Label Type field.';
                }
                field("Reverse Type"; Rec."Reverse Type")
                {
                    ToolTip = 'Specifies the value of the Reverse Type field.';
                }
                field("Expire Offset"; Rec."Expire Offset")
                {
                    ToolTip = 'Specifies the value of the Expire Offset field.';
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        // SetAllObj();
        // if Rec.GetAPIKey() = '' then
        //     APIKey := ''
        // else
        //     APIKey := '****';
        APIKey := Rec.GetAPIKey()
    end;

    // local procedure SetAllObj()
    // var
    //     AllObjWithCaption: Record AllObjWithCaption;
    // begin
    //     if Rec."Report ID" = 0 then
    //         AllObjWithCaption.Init()
    //     else
    //         AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Codeunit, Rec."Report ID");
    // end;

    var
        APIKey: Text;
}
