table 50000 toets
{
    Caption = 'toets';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(10; "id"; Integer)
        {
            Caption = 'id';
            AutoIncrement = true;
        }
        field(20; "custom fields"; Text[250])
        {
            Caption = 'custom fields';
        }
        field(30; "Time recieved"; DateTime)
        {
            Caption = 'Time recieved';
        }
        field(40; "RecId"; text[250])
        {
            Caption = 'Rec ID';
        }
    }
    keys
    {
        key(PK; "id")
        {
            Clustered = true;
        }
    }
}
