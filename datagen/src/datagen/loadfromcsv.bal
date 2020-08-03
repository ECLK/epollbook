import ballerina/io;

// fields of the data files provided week of July 25
type CSVElector record{
    string YearOfRevision;
    string DistrictSI;
    string DistrictTA;
    string PollingDivisionSI;
    string PollingDivisionTA;
    string PollingStationID;
    string DSD_SI; // divisional secretariat
    string DSD_TA;
    string GND_SI;
    string GND_TA;
    string VS_SI;
    string VS_TA;
    string HouseNo;
    string ElectorID;
    string NationalID;
    string Name_SI;
    string? Name_TA;
    string Gender_SI;
    string Gender_TA;
    string GenderCode_SI;
    string GenderCode_TA;
};

function loadFromCSV(string filePath) returns @tainted table<CSVElector>|error {
    io:ReadableCSVChannel rCsvChannel = check <@untainted>io:openReadableCsvFile(<@untainted>filePath);
    table<CSVElector> electorTable = <table<CSVElector>>rCsvChannel.getTable(CSVElector);
    check <@untainted> rCsvChannel.close();
    return electorTable;
}


