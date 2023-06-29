pageextension 87129 "wan W. Worker WMS Role Center" extends "Whse. Worker WMS Role Center"
{
    layout
    {
        addbefore("User Tasks Activities")
        {
            part(wanClickCollectActivities; "wan Click & Collect Activities")
            {
                ApplicationArea = All;
            }
        }
    }
}
