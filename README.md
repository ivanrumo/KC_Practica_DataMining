# Practica DataMining

## Objetivo y análisis exploratorio

El objetivo de la práctica es abordar un problema de data mining realista siguiendo la metodología
y buenas prácticas explicadas durante las clases teóricas.

Dicho lo cual, en estas instrucciones no se especifican los pasos exactos que el alumno tiene que llevar
a cabo para realizar esta tarea con éxito. Es parte del trabajo aplicar las técnicas de
procesamiento/transformación de variables que mejor se acondicionen al problema, identificar los
modelos adecuados que proporcionen buenas prestaciones así como las variables potencialmente más
relevantes, y elegir la métrica adecuada para contrastar los distintos modelos.

Las posibilidades son amplias, así que es recomendable abordar una aproximación incremental, esto
es, comenzar por soluciones sencillas para progresivamente aumentar la complejidad de las técnicas
utilizadas.

Se trabajará con uno de los dataset que ofrece SAS Institute para las prácticas y exámenes de data
mining para resolver un problema de modelización.

La descripción dada del dataset es la siguiente:

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dataset.png)

Para realizar el análisis exploratorio creamos una librería, cargamos el conjunto de datos y mostramos los primeros registros

```sas
*conexion de libreria;
libname lib_prac '/home/u38080140/ivanrubiomoreno/Practica';

* Cargamos el dataset ;
* Tenemos 50000 observations and 10 variables.
data bweight;
  set lib_prac.bweight;
 run;
 
proc print data= lib_data.babyWeigths (obs=10);
run;
```

Al cargar el dataset vemos que tiene 50.000 filas y las 10 variables que se indicaban en la descripción del dataset.

Confirmamos que tenemos como variables categóricas categóricas las columnas Black, Married, Boy MomSmoke y MomEdLevel.

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/primeros_registros.png)

El campo MomAge tiene la edad de la madre, pero los valores no son la edad real. Los valores van a escala. 0 indica que tiene 25 años. Si tiene menos de 25 tiene valores negativos y si tiene mas de 25 años tiene valores positivos. Vamos a sumar 25 al campo MomAge para tener los valores reales de edad y así ser más legible a primera vista.

```sas
data bweight;
 set bweight;
 MomAge = MomAge + 25;
run;
```

Hago un poco de limpieza eliminando las observaciones duplicadas:

```sas
proc sort nodupkey data= bweight;
	by _all_;
run;
```

Después de hacer limpieza nos quedamos con 48734 y 10 variables.

## Análisis de variable objetivo

La variable objetivo de denomina **weight**. Vamos a analizar el contenido de esta variable mediante una tabla de frecuencias.

```sas
proc freq data=bweight; 
  tables weight;
run;

proc means data= bweight;
	var weight ;
run;

proc univariate data=bweight normal plot;
 var weight;
 qqplot Weight / NORMAL (MU=EST SIGMA=EST COLOR=RED L=1);
 HISTOGRAM /NORMAL(COLOR=MAROON W=4) CFILL = BLUE CFRAME = LIGR;
 INSET MEAN STD /CFILL=BLANK FORMAT=5.2;
run;

```

Por suerte vemos que todas las filas tienen valor en la variable objetivo.

Vemos que los datos están muy repartidos. Hay que analizar si tenemos outliers.

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/means_weight.png)

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/medidas_basicas.png)

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/cuartiles_weight.png)

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/grafico_barra_weight.png)

Se ve que tanto por arriba y por abajo hay algunos valores que se desvian mucho de la media, la mediana y la moda. Un 1% tienen valores por debajo de 1526 y otro 1% valores por encima de 4621.
Decido eliminar ese 1% por encima y debajo ya que creo que es ruido que puede afectar negativamente a mi modelo.

```sas
data bweight;
   set bweight;
   if weight <= 1526 or weight >= 4621 then delete;
run;
```

Después de eliminar estas observaciones nos quedamos con 47741 observaciones.

## Análisis variables independientes

Vamos analizar la variables independientes. En primer lugar vamos a sacar una tabla con las medias de las variables numéricas:

```sas
proc means data=bweight;
  var _numeric_;
run;
```

![Tabla medias](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/tabla_medias.png)

Vemos que ninguna variable tiene valores "missing". Todas tienen 48734 valores. Vemos que la desviación estándar no tiene valores muy altos (menos en la variableobjetivo).

Lo siguiente que hacemos es un TTest con la opción de gráficos activada:

```sas
ods graphics on;
proc ttest data=bweight;
  var _numeric_;
 run;
ods graphics off; 
```

Vamos a analizar la información que nos proporciona SAS:

### Weight

* Como ya hemos visto antes, el peso sigue una distribución normal.
* La distribución estándar está muy alejada de la media.
* Hay outliers por arriba y por abajo.
* La mayoría de los datos siguen la recta Q-Q. Los valores más bajos son los que salen más desviados. Habría que averiguar si además de nacimientos también se han incluido abortos. En esos casos es posible que los fetos al no estar desarrollados arrojen estos datos que se desvían del resto.

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dist_weigth.png)

### Black.

Este es un campo dicotómico. Vemos que hay muchos mas que no son de raza que negra que los que si. 

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dist_black.png)

### Married

También es una variable dicotómica. En este caso vemos que hay más nacimientos de madres casadas que solteras.

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dist_married.png)

### Boy

Variable dicotómica. Como se ve en la gráfica, en la media y la desviación estándar los valores está muy repartidos. 

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dist_boy.png)


### MomAge

Los datos se desvían un poco de una distribución normal. El valor mínimo es 16 años y el máximo 43 años. Es lógico que no haya datos de edades muy bajos y muy altos.  

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dist_momage.png)


### MomSmoke

Variable dicotómica. Vemos que hay muchas menos madres fumadoras que no fumadoras. 

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dist_momsmoke.png)

### CigsperDay

Lógicamente, al haber muchas menos madres no fumadoras es normal que el valor que más se repita sea el 0.

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dist_cigsperday.png)

### MomWtGain

Este dato tiene una distribución muy extraña. Podría haber seguido una distribución normal, pero hace unos picos un poco rarao. En el Q-Q podemos ver como se escalona.
La desviación estándar es bastante superior a la media.
Se pueden ver valores negativos muy grandes lo cual parece raro y en valores positivos vemos muchos ourliers.

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dist_momwtgain.png)

Vamos ha hacer un estudio más detallado de esta variable.

```sas
proc univariate data=bweight normal plot;
 var MomWtGain;
 qqplot MomWtGain / NORMAL (MU=EST SIGMA=EST COLOR=RED L=1);
 HISTOGRAM /NORMAL(COLOR=MAROON W=4) CFILL = BLUE CFRAME = LIGR;
 INSET MEAN STD /CFILL=BLANK FORMAT=5.2;
run;
```

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/datos_momwtgain.png)

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/quartiles_momwtgain.png)

Con los datos obtenidos decido eliminar del dataset el 1% de los pesos positivos para quitar los outliers que puedan meter ruido en los modelos, por lo que hay que eliminar las observaciones con valores mayores de 36.

```sas
data bweight;
   set bweight;
   if MomWtGain >= 36 then delete;
run;
```

Después de esta limpieza nos quedamos con 47232 observaciones.

### Visit

Este dato tiene tres posibles valores: Del 0 al 3. La distribución no es normal. Más adelante veremos valores concretos, pero el 3 es el valor que más se repite.

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dist_visit.png)

### MomEdLevel

Los datos están bastante reraptidos entre los cuatro posibles valores. La media y la desviación estandar teníene valores muy cercanos.

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dist_momedlevel.png)

## Tablas de frecuencias.

Voy obtener tablas de frecuencias de las variables independientes para comprobar si tienen valores todas las observaciones.

### Black

```sas
proc freq data=bweight; 
  tables black;
run;
```

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/freq_black.png)

Vemos que no tenemos valores a missing, por lo que esta variable la dejamos como está.

### Married

```sas
proc freq data=bweight; 
  tables married;
run;
```

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/freq_married.png)

Al igual que la variable anterior, en el caso de _married_ no tenemos valores a missing, por lo que esta variable la dejamos como está.

### Boy

```sas
proc freq data=bweight; 
  tables boy;
run;
```

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/freq_boy.png)

No tenemos valores a missing. La variable la dejamos como viene de origen.

### MomAge

```sas
proc freq data=bweight; 
  tables MomAge;
run;
```

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/freq_momage.png)

No tenemos valores a missing. La variable la dejamos como viene de origen.

### MomSmoke

```sas
proc freq data=bweight; 
  tables MomSmoke;
run;
```

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/freq_momsmoke.png)

No tenemos valores a missing. La variable la dejamos como viene de origen.

### CigsPerDay

```sas
proc freq data=bweight; 
  tables CigsPerDay;
run;
```

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/freq_cigsperday.png)

No tenemos valores a missing. La variable la dejamos como viene de origen.

### MomWtGain

```sas
proc freq data=bweight; 
  tables MomWtGain;
run;
```

En este caso no muestro la tabla de frecuencias, porque tiene muchos valores distintos y no me cabe. Aunque puedo decir que no tiene valores a missing, así que queda como está.

### Visit

```sas
proc freq data=bweight; 
  tables Visit;
run;
```

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/freq_visit.png)

No tenemos valores a missing. La variable la dejamos como viene de origen.

### MomEdLevel

```sas
proc freq data=bweight; 
  tables MomEdLevel;
run;
```

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/freq_momedlevel.png)

No tenemos valores a missing. La variable la dejamos como viene de origen.

## Coeficiones de correlación

Vamos a sacar la tabla con los coeficientes de correlación para ver si hay variables que estén muy correladas entre si:

```sas
proc corr data=bweight;
	var _numeric_;
run;
```

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/corr.png)

En la tabla de correlaciones no se observan valores por encima de 90. El valor más alto es de 0.82 para las variables MomSmoke y CigsPerDay. Claramente estas variables está relacionadas por lo que voy a eliminar la columna MomSmoke ya es que menos informativa. Solo indica si fuma o no la madre, pero CigsPerDay además de indicar si fuma o no, indica el número de cigarrillos que fuma al día. 

Al eliminar la variable MomSmoke del conjunto de datos, al eliminar duplicados seguimos manteniendo las 48734 observaciones.