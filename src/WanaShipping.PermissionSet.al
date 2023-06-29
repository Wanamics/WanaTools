permissionset 87110 "WanaShipping"
{
    Access = Internal;
    Assignable = true;
    Caption = 'WanaShipping', Locked = true;
    Permissions =
        report "wan DPD Shipping Label" = X,
        xmlport "wan DPD CreateShptWithLabelsBc" = X,
        codeunit "wan Shipping Agent API Mgt." = X,
        page "wan Shipping Agent Label Setup" = X,
        report "wan Shipping Agent Label" = X,
        report "wan Default Shipping Label" = X,
        report "wan Outstanding Shipping Label" = X,
        table "wan Shipping Agent Label Setup" = X,
        tabledata "wan Shipping Agent Label Setup" = R,
        tabledata "wan Shipping Cost" = R,
        table "wan Shipping Cost" = X,
        page "wan Shipping Costs" = X;
}