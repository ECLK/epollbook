import ballerina/http;
import ballerina/io;

listener http:Listener hl = new(9090);

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
        io:println(string `Returning election data for ${election} for district=${district}, division=${division}, station=${station} with ${sel.length().toString()} items`);
        check hc->ok(<@untainted> sel);
    }

    @http:ResourceConfig {
        path: "/info/{election}",
        methods: ["GET"]
    }
    resource function info(http:Caller hc, http:Request hr, string election) returns @tainted error? {
        json[] districts = check getInfo(election);
        io:println(string `Returning election info for ${election} with ${districts.length().toString()} items`);
        check hc->ok(<@untainted> districts); 
    }

    # Record the presence of an elector in the queue at a certain polling station at a given time.
    # + return - error if something goes wrong
    @http:ResourceConfig {
        path: "/queued/{election}/{district}/{division}/{station}/{voterID}/{timestamp}",
        methods: ["POST"]
    }
    resource function queued(http:Caller hc, http:Request hr, string election, string district, string division, string station, string voterID, string timestamp) returns error? {
        io:println(string `Recording ${STATUS_QUEUED} for election ${election} by voter ${voterID} at ${timestamp} in district ${district}, division ${division}, polling station ${station}`);
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
        io:println(string `Returning queue of voters for ${election} for district=${district}, division=${division}, station=${station}: ${voters.length().toString()} voters`);
        check hc->ok(<@untainted> voters);
    }

    # Record the vote of an elector in an election at a certain polling station at a given time.
    # + return - error if something goes wrong
    @http:ResourceConfig {
        path: "/voted/{election}/{district}/{division}/{station}/{voterID}/{timestamp}",
        methods: ["POST"]
    }
    resource function voted(http:Caller hc, http:Request hr, string election, string district, string division, string station, string voterID, string timestamp) returns error? {
        io:println(string `Recording ${STATUS_VOTED} for election ${election} by voter ${voterID} at ${timestamp} in district ${district}, division ${division}, polling station ${station}`);
        check setVoterStatus(election, district, division, station, voterID, timestamp, STATUS_VOTED);
        check hc->accepted(STATUS_VOTED);
    }
}
