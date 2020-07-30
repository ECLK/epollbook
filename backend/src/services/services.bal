import ballerina/http;
import ballerina/io;

listener http:Listener hl = new(9090);

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
        // TODO: making a copy to avoid error ("error: Couldn't complete outbound response")
        // See: https://github.com/ballerina-platform/ballerina-lang/issues/24584
        io:println(string `Returning election data for ${election} for district=${district}, division=${division}, station=${station} with ${sel.length().toString()} items`);
        //json[] res = sel.map(x => x);
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
        path: "/queued/{election}/{stationID}/{voterID}/{timestamp}",
        methods: ["POST"]
    }
    resource function queued(http:Caller hc, http:Request hr, string election, string stationID, string voterID, string timestamp) returns error? {
        string status = "QUEUED";
        io:println(string `Recording ${status} for election ${election} by voter ${voterID} at ${timestamp} in polling station ${stationID}`);
        check setVoterStatus(election, stationID, voterID, timestamp, status);
        check hc->accepted(status);
    }

    # Record the vote of an elector in an election at a certain polling station at a given time.
    # + return - error if something goes wrong
    @http:ResourceConfig {
        path: "/voted/{election}/{stationID}/{voterID}/{timestamp}",
        methods: ["POST"]
    }
    resource function voted(http:Caller hc, http:Request hr, string election, string stationID, string voterID, string timestamp) returns error? {
        string status = "VOTED";
        io:println(string `Recording ${status} for election ${election} by voter ${voterID} at ${timestamp} in polling station ${stationID}`);
        check setVoterStatus(election, stationID, voterID, timestamp, status);
        check hc->accepted(status);
    }
}
