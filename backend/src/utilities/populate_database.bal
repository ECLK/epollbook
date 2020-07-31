import ballerina/io;
import ballerina/lang.'int;
import ballerina/time;
import ballerina/math;

public function main(string? filePath = ()) returns @tainted error? {
    if filePath is () {
        check generateSQL(createData());
    } else {
        io:ReadableCSVChannel rCsvChannel = check <@untainted>io:openReadableCsvFile(<@untainted>filePath);
        table<Elector> electorTable = <table<Elector>>rCsvChannel.getTable(Elector);
        check generateSQL(electorTable);
        check <@untainted> rCsvChannel.close();
    }
}

function loadData(string srcFilePath) returns error? {
    io:ReadableCSVChannel rCsvChannel = check <@untainted>io:openReadableCsvFile(<@untainted>srcFilePath);
    table<Elector> electorTable = <table<Elector>>rCsvChannel.getTable(Elector);
    int row = 0;
    foreach var rec in electorTable {
        if row == 0 { // ignore header line
            row += 1;
            continue;
        }
        //boolean isMale = rec.Gender_SI == "පුරුෂ";
        insertElectorDataToDB(rec);
    }
    check <@untainted> rCsvChannel.close();
}

function createData() returns table<Elector> {
    string[] gender_SI = ["ස්ත්‍රී", "පුරුෂ"];
    string[] gender_TA = ["பெண்", "ஆண்"];
    table<Elector> data = table {
        {YearOfRevision,DistrictSI,DistrictTA,PollingDivisionSI,PollingDivisionTA,PollingStationID,GND_SI,GND_TA,VS_SI,VS_TA,HouseNo,ElectorID,SLIN_NIC,Name_SI,Name_TA,Gender_SI,Gender_TA},
        [
            {"YearOfRevision","DistrictSI","DistrictTA","PollingDivisionSI","PollingDivisionTA","PollingStationID","GND_SI","GND_TA","VS_SI","VS_TA","HouseNo","ElectorID","NIC","Name_SI","Name_TA","Gender_SI","Gender_TA"}
        ]
    };
    foreach var pd in 0 ... 3 {
        foreach var psNum in 1 ... 5 {
            string gnd = string`PD${pd+1}-GND-${checkpanic math:randomInRange(1,6)}`;
            int nelectors = 1500 + 50 * checkpanic math:randomInRange(1, 10);
            foreach var elector in 1 ... nelectors {
                int yearOfBirth = checkpanic math:randomInRange(10, 93); // born from 1910 to 1992 (just for tests)
                int gender = checkpanic math:randomInRange(0,2);
                int dobdays = checkpanic math:randomInRange(1,366);
                int seqNo = checkpanic math:randomInRange(1,1000);
                string NIC = string`${yearOfBirth}${io:sprintf("%03d", gender == 0 ? dobdays : dobdays+500)}${io:sprintf("%03d",seqNo)}v`;
                Elector e = {
                    YearOfRevision: "2019",
                    DistrictSI: "1 - කොළඹ",
                    DistrictTA: "1 - கொழும்பு",
                    PollingDivisionSI: string`PD${pd+1}-SI`,
                    PollingDivisionTA: string`PD${pd+1}-TA`,
                    PollingStationID: psNum.toString(),
                    GND_SI: gnd+"_SI",
                    GND_TA: gnd+"_TA",
                    VS_SI: "VS_SI",
                    VS_TA: "VS_TA",
                    HouseNo: string`${checkpanic math:randomInRange(1,200)}`,
                    ElectorID: elector.toString(),
                    SLIN_NIC: NIC,
                    Name_SI: string`Name-SI-elector#-${elector}`,
                    Name_TA: string`Name-TA-elector#-${elector}`,
                    Gender_SI: gender_SI[gender],
                    Gender_TA: gender_TA[gender]
                };
                var v = data.add(e);
            }
        }
    }
    return data;
}

function generateSQL(table<Elector> electorTable) returns error? {
    io:println("DROP TABLE IF EXISTS `voter_registry`;");
    io:println(CREATE_VOTER_REGISTRY_TABLE + ";");
    io:println("DROP TABLE IF EXISTS `vote_records`;");
    io:println(CREATE_VOTE_RECORDS_TABLE + ";");
    int row = 0;
    foreach var rec in electorTable {
        if row == 0 { // ignore header line
            row += 1;
            continue;
        }
        printInsert(rec);
    }
}

function printInsert(Elector rec) {
    io:println(string`INSERT INTO voter_registry (YearOfRevision,DistrictSI,DistrictTA,PollingDivisionSI,PollingDivisionTA,PollingStationID,GND_SI,GND_TA,VS_SI,VS_TA,HouseNo,ElectorID,NIC,Name_SI,Name_TA,Gender_SI,Gender_TA) 
      VALUES ('${rec.YearOfRevision}','${rec.DistrictSI}','${rec.DistrictTA}','${rec.PollingDivisionSI}','${rec.PollingDivisionTA}','${rec.PollingStationID}','${rec.GND_SI}','${rec.GND_TA}','${rec.VS_SI}','${rec.VS_TA}','${rec.HouseNo}','${rec.ElectorID}','${rec.SLIN_NIC}','${rec.Name_SI}','${rec.Name_TA}','${rec.Gender_SI}','${rec.Gender_TA}');`);
}

function calculateDOBFromNIC(string nic) returns time:Time|error
{
    int current_year = 20;
    int length_old_NIC = 10;
    int length_new_NIC = 12;
    string DOB_year;
    string DOB_month;
    string DOB_date;
    int|error next_three_digits;

    if (nic.length() == length_old_NIC || nic.length() == length_new_NIC)
    {
        if (nic.length() == length_old_NIC)
        {
            int|error first_two_digits = 'int:fromString(nic.substring(0, 2));
            if (first_two_digits is int)
            {
                if (first_two_digits > current_year)
                {
                    // adjusting DOB_year to 1900s
                    DOB_year = "19".concat(first_two_digits.toString());
                }
                else
                {
                    // adjusting DOB_year to 2000s
                    DOB_year = "20".concat(first_two_digits.toString());
                }

            }
            else
            {
                return first_two_digits;
            }
            next_three_digits = 'int:fromString(nic.substring(2, 5));
        }
        else
        {
            int|error first_four_digits = 'int:fromString(nic.substring(0, 4));
            if (first_four_digits is int)
            {
                DOB_year = first_four_digits.toString();
            }
            else
            {
                return error("Cannot convert new NIC to integer value.");
            }
            next_three_digits = 'int:fromString(nic.substring(4, 7));

        }

        if (next_three_digits is int)
        {

            // Subtracting 500 to the next three digits if the person is female
            if (next_three_digits> 365)
            {
                next_three_digits -= 500;
            }

            if (next_three_digits <= 365 && next_three_digits > 0)
            {
                // Uses leap year to calculate the month and date for the day of the year because apparently that's how
                // government do it.
                string leapYear = "2020";
                string dateString = io:sprintf("%s-%s", leapYear, next_three_digits);
                time:Time|error tempTime = time:parse(dateString, "yyyy-D");
                if (tempTime is time:Time)
                {
                    DOB_month = time:getMonth(tempTime).toString();
                    DOB_date = time:getDay(tempTime).toString();
                    dateString = io:sprintf("%s-%s-%s", DOB_year, DOB_month, DOB_date);
                    time:Time|error DOB = time:parse(dateString, "yyyy-M-d");
                    return DOB;

                }
                else
                {
                    return tempTime;
                }
            }
            else
            {
                return error("Day of the year must be between 0 and 365.");
            }

        }
        else
        {
            return next_three_digits;
        }
    }
    else
    {
        return error("Invalid NIC format.");
    }

}

