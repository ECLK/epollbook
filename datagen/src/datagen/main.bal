import ballerina/io;
import ballerina/lang.'int;
import ballerina/time;
import ballerina/math;
import ballerina/log;

public function main(string? filePath = ()) returns @tainted error? {
    if filePath is () {
        check generateSQLInserts(createData());
    } else {
 //       check generateSQLInserts(check loadFromCSV(filePath));
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
                int seqNo = checkpanic math:randomInRange(1,1000);
                string NIC = string`${yearOfBirth}${io:sprintf("%03d", gender == 0 ? dobdays : dobdays+500)}${io:sprintf("%03d",seqNo)}v`;
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

