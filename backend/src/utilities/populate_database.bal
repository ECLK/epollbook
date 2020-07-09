import ballerina/io;
import ballerina/lang.'int;
import ballerina/log;
import ballerina/time;


public function main() returns @tainted error? {
    string srcFilepath = "src/utilities/resources/";


    string choice = io:readln("1: Add Elector Data\n2: Add Polling Station Data\n\nChoice: ");
    string srcFileName = io:readln("File Name: ");
    srcFilepath = io:sprintf("%s/%s", srcFilepath, srcFileName);
    if (choice == "1")
    {
        handleVoterRegistry(srcFilepath);
    }
    else if (choice == "2")
    {
        handlePollingStations(srcFilepath);
    }



}

function closeReadableCSVChannel(io:ReadableCSVChannel csvChannel)
{
    var result = csvChannel.close();
    if (result is error)
    {
        log:printError("Error occurred while closing the channel: ", err = result);
    }
}

function calculateDOBFromNIC(string nic, boolean isMale) returns time:Time|error
{
    int current_year = 20;
    int length_old_NIC = 10;
    int length_new_NIC = 12;
    string DOB_year;
    string DOB_month;
    string DOB_date;
    int|error next_three_digits;

    if (nic.length() == length_old_NIC || nic.length() == length_new_NIC)
    {
        if (nic.length() == length_old_NIC)
        {
            int|error first_two_digits = 'int:fromString(nic.substring(0, 2));
            if (first_two_digits is int)
            {
                if (first_two_digits > current_year)
                {
                    // adjusting DOB_year to 1900s
                    DOB_year = "19".concat(first_two_digits.toString());
                }
                else
                {
                    // adjusting DOB_year to 2000s
                    DOB_year = "20".concat(first_two_digits.toString());
                }

            }
            else
            {
                return first_two_digits;
            }
            next_three_digits = 'int:fromString(nic.substring(2, 5));
        }
        else
        {
            int|error first_four_digits = 'int:fromString(nic.substring(0, 4));
            if (first_four_digits is int)
            {
                DOB_year = first_four_digits.toString();
            }
            else
            {
                return error("Cannot convert new NIC to integer value.");
            }
            next_three_digits = 'int:fromString(nic.substring(4, 7));

        }

        if (next_three_digits is int)
        {

            // Adding 500 to the next three digits if the person is female
            if (!isMale)
            {
                next_three_digits -= 500;
            }

            if (next_three_digits <= 365 && next_three_digits > 0)
            {
                // Uses leap year to calculate the month and date for the day of the year because apparently that's how
                // government do it.
                string leapYear = "2020";
                string dateString = io:sprintf("%s-%s", leapYear, next_three_digits);
                time:Time|error tempTime = time:parse(dateString, "yyyy-D");
                if (tempTime is time:Time)
                {
                    DOB_month = time:getMonth(tempTime).toString();
                    DOB_date = time:getDay(tempTime).toString();
                    dateString = io:sprintf("%s-%s-%s", DOB_year, DOB_month, DOB_date);
                    time:Time|error DOB = time:parse(dateString, "yyyy-M-d");
                    return DOB;

                }
                else
                {
                    return tempTime;
                }
            }
            else
            {
                return error("Day of the year must be between 0 and 365.");
            }

        }
        else
        {
            return next_three_digits;
        }
    }
    else
    {
        return error("Invalid NIC format.");
    }

}

function handleVoterRegistry(string srcFileName)
{

    io:ReadableCSVChannel|error rCsvChannel = io:openReadableCsvFile(srcFileName);
    if (rCsvChannel is io:ReadableCSVChannel)
    {
        var tblResult = rCsvChannel.getTable(Elector);
        if (tblResult is table<record {}>)
        {
            table<Elector> electorTable = <table<Elector>>tblResult;
            foreach var rec in electorTable {

                boolean isMale = rec.Gender_SI == "පුරුෂ";

                time:Time|error DOB = calculateDOBFromNIC(rec.SLIN_NIC, isMale);
                if (DOB is time:Time)
                {
                    rec.DOB = io:sprintf("%s-%s-%s", time:getYear(DOB), time:getMonth(DOB), time:getDay(DOB));
                    insertElectorDataToDB(rec);

                }
                else
                {
                    // inserting a default date in case of an error in DOB calculation
                    rec.DOB = "0000-00-00";
                    insertElectorDataToDB(rec);
                    log:printError(rec.SLIN_NIC, DOB);

                }


            }
        } else
        {
            log:printError("An error occurred while creating table: ", err = tblResult);
        }
        closeReadableCSVChannel(rCsvChannel);
    }
    else
    {
        log:printError("An error occurred while trying to read the CSV file", err = rCsvChannel);
    }



}

function handlePollingStations(string srcFilePath)
{
    io:ReadableCSVChannel|error rCsvChannel = io:openReadableCsvFile(srcFilePath);
    if (rCsvChannel is io:ReadableCSVChannel)
    {
        var tblResult = rCsvChannel.getTable(PollingStation);
        if (tblResult is table<record {}>)
        {
            table<PollingStation> pollingStationTable = <table<PollingStation>>tblResult;
            foreach var rec in pollingStationTable {

                var t = insertPollingStationToDB(rec);

            }
        } else
        {
            log:printError("An error occurred while creating table: ", err = tblResult);
        }
        closeReadableCSVChannel(rCsvChannel);
    }
    else
    {
        log:printError("An error occurred while trying to read the CSV file", err = rCsvChannel);
    }


}
