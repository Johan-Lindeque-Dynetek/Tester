codeunit 50002 "APIDynamicFieldReturnHandler"
{
    internal procedure GetCustomFieldsList(): List of [Integer]
    begin

        // case (TargetTableID) of
        //     (Database::Customer):
                exit(FieldCustomerList);
        // add other

        // end;
    end;

    // internal procedure BuildCustomerFieldsListFromReqList(CustomFields: Text)
    // var
    //     Field: Record Field;
    //     CurrentName: text;
    // begin
    //     FieldNamesList := CustomFields.Split('|');
    //     if FieldNamesList.Count > 0 then begin
    //         // check field bestaan ? add field no. ELSE continue
    //         foreach CurrentName in FieldNamesList do begin
    //             Field.SetRange(TableNo, Database::Customer);
    //             Field.SetFilter(FieldName, CurrentName);
    //             if Field.FindFirst() then begin
    //                 FieldCustomerList.Add(Field."No.");
    //             end
    //             else
    //                 FieldCustomerList.Add(0);

    //         end;

    //     end;
    // end;


    var
        FieldCustomerList: List of [Integer];
        FieldNamesList: List of [Text];

}
