pageextension 87111 "wan Shipping Agents" extends "Shipping Agents"
{
    layout
    {
        addafter("Internet Address")
        {
            field("wan Tracking Codeunit ID"; Rec."wan Tracking Codeunit ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Tracking Codeunit Id field.';
            }
        }
    }
    actions
    {
        addlast(navigation)
        {
            action(wanShippingAgentSetup)
            {
                ApplicationArea = All;
                Image = Setup;
                Caption = 'Setup';
                Scope = Repeater;
                RunObject = page "wan Shipping Agent Label Setup";
                RunPageLink = "Shipping Agent Code" = field(Code);
            }
        }
    }
}
