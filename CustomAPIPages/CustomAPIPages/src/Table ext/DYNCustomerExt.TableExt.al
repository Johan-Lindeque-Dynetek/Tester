tableextension 50000 "DYN Customer Ext" extends Customer
{
    fields
    {
        field(50000; "DYN Last Modified"; DateTime)
        {
            Caption = 'DYN Last Modified';
            DataClassification = ToBeClassified;
        }
        field(50010; "DYN Custom Fields"; Text[250])
        {
            Caption = 'DYN Custom Fields';
            DataClassification = ToBeClassified;
        }
    }
}
