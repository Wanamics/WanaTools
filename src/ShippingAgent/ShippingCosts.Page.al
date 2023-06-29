page 87111 "wan Shipping Costs"
{
    Caption = 'Shipping Costs';
    PageType = List;
    SourceTable = "wan Shipping Cost";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Services Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Starting Weight"; Rec."Starting Weight")
                {
                    ApplicationArea = All;
                }
                field("Cost (LCY)"; Rec."Cost (LCY)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
