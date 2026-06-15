# README - Sistema POS de Restaurante Local

Explicación de lo que se está usando:

- La librería printing y pdf se puede usar en impresoras con IPv4 estático y también las que no tienen IP (se autodetectan de forma dinámica a través de las capacidades de red y del spooler nativo de Android en la misma red Wi-Fi).

## 1. Descripción del Proyecto
Este proyecto es una aplicación móvil nativa desarrollada en **Flutter** diseñada para operar de forma local (*Local-First*) en tabletas y celulares dentro de un restaurante. Permite registrar comandas, guardarlas de manera permanente en un almacenamiento local y mandarlas a imprimir directamente en hojas de tamaño **A4** utilizando la infraestructura de red inalámbrica del establecimiento, funcionando con un 100% de independencia de servidores externos o internet.

## 2.- Funcionamiento del Motor de Impresión A4
Al descartar los comandos tradicionales ESC/POS de bytes crudos (que deformaban el texto al no detectar el fin de la hoja en bandejas grandes), el sistema procesa la impresión así:

Maquetación Vectorial: La librería pdf dibuja un documento digital estructurado con títulos en negrita, tablas perimetrales para los platos y alineamientos específicos de precios utilizando coordenadas exactas de una hoja A4.

Invocación del Administrador Nativo: La librería printing actúa como un puente que despierta el Spooler de Impresión de Android.

Flexibilidad de Conectividad: Esto permite que el usuario final pueda imprimir tanto en impresoras industriales que posean una dirección IPv4 fija asignada, como en impresoras domésticas o de oficina inalámbricas sin IP fija (vía protocolos automáticos Mopria, AirPrint o servicios en la nube locales).

## 3.- Requisitos Críticos del Sistema

Android Manifest: Es obligatorio declarar la línea <uses-permission android:name="android.permission.INTERNET" /> directamente debajo de la raíz del nodo <manifest>, de lo contrario el sistema operativo bloqueará las conexiones salientes hacia las impresoras de la red local.