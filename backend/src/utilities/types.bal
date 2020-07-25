# Format of the voter registry CSV files
type Elector record{
    string YearOfRevission;
    string DistrictSI;
    string DistrictTA;
    string PollingDivisionSI;
    string PollingDivisionTA;
    string PollingStationID;
    string GND_SI;
    string GND_TA;
    string VS_SI;
    string VS_TA;
    string HouseNo;
    string ElectorID;
    string SLIN_NIC;
    string Name_SI;
    string Name_TA;
    string Gender_SI;
    string Gender_TA;
    string DOB?;
};

//# Format of the polling station data CSV files
//type PollingStation record{
//    string PollingStationID;
//    string PollingDivisionID;
//    string Name;
//    string Location;
//};
//
//# Format of the polling division data CSV files
//type PollingDivision record{
//    string PollingDivisionID;
//    string ElectoralDistrictID;
//    string Name;
//};
//
//# Format of the electoral district data CSV files
//type ElectoralDistrict record{
//    string ElectoralDistrictID;
//    string ProvincialID;
//    string Name;
//};
//
//# Format of the province data CSV files
//type Province record{
//    string ProvincialID;
//    string Name;
//};
