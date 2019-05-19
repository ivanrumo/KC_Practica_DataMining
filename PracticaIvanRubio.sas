*conexion de libreria;
libname lib_prac '/home/u38080140/ivanrubiomoreno/Practica';

* Cargamos el dataset ;
* Tenemos 50000 observations and 10 variables.;
data bweight (); 
  set lib_prac.bweight;
 run;

* mostramos los primeros registros;
proc print data = bweight(obs=10);
run;

/* sumamos 25 a la edad de la madre */
data bweight;
 set bweight;
 MomAge = MomAge + 25;
run;


* hacemos un poco delimpieza ;
* después de quitar duplucados tenemos 48734 observations and 10 variables.;
proc sort nodupkey data= bweight;
	by _all_;
run;

* analizamos la variable objetivo ;
proc freq data=bweight; 
  tables weight;
run;

proc means data= bweight;
	var weight ;
run;

proc univariate data=bweight normal plot;
 var _numeric_;
 qqplot _numeric_ / NORMAL (MU=EST SIGMA=EST COLOR=RED L=1);
 HISTOGRAM /NORMAL(COLOR=MAROON W=4) CFILL = BLUE CFRAME = LIGR;
 INSET MEAN STD /CFILL=BLANK FORMAT=5.2;
run;


proc univariate data=bweight normal plot;
 var weight;
 qqplot Weight / NORMAL (MU=EST SIGMA=EST COLOR=RED L=1);
 HISTOGRAM /NORMAL(COLOR=MAROON W=4) CFILL = BLUE CFRAME = LIGR;
 INSET MEAN STD /CFILL=BLANK FORMAT=5.2;
run;

/* eliminamos los outliers. Nos quedamos con 47741 observaciones*/
data bweight;
   set bweight;
   if weight <= 1926 or weight >= 4621 then delete;
run;

/* sacamos loas medias de las variables numéricas */
proc means data=bweight;
  var _numeric_;
run;


/* hacemos un ttest con los gráficos activados */
ods graphics on;
proc ttest data=bweight;
  var _numeric_;
 run;
ods graphics off; 

/* analizamos mas detenidamente MomWtGain */
proc univariate data=bweight normal plot;
 var MomWtGain;
 qqplot MomWtGain / NORMAL (MU=EST SIGMA=EST COLOR=RED L=1);
 HISTOGRAM /NORMAL(COLOR=MAROON W=4) CFILL = BLUE CFRAME = LIGR;
 INSET MEAN STD /CFILL=BLANK FORMAT=5.2;
run;

/* eliminamos los outliers. Nos quedamos con 47232 observaciones*/
data bweight;
   set bweight;
   if MomWtGain >= 36 then delete;
run;


/* analizamos la varible black */
proc freq data=bweight; 
  tables black;
run;

/* analizamos la varible boy */
proc freq data=bweight; 
  tables boy;
run;

/* analizamos la varible married */
proc freq data=bweight; 
  tables married;
run;

/* analizamos la varible momage */
proc freq data=bweight; 
  tables MomAge;
run;

/* analizamos la varible momsmoke */
proc freq data=bweight; 
  tables MomSmoke;
run;

/* analizamos la varible cigsperday */
proc freq data=bweight; 
  tables CigsPerDay;
run;

/* analizamos la varible momwtgain */
proc freq data=bweight; 
  tables MomWtGain;
run;

/* analizamos la varible visit */
proc freq data=bweight; 
  tables Visit;
run;

/* analizamos la varible momedlevel */
proc freq data=bweight; 
  tables MomEdLevel;
run;

/* sacamos una tabla de correlación */
proc corr data=bweight;
	var _numeric_;
run;

%let lib1 = '/home/u38080140/ivanrubiomoreno/output/glm_bweight.txt';
%macro glm_select (t_input, vardepen, varcategoricas, varindepen, interacciones, frac_ini, frac_fin, semi_ini, semi_fin, seleccion, selecc_name); 
	
	%do frac = &frac_ini. %to &frac_fin.;
		data;
		  fra=&frac/10;
		  call symput('porcen',left(fra));
		run;
		
		%do semilla = &semi_ini. %to &semi_fin.;
			ods graphics on;
			ods output SelectionSummary=modelos;
			ods output SelectedEffects=efectos;
			ods output Glmselect.SelectedModel.FitStatistics=ajuste;
			
			proc glmselect data=&t_input. plots=all seed=&semilla;
			  partition fraction(validate=&porcen);
			  class &varcategoricas.;
			  model &vardepen. = &varindepen. &interacciones.
			   / selection=&seleccion details=all stats=all; run;   
			
			ods graphics off;  
			ods html close;   
				  		
			data union&semilla.; 
			  i=12; 
			  set efectos; 
			  set ajuste point=i; 
			run; *observación 12 ASEval;
			
			data  _null_;
			  semilla=&semilla;
			  selecc_name=&selecc_name;
			  file &lib1 mod;
			  set union&semilla.;
			  put effects @201 nvalue1 @215 semilla @225 selecc_name;
			run;
			
			proc sql; drop table union&semilla.; quit;
		%end;
	%end;
	/*proc sql; drop t able modelos,efectos,ajuste,union; quit;*/
%mend;

%macro glm_select_selections (t_input, vardepen, varcategoricas, varindepen, interacciones, frac_ini, frac_fin, semi_ini, semi_fin); 
	/* borramos el contenido del fichero */
	data  _null_;
	 file &lib1  OLD;
	run;
	
	%glm_select(&t_input., 
					&vardepen., &varcategoricas., &varindepen., &interacciones., 
					&frac_ini., &frac_fin., &semi_ini., &semi_fin., 
					stepwise(select=aic choose=validate), 'stepwise_validate');
	%glm_select(&t_input., 
					&vardepen., &varcategoricas., &varindepen., &interacciones., 
					&frac_ini., &frac_fin., &semi_ini., &semi_fin., 
					stepwise(select=aic choose=cv), 'stepwise_cv');
					
	%glm_select(&t_input., 
					&vardepen., &varcategoricas., &varindepen., &interacciones., 
					&frac_ini., &frac_fin., &semi_ini., &semi_fin., 
					forward, 'forward');

	%glm_select(&t_input, 
					&vardepen, &varcategoricas, &varindepen, &interacciones, 
					&frac_ini, &frac_fin, &semi_ini, &semi_fin, 
					backward, 'backward');
%mend;

/* con estas iteraciones los valoes de ASE son muy elevados 
Intercept MomSmoke MomWtGain Black Married Boy Visit MomEdLevel MomAge*Black MomAge*MomSmoke MomAge*MomEdLevel         286858         12345     stepwise_validate
Intercept MomSmoke MomWtGain Black Married Boy Visit MomEdLevel MomAge*Black MomAge*MomSmoke MomAge*MomEdLevel         290772         12345     stepwise_validate
Intercept MomSmoke MomWtGain Black Married Boy Visit MomAge*MomSmoke                                                   291000         12345     stepwise_validate
Intercept MomSmoke MomWtGain Black Married Boy Visit MomEdLevel MomAge*Black MomAge*MomSmoke MomAge*MomEdLevel         278805         12345     stepwise_cv
Intercept MomSmoke MomWtGain Black Married Boy Visit MomEdLevel MomAge*Black MomAge*MomSmoke MomAge*MomEdLevel         287524         12345     stepwise_cv
Intercept MomSmoke MomWtGain Black Married Boy Visit MomEdLevel MomAge*Black MomAge*Married MomAge*MomSmoke            286883         12345     stepwise_cv
Intercept MomSmoke MomWtGain Black Married Boy MomAge*MomSmoke                                                         287150         12345     forward
Intercept MomSmoke MomWtGain Black Married Boy MomAge*MomSmoke                                                         291100         12345     forward
Intercept MomSmoke MomWtGain Black Married Boy MomAge*Black MomAge*MomSmoke                                            291123         12345     forward
Intercept MomSmoke MomWtGain Black Married Boy MomAge*MomSmoke                                                         287150         12345     backward
Intercept MomSmoke MomWtGain Black Married Boy MomAge*MomSmoke                                                         291100         12345     backward
Intercept MomSmoke MomWtGain Black Married Boy MomAge*Black MomAge*MomSmoke                                            291123         12345     backward
*/
%glm_select_selections(bweight, weight, 
  Black Married Boy Visit MomEdLevel MomSmoke,
  MomAge MomSmoke MomWtGain Black Married Boy Visit MomEdLevel,
  MomAge*Black MomAge*Married MomAge*Boy MomAge*MomSmoke MomAge*MomWtGain MomAge*Visit MomAge*MomEdLevel ,
  3, 5, 12345, 12346);
  
/* 
Como está claro que las iteraciones que he cogido no son muy buenas voy a sacar unos modelos sin iteraciones a ver que variables
independientes salen en esos modelos
*/
%glm_select_selections(bweight, weight, 
  Black Married Boy  Visit MomEdLevel MomSmoke,
  MomAge  MomWtGain Black Married Boy Visit MomEdLevel,
  MomSmoke ,
  3, 5, 12345, 12346);

/* En los modelos anteriores las variables que siempre están en lo modelos son:
  - MomAge MomWtGain Black Married Boy MomSmoke
Así que voy ha hacer iteraciones con estas variables. 
*/
%glm_select_selections(bweight, weight, 
  Black Married Boy Visit MomEdLevel MomSmoke,
  MomAge MomWtGain Black Married Boy Visit MomEdLevel MomSmoke,
  MomAge*MomWtGain MomAge*Black MomAge*Married MomAge*Boy MomAge*Visit MomAge*MomEdLevel MomAge*MomSmoke
  MomWtGain*Black MomWtGain*Married MomWtGain*Boy MomWtGain*Visit MomWtGain*MomEdLevel MomWtGain*MomSmoke
  Black*Married Black*Boy Black*Visit Black*MomEdLevel Black*MomSmoke
  Married*Boy Married*Visit Married*MomEdLevel Married*MomSmoke
  Boy*Visit Boy*MomEdLevel Boy*MomSmoke
  MomSmoke*MomEdLevel MomSmoke*Visit,
  3, 5, 12345, 12346);


* volvemos a analizar la variable objetivo ;
proc univariate data=bweight normal plot;
 var weight;
 qqplot weight / NORMAL (MU=EST SIGMA=EST COLOR=RED L=1);
 HISTOGRAM /NORMAL(COLOR=MAROON W=4) CFILL = BLUE CFRAME = LIGR;
 INSET MEAN STD /CFILL=BLANK FORMAT=5.2;
run;

* quitamos otra vez ouliers ;
data bweight;
   set bweight;
   if weight <= 2182 or weight >= 4621 then delete;
run;

* estudiamos otra vez MomWtGain ;
proc univariate data=bweight normal plot;
 var MomWtGain;
 qqplot MomWtGain / NORMAL (MU=EST SIGMA=EST COLOR=RED L=1);
 HISTOGRAM /NORMAL(COLOR=MAROON W=4) CFILL = BLUE CFRAME = LIGR;
 INSET MEAN STD /CFILL=BLANK FORMAT=5.2;
run;

* quitamos mas outliers;
data bweight;
   set bweight;
   if MomWtGain <= -30 or MomWtGain >= 30 then delete;
run;


* guardamos el data set en la libreria para poder utilizarlo en el miner posteriormente;
data lib_prac.bweight_dummy;
   set bweight;
run;


/* volvemos a probar */
%glm_select_selections(bweight, weight, 
  Black Married Boy Visit MomEdLevel MomSmoke,
  MomAge MomWtGain Black Married Boy Visit MomEdLevel MomSmoke,
  MomAge*MomWtGain MomAge*Black MomAge*Married MomAge*Boy MomAge*Visit MomAge*MomEdLevel MomAge*MomSmoke
  MomWtGain*Black MomWtGain*Married MomWtGain*Boy MomWtGain*Visit MomWtGain*MomEdLevel MomWtGain*MomSmoke
  Black*Married Black*Boy Black*Visit Black*MomEdLevel Black*MomSmoke
  Married*Boy Married*Visit Married*MomEdLevel Married*MomSmoke
  Boy*Visit Boy*MomEdLevel Boy*MomSmoke
  MomSmoke*MomEdLevel MomSmoke*Visit,
  3, 5, 12345, 12346);

* ejecutamos la macro para obener los modelos buscados ;
%glm_select_selections(bweight, weight, 
  Black Married Boy Visit MomEdLevel MomSmoke,
  MomAge MomWtGain Black Married Boy Visit MomEdLevel MomSmoke,
  MomAge*MomWtGain MomAge*Black MomAge*Married MomAge*Boy MomAge*Visit MomAge*MomEdLevel MomAge*MomSmoke
  MomWtGain*Black MomWtGain*Married MomWtGain*Boy MomWtGain*Visit MomWtGain*MomEdLevel MomWtGain*MomSmoke
  Black*Married Black*Boy Black*Visit Black*MomEdLevel Black*MomSmoke
  Married*Boy Married*Visit Married*MomEdLevel Married*MomSmoke
  Boy*Visit Boy*MomEdLevel Boy*MomSmoke
  MomSmoke*MomEdLevel MomSmoke*Visit,
  3, 5, 12345, 12400);

/* hacemos un dataset con los datos del fichero */
data seleccion;
  INFILE  '/home/u38080140/ivanrubiomoreno/output/glm_bweight.txt';
  length modelo $243;
  input modelo $1-200 ase semilla tipo_seleccion $225-242;
 run;

proc sort  data=seleccion; by modelo;

proc freq  data=seleccion; tables modelo / noprint out=frec_modelos; run;

proc sort data=frec_modelos out=modelos_ordenados; by descending count; run;

/*
MomWtGain Black Married Boy MomAge*MomSmoke
MomWtGain Black Married Boy MomEdLevel MomAge*MomSmoke
Black Married Boy MomEdLevel MomAge*MomSmoke MomWtGain*Boy
MomWtGain Boy MomAge*Boy MomAge*MomSmoke Black*MomSmoke Married*MomSmoke
*/


ods graphics on;

/* Modelos seleccionados */
proc glm data=lib_prac.bweight_dummy;
  class Black Married Boy MomSmoke;
  model weight = MomWtGain Black Married Boy MomAge*MomSmoke
/ solution e;
run;

proc glm data=lib_prac.bweight_dummy;
  class Black Married Boy Visit MomEdLevel MomSmoke;
  model weight = MomWtGain Black Married Boy MomEdLevel MomAge*MomSmoke
/ solution e;
run;

proc glm data=lib_prac.bweight_dummy;
  class Black Married Boy Visit MomEdLevel MomSmoke;
  model weight = Black Married Boy MomEdLevel MomAge*MomSmoke MomWtGain*Boy
/ solution e;
run;

proc glm data=lib_prac.bweight_dummy;
  class Black Married Boy Visit MomEdLevel MomSmoke;
  model weight = MomWtGain Boy MomAge*Boy MomAge*MomSmoke Black*MomSmoke Married*MomSmoke
/ solution e;
run;

ods graphics off;







