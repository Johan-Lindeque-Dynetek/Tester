page 50001 Toets
{
    ApplicationArea = All;
    Caption = 'Toets';
    PageType = List;
    SourceTable = toets;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.id)
                {
                    ToolTip = 'Specifies the value of the id field.', Comment = '%';
                }
                field("custom fields"; Rec."custom fields")
                {
                    ToolTip = 'Specifies the value of the custom fields field.', Comment = '%';
                }
                field("Time recieved"; Rec."Time recieved")
                {
                    ToolTip = 'Specifies the value of the Time recieved field.', Comment = '%';
                }
                field(RecId; Rec.RecId)
                {
                    ToolTip = 'Specifies the value of the Rec ID field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Test)
            {
                ApplicationArea = All;
                Caption = 'Test fields';

                trigger OnAction()
                var
                    Customer: Record Customer;
                begin

                    Customer.Get(10000);
                    RecToJsonHelper.Init();
                    RecToJsonHelper.BuildCustomerFieldsListFromReqList('No.|Name|DYN Last Modified');
                    RecToJsonHelper.Append(Customer.RecordId());
                    RecToJsonHelper.Insert();

                    // exit(RecToJsonHelper.OutputStrJSONObject());
                    Message('"CustomFields": ' + RecToJsonHelper.OutputStrJSONObject());
                    // Message(Format(DynamicFieldReturnHandler.GetCustomFieldsList()));
                end;
            }
        }
    }

    var
        DynamicFieldReturnHandler: Codeunit "APIDynamicFieldReturnHandler";
        RecToJsonHelper: Codeunit "Rec To Json Helper";
        CustomField: Text;

}
