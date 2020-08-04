import ballerina/io;
import ballerina/math;
import ballerina/log;

public function main(string? filePath = ()) returns @tainted error? {
    if filePath is () {
        check generateSQLInserts(createData());
    } else {
        check generateSQLInserts(check loadFromCSV(filePath));
    }
}

type DBElector record {
    string YearOfRevision;
    int DistrictID;
    string PollingDivisionID;
    int PollingStationID;
    string GNDivision_SI;
    string GNDivision_TA;
    string Street_SI;
    string Street_TA;
    string HouseNo;
    int ElectorID;
    string NationalID;
    string Name_SI;
    string Name_TA;
    string Sex;
};

function createData() returns table<DBElector> {
    table<DBElector> data = table {};
    string[] divs = ["A","B","C", "D", "E"];
    string[] sexes = ["MALE","FEMALE"];
    int totalElectors = 0;
    foreach var pd in 0 ... divs.length()-1 {
        foreach var psNum in 1 ... 3 {
            string gnd = string`PD${pd+1}-GND-for-PS-${psNum}`;
            int nelectors = 1000 + 50 * checkpanic math:randomInRange(1, 11);
            totalElectors += nelectors;
            log:printInfo(string`Generating: ${nelectors} electors for polling station #${psNum} of pd '${divs[pd]}' of district 'Colombo'`);
            foreach var elector in 1 ... nelectors {
                int yearOfBirth = checkpanic math:randomInRange(10, 93); // born from 1910 to 1992 (just for tests)
                int gender = checkpanic math:randomInRange(0,2);
                int dobdays = checkpanic math:randomInRange(1,366);
                int seqNo = checkpanic math:randomInRange(1,10000); // technically 3 digit seq # + check digit but we don't worry
                string NIC = string`${yearOfBirth}${io:sprintf("%03d", gender == 0 ? dobdays : dobdays+500)}${io:sprintf("%04d",seqNo)}v`;
                DBElector e = {
                    YearOfRevision: "2019",
                    DistrictID: 1,
                    PollingDivisionID: divs[pd],
                    PollingStationID: psNum,
                    GNDivision_SI: gnd+"_SI",
                    GNDivision_TA: gnd+"_TA",
                    Street_SI: "පාර",
                    Street_TA: "சாலை",
                    HouseNo: string`${checkpanic math:randomInRange(1,200)}`,
                    ElectorID: elector,
                    NationalID: NIC,
                    Name_SI: string`නාමය-SI-elector#-${elector}`,
                    Name_TA: string`பெயர்-TA-elector#-${elector}`,
                    Sex: sexes[gender]
                };
                var v = data.add(e);
            }
        }
    }
    log:printInfo(string`Generated total of ${totalElectors} electors.`);
    return data;
}

function generateSQLInserts(table<DBElector> electorTable) returns error? {
    io:println ("USE epollbook;\n");
    foreach var rec in electorTable {
        io:println(string `INSERT INTO ElectorRegistry (YearOfRevision, DistrictID, PollingDivisionID, PollingStationID, GNDivision_SI, GNDivision_TA, Street_SI, Street_TA, HouseNo, ElectorID, NationalID, Name_SI, Name_TA, Sex) 
          VALUES ('${rec.YearOfRevision}','${rec.DistrictID}','${rec.PollingDivisionID}','${rec.PollingStationID}','${rec.GNDivision_SI}','${rec.GNDivision_TA}','${rec.Street_SI}','${rec.Street_TA}','${rec.HouseNo}','${rec.ElectorID}','${rec.NationalID}','${rec.Name_SI}','${rec.Name_TA}','${rec.Sex}');`);
    }
}
