permissionset 87111 "WanaShipping_SETUP"
{
    Caption = 'WanaShipping Setup';
    Assignable = true;
    Permissions =
        tabledata "wan Shipping Agent Label Setup" = R,
        tabledata "wan Shipping Cost" = RIMD,
        tabledata "wan Click & Collect Employee" = RIMD;
}