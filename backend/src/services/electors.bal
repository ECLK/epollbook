import ballerinax/java.jdbc;
import ballerina/config;
import ballerina/jsonutils;
import ballerina/log;
import ballerina/lang.'int;
import ballerina/time;
import ballerina/io;

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
    var res = dbClient->update(STATUSUPDATE, election, districtID, divisionID, stationID, voterID, getVoterAge(voterID), status, timestamp);
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
function getVoterAge(string elector) returns int {
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
    log:printInfo(string`Got NIC for elector ${elector} as ${nic}`);

    int current_year = 20;
    int length_old_NIC = 9;
    int length_new_NIC = 12;
    int DOB_year;
    string DOB_month;
    string DOB_date;
    int|error days_from_jan1_digits;

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
                // adjusting DOB_year to 1900s
                DOB_year = 1900 + year_digits;
            } else {
                // adjusting DOB_year to 2000s
                DOB_year = 2000 + year_digits;
            }
        }
        days_from_jan1_digits = 'int:fromString(nic.substring(2, 5));
    } else {
        int|error year_digits = 'int:fromString(nic.substring(0, 4));
        if year_digits is error {
            log:printError(string`Error getting age chars for NIC: ${nic}`);
            return -1;
        } else {
            DOB_year = year_digits;
        }
        days_from_jan1_digits = 'int:fromString(nic.substring(4, 7));
    }

    boolean DOB_year_is_leap = DOB_year % 4 == 0 ? true : false;
    int ndaysInYear = DOB_year_is_leap ? 366 : 365;

    // get month & day of birth
    if days_from_jan1_digits is error {
        log:printError(string`Error getting days from Jan 1 for NIC: ${nic}`);
        return -1;
    } else {
        // Subtracting 500 to the next three digits if the person is female
        if days_from_jan1_digits > ndaysInYear {
            days_from_jan1_digits -= 500;
        }
        if days_from_jan1_digits > ndaysInYear || days_from_jan1_digits <= 0 {
            log:printError(string`Invalid number of days from Jan 1 for NIC: ${nic}`);
            return -1;
        }

        // Uses leap year to calculate the month and date for the day of the year because apparently that's how
        // government do it.
            string leapYear = "2020";
            string dateString = io:sprintf("%s-%s", leapYear, days_from_jan1_digits);
            time:Time|error tempTime = time:parse(dateString, "yyyy-D");
            if (tempTime is time:Time)
            {
                DOB_month = time:getMonth(tempTime).toString();
                DOB_date = time:getDay(tempTime).toString();
                dateString = io:sprintf("%s-%s-%s", DOB_year, DOB_month, DOB_date);
                time:Time|error DOB = time:parse(dateString, "yyyy-M-d");
                //return DOB;
return -1;
            }
    }
    return -1;
}
