import ballerina/io;
import ballerina/lang.'int;
import ballerina/log;

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
    string? VS_TA;
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

map<int> districtCodes = {
    "1 - කොළඹ": 1
};
map<string> pdCodes = {
    "ඉ - බටහිර කොළඹ": "E",
    "ඒ - කඩුවෙල": "J"
};
map<string> sexCodes = {
    "ගැ": "FEMALE",
    "පි": "MALE"
};

function loadFromCSV(string filePath) returns @tainted table<DBElector>|error {
    io:ReadableCSVChannel rCsvChannel = check <@untainted>io:openReadableCsvFile(<@untainted>filePath);
    table<CSVElector> electorTable = <table<CSVElector>>rCsvChannel.getTable(CSVElector);
    check <@untainted> rCsvChannel.close();
    table<DBElector> results = table {};
    int rowCount = 0;
    foreach CSVElector row in electorTable {
        rowCount += 1;
        if rowCount == 1 {
            continue; // ignore header row
        }
        log:printInfo(string`Reading row ${rowCount}`);

        DBElector e = {
            YearOfRevision: row.YearOfRevision,
            DistrictID: districtCodes[row.DistrictSI] ?: -1,
            PollingDivisionID: pdCodes[row.PollingDivisionSI] ?: "UNKNOWN PD!: '" + row.PollingDivisionSI + "'",
            PollingStationID: check 'int:fromString(row.PollingStationID),
            GNDivision_SI: row.GND_SI,
            GNDivision_TA: row.GND_TA,
            Street_SI: row.VS_SI,
            Street_TA: row.VS_TA ?: "*",
            HouseNo: row.HouseNo,
            ElectorID: check 'int:fromString(row.ElectorID),
            NationalID: row.NationalID,
            Name_SI: row.Name_SI,
            Name_TA: row.Name_TA ?: "*",
            Sex: sexCodes[row.GenderCode_SI] ?: "UNKNOWN"
        };
        error? err = results.add(e); // ignore error
    }
    return results;
}


