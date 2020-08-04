DROP DATABASE IF EXISTS epollbook;
CREATE DATABASE epollbook CHARACTER SET utf8 COLLATE utf8_general_ci;

USE epollbook;

CREATE TABLE ElectoralDistricts (
    ID INT NOT NULL,
    Name_EN varchar(100) DEFAULT NULL,
    Name_SI varchar(100) DEFAULT NULL,
    Name_TA varchar(100) DEFAULT NULL,
    PRIMARY KEY (ID)
);

INSERT INTO ElectoralDistricts VALUES 
    (1, 'Colombo', 'කොළඹ', 'கொழும்ப');

CREATE TABLE PollingDivisions (
    DistrictID INT NOT NULL,
    ID VARCHAR(1),
    Name_EN varchar(100) DEFAULT NULL,
    Name_SI varchar(100) DEFAULT NULL,
    Name_TA varchar(100) DEFAULT NULL,
    CONSTRAINT PDKey PRIMARY KEY (DistrictID,ID),
    FOREIGN KEY (DistrictID) REFERENCES ElectoralDistricts(ID)
);

INSERT INTO PollingDivisions VALUES
    (1, 'E', 'COLOMBO-WEST', 'බටහිර කොළඹ', 'கொழும்பு மேற்க'),
    (1, 'J', 'KADUWELA', 'කඩුවෙල', 'கடுவெல');

CREATE TABLE ElectorRegistry (
    ID INT NOT NULL AUTO_INCREMENT,
    YearOfRevision varchar(5) NOT NULL,
    DistrictID INT NOT NULL,  
    PollingDivisionID varchar(1) NOT NULL,    
    PollingStationID INT NOT NULL,    
    GNDivision_SI varchar(100) DEFAULT NULL,    
    GNDivision_TA varchar(100) DEFAULT NULL,    
    Street_SI varchar(100) DEFAULT NULL,    
    Street_TA varchar(100) DEFAULT NULL,    
    HouseNo varchar(100) DEFAULT NULL,    
    ElectorID int NOT NULL,    
    NationalID varchar(12) DEFAULT NULL,    
    Name_SI varchar(255) DEFAULT NULL,    
    Name_TA varchar(255) DEFAULT NULL,    
    Sex enum('MALE','FEMALE','UNKNOWN') DEFAULT 'UNKNOWN',   
    PRIMARY KEY (ID),
    FOREIGN KEY (DistrictID) REFERENCES ElectoralDistricts (ID) 
);

CREATE TABLE VoteRecords (
    Election varchar(10) NOT NULL,
    DistrictID INT NOT NULL,  
    PollingDivisionID varchar(1) NOT NULL,    
    PollingStationID INT NOT NULL,    
    ID INT NOT NULL,
    Age int DEFAULT -1,
    VotingStatus enum('NOT-VOTED','QUEUED','VOTED') DEFAULT 'NOT-VOTED',
    TimeStamp timestamp DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (DistrictID, PollingDivisionID, PollingStationID, ID)
    -- PRIMARY KEY (ID),
    -- CONSTRAINT ID FOREIGN KEY (ID) REFERENCES ElectorRegistry (ID)
);
