Report 87090 "wan SQL InsertIntoSelectFrom"
/*
PREREQUISITE :
- Both databases must have the same schema (check they have same extensions/version installed)
- User must have 'SUPER' PermissionSet

PROCESSUS :
- Deploy this extension to the 'source' environment
- Run this report from the URL (...?Report=xxx)
- Execute the .sql (!!! WARNING double check target database and ToCompanyName !!!)

WARNING :
- When a field has the property { AutoIncrement = true; }, SQL command 'Set Identity_Insert' is added ('on' before 'Insert to' and 'off' after)
    I don't found any way to check this property by code, so you have to add your own tables to the HasAutoIncrementIdentity procedure.
*/
{
    Caption = 'SQL InsertIntoSelectFrom';
    ProcessingOnly = true;
    ApplicationArea = All;

    dataset
    {
        dataitem(Company; Company)
        {
            // RequestFilterFields = Name;
            DataItemTableView = sorting(Name);
            dataitem(PublishedApplication; "Published Application")
            {
                // RequestFilterFields = "Runtime Package ID";
                DataItemTableView = sorting("Runtime Package ID");

                dataitem(PerCompanyTable; AllObj)
                {
                    DataItemTableView = sorting("Object Type", "Object ID") where("Object Type" = const(Table));
                    // RequestFilterFields = "Object ID";
                    // RequestFilterHeading = 'Per company Tables';

                    // trigger OnPreDataitem()
                    // begin
                    //     Progress.Open('@1@@@@@@@@@@@@@@@@@@');
                    //     gCount := Count;
                    // end;

                    trigger OnAfterGetRecord()
                    var
                        TableMetadata: Record "Table Metadata";
                    begin
                        // gProgress += 1;
                        // Progress.Update(1, gProgress * 10000 div gCount);
                        if not IsTemporary then begin
                            TableMetadata.Get("Object ID");
                            if TableMetadata.DataPerCompany and
                               (TableMetadata.TableType = TableMetadata.TableType::Normal) and
                               (TableMetadata.ObsoleteState = TableMetadata.ObsoleteState::No) then
                                if "App Package ID" = PublishedApplication."Package ID" then
                                    InsertIntoSelectFrom(PerCompanyTable, PublishedApplication)
                                else
                                    InsertIntoSelectFromExtension(PerCompanyTable, PublishedApplication);
                        end;
                    end;

                    // trigger OnPostDataItem()
                    // begin
                    //     Progress.Close;
                    // end;
                }
                dataitem(GlobalTableWithCompanyName; AllObj)
                {
                    //DataItemTableView = sorting(Name) where(DataPerCompany = const(false), TableType = const(Normal), ObsoleteState = const(No));
                    DataItemTableView = sorting("Object Type", "Object ID") where("Object Type" = const(Table));
                    // RequestFilterFields = ID;
                    // RequestFilterHeading = 'Global Tables';

                    // trigger OnPreDataItem()
                    // begin
                    //     WriteText('');
                    //     WriteText('-- GlobalTableWithCompanyName begin');
                    // end;
                    trigger OnPreDataItem()
                    begin
                        SetRange("App Package ID", PublishedApplication."Package ID");
                    end;

                    trigger OnAfterGetRecord()
                    var
                        TableMetadata: Record "Table Metadata";
                    begin
                        if not IsTemporary then begin
                            TableMetadata.Get("Object ID");
                            if not TableMetadata.DataPerCompany and
                               (TableMetadata.TableType = TableMetadata.TableType::Normal) and
                               (TableMetadata.ObsoleteState = TableMetadata.ObsoleteState::No) then
                                if HasFieldCompanyName("Object ID") then begin
                                    WriteText('-- ' + Format("Object ID") + ' (per Database) ' + PublishedApplication.Name + ' (' + PublishedApplication.Publisher + ')');
                                    // if ReplaceAll then
                                    WriteText('Delete ' + SQLTableName('', "Object Name", PublishedApplication.ID) + ' Where [Company Name] = ''' + ToCompanyName + '''');
                                    if HasAutoIncrementIdentity("Object ID") then
                                        WriteText('Set Identity_Insert ' + SQLTableName('', "Object Name", PublishedApplication.ID) + ' On');
                                    WriteText('Insert into ' + SQLTableName('', "Object Name", PublishedApplication.ID));
                                    WriteText('  (      ' + FieldList("Object ID", '', PublishedApplication."Package ID") + ')');
                                    WriteText('  Select ' + FieldList("Object ID", ToCompanyName, PublishedApplication."Package ID"));
                                    WriteText('    From [' + SQL_Name(FromDatabase) + '].' + SQLTableName('', "Object Name", PublishedApplication.ID));
                                    WriteText('    Where [Company Name] = ''' + Company.Name + '''');
                                    if HasAutoIncrementIdentity("Object ID") then
                                        WriteText('Set Identity_Insert ' + SQLTableName('', "Object Name", PublishedApplication.ID) + ' Off');
                                end;
                        end;
                    end;
                    // trigger OnPostDataItem()
                    // begin
                    //     WriteText('');
                    //     WriteText('-- GlobalTableWithCompanyName end');
                    // end;
                }
            }

            // trigger OnPreDataItem()
            // var
            //     ConfirmMsg: Label 'Do you want to create a SQL script for %1 and for %2?';
            //     CompanyLbl: Label 'company %1 only';
            //     CompaniesLbl: Label '%1 companies';
            //     AppLbl: Label 'application %1 from %2 only';
            //     AppsLbl: Label '%1 applications';
            //     CompanyMsg: Text;
            //     AppMsg: Text;
            // begin
            //     if Count > 1 then
            //         CompanyMsg := StrSubstNo(CompaniesLbl, Count)
            //     else
            //         if FindFirst() then
            //             CompanyMsg := StrSubstNo(CompanyLbl, Company.Name);

            //     if PublishedApplication.Count <> 1 then
            //         AppMsg := StrSubstNo(AppsLbl, PublishedApplication.Count)
            //     else
            //         if PublishedApplication.FindFirst() then
            //             AppMsg := StrSubstNo(AppLbl, PublishedApplication.Name, PublishedApplication.Publisher);

            //     if not Confirm(ConfirmMsg, false, CompanyMsg, AppMsg) then
            //         CurrReport.Quit();
            // end;
            trigger OnPreDataItem()
            var
                ConfirmMsg: Label 'Do you want to create a SQL script to copy company %1 from database %2 to %3?';
            begin
                if not Confirm(ConfirmMsg, false, CompanyName, FromDatabase, ToDatabase) then
                    CurrReport.Quit();
                Company.SetRange(Name, CompanyName);
                ProgressDialog.OpenCopyCountMax('', Count);
            end;

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
            end;
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
                        Caption = 'From Database';
                    }
                    field(ToDatabase; ToDatabase)
                    {
                        Caption = 'To Database';
                    }
                    // field(Company.Name; Company.Name)
                    // {
                    //     Caption = 'From Company';
                    //     TableRelation = Company;
                    // }
                    field(ToCompany; ToCompanyName)
                    {
                        Caption = 'To Company Name';
                    }

                    // field(FromAppPackageID; PublishedApplication."Runtime Package ID")
                    // {
                    //     Caption = 'From App Package ID';
                    //     TableRelation = "Published Application";
                    // }
                    // field(SkipIfEmpty; SkipIfEmpty)
                    // {
                    //     Caption = 'Skip if Empty';
                    // }
                    // field(ReplaceAll; ReplaceAll)
                    // {
                    //     Caption = 'Replace All';
                    // }
                }
            }
        }
    }
    trigger OnInitReport()
    var
        UserPermissions: Codeunit "User Permissions";
        ErrorMsg: Label 'User must have SUPER permission set';
    begin
        if not UserPermissions.IsSuper(UserSecurityId()) then
            error(ErrorMsg);
        ToCompanyName := CompanyName;
    end;

    trigger OnPreReport()
    begin
        // PublishedApplication.Get(PublishedApplication."Runtime Package ID");
        //Company.TESTFIELD(Name);
        TempBlob.CreateOutstream(oStream);
        WriteText('Use [' + ToDatabase + ']');
        WriteText('GO');
        WriteText('Begin Transaction');
    end;

    trigger OnPostReport()
    begin
        WriteText('Commit');
        FileManagement.BLOBExport(TempBlob, 'CopyCompany.sql', true);
    end;

    var
        FromDatabase: Text;
        ToDatabase: Text;
        // Company.Name: Text;
        ToCompanyName: Text;
        // Progress: Dialog;
        // gCount: Integer;
        // gProgress: Integer;
        ProgressDialog: Codeunit "Progress Dialog";
        oStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        // ConfirmReplace: label 'File %1 already exists. Do you want to replace it ?';
        FileManagement: Codeunit "File Management";
    // ReplaceAll: Boolean;
    // SkipIfEmpty: Boolean;

    // local procedure IsSelected(var pRec: Record AllObj): Boolean
    // var
    //     RecRef: RecordRef;
    // begin
    //     if not SkipIfEmpty then
    //         exit(false);
    //     RecRef.Open(pRec."Object ID");
    //     if SkipIfEmpty then
    //         exit(not RecRef.IsEmpty)
    //     else
    //         exit(true);
    // end;

    local procedure InsertIntoSelectFrom(pRec: Record AllObj; pPublishedApplication: Record "Published Application")
    var
        Fields: Text;
    begin
        // IsSelected(pRec);
        WriteText('-- ' + Format(pRec."Object ID") + ' ' + pPublishedApplication.Name + ' (' + pPublishedApplication.Publisher + ')');
        // if ReplaceAll then
        WriteText('Delete ' + SQLTableName(ToCompanyName, pRec."Object Name", pPublishedApplication.ID));
        if HasAutoIncrementIdentity(pRec."Object ID") then
            WriteText('Set Identity_Insert ' + SQLTableName(ToCompanyName, pRec."Object Name", pPublishedApplication.ID) + ' On');
        Fields := FieldList(pRec."Object ID", '', pPublishedApplication."Package ID");
        WriteText('Insert into ' + SQLTableName(ToCompanyName, pRec."Object Name", pPublishedApplication.ID));
        WriteText('  (      ' + Fields + ')');
        WriteText('  Select ' + Fields);
        WriteText('    From [' + SQL_Name(FromDatabase) + '].' + SQLTableName(Company.Name, pRec."Object Name", pPublishedApplication.ID));
        if HasAutoIncrementIdentity(pRec."Object ID") then
            WriteText('Set Identity_Insert ' + SQLTableName(ToCompanyName, pRec."Object Name", pPublishedApplication.ID) + ' Off');
    end;

    local procedure InsertIntoSelectFromExtension(pRec: Record AllObj; pPublishedApplication: Record "Published Application")
    var
        Field: Record Field;
        Fields: Text;
        Dependency: Record "Published Application";
    begin
        Field.SetRange(TableNo, pRec."Object ID");
        Field.SetRange("App Package ID", pPublishedApplication."Package ID");
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(Enabled, true);
        if Field.IsEmpty then
            exit;
        // IsSelected(pRec);
        Dependency.Get(pRec."App Runtime Package ID");
        WriteText('-- ' + Format(pRec."Object ID") + ' ' + pPublishedApplication.Name + ' (' + pPublishedApplication.Publisher + ') extends ' + Dependency.Name + ' (' + Dependency.Publisher + ')');
        // if ReplaceAll then
        WriteText('Delete ' + SQLTableName(ToCompanyName, pRec."Object Name", pPublishedApplication.ID));
        Fields := PrimaryKeyFields(pRec."Object ID") + ',' + FieldList(pRec."Object ID", '', pPublishedApplication."Package ID");
        WriteText('Insert into ' + SQLTableName(ToCompanyName, pRec."Object Name", pPublishedApplication.ID));
        WriteText('  (      ' + Fields + ')');
        WriteText('  Select ' + Fields);
        WriteText('    from [' + SQL_Name(FromDatabase) + '].' + SQLTableName(Company.Name, pRec."Object Name", pPublishedApplication.ID));
    end;

    local procedure PrimaryKeyFields(pTableID: Integer) ReturnValue: Text
    var
        RRef: RecordRef;
        KRef: KeyRef;
        FRef: FieldRef;
        i: Integer;

    begin
        RRef.Open(pTableID);
        KRef := RRef.KeyIndex(1);
        for i := 1 to KRef.FieldCount do begin
            FRef := KRef.FieldIndex(i);
            if ReturnValue <> '' then
                ReturnValue := ReturnValue + ',';
            if FRef.Active then
                ReturnValue += '[' + SQL_Name(FRef.Name) + ']';
        end;
    end;

    local procedure FieldList(pTableID: Integer; pReplaceCompanyName: Text; pPackageID: Guid) ReturnValue: Text
    var
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo, pTableID);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(Enabled, true);
        // Field.SetRange("No.", 1, 2000000000); // keep [$systemId] but avoid ([SystemCreatedAt],[SystemCreatedBy],[SystemModifiedAt],[SystemModifiedBy])
        Field.SetRange("App Package ID", pPackageID); //PublishedApplication."Package ID");
        if Field.FindSet then
            repeat
                if ReturnValue <> '' then
                    ReturnValue := ReturnValue + ',';
                if field."No." > 2000000000 then // [SystemCreatedAt],[SystemCreatedBy],[SystemModifiedAt],[SystemModifiedBy] are '$' prefixed
                    ReturnValue += '[' + '$' + SQL_Name(Field.FieldName) + ']'
                else
                    if (Field.FieldName = 'Company Name') and (pReplaceCompanyName <> '') then
                        ReturnValue += '''' + pReplaceCompanyName + ''''
                    else
                        ReturnValue += '[' + SQL_Name(Field.FieldName) + ']';
            until Field.Next = 0;
    end;

    local procedure SQLTableName(pCompanyName: Text; pName: Text; pAppID: Guid): Text
    begin
        if pCompanyName = '' then
            exit('[dbo].[' + SQL_Name(pName) + '$' + FormatGUID(pAppID) + ']')
        else
            exit('[dbo].[' + SQL_Name(pCompanyName) + '$' + SQL_Name(pName) + '$' + FormatGUID(pAppID) + ']');
    end;

    // local procedure SQLFieldName(pName: Text): Text
    // begin
    //     exit(ConvertStr(pName, '.%/''', '____'));
    // end;

    local procedure SQL_Name(pName: Text): Text
    begin
        exit(ConvertStr(pName, '.%/''', '____'));
    end;

    local procedure FormatGUID(pGUID: Guid): Text
    begin
        exit(delchr(format(pGuid), '=', '{}'))
    end;

    local procedure WriteText(pText: Text)
    var
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        oStream.WriteText(pText + CRLF);
    end;
    // local procedure UpdateCompanyInformation(): Text
    // var
    //     CompanyInformation: Record "Company Information";
    // begin
    //     exit('Update ' + SQLTableName(??Company, CompanyInformation.TableName) + ' Set [System Indicator] = ' + Format(CompanyInformation."system indicator"::Custom));
    // end;

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
            1062, //Database::"Payment Reporting Argument",
            Database::"User Task",
            Database::"Document Attachment",
            Database::"Data Privacy Records",
            Database::"Journal User Preferences",
            Database::"Credit Trans Re-export History",
            Database::"Intermediate Data Import",
            Database::"Data Exch.",
            Database::"Payment Export Data",
            Database::"XML Buffer",
            1470, //Database::"Product Video Buffer",
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
            1807, //Database::"Assisted Setup Log",
            Database::"O365 Payment Service Logo",
            2132, //Database::"O365 Settings Menu",
            2155, //Database::"O365 Payment Instructions",
            Database::"Calendar Event",
            2163, //Database::"O365 Sales Event",
            Database::"Integration Field Mapping",
            Database::"Temp Integration Field Mapping",
            Database::"Integration Synch. Job Errors",
            Database::"BOM Buffer",
            Database::"Item Attribute",
            Database::"Item Attribute Value",
            Database::"Record Set Definition",
            Database::"Record Set Tree",
            Database::"Record Set Buffer",
            Database::"Custom Report Selection",
            Database::"CAL Test Line",
            Database::"CAL Test Enabled Codeunit",
            Database::"CAL Test Result",
            Database::"Semi-Manual Execution Log",

            1070, // Database::"PayPal Payments Standard Account",
            1360, // Database::"WorldPay Payments Standard Account",
            3905, // Database::"Retention Policy Log Entry",
            4151, // Database::"Persistent Blob",
            Database::"Email Outbox",
            Database::"Sent Email",
            8901, // Database::"Email Error",
            8904, // Database::"Email Message Attachment",
            Database::"Email Scenario Attachments",
            20100, //Database::"AMC Bank Banks":
            87092, // Database::"WanaPort Log",
            Database::"Posted Gen. Journal Line",
            Database::"Dimension Correction",
            Database::"Dim Correct Selection Criteria",
            Database::"Invalidated Dim Correction",
            Database::"CRM Annotation Buffer",
            Database::"Dataverse Entity Change",
            Database::"Price List Line",
            Database::"Dtld. Price Calculation Setup",
            Database::"Price Worksheet Line",
            Database::"Config. Field Map",
            Database::"Profile Designer Diagnostic",
            Database::"Payment Period Setup",
            57011, //Database::"_Codexia Entry",
            4703, //Database::"VAT Group Submission Line",

            Database::"Batch Processing Session Map":
                exit(true);
        end;
    end;
}
