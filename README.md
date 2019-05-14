# Practica DataMining

## Carga de datos

En primer lugar creamos una librería y cargamos el conjunto de datos

```sas
*conexion de libreria;
libname lib_prac '/home/u38080140/ivanrubiomoreno/Practica';

* Cargamos el dataset ;
* Tenemos 50000 observations and 10 variables.
data bweight;
  set lib_prac.bweight;
 run;
```

Vemos que el conjunto de datos se compone de 50.000 observaciones y 10 variables. 

## Análisis de variable objetivo

La variable objetivo de denomina **weight**. Vamos a analizar el contenido de esta variable mediante una tabla de frecuencias.

```sas
proc freq data=bweight; 
  tables weight;
run;
```

Vemos que los datos están muy repartidos. Hay que analizar si tenemos outliers. Por suerte vemos que todas las filas tienen valor en la variable objetivo. 

Vamos a mostrar un gráfico de barras para ver como se reparten los datos.

```sas
proc gchart data=bweight;
  vbar weight / type = freq;
run;
```

![grafico barras weight](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/grafico_barra_weight.png)

Podemos observar que los datos siguen una distribución normal. Parece lógico que la mayoría de bebes al nacer tengan un peso que similar. En los extremos estarán, por ejemplo, nacimientos de bebes prematuros.

Vamos a hacer un poco de limpieza eliminando las observaciones duplicadas:

```sas
proc sort nodupkey data= bweight;
	by _all_;
run;
```

Después de hacer limpieza nos quedamos con 48734 y 10 variables.

Ya tenemos analizada nuestra variable objetivo. Hemos visto que es de tipo numérico, por lo que no tenemos que hacerla numérica y que tiene una distribución normal. 

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

El campo MomAge tiene la edad de la madre, pero los valores no son la edad real. Los valores van a escala. 0 indica que tiene 25 años. Si tiene menos de 25 tiene valores negativos y si tiene mas de 25 años tiene valores positivos. Vamos a sumar 25 al campo MomAge para tener los valores reales de edad y con ese campo cambiado volvemos a ejecutar el TTest:

```sas
data bweight;
 set bweight;
 MomAge = MomAge + 25;
run;

proc freq data=bweight; 
  tables MomAge;
run;
```

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
La desviación estandar es bastante superior a la media. 

![](https://raw.githubusercontent.com/ivanrumo/KC_Practica_DataMining/master/img/dist_momwtgain.png)


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