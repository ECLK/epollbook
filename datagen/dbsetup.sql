CREATE DATABASE epollbook;
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
    (1, 'A', 'COLOMBO-NORTH', '', ''),
    (1, 'B', 'COLOMBO-CENTRAL', '', ''),
    (1, 'C', 'BORELLA', '', ''),
    (1, 'D', 'COLOMBO-EAST', '', ''),
    (1, 'E', 'COLOMBO-WEST', 'බටහිර කොළඹ', 'கொழும்பு மேற்க'),
    (1, 'F', 'DEHIWALA', '', ''),
    (1, 'G', 'RATMALANA', '', ''),
    (1, 'H', 'KOLONNAWA', '', ''),
    (1, 'I', 'KOTTE', '', ''),
    (1, 'J', 'KADUWELA', 'කඩුවෙල', 'கடுவெல'),
    (1, 'K', 'AVISSAWELLA', '', ''),
    (1, 'L', 'HOMAGAMA', '', ''),
    (1, 'M', 'MAHARAGAMA', '', ''),
    (1, 'N', 'KESBEWA', '', ''),
    (1, 'O', 'MORATUWA', '', '');

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
    ElectorID INT NOT NULL,
    Age int DEFAULT -1,
    VotingStatus enum('NOT-VOTED','QUEUED','VOTED') DEFAULT 'NOT-VOTED',
    QueuedTime timestamp DEFAULT NULL,
    VotedTime timestamp DEFAULT NULL,
    PRIMARY KEY (ElectorID),
    CONSTRAINT ID FOREIGN KEY (ElectorID) REFERENCES ElectorRegistry (ID)
);
