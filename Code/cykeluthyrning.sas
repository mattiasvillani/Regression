*/ Glöm inte att läsa in/importera datamaterialet cykeluthyr.csv (finns under Föreläsning F1 på webbsidan) i SAS först. 
*/ Det importerade datamaterialet ska heta cykeluthyr och ligga i WORK mappen
*/ (som är default) när man importerar data.

Title "Enkel linjär regression nRides mot temp";
proc reg data = work.cykeluthyr;
model NRIDES = TEMP;
run;

Title "Multipel linjär regression - nRides mot temp och hum";
proc reg data = work.cykeluthyr;
model NRIDES = TEMP HUM;
run;

Title "Multipel linjär regression - nRides mot temp och hum";
proc reg data = work.cykeluthyr;
model NRIDES = TEMP HUM WINDSPEED;
run;

