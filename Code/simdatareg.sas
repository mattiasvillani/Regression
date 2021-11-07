/* Baserat på "Simulating Data with SAS", Kapitel 11 (Wicklin, 2013, p. 208-209) */
%let N = 1000;                 /* antalet observationer i det simulerade datamaterialet */
%let nVars =  2;               /* antalet förklarande variabler */
 
data SimReg; 
  call streaminit(12345); 
  array x[&nVars]  x1-x&nVars;   /* förklarande variabler med namn x1, x2, x3, ... */
 
  do k = 1 to &N;  /* upprepa för varje observation i det simulerade stickprovet. */
    /* 2. Simulara värden på alla förklarande variabler */ 
    do i = 1 to &nVars;        
       x[i] = round(rand("Normal"), 0.001);
    end; 
 
    /* 3. Simulera y-värden genom att beräkna alpha + beta1*x1 + beta2*x2 och addera feltermen epsilon */
    y = 4 + 3*x[1] - 2*x[&nVars] + rand("Normal", 0, 1);                    
    output;  
  end;  
  drop i k;
run;     

/* Beräkna minsta-kvadratskattningar på det simulerade datamaterialet */
/* Skattningarna bör inte avvika för mycket från populationsregressionen alpha = 4, beta1 = 3, beta2 = -2 */
proc reg data=SimReg;
   model y = x1-x&nVars;
quit;