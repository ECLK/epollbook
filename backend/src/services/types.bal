# Information about an elector that we have in the system
type Elector record {
    string revisionYear;
    string district;
    string division;
    string station;
    string name;
    int id;
    string slin;
    string sex;
};

type Election record {
    string id;
    string revisionYear; // revision year for elector list used for this election
};