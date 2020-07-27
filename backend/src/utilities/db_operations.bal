import ballerina/config;
import ballerina/log;
import ballerinax/java.jdbc;

// default values are for testing only
jdbc:Client dbClient = new ({
    url: config:getAsString("eclk.epb.db.url", "jdbc:mysql://localhost:3306/epollbook"),
    username: config:getAsString("eclk.epb.db.username", "root"),
    password: config:getAsString("eclk.epb.db.password", "root"),
    dbOptions: {
        useSSL: config:getAsString("eclk.epb.db.useSsl", "false")
    }
});


# Queries
const string CREATE_VOTER_REGISTRY_TABLE = "CREATE TABLE IF NOT EXISTS voter_registry (" +
    "   ID INT NOT NULL AUTO_INCREMENT," + 
    "   YearOfRevision varchar(5) NOT NULL," +
    "   DistrictSI varchar(100) DEFAULT NULL," +
    "   DistrictTA varchar(100) DEFAULT NULL," +
    "   PollingDivisionSI varchar(25) DEFAULT NULL," +
    "   PollingDivisionTA varchar(250) DEFAULT NULL," +
    "   PollingStationID varchar(5) DEFAULT NULL," +
    "   GND_SI varchar(100) DEFAULT NULL," +
    "   GND_TA varchar(100) DEFAULT NULL," +
    "   VS_SI varchar(100) DEFAULT NULL," +
    "   VS_TA varchar(100) DEFAULT NULL," +
    "   HouseNo varchar(100) DEFAULT NULL," +
    "   ElectorID varchar(5) NOT NULL," +
    "   NIC varchar(12) DEFAULT NULL," +
    "   Name_SI varchar(255) DEFAULT NULL," +
    "   Name_TA varchar(255) DEFAULT NULL," +
    "   Gender_SI varchar(12) DEFAULT NULL," +
    "   Gender_TA varchar(12) DEFAULT NULL," +
    "   PRIMARY KEY (ID)" +
    ")";

const string CREATE_VOTE_RECORDS_TABLE = "CREATE TABLE IF NOT EXISTS vote_records (" +
    "   ID INT NOT NULL," +
    "   PollingStationID varchar(10) NOT NULL," +
    "   ElectionID varchar(10) NOT NULL," +
    "   Status varchar(30) DEFAULT NULL," +
    "   Timestamp timestamp(2) NULL DEFAULT NULL," +
    "   PRIMARY KEY (ID)," +
    "   KEY PollingStationID_idx (PollingStationID)," +
    "   CONSTRAINT ID FOREIGN KEY (`ID`) REFERENCES voter_registry (ID)" +
    ") ";

const string INSERT_ELECTOR = "INSERT INTO voter_registry (YearOfRevision,DistrictSI,DistrictTA,PollingDivisionSI,PollingDivisionTA,PollingStationID,GND_SI,GND_TA,VS_SI,VS_TA,HouseNo,ElectorID,NIC,Name_SI,Name_TA,Gender_SI,Gender_TA) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

function __init() {
    // create tables
    _ = checkpanic dbClient->update(CREATE_VOTER_REGISTRY_TABLE);
    _ = checkpanic dbClient->update(CREATE_VOTE_RECORDS_TABLE);
}

function insertElectorDataToDB(Elector row) {
   // io:println("Inserting ", row.DistrictSI, "/", row.PollingDivisionSI, "/", row.PollingDivisionSI, "/", row.ElectorID, " with Name_SI='", row.Name_SI, "' Name_TA='", row.Name_TA, "'");
    var result = dbClient->update(INSERT_ELECTOR, row.YearOfRevission, row.DistrictSI, row.DistrictTA, row.PollingDivisionSI,
        row.PollingDivisionTA, row.PollingStationID, row.GND_SI, row.GND_TA, row.VS_SI, row.VS_TA, row.HouseNo,
        row.ElectorID, row.SLIN_NIC, row.Name_SI, row.Name_TA, row.Gender_SI, row.Gender_TA);
    if (result is error) {
        log:printError(string`Error in adding elector: ${row.DistrictSI}/${row.PollingDivisionSI}/${row.PollingStationID}/${row.ElectorID} to the database`, err = result);
    } else {
        log:printInfo(string`Added elector: ${row.DistrictSI}/${row.PollingDivisionSI}/${row.PollingStationID}/${row.ElectorID} to the database`);
    }
}
