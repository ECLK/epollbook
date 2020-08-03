import ballerina/http;
import ballerina/log;

listener http:Listener hl = new(9090);

const STATUS_NOT_VOTED = "NOT-VOTED";
const STATUS_QUEUED = "QUEUED";
const STATUS_VOTED = "VOTED";

@http:ServiceConfig {
    basePath: "/"
}
service PollBook on hl {
    @http:ResourceConfig {
        path: "/electors/{election}/{district}/{division}/{station}",
        methods: ["GET"]
    }
    resource function electors(http:Caller hc, http:Request hr, string election, string district, string division, string station) returns @tainted error? {
        json[] sel = check getElectors(election, district, division, station);
        log:printInfo(string `Returning election data for ${election} for district=${district}, division=${division}, station=${station} with ${sel.length().toString()} items`);
        check hc->ok(<@untainted> sel);
    }

    @http:ResourceConfig {
        path: "/info/{election}",
        methods: ["GET"]
    }
    resource function info(http:Caller hc, http:Request hr, string election) returns @tainted error? {
        json[] districts = check getInfo(election);
        log:printInfo(string `Returning election info for ${election} with ${districts.length().toString()} items`);
        check hc->ok(<@untainted> districts); 
    }

    # Record the presence of an elector in the queue at a certain polling station at a given time.
    # + return - error if something goes wrong
    @http:ResourceConfig {
        path: "/queued/{election}/{district}/{division}/{station}/{voterID}/{timestamp}",
        methods: ["POST"]
    }
    resource function queued(http:Caller hc, http:Request hr, string election, string district, string division, string station, string voterID, string timestamp) returns error? {
        log:printInfo(string `Recording ${STATUS_QUEUED} for election ${election} by voter ${voterID} at ${timestamp} in district ${district}, division ${division}, polling station ${station}`);
        check setVoterStatus(election, district, division, station, voterID, timestamp, STATUS_QUEUED);
        check hc->accepted(STATUS_QUEUED);
    }

    # Return list of electors currently in the queue
    # + return - error if something goes wrong
    @http:ResourceConfig {
        path: "/show-queue/{election}/{district}/{division}/{station}",
        methods: ["GET"]
    }
    resource function showQueue(http:Caller hc, http:Request hr, string election, string district, string division, string station) returns @tainted error? {
        json[] voters = check getQueue(election, district, division, station);
        log:printInfo(string `Returning queue of voters for ${election} for district=${district}, division=${division}, station=${station}: ${voters.length().toString()} voters`);
        check hc->ok(<@untainted> voters);
    }

    # Record the vote of an elector in an election at a certain polling station at a given time.
    # + return - error if something goes wrong
    @http:ResourceConfig {
        path: "/voted/{election}/{district}/{division}/{station}/{voterID}/{timestamp}",
        methods: ["POST"]
    }
    resource function voted(http:Caller hc, http:Request hr, string election, string district, string division, string station, string voterID, string timestamp) returns error? {
        log:printInfo(string `Recording ${STATUS_VOTED} for election ${election} by voter ${voterID} at ${timestamp} in district ${district}, division ${division}, polling station ${station}`);
        check setVoterStatus(election, district, division, station, voterID, timestamp, STATUS_VOTED);
        check hc->accepted(STATUS_VOTED);
    }

    # Reset the voting status of an elector in an election at a certain polling station at a given time.
    # This is called if a voter was mistakenly selected as voting or queuing
    # + return - error if something goes wrong
    @http:ResourceConfig {
        path: "/reset-elector/{election}/{district}/{division}/{station}/{voterID}/{timestamp}",
        methods: ["POST"]
    }
    resource function resetElector(http:Caller hc, http:Request hr, string election, string district, string division, string station, string voterID, string timestamp) returns error? {
        log:printInfo(string `Recording ${STATUS_NOT_VOTED} for election ${election} by voter ${voterID} at ${timestamp} in district ${district}, division ${division}, polling station ${station}`);
        check setVoterStatus(election, district, division, station, voterID, timestamp, STATUS_NOT_VOTED);
        check hc->accepted(STATUS_NOT_VOTED);
    }
}
