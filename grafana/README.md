### Grafana dashboards for the ECLK Epollbook. 

Users can observe real-time updates on voter turnout, the total number of 
registered voters (static), voter distribution over time, and age and gender-based voter statistics. Currently, there 
are 03 dashboards to provide analytics at the polling station, polling division level, and electoral district level.

#### Dependencies
* Grafana: 	v7.0.5+
* MySQL :	v8.0.19 

#### Setup : Dev Env
1. Clone the ECLK/epollbook repository if you haven’t done it already.
2. Make sure the database is already configured (refer to section 02).
3. Make sure grafana is installed and running.
4. Open the browser and go to the grafana port on the localhost (the default HTTP port is 3000). 
```http://localhost:3000/```

5. On the login page, enter “admin” for both username and password. Change the password if prompted.
6. Click on the gear icon on the left panel, select **Data Sources**, and then click **Add data source.**
7. Fill in the connection details and select **save and test.**
8. Click on the + icon on the left panel, select **Import**, and then click **Upload .json file.**
9. Select **electoral_district_dashboard.json** file from the grafana directory in the repository and select **MySQL** 
as the data source. If you get an error about templating variables, **make sure you have populated the database initially.**
10. Repeat step 09 for the other two dashboard files as well.  



