Report 87090 "wan SQL InsertIntoSelectFrom"
{
    Caption = 'SQL InsertIntoSelectFrom';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Company; Company)
        {
            DataItemTableView = sorting(Name);
            MaxIteration = 1;
            dataitem(CompanyTable; "Table Metadata")
            {
                DataItemTableView = sorting(ID) where(DataPerCompany = const(true), TableType = const(Normal), ObsoleteState = const(No));
                RequestFilterFields = ID;
                RequestFilterHeading = 'Company Tables';

                trigger OnAfterGetRecord()
                begin
                    gProgress += 1;
                    Progress.Update(1, gProgress * 10000 div gCount);
                    InsertIntoSelectFrom(CompanyTable);
                end;

                trigger OnPostDataItem()
                begin
                    Progress.Close;
                end;

                trigger OnPreDataItem()
                begin
                    Progress.Open('@1@@@@@@@@@@@@@@@@@@');
                    gCount := Count;
                end;
            }
            /*
            dataitem(GlobalTableWithCompanyName; "Table Metadata")
            {
                DataItemTableView = sorting(Name) where(DataPerCompany = const(false), TableType = const(Normal), ObsoleteState = const(No));
                RequestFilterFields = ID;
                RequestFilterHeading = 'Global Tables';

                trigger OnAfterGetRecord()
                begin
                    if HasFieldCompanyName(ID) and not IsExtensionTable(ID) then begin
                        WriteText('-- ' + Format(ID));
                        if ReplaceAll then
                            WriteText('Delete ' + SQLTableName('', Name) + ' Where [Company Name] = ''' + Company.Name + '''');
                        if HasAutoIncrementIdentity(ID) then
                            WriteText('Set Identity_Insert ' + SQLTableName('', Name) + ' On');
                        WriteText(
                          'Insert into ' + SQLTableName('', Name) +
                          ' (' + FieldList(ID, '') + ')' +
                          ' Select ' + FieldList(ID, Company.Name) +
                          ' From [' + SQL_Name(FromDatabase) + '].' + SQLTableName('', Name) +
                          ' Where [Company Name] = ''' + FromCompanyName + '''');
                        if HasAutoIncrementIdentity(ID) then
                            WriteText('Set Identity_Insert ' + SQLTableName(Company.Name, Name) + ' Off');
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    WriteText('');
                    WriteText('-- GlobalTableWithCompanyName');
                end;
            }
            */
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FromDatabase; FromDatabase)
                    {
                        ApplicationArea = All;
                        Caption = 'From Database';
                    }
                    field(FromCompany; FromCompanyName)
                    {
                        ApplicationArea = All;
                        Caption = 'From Company';
                    }
                    field(SkipIfEmpty; SkipIfEmpty)
                    {
                        ApplicationArea = All;
                        Caption = 'Skip if Empty';
                    }
                    field(ReplaceAll; ReplaceAll)
                    {
                        ApplicationArea = All;
                        Caption = 'Replace All';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        //Company.TESTFIELD(Name);
        TempBlob.CreateOutstream(oStream);
        WriteText('Use [?Database?]');
        WriteText('GO');
        WriteText('Begin Transaction');
    end;

    trigger OnPostReport()
    begin
        WriteText('Commit');
        //ClientFileName := FileManagement.BLOBExport(TempBlob,ClientFileName,TRUE);
        FileManagement.BLOBExport(TempBlob, 'CopyCompany.sql', true);
    end;

    var
        FromDatabase: Text;
        FromCompanyName: Text;
        Progress: Dialog;
        gCount: Integer;
        gProgress: Integer;
        oStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        ConfirmReplace: label 'File %1 already exists. Do you want to replace it ?';
        FileManagement: Codeunit "File Management";
        ReplaceAll: Boolean;
        SkipIfEmpty: Boolean;

    local procedure IsSelected(var pRec: Record "Table Metadata"): Boolean
    var
        RecRef: RecordRef;
    begin
        //if IsExtensionTable(pRec.ID) then
        //    exit(false);
        RecRef.Open(pRec.ID);
        if not RecRef.ReadPermission then
            exit(false);
        if SkipIfEmpty then
            exit(not RecRef.IsEmpty)
        else
            exit(true);
    end;

    local procedure InsertIntoSelectFrom(pRec: Record "Table Metadata")
    begin
        IsSelected(pRec);
        WriteText('-- ' + Format(pRec.ID));
        if ReplaceAll then
            WriteText('Delete ' + SQLTableName(Company.Name, pRec.Name));
        if HasAutoIncrementIdentity(pRec.ID) then
            WriteText('Set Identity_Insert ' + SQLTableName(Company.Name, pRec.Name) + ' On');
        WriteText(
            'Insert into ' + SQLTableName(Company.Name, pRec.Name) +
            ' (' + FieldList(pRec.ID, '') + ')' +
            ' Select ' + FieldList(pRec.ID, '') +
            ' From [' + SQL_Name(FromDatabase) + '].' + SQLTableName(FromCompanyName, pRec.Name));
        if HasAutoIncrementIdentity(pRec.ID) then
            WriteText('Set Identity_Insert ' + SQLTableName(Company.Name, pRec.Name) + ' Off');
    end;


    local procedure FieldList(pTableID: Integer; pReplaceCompanyName: Text) ReturnValue: Text
    var
        "Field": Record "Field";
    begin
        begin
            Field.SetRange(Field.TableNo, pTableID);
            Field.SetRange(Field.Class, Field.Class::Normal);
            Field.SetRange(Field.Enabled, true);
            if Field.FindSet then
                repeat
                    //TODO Avoid System fields ? ([$systemId],[SystemCreatedAt],[SystemCreatedBy],[SystemModifiedAt],[SystemModifiedBy])
                    //if not IsExtensionField(Field) then begin
                    if ReturnValue <> '' then
                        ReturnValue := ReturnValue + ',';
                    if (Field.FieldName = 'Company Name') and (pReplaceCompanyName <> '') then
                        ReturnValue += '''' + pReplaceCompanyName + ''''
                    else
                        ReturnValue += '[' + SQLFieldName(Field.FieldName) + ']';
                //end;
                until Field.Next = 0;
        end;
    end;

    local procedure SQLTableName(pCompanyName: Text; pName: Text): Text
    begin
        if pCompanyName = '' then
            exit('[dbo].[' + SQL_Name(pName) + ']')
        else
            exit('[dbo].[' + SQL_Name(pCompanyName) + '$' + SQL_Name(pName) + ']');
        //TODO +Extension ID ?
    end;

    local procedure SQLFieldName(pName: Text): Text
    begin
        exit(ConvertStr(pName, '.%/''', '____'));
    end;

    local procedure SQL_Name(pName: Text): Text
    begin
        exit(ConvertStr(pName, '.%/''', '____'));
    end;

    local procedure WriteText(pText: Text)
    var
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        oStream.WriteText(pText + CRLF);
    end;

    /*
    local procedure IsExtensionField(pField: Record "Field"): Boolean
    begin
        case pField.TableNo of
            Database::Item:
                exit(pField.FieldName in ['Has Sales Forecast']);
            Database::"Activities Cue":
                exit(pField.FieldName in ['Replication Success Rate']);
            Database::"Finance Cue":
                exit(pField.FieldName in ['Replication Success Rate']);
        end;
    end;

    local procedure IsExtensionTable(pTableID: Integer): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
        NullGUID: Guid;
    begin
        AllObjWithCaption.Get(AllObjWithCaption."Object type"::Table, pTableID);
        exit(AllObjWithCaption."App Package ID" <> NullGUID);
    end;
    */
    local procedure HasAutoIncrementIdentity(pTableID: Integer): Boolean
    begin
        case pTableID of
            Database::"Record Export Buffer",
            Database::"Incoming Document",
            Database::"VAT Registration Log",
            Database::"Reservation Entry",
            Database::"Dimension Value",
            Database::"Change Log Entry",
            Database::"Approval Entry",
            Database::"Posted Approval Entry",
            Database::"Workflow Webhook Entry",
            Database::"Workflow Webhook Notification",
            Database::"Job Queue Log Entry",
            Database::"Report Inbox",
            Database::"Dimension Set Tree Node",
            Database::"VAT Rate Change Log Entry",
            Database::"G/L Account Category",
            Database::"Error Message",
            Database::"Activity Log",
            Database::"Custom Address Format",
            Database::"VAT Report Line",
            Database::"VAT Statement Report Line",
            Database::"Name/Value Buffer",
            Database::"Time Sheet Posting Entry",
            Database::"Job WIP Total",
            //Database::"Payment Reporting Argument",
            Database::"User Task",
            Database::"Document Attachment",
            Database::"Data Privacy Records",
            Database::"Journal User Preferences",
            Database::"Credit Trans Re-export History",
            Database::"Intermediate Data Import",
            Database::"Data Exch.",
            Database::"Payment Export Data",
            Database::"XML Buffer",
            //Database::"Bank Data Conv. Bank",
            //Database::"Mini Customer Template",
            //Database::"Item Template",
            //Database::"Mini Vendor Template",
            //Database::"Product Video Buffer",
            //Database::"Product Video Category",
            Database::"Workflow Step",
            Database::"Notification Entry",
            Database::"Workflow Event Queue",
            Database::"Workflow Rule",
            Database::"Workflow - Record Change",
            Database::"Workflow Record Change Archive",
            Database::"Workflow Webhook Sub Buffer",
            Database::"Restricted Record",
            Database::"Office Suggested Line Item",
            Database::"Payroll Setup",
            Database::"Import G/L Transaction",
            Database::"Payroll Import Buffer",
            Database::"Data Migration Error",
            Database::"Data Migration Parameters",
            //Database::"Assisted Setup Log",
            Database::"O365 Payment Service Logo",
            //Database::"O365 Settings Menu",
            //Database::"O365 Payment Instructions",
            Database::"Calendar Event",
            //Database::"O365 Sales Event",
            Database::"Integration Field Mapping",
            Database::"Temp Integration Field Mapping",
            Database::"Integration Synch. Job Errors",
            Database::"BOM Buffer",
            Database::"Item Attribute",
            Database::"Item Attribute Value",
            //Database::"MS- PayPal Standard Account",
            Database::"Record Set Definition",
            Database::"Record Set Tree",
            Database::"Record Set Buffer",
            Database::"Custom Report Selection",
            Database::"CAL Test Line",
            Database::"CAL Test Enabled Codeunit",
            Database::"CAL Test Result",
            Database::"Semi-Manual Execution Log":
                exit(true);
        end;
    end;

    local procedure UpdateCompanyInformation(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        exit('Update ' + SQLTableName(Company.Name, CompanyInformation.TableName) + ' Set [System Indicator] = ' + Format(CompanyInformation."system indicator"::Custom));
    end;

    local procedure HasFieldCompanyName(pTableID: Integer): Boolean
    var
        "Field": Record "Field";
    begin
        case pTableID of
            Database::Object,
            Database::"Webhook Subscription",
            Database::"Table Information":
                exit(false);
            else
                Field.SetRange(Field.TableNo, pTableID);
                Field.SetRange(Field.FieldName, 'Company Name');
                exit(Field.FindFirst and (Field.Class = Field.Class::Normal) and (Field.ObsoleteState = Field.Obsoletestate::No) and (Field.TableName <> 'Informations table'));
        end;
    end;
}
