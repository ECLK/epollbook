Elector[] electors = [];

# Do any database initialization here - runs at program startup time
function init() {
    loadElectors();
}

function loadElectors() {
    // replace with code to load from DB
    electors = [
        {
            revisionYear: "2019",
            district: "Colombo",
            division: "Kotte",
            station: "7",
            name: "Shah Maara Name Ne",
            id: 13,
            slin: "708021630V",
            sex: "F"
        },              
        {
            revisionYear: "2019",
            district: "Colombo",
            division: "Kotte",
            station: "8",
            name: "Hata Hatha",
            id: 16,
            slin: "675151356X",
            sex: "F"
        },              
        {
            revisionYear: "2019",
            district: "Colombo",
            division: "Kotte",
            station: "8",
            name: "Seventy Two Person",
            id: 98,
            slin: "72655500V",
            sex: "F"
        },      
        {
            revisionYear: "2019",
            district: "Colombo",
            division: "Kotte",
            station: "7",
            name: "Aiyoh Sirisena",
            id: 23,
            slin: "402560050V",
            sex: "M"
        }
    ];
}

# Return the list of electors for a particular election, district, divison and polling station.
# + election - ID of the election (ignored for now)
# + district - ID of the electoral district
# + division - ID of the polling division
# + station - ID of the polling station
# + return - list of matching electors
function getElectors(string election, string district, string division, string station) returns json[] {
    json[] selected = 
        from var elector in electors
        where elector.district == district && elector.division == division && elector.station == station
        select { 
           name: elector.name, 
           id: elector.id, 
           slin: elector.slin, 
           sex: elector.sex 
        };
    return selected;
}