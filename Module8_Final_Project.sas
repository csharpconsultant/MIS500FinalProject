/* Author: Anthony Vuolo
   MIS500 - CSU Global
   Date: 6/07/2020
   Module 8 - Portfolio Project - Analyzing e-commerce data using SAS
*/


*load the 2019 order data;
FILENAME REFFILE '/folders/myfolders/EtsySoldOrders2019.csv';

PROC IMPORT DATAFILE=REFFILE DBMS=CSV OUT=Orders2019;
	GETNAMES=YES;
RUN;


*sort by order id. If we don't sort, we can't merge. ;
PROC SORT Data=Orders2019;
	BY Order_ID;
RUN;

*load the 2020 order data;
FILENAME REFFILE '/folders/myfolders/EtsySoldOrders2020.csv';

PROC IMPORT DATAFILE=REFFILE DBMS=CSV OUT=Orders2020;
	GETNAMES=YES;
RUN;

*sort by order id. If we don't sort, we can't merge.;
PROC SORT Data=Orders2020;
	BY Order_ID;
RUN;

*merge the 2019 and 2020 data;
DATA OrdersCombined;
	MERGE Orders2019 Orders2020;
	BY Order_ID;

PROC PRINT DATA=OrdersCombined;
RUN;


*lets anylze the order value variable and see if the distribution is normal. Also check for outliers;
proc univariate data=OrdersCombined normal; 
		VAR Order_Value;
		qqplot Order_Value /Normal(mu=est sigma=est color=red l=1);
		run;

*remove outliers below the 1% quantile and 99% quantile - winsorization;
%pctlcap(input=OrdersCombined, output=OrdersNoOutliers, class=none, vars = Order_Value, pctl=1 99);

*let us anylyze the order value variable again and see what the distribution looks like;
proc univariate data=OrdersNoOutliers normal; 
		VAR Order_Value;
		qqplot Order_Value /Normal(mu=est sigma=est color=red l=1);
		HISTOGRAM ORDER_VALUE/NORMAL;
		run;

* Add a new field to the data set called StateCategory.  if the ship to state is CA then it will be C or A for all others;
DATA OrdersByState;
	SET OrdersNoOutliers;
	
	StateCategory = "";
	If Ship_State="CA" THEN StateCategory = "C"; ELSE StateCategory = "A";

RUN;

* Run a 2 sample test based on StateCategory and Order_Value; 
PROC TTEST;
CLASS StateCategory;
VAR Order_Value;
Title "Two-Sample T-Test";
RUN; 






