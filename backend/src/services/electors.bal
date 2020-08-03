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
    string SELECT_ELECTORS = 
        "SELECT ID, ElectorID, NationalID, GNDivision_SI, Street_SI, HouseNo, Name_SI, Name_TA, Sex " +
        "FROM ElectorRegistry " + 
        "WHERE DistrictID=? AND PollingDivisionID=? AND PollingStationID=?";
    table<record{}> ret = check dbClient->select(SELECT_ELECTORS, ElectorResponse, districtSI, divisionSI, stationID);
    return <json[]> jsonutils:fromTable(ret);
}

// CREATE TABLE VoteRecords (
//     Election varchar(10) NOT NULL,
//     DistrictID INT NOT NULL,  
//     PollingDivisionID varchar(1) NOT NULL,    
//     PollingStationID INT NOT NULL,    
//     ID INT NOT NULL,
//     Age int DEFAULT -1,
//     VotingStatus enum('NOT-VOTED','QUEUED','VOTED') DEFAULT 'NOT-VOTED',
//    TimeStamp timestamp DEFAULT NULL,
//     PRIMARY KEY (ID),
//     CONSTRAINT ID FOREIGN KEY (ID) REFERENCES ElectorRegistry (ID)
// );

function setVoterStatus(string election, string districtID, string divisionID, string stationID, string voterID, string timestamp, string status) returns error? {
    string STATUSUPDATE = "REPLACE INTO VoteRecords(Election, DistrictID, PollingDivisionID, PollingStationID, ID, VotingStatus, Timestamp) VALUES (?, ?, ?, ?, ?, ?, ?)";
    var res = dbClient->update(STATUSUPDATE, election, districtID, divisionID, stationID, voterID, status, timestamp);
    if !(res is jdbc:UpdateResult) {
        log:printError(string`Error recording ${status} status of voter ${voterID} at polling station '${districtID}/${divisionID}/${stationID}'`);
        return res;
    }
}

function getQueue(string election, string districtID, string divisionID, string stationID) returns @tainted json[]|error {
    string SELECT_QUEUE = "SELECT ID FROM VoteRecords where VotingStatus= ? AND DistrictID = ? AND PollingDivisionID = ? AND PollingStationID = ?";
    table<record{}> ret = check dbClient->select(SELECT_QUEUE, record { string ID; }, STATUS_QUEUED, districtID, divisionID, stationID);
    return <json[]> jsonutils:fromTable(ret);
}