import ballerinax/java.jdbc;
import ballerina/config;
import ballerina/jsonutils;
import ballerina/log;

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
    string SELECT_ELECTORS = "SELECT ID, ElectorID, NIC, Name_SI, Name_TA FROM voter_registry WHERE DistrictSI = ? AND PollingDivisionSI = ? AND PollingStationID = ?";
    table<record{}> ret = check dbClient->select(SELECT_ELECTORS, Elector, districtSI, divisionSI, stationID);
    return <@untainted> <json[]> jsonutils:fromTable(ret);
}

function setVoterStatus(string election, string stationID, string voterID, string timestamp, string status) returns error? {
    string ENTER_QUEUE = "REPLACE INTO vote_records(ID,PollingStationID,ElectionID, Timestamp, Status) VALUES (?, ?, ?, ?, ?)";
    var res = dbClient->update(ENTER_QUEUE, voterID, stationID, election, timestamp, status);
    if !(res is jdbc:UpdateResult) {
        log:printError(string`Error recording ${status} status of voter ${voterID} at polling station '${stationID}'`);
        return res;
    }
}
