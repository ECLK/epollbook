import ballerina/jsonutils;

function getInfo(string election) returns @tainted json[]|error {
    string SELECT_DISTRICTS = "SELECT DISTINCT DistrictSI, DistrictTA, PollingDivisionSI, PollingDivisionTA, PollingStationID FROM voter_registry";
    table<record{}> ret = check dbClient->select(SELECT_DISTRICTS, record{ string DistrictSI; string DistrictTA; string PollingDivisionSI; string PollingDivisionTA; string PollingStationID; });
    return <@untainted> <json[]> jsonutils:fromTable(ret);

}
