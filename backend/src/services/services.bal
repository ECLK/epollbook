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
    resource function electors(http:Caller hc, http:Request hr, string election, string district, string division, string station) returns error? {
        io:println(string `Returing election data for ${election} for district=${district}, division=${division}, station=${station}`);
        json[] sel = getElectors(election, district, division, station);
        // TODO: making a copy to avoid error ("error: Couldn't complete outbound response")
        // See: https://github.com/ballerina-platform/ballerina-lang/issues/24584
        json[] res = sel.map(x => x);
        check hc->ok(res);
    }

    # Record the presence of an elector in the queue at a certain polling station at a given time.
    # + return - error if something goes wrong
    @http:ResourceConfig {
        path: "/queued/{election}/{district}/{division}/{station}/{elector}/{timestamp}",
        methods: ["POST"]
    }
    resource function queued(http:Caller hc, http:Request hr, string election, string district, string division, 
                           string station, string elector, string timestamp) returns error? {
        io:println(string `Recording queuing for ${election} for district=${district}, division=${division}, station=${station} by ${elector} at ${timestamp}`);
        check hc->accepted("Queued");
    }

    # Record the vote of an elector in an election at a certain polling station at a given time.
    # + return - error if something goes wrong
    @http:ResourceConfig {
        path: "/voted/{election}/{district}/{division}/{station}/{elector}/{timestamp}",
        methods: ["POST"]
    }
    resource function voted(http:Caller hc, http:Request hr, string election, string district, string division, 
                           string station, string elector, string timestamp) returns error? {
        io:println(string `Recording vote for ${election} for district=${district}, division=${division}, station=${station} by ${elector} at ${timestamp}`);
        check hc->accepted("Vote recorded");
    }
}