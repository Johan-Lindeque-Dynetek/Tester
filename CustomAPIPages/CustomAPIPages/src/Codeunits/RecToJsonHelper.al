codeunit 50000 "Rec To Json Helper"
{
    trigger OnRun()
    begin

    end;

    #region Main Functions
    /// <summary>
    /// Init new Json Object to be populated
    /// </summary>
    procedure Init()
    begin
        Clear(MainJsonObject);
    end;

    /// <summary>
    /// Add the current JsonObject to the Main Array used for output
    /// </summary>
    procedure Insert()
    begin
        MainJsonArray.Add(MainJsonObject);
    end;

    /// <summary>
    /// Get the Main array contents as JSON text
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure OutputStrJSONArray(): Text
    var
        JsonTextOut: Text;
    begin
        MainJsonArray.WriteTo(JsonTextOut);
        CleanJSONRequestData(JsonTextOut);
        exit(JsonTextOut);
    end;

    procedure OutputStrJSONObject(): Text
    var
        JsonTextOut: Text;
    begin
        MainJsonObject.WriteTo(JsonTextOut);
        CleanJSONRequestData(JsonTextOut);
        exit(JsonTextOut);
    end;

    /// <summary>
    /// Get the Main array contents as JSON Array
    /// </summary>
    /// <returns>Return value of type JsonArray.</returns>
    procedure OutputAsArray(): JsonArray
    begin
        exit(MainJsonArray);
    end;

    #endregion Main Functions


    #region Custom Additions
    /// <summary>
    /// Append text property to the Current Object
    /// </summary>
    /// <param name="PropertyName">Text.</param>
    /// <param name="PropertyValue">text.</param>
    procedure Append(PropertyName: Text; PropertyValue: text)
    begin
        MainJsonObject.Add(CleanJsonPropName(PropertyName), PropertyValue);
    end;

    /// <summary>
    /// Append Json Array property to the Current Object
    /// </summary>
    /// <param name="PropertyName">Text.</param>
    /// <param name="PropertyValue">JsonArray.</param>
    procedure Append(PropertyName: Text; PropertyValue: JsonArray)
    begin
        MainJsonObject.Add(CleanJsonPropName(PropertyName), PropertyValue);
    end;

    /// <summary>
    /// Append.
    /// </summary>
    /// <param name="PropertyName">Text.</param>
    /// <param name="PropertyValue">Integer.</param>
    procedure Append(PropertyName: Text; PropertyValue: Integer)
    begin
        MainJsonObject.Add(CleanJsonPropName(PropertyName), PropertyValue);
    end;
    #endregion Custom Additions



    #region BC Record Processing

    /// <summary>
    /// Append properties from provided Record Ref
    /// </summary>
    /// <param name="RecordRefIn">RecordRef.</param>
    procedure Append(RecID: RecordId)
    var
        RecRef: RecordRef;

    begin
        // Stage 1 - Change into Recref
        Clear(RecRef);

        RecRef.Open(RecID.TableNo);
        RecRef.Get(RecID);
        GenerateJSONFromRecordRef(RecRef);
    end;

    local procedure GenerateJSONFromRecordRef(var RecordRef: RecordRef)
    var
        FieldRef: FieldRef;
        FieldNo: Integer;

    begin
        foreach FieldNo in SelectedFieldList do begin
            FieldRef := RecordRef.Field(FieldNo);
            AddFieldtoJsonObject(FieldRef, MainJsonObject);
        end;
    end;

    local procedure AddFieldtoJsonObject(var FieldRef: FieldRef; var RecObject: JsonObject)
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        Number: Decimal;
        IntNum: Integer;
        TempText: Text;
        DateType: Date;
        DateTimeType: DateTime;
        BoolType: Boolean;
        BigIntNum: BigInteger;
        InStream: InStream;
        OutStream: OutStream;
        extractedEnumInteger: Text;

        OptionMemberList: Text;
        FieldRefOrdinalVal: Integer;
        IndexFieldRefVal: Integer;
        returnVal: Integer;
    begin
        //  Calc blob type fields to get their data to put in json.
        if FieldRef.Type = FieldType::Blob then
            FieldRef.CalcField();

        case FieldRef.Type of

            FieldRef.Type::Blob:
                begin
                    Clear(InStream);
                    Clear(OutStream);

                    FieldRef.CalcField();
                    TempBlob.FromFieldRef(FieldRef);
                    TempBlob.CreateInStream(InStream);

                    TempText := Base64Convert.ToBase64(InStream);

                    RecObject.Add(CleanJsonPropName(FieldRef.Name), TempText);
                end;

            FieldRef.Type::DateTime:
                begin
                    DateTimeType := FieldRef.Value;
                    RecObject.Add(CleanJsonPropName(FieldRef.Name), DateTimeType);
                end;
            FieldRef.Type::Date:
                begin
                    DateType := FieldRef.Value;

                    //<Closing><Day>. <Month Text> <Year4> ID=4 Returns: 5. April 2021
                    TempText := Format(DateType, 0, 9);
                    TempText := TempText.Replace('C', '');
                    RecObject.Add(CleanJsonPropName(FieldRef.Name), TempText);
                end;
            FieldRef.Type::Decimal:
                begin
                    if FieldRef.Class = FieldClass::FlowField then
                        FieldRef.CalcField();

                    Number := FieldRef.Value;
                    RecObject.Add(CleanJsonPropName(FieldRef.Name), Number);

                end;

            FieldRef.Type::Integer:
                begin
                    if FieldRef.Class = FieldClass::FlowField then
                        FieldRef.CalcField();

                    IntNum := FieldRef.Value;
                    RecObject.Add(CleanJsonPropName(FieldRef.Name), IntNum);

                end;
            // FieldRef.Type::Text, FieldRef.Type::Option:
            FieldRef.Type::Text:
                begin
                    if FieldRef.Class = FieldClass::FlowField then
                        FieldRef.CalcField();

                    TempText := Format(FieldRef.Value);
                    RecObject.Add(CleanJsonPropName(FieldRef.Name), TempText);

                end;

            FieldRef.Type::Code:
                begin
                    if FieldRef.Class = FieldClass::FlowField then
                        FieldRef.CalcField();

                    TempText := Format(FieldRef.Value);
                    RecObject.Add(CleanJsonPropName(FieldRef.Name), TempText);
                end;

            FieldRef.Type::Boolean:
                begin
                    BoolType := FieldRef.Value;
                    if (BoolType) then
                        RecObject.Add(CleanJsonPropName(FieldRef.Name), true)
                    else
                        RecObject.Add(CleanJsonPropName(FieldRef.Name), false);
                end;

            FieldRef.Type::BigInteger:
                begin
                    if FieldRef.Class = FieldClass::FlowField then
                        FieldRef.CalcField();

                    BigIntNum := FieldRef.Value;
                    RecObject.Add(CleanJsonPropName(FieldRef.Name), BigIntNum);
                end;

            FieldRef.Type::Option:
                begin
                    extractedEnumInteger := Format(FieldRef.Value, 0, 9);
                    Evaluate(FieldRefOrdinalVal, extractedEnumInteger);

                    // OptionMemberList := FieldRef.OptionMembers();


                    // if not FieldRef.IsEnum then
                    //     FieldRefOrdinalVal := FindOptionFieldCaptionFromIndex(OptionMemberList, FieldRef.Value)

                    // else begin
                    //     // IndexFieldRefVal := OptionMemberList.IndexOf(FieldRef.Value);
                    //     IndexFieldRefVal := FindOptionFieldCaptionFromIndex(OptionMemberList, FieldRef.Value);

                    //     FieldRefOrdinalVal := fieldref.GetEnumValueOrdinal(IndexFieldRefVal + 1);

                    // end;

                    // if FieldRefOrdinalVal = -1 then
                    //     Clear(FieldRefOrdinalVal);
                    RecObject.Add(CleanJsonPropName(FieldRef.Name), FieldRefOrdinalVal);



                end;

        end;
    end;

    local procedure FindOptionFieldCaptionFromIndex(InputString: Text; SearchWord: Text): Integer
    var
        Words: List of [Text];
        Word: Text;
        Index: Integer;
        I: Integer;
    begin
        Index := -1; // Initialize index to -1 (not found)
        Words := InputString.Split(','); // Split the input string by commas

        I := 0;
        foreach Word in Words do begin
            if Word = SearchWord then begin
                Index := I;
                break;
            end;
            I += 1;
        end;

        exit(Index);
    end;

    local procedure CleanJsonPropName(fieldCaption: Text): Text
    var
        FieldName: Text;
        FirstChar: Char;
    begin
        FieldName := fieldCaption
        .Replace('.', '')
        .Replace('/', '')
        .Replace(' ', '')
        .Replace('-', '')
        .Replace(')', '')
        .Replace('(', '')
        .Replace(']', '')
        .Replace('[', '');

        FirstChar := FieldName[1];
        if FirstChar in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'] then
            exit('_' + FieldName);

        exit(FieldName);
    end;

    local procedure CleanJSONRequestData(var JsonTextOut: Text)
    begin
        // Format boolean correct
        JsonTextOut := JsonTextOut.Replace(':"Yes"', ':true');
        JsonTextOut := JsonTextOut.Replace(':"No"', ':false');
    end;
    #endregion BC Record Processing


internal procedure BuildCustomerFieldsListFromReqList(CustomFields: Text)
    var
        Field: Record Field;
        CurrentName: text;
    begin
        FieldNamesList := CustomFields.Split('|');
        if FieldNamesList.Count > 0 then begin
            foreach CurrentName in FieldNamesList do begin
                Field.SetRange(TableNo, Database::Customer);
                Field.SetFilter(FieldName, CurrentName);
                if Field.FindFirst() then begin
                    SelectedFieldList.Add(Field."No.");
                end;

            end;

        end;
    end;

    var
        SelectedFieldList: List of [Integer];
        
        FieldNamesList: List of [Text];
        CurrselectedTable: Integer;
        MainJsonArray: JsonArray;
        MainJsonObject: JsonObject;

}