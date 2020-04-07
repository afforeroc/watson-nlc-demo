# Watson Natural Language Classifier Demo

## Descripción
Esta demostración te permitirá:
- Crear un modelo NLC especificando: un nombre para el modelo ("estadoTiempo-xx"), un idioma ("es") y un archivo de entrenamiento ("estado_tiempo.csv").
- Verificar el estado del modelo: Entrenando ("Training") ó Disponible ("Available")
- Probar tu modelo con un archivo de prueba ("ejemplo_prueba.txt")

## Sistemas operativos
- Ubuntu 18.04.1 LTS

## Prerequisitos
El paquete 'jq' es usado en los scripts para manipular elementos de json y crear un metadata
```
$ sudo apt-get install jq
```

## Cómo ejecutar en SHELL (terminal/ventana de comandos)
```
$ ./wnlc.sh -push estadoTiempo es estado_tiempo.csv 
$ ./wnlc.sh -status estadoTiempo-xx
$ ./wnlc.sh -test estadoTiempo prueba.txt
```

## Información adicional:
El paquete 'dos2unix' fue usado para ejecutar archivos bash en Ubuntu como subsistema de Windows 10
```
$ sudo apt-get install dos2unix
$ dos2unix nlc-push-model.sh
```

