import ballerina/jsonutils;

function getInfo(string election) returns @tainted json[]|error {
    string INFOQUERY = 
        "SELECT DISTINCT " + 
        "    ElectoralDistricts.Name_EN AS DistrictName, " + 
        "    ElectoralDistricts.ID AS DistrictID, " + 
        "    PollingDivisions.Name_EN AS PollingDivisionName, " + 
        "    PollingDivisions.ID AS PollingDivisionID, " + 
        "    ElectorRegistry.PollingStationID " + 
        "FROM ElectorRegistry " + 
        "INNER JOIN PollingDivisions ON ElectorRegistry.PollingDivisionID=PollingDivisions.ID " + 
        "INNER JOIN ElectoralDistricts ON ElectorRegistry.DistrictID=ElectoralDistricts.ID";
    table<record{}> ret = check dbClient->select(INFOQUERY, InfoResponse);
    return <@untainted> <json[]> jsonutils:fromTable(ret);
}
