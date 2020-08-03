import ballerinax/java.jdbc;
import ballerina/config;
import ballerina/jsonutils;
import ballerina/log;
import ballerina/lang.'int;
import ballerina/time;

// default values are for testing only
jdbc:Client dbClient = new ({
    url: config:getAsString("eclk.epb.db.url", "jdbc:mysql://localhost:3306/epollbook"),
    username: config:getAsString("eclk.epb.db.username", "root"),
    password: config:getAsString("eclk.epb.db.password", "root"),
    dbOptions: {
        useSSL: config:getAsString("eclk.epb.db.useSsl", "false")
    }
});


# Return the list of electors for a particular election, district, divison and polling station.
# + election - ID of the election (ignored for now)
# + districtSI - ID of the electoral district
# + divisionSI - ID of the polling division
# + stationID - ID of the polling station
# + return - list of matching electors
function getElectors(string election, string districtSI, string divisionSI, string stationID) returns @tainted json[]|error {
    string SELECT_ELECTORS = 
        "SELECT ID, ElectorID, NationalID, GNDivision_SI, Street_SI, HouseNo, Name_SI, Name_TA, Sex " +
        "FROM ElectorRegistry " + 
        "WHERE DistrictID=? AND PollingDivisionID=? AND PollingStationID=?";
    table<record{}> ret = check dbClient->select(SELECT_ELECTORS, ElectorResponse, districtSI, divisionSI, stationID);
    return <json[]> jsonutils:fromTable(ret);
}

function setVoterStatus(string election, string districtID, string divisionID, string stationID, string voterID, string timestamp, string status) returns error? {
    string STATUSUPDATE = "REPLACE INTO VoteRecords(Election, DistrictID, PollingDivisionID, PollingStationID, ID, Age, VotingStatus, Timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    var res = dbClient->update(STATUSUPDATE, election, districtID, divisionID, stationID, voterID, <@untainted> getVoterAge(voterID), status, timestamp);
    if !(res is jdbc:UpdateResult) {
        log:printError(string`Error recording ${status} status of voter ${voterID} at polling station '${districtID}/${divisionID}/${stationID}'`);
        return res;
    }
}

function getInStatus(string election, string districtID, string divisionID, string stationID, string status) returns @tainted json[]|error {
    string SELECT_QUEUE = "SELECT ID FROM VoteRecords where VotingStatus = ? AND DistrictID = ? AND PollingDivisionID = ? AND PollingStationID = ?";
    table<record{}> ret = check dbClient->select(SELECT_QUEUE, record { string ID; }, status, districtID, divisionID, stationID);
    return <json[]> jsonutils:fromTable(ret);
}

# Look up the elector in the DB and calculate their age as of the current date (in years only) from their NIC.
# + elector - ID of the elector in the DB
# + return - age of the elector in years with -1 being returned if unable to get it for whatever reason
function getVoterAge(string elector) returns @tainted int {
    string ELECTOR_QUERY = "SELECT NationalID from ElectorRegistry where ID = ?";
    table<record{}>|error ret = dbClient->select(ELECTOR_QUERY, record { string nationalID; }, elector);
    string nic = "";
    if ret is error {
        log:printError(string`Error while retrieving nationalID of elector ${elector}: ${ret.reason()}`);
        return -1;
    } else {
        record { string nationalID; } res = <record { string nationalID; }> ret.getNext();
        nic = res.nationalID;
    }

    int current_year = 20;
    int length_old_NIC = 9;
    int length_new_NIC = 12;
    int yearOfBirth;
    int|error daysFromJan1;

    if nic.length() != length_old_NIC && nic.length() != length_new_NIC {
        log:printError(string`Error: invalic NIC length: ${nic}`);
        return -1;
    }

    // get year of birth
    if nic.length() == length_old_NIC {
        int|error year_digits = 'int:fromString(nic.substring(0, 2));
        if year_digits is error {
            log:printError(string`Error getting age chars for NIC: ${nic}`);
            return -1;
        } else {
            if year_digits > current_year {
                // adjusting yearOfBirth to 1900s
                yearOfBirth = 1900 + year_digits;
            } else {
                // adjusting yearOfBirth to 2000s
                yearOfBirth = 2000 + year_digits;
            }
        }
        daysFromJan1 = 'int:fromString(nic.substring(2, 5));
    } else {
        int|error year_digits = 'int:fromString(nic.substring(0, 4));
        if year_digits is error {
            log:printError(string`Error getting age chars for NIC: ${nic}`);
            return -1;
        } else {
            yearOfBirth = year_digits;
        }
        daysFromJan1 = 'int:fromString(nic.substring(4, 7));
    }

    boolean yearOfBirth_is_leap = yearOfBirth % 4 == 0 ? true : false;
    int ndaysInYear = yearOfBirth_is_leap ? 366 : 365;

    // get month & day of birth
    if daysFromJan1 is error {
        log:printError(string`Error getting days from Jan 1 for NIC: ${nic}`);
        return -1;
    } else {
        // Subtracting 500 to the next three digits if the person is female
        if daysFromJan1 > ndaysInYear {
            daysFromJan1 -= 500;
        }
        if daysFromJan1 > ndaysInYear || daysFromJan1 <= 0 {
            log:printError(string`Invalid number of days from Jan 1 for NIC: ${nic}`);
            return -1;
        }
        time:Time ct = time:currentTime();
        int currentYear = time:getYear(ct);

        // calculate # of days to today
        int currentMonth = time:getMonth(ct);
        int[] monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]; // note: logic uses 365 day years
        int days2Today = 0;
        foreach int i in 0 ... currentMonth-2 { // add up past month days
            days2Today += monthDays[i];
        }
        days2Today += time:getDay(ct); // add days in current month

        // adjust daysFromJan1 if person was born on leap year on or after Feb 29th
        int dfJ = daysFromJan1;
        if yearOfBirth % 4 == 0 && daysFromJan1 >= 60 {
            dfJ -= 1;
        }

        // age in years is difference in years adjusted down by 1 if needed
        int age = currentYear - yearOfBirth;
        return dfJ > days2Today ? age-1 : age;
    }
}
