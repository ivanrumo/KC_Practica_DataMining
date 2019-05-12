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


