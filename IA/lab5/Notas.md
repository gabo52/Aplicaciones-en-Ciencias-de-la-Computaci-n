# Algoritmos genéticos

## Representación:

En AGs:

Representación binaria.

[1000 1011 0110 1111] -> [8,11,6,15]

Representación Enteral/Real

[8.1, 11, 6.4, 15.9]

Representación con permutaciones:

[a,c,e,b,g,h,d,f]

Representación con árboles:

     +
   /   \
  a     '/'        -> a+b/c
       /   \
      b     c

## Población:

Conjunto de individuos, por general de tamaño fijo

## Función de Fitness en AGs

Es la función objetivo, representa a los requerimientos a los que la población debe adaptarse.

Asigna un único valor (nro. real) a cada individuo, lo cual es necesario para la selección.

El fitness máximiza usualmente.

## Selección de progenitores:

Se escoge un conjunto de individuos de la población basado en su *fitness*, para generar nuevos individuos.

Es usualmente probabilístico.

También se pueden escoger individuos con poco fitness(con poca probabilidad), lo que ayuda a escapar de óptimos locales.

- Técnica de la ruleta:

Se les atribuye a los individuos pedazos de una ruleta cuyo ancho es proporcional a su fitness.
Se gira la ruleta n veces para seleccionar los n progenitores.

- Seleccion por torneo:

Se seleccionan k individuos aleatoriamente y escogen el mejor.
Reper n veces.

## Cruzamiento

El cruzamiento se realiza normalmente entre 2 padres escogidos con cierta probabilidad Pr(taza de recombinación).

- Cruzamiento de 1 punto.
- Cruzamiento multipunto
- Cruzamiento uniforme.
- Cruzamiento de permutaciones.
- Cruzamiento de punto flotante.

## Mutación

Altera aleatoriamente los alelos de los individuos hijos con una probabilidad Pm(**taza de mutación**)

Depende de la representación escogida.

- Mutación bitwise: Se cambia bit por bit.
- Mutación de punto flotante: [x1,x2,x3,x4] ---> [x1,x2',x3,x4]
                                                 x2' = x2 + a * deltaMax
                                                 -1 <= a <= 1
- Mutación de permutaciones:

    Swap        [1,*2*,3,4,*5*,6,7,8,9]         ->  [1,5,3,4,2,6,7,8,9]
    Inversión   [1,*2*,*3*,*4*,*5*,6,7,8,9]     ->  [1,5,4,3,2,6,7,8,9]

## Efectos de cruzamiento y Mutación

- Recombinación tiene un rol **explotativo**, hace que la población evolucione a individuos con la mejor combinación de alelos observados en el proceso evolutivo.
- Mutación tiene un rol **explorativo**, es na fuente de generación de nuevos alelos en la población con la esperanza de encontrar nuevas regiones prometedoras o escapar de la convergencia actual.


## Selección de sobrevivientes

Trata de como escoger la población de la siguiente generación a partir de la población actual y la población de hijos generada.

Selección: "Todos los hijos reemplazan a los padres"


Selección Elitista:

- Reemplazar todos los padres por los hijos, menos el mejor padre.
- Seleccionar los n mejores individuos de la unión de padres e hijos (selección por ranking)