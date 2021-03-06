type InfoResponse record  {
    string DistrictName;
    int DistrictID;
    string PollingDivisionName;
    string PollingDivisionID;
    int PollingStationID;
};

type ElectorResponse record {
    string ElectorID;
    int ID;
    string NationalID;
    string GNDivision_SI;
    string Street_SI;
    string HouseNo;
    string Name_SI;
    string Name_TA;
    string Sex;
};
