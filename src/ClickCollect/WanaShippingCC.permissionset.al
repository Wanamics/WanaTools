permissionset 87112 "WanaShipping_CC"
{
    Caption = 'WanaShipping Click & Collect';
    Assignable = true;
    Permissions =
        tabledata "wan Click & Collect Employee" = R,
        table "wan Click & Collect Employee" = X,
        report "wan Click & Collect Shipments" = X,
        page "wan Click & Collect Employees" = X,
        page "wan Click & Collect Shipments" = X;
}