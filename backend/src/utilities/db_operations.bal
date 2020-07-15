import ballerina/config;
import ballerinax/java.jdbc;
import ballerina/log;
import ballerina/io;

// default values are for testing only
jdbc:Client dbClient = new ({
    url: config:getAsString("eclk.epb.db.url", "jdbc:mysql://localhost:3306/epoll_book"),
    username: config:getAsString("eclk.epb.db.username", "root"),
    password: config:getAsString("eclk.epb.db.password", "root"),
    dbOptions: {
        useSSL: config:getAsString("eclk.epb.db.useSsl", "false")
    }
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

const string CREATE_VOTE_RECORDS_TABLE = "CREATE TABLE IF NOT EXISTS vote_records (" +
                                            "   ElectorID varchar(10) NOT NULL," +
                                            "   PollingStationID varchar(10) NOT NULL," +
                                            "   Status varchar(30) DEFAULT NULL," +
                                            "   Timestamp timestamp(2) NULL DEFAULT NULL," +
                                            "   PRIMARY KEY (ElectorID)," +
                                            "   KEY PollingStationID_idx (PollingStationID)," +
                                            "   CONSTRAINT ElectorID FOREIGN KEY (`ElectorID`) REFERENCES voter_registry (ElectorID)," +
                                            "   FOREIGN KEY (PollingStationID) REFERENCES polling_station (PollingStationID)" +
                                            ") ";

const string CREATE_POLLING_STATION_TABLE = "CREATE TABLE IF NOT EXISTS polling_station (" +
                                              "     PollingStationID varchar(10) NOT NULL," +
                                              "     PollingDivisionID varchar(10) DEFAULT NULL," +
                                              "     Name varchar(100) DEFAULT NULL," +
                                              "     Location varchar(45) DEFAULT NULL," +
                                              "     PRIMARY KEY (`PollingStationID`)," +
                                              "     KEY `PollingDivisionID_idx` (`PollingDivisionID`)," +
                                              "     CONSTRAINT PollingDivisionID FOREIGN KEY (PollingDivisionID) REFERENCES polling_division (PollingDivisionID)" +
                                            ") ";

const string CREATE_POLLING_DIVISION_TABLE = "CREATE TABLE IF NOT EXISTS `polling_division` (" +
                                               "    `PollingDivisionID` varchar(10) NOT NULL," +
                                               "    `ElectoralDistrictID` varchar(10) DEFAULT NULL," +
                                               "    `Name` varchar(100) DEFAULT NULL," +
                                               "    PRIMARY KEY (`PollingDivisionID`)," +
                                               "    KEY `ElectoralDistrictID_idx` (`ElectoralDistrictID`)," +
                                               "    CONSTRAINT `ElectoralDistrictID` FOREIGN KEY (`ElectoralDistrictID`) REFERENCES `electoral_district` (`ElectoralDistrictID`)" +
                                            " )";

const string CREATE_ELECTRORAL_DISTRICT_TABLE = "CREATE TABLE IF NOT EXISTS `electoral_district` ( " +
                                                "   `ElectoralDistrictID` varchar(10) NOT NULL," +
                                                "   `ProvincialID` varchar(10) DEFAULT NULL," +
                                                "   `Name` varchar(100) DEFAULT NULL," +
                                                "   PRIMARY KEY (`ElectoralDistrictID`)," +
                                                "   KEY `ProvincialID_idx` (`ProvincialID`)," +
                                                "   CONSTRAINT `ProvincialID` FOREIGN KEY (`ProvincialID`) REFERENCES `province` (`ProvincialID`)" +
                                                ")";

const string CREATE_PROVINCE_TABLE = "CREATE TABLE IF NOT EXISTS `province` ( " +
                                     "      `ProvincialID` varchar(10) NOT NULL," +
                                     "      `Name` varchar(100) DEFAULT NULL," +
                                     "      PRIMARY KEY (`ProvincialID`)" +
                                     ") ";

const string INSERT_ELECTOR = "INSERT INTO voter_registry VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
const string INSERT_POLLING_STATION = "INSERT INTO polling_station VALUES (?, ?, ?, ?)";
const string INSERT_POLLING_DIVISION = "INSERT INTO polling_division VALUES (?, ?, ?)";
const string INSERT_ELECTORAL_DISTRICT = "INSERT INTO electoral_district VALUES (?, ?, ?)";
const string INSERT_PROVINCE = "INSERT INTO province VALUES (?, ?)";

function __init()
{
    // create tables
    _ = checkpanic dbClient->update(CREATE_PROVINCE_TABLE);
    _ = checkpanic dbClient->update(CREATE_ELECTRORAL_DISTRICT_TABLE);
    _ = checkpanic dbClient->update(CREATE_POLLING_DIVISION_TABLE);
    _ = checkpanic dbClient->update(CREATE_POLLING_STATION_TABLE);
    _ = checkpanic dbClient->update(CREATE_VOTER_REGISTRY_TABLE);
    _ = checkpanic dbClient->update(CREATE_VOTE_RECORDS_TABLE);

}

function insertElectorDataToDB(Elector row)
{

    var result = dbClient->update(INSERT_ELECTOR, row.YearOfRevission, row.DistrictSI, row.DistrictTA, row.PollingDivisionSI,
        row.PollingDivisionTA, row.PollingStationID, row.GND_SI, row.GND_TA, row.VS_SI, row.VS_TA, row.HouseNo,
        row.ElectorID, row.SLIN_NIC, row.Name_SI, row.Name_TA, row.Gender_SI, row.Gender_TA, <string>row?.DOB);
    if(result is jdbc:UpdateResult)
    {
        log:printDebug(io:sprintf("Added elector ID: %s to the database.",row.ElectorID));
    }
    else
    {
        log:printError(io:sprintf("Error in adding elector ID: %s to the database.",row.ElectorID),err = result);

    }

}


function insertPollingStationToDB(PollingStation row)
{
    var result = dbClient->update(INSERT_POLLING_STATION,row.PollingStationID,row.PollingDivisionID,row.Name,row.Location);

    if (result is jdbc:UpdateResult)
    {
        log:printDebug(io:sprintf("Added polling station ID: %s to the database.",row.PollingStationID));
    }
    else
    {
        log:printError(io:sprintf("Error in adding polling station ID: %s to the database.",row.PollingStationID),err = result);
    }
}

function insertPollingDivisionToDB(PollingDivision row)
{
    var result = dbClient->update(INSERT_POLLING_DIVISION,row.PollingDivisionID,row.ElectoralDistrictID,row.Name);

        if (result is jdbc:UpdateResult)
        {
            log:printDebug(io:sprintf("Added polling division ID: %s to the database.",row.PollingDivisionID));
        }
        else
        {
            log:printError(io:sprintf("Error in adding polling division ID: %s to the database.",row.PollingDivisionID),err = result);
        }
}

function insertElectoralDistrictToDB(ElectoralDistrict row)
{
    var result = dbClient->update(INSERT_ELECTORAL_DISTRICT,row.ElectoralDistrictID,row.ProvincialID,row.Name);

        if (result is jdbc:UpdateResult)
        {
            log:printDebug(io:sprintf("Added electoral district ID: %s to the database.",row.ElectoralDistrictID));
        }
        else
        {
            log:printError(io:sprintf("Error in adding electoral district ID: %s to the database.",row.ElectoralDistrictID),err = result);
        }
}

function insertProvinceToDB(Province row)
{
    var result = dbClient->update(INSERT_PROVINCE,row.ProvincialID,row.Name);

        if (result is jdbc:UpdateResult)
        {
            log:printDebug(io:sprintf("Added province ID: %s to the database.",row.ProvincialID));
        }
        else
        {
            log:printError(io:sprintf("Error in adding province ID: %s to the database.",row.ProvincialID),err = result);
        }
}
