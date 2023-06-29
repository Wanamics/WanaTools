pageextension 87110 "wan Shipping Agent Services" extends "Shipping Agent Services"
{
    layout
    {
        addlast(Control1)
        {

            field("wan Shipping Fixed Cost (LCY)"; Rec."wan Shipping Fixed Cost (LCY)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Shipping Fixed Cost (LCY) field.';
            }
            field("wan Shipping Cost Overhead %"; Rec."wan Shipping Cost Overhead %")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Shipping Cost Overhead % field.';
            }
        }

    }
    actions
    {
        addlast(navigation)
        {
            action(wanShippingCosts)
            {
                ApplicationArea = All;
                Image = Setup;
                Caption = 'Shipping Costs';
                Scope = Repeater;
                RunObject = page "wan Shipping Costs";
                RunPageLink = "Shipping Agent Code" = field("Shipping Agent Code"), "Shipping Agent Services Code" = field(Code);
            }
        }
    }
}
