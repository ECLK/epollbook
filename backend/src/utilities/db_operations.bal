//import ballerina/config;
import ballerinax/java.jdbc;
import ballerina/log;
import ballerina/io;

# DB info for testing
string dbUser = "root";
string dbPassword = "root";
string dbName = "epoll_book";
string dbURL = "jdbc:mysql://localhost:3306/epoll_book";

//jdbc:Client dbClient = new ({
//    url: config:getAsString("eclk.epb.db.url"),
//    username: config:getAsString("eclk.epb.db.username"),
//    password: config:getAsString("eclk.epb.db.password"),
//    dbOptions: {
//        useSSL: config:getAsString("eclk.epb.db.useSsl")
//    }
//});

jdbc:Client dbClient = new ({
    url: dbURL,
    username: dbUser,
    password: dbPassword,
    dbOptions: {useSSL: false}

});

# Queries
const string CREATE_VOTER_REGISTRY_TABLE = "CREATE TABLE IF NOT EXISTS voter_registry (" +
    "   YearOfRevission varchar(5) NOT NULL," +
    "   DistrictSI varchar(12) DEFAULT NULL," +
    "   DistrictTA varchar(12) DEFAULT NULL," +
    "   PollingDivisionSI varchar(12) DEFAULT NULL," +
    "   PollingDivisionTA varchar(12) DEFAULT NULL," +
    "   PollingStationID varchar(5) DEFAULT NULL," +
    "   GND_SI varchar(25) DEFAULT NULL," +
    "   GND_TA varchar(12) DEFAULT NULL," +
    "   VS_SI varchar(25) DEFAULT NULL," +
    "   VS_TA varchar(45) DEFAULT NULL," +
    "   HouseNo varchar(45) DEFAULT NULL," +
    "   ElectorID varchar(5) NOT NULL," +
    "   NIC varchar(12) DEFAULT NULL," +
    "   Name_SI varchar(255) DEFAULT NULL," +
    "   Name_TA varchar(255) DEFAULT NULL," +
    "   Gender_SI varchar(12) DEFAULT NULL," +
    "   Gender_TA varchar(5) DEFAULT NULL," +
    "   DOB date DEFAULT NULL," +
    "   PRIMARY KEY (ElectorID)," +
    "   KEY Polling_Station_ID_index (PollingStationID)," +
    "   KEY SLIN_NIC_index (NIC)," +
    "  CONSTRAINT PollingStationID FOREIGN KEY (PollingStationID) REFERENCES polling_station (PollingStationID)" +
    ")";

const string INSERT_ELECTOR = "INSERT INTO voter_registry VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

function __init()
{
    // create tables
    _ = checkpanic dbClient->update(CREATE_VOTER_REGISTRY_TABLE);

}

function insertElectorDataToDB(Elector row)
{

    var result = dbClient->update(INSERT_ELECTOR, row.YearOfRevission, row.DistrictSI, row.DistrictTA, row.PollingDivisionSI,
        row.PollingDivisionTA, row.PollingStationID, row.GND_SI, row.GND_TA, row.VS_SI, row.VS_TA, row.HouseNo,
        row.ElectorID, row.SLIN_NIC, row.Name_SI, row.Name_TA, row.Gender_SI, row.Gender_TA, <string>row?.DOB);
    if(result is jdbc:UpdateResult)
    {
        log:printDebug(io:sprintf("Added elector: %s",row.ElectorID));
    }
    else
    {
        log:printError(io:sprintf("Error in adding elector: %s",row.ElectorID),err = result);

    }

}
