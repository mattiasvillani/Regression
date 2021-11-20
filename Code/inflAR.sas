*/ Glöm inte att läsa in/importera datamaterialet InflationReporanta.csv (finns under Föreläsning F1 på webbsidan) i SAS först. 
*/ Det importerade datamaterialet ska heta inflrepo i SAS och ligga i WORK mappen
*/ (som är default) när man importerar data.

data work.inflrepo;
set work.inflrepo;
y = KPIF;
lag1_y = lag(y);
lag2_y = lag2(y);
lag3_y = lag3(y);
lag4_y = lag4(y);
lag12_y = lag12(y);
run;

title "AR(1)";
proc autoreg data=work.inflrepo;
model y=lag1_y;
run;

title "AR(4)";
proc autoreg data=work.inflrepo;
model y=lag1_y lag2_y lag3_y lag4_y;
run;

title "AR(1,12)";
proc autoreg data=work.inflrepo;
model y=lag1_y lag12_y;
run;