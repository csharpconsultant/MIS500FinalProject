/*************************************************
Percentile Capping / Winsorize macro
*input = dataset to winsorize;
*output = dataset to output with winsorized values;
*class = grouping variables to winsorize;
* Specify "none" in class for no grouping variable;
*vars = Specify variable(s) in which you want values to be capped;
*pctl = define lower and upper percentile - acceptable range;
**************************************************/

%macro pctlcap(input=, output=, class=none, vars=, pctl=1 99);

%if &output = %then %let output = &input;
 
%let varL=;
%let varH=;
%let xn=1;

%do %until (%scan(&vars,&xn)= );
%let token = %scan(&vars,&xn);
%let varL = &varL &token.L;
%let varH = &varH &token.H;
%let xn=%EVAL(&xn + 1);
%end;

%let xn=%eval(&xn-1);

data xtemp;
set &input;
run;

%if &class = none %then %do;

data xtemp;
set xtemp;
xclass = 1;
run;

%let class = xclass;
%end;

proc sort data = xtemp;
by &class;
run;

proc univariate data = xtemp noprint;
by &class;
var &vars;
output out = xtemp_pctl PCTLPTS = &pctl PCTLPRE = &vars PCTLNAME = L H;
run;

data &output;
merge xtemp xtemp_pctl;
by &class;
array trimvars{&xn} &vars;
array trimvarl{&xn} &varL;
array trimvarh{&xn} &varH;

do xi = 1 to dim(trimvars);
if not missing(trimvars{xi}) then do;
if (trimvars{xi} < trimvarl{xi}) then trimvars{xi} = trimvarl{xi};
if (trimvars{xi} > trimvarh{xi}) then trimvars{xi} = trimvarh{xi};
end;
end;
drop &varL &varH xclass xi;
run;

%mend pctlcap;

%pctlcap(input=test, output=result, class=none, vars = X1 X2 X7, pctl=1 99);