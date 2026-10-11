# Práctica de mapas y permisos

Proyecto de SwiftUI para ejecutar en el **simulador de iPhone de Xcode**. Implementa los diez pasos de `Ejercicio2.pdf`: mapa, coordenadas, región, cambio de lugares, permiso de ubicación y actualizaciones mediante `LocationManager`.

## Abrir y ejecutar

1. Copia esta carpeta completa a la Mac donde utilizas Xcode. Si recibiste el ZIP, descomprímelo primero.
2. Abre **MapasYPermisos.xcodeproj**. No necesitas crear un proyecto ni pegar los archivos por separado.
3. Selecciona el esquema **MapasYPermisos** y un **simulador de iPhone con iOS 17 o posterior** en la barra superior. No selecciones “Any iOS Device”, porque ese destino sirve para compilar, no para ejecutar.
4. Pulsa **Run** o **⌘R**. Usa Xcode 15 o posterior, con el runtime de iOS correspondiente instalado. El código utiliza Swift 5 y las APIs de mapas disponibles desde iOS 17.
5. Prueba el selector, **Ir al lugar** y **Ver todos**. Después pulsa **Mi ubicación** y permite el acceso mientras usas la app.

El simulador no necesita una cuenta de desarrollador de pago ni configurar un equipo de firma. Si Xcode pide un equipo, comprueba primero que seleccionaste un simulador y no un iPhone físico. La descarga de los mapas requiere conexión a Internet.

Xcode se ejecuta en macOS. El simulador emula el dispositivo iPhone; estos archivos no convierten Xcode en una aplicación para Windows.

## Probar la ubicación del simulador

La posición del simulador es un dato de prueba y puede ser distinta de la ubicación física de la computadora. Para fijar una posición:

1. Con la app abierta, pulsa **Mi ubicación** y acepta el permiso.
2. En la ventana del **Simulator**, abre **Features > Location > Custom Location** e introduce latitud `19.847707` y longitud `-90.476276`. El nombre del menú puede variar según la versión.
3. Cambia a `19.848900`, `-90.475100`. Comprueba que se actualicen las coordenadas, la hora de lectura y el centro del mapa sin volver a pulsar el botón.

Para reproducir varios puntos, el proyecto ya incluye **Pruebas/RecorridoCampeche.gpx**. Mientras ejecutas con el depurador de Xcode, selecciona **Debug > Simulate Location > RecorridoCampeche**. Si no aparece, utiliza **Add GPX File to Project** en ese menú y selecciona el archivo incluido. No lo vuelvas a copiar si Xcode indica que ya forma parte del proyecto.

El GPX contiene cinco puntos simulados. Sirve para observar cambios sucesivos; no representa evidencia de una trayectoria real ni garantiza una frecuencia exacta de actualización. Si el recorrido no avanza en tu versión del simulador, usa las dos coordenadas manuales anteriores.

## Cómo se utiliza

- **Selector de lugar:** cambia entre Campeche, Mérida y Ciudad de México. Son ubicaciones de ejemplo; los restaurantes del documento eran una sugerencia.
- **Ir al lugar:** vuelve a centrar el mapa en la opción seleccionada, incluso si ya estaba seleccionada.
- **Ver todos:** encuadra los tres marcadores.
- **Mi ubicación:** solicita permiso si hace falta y comienza a recibir lecturas. La cámara se centra en cada lectura válida, conservando la escala visible.
- **Detener:** detiene las actualizaciones de ubicación y permite explorar el mapa libremente. Elegir un lugar también detiene el seguimiento.
- **Abrir Ajustes:** aparece cuando el permiso está denegado o restringido. Una restricción del sistema puede requerir intervención del administrador o del responsable del dispositivo.

La app muestra latitud, longitud, precisión estimada y hora de la última lectura recibida. El seguimiento se pausa cuando la app deja de estar activa y se reanuda al regresar si seguía solicitado. No se habilita ubicación en segundo plano ni se guarda un historial de coordenadas.

## Archivos principales

| Archivo | Función |
| --- | --- |
| `MapasYPermisosApp.swift` | Punto de entrada de la aplicación. |
| `ContentView.swift` | Mapa, marcadores, selector, botones y conexión con los cambios de ubicación. |
| `Place.swift` | Tres lugares con identificador, coordenadas y región. |
| `LocationManager.swift` | Adaptación del archivo del profesor: permisos, delegado, lecturas, errores y pausa. |
| `Info-iOS.plist` | Explicación que iOS muestra al pedir permiso y configuración de la aplicación. |
| `Pruebas/RecorridoCampeche.gpx` | Ubicaciones simuladas para las pruebas en Xcode. |
| `PRUEBAS.md` | Procedimiento de comprobación y capturas para el futuro reporte. |
| `Referencias/LocationManager-profesor.swift` | Copia sin modificar del archivo proporcionado. No forma parte del target. |

## Relación con las instrucciones

| Paso del PDF | Implementación |
| --- | --- |
| 1 | Importaciones de SwiftUI, MapKit y CoreLocation; Combine se importa explícitamente para ObservableObject y Published. |
| 2 | Coordenadas de cada lugar en `Place`. El punto inicial conserva `19.847707, -90.476276`. |
| 3 | `MKCoordinateSpan` define la extensión visible. Se utilizan valores positivos de `0.05` y `0.01` grados. |
| 4 | `Place.region` combina centro y extensión en `MKCoordinateRegion`. |
| 5 | `Map(position: $camera)` presenta el mapa mediante la API actual. |
| 6 | `showSelectedPlace()` modifica la cámara almacenada con `@State`. |
| 7 | `Picker` selecciona un lugar y `onChange` actualiza el mapa. |
| 8 | `NSLocationWhenInUseUsageDescription` ya está configurada en `Info-iOS.plist`. |
| 9 | Se integra una adaptación atribuida de `LocationManager.swift`. |
| 10 | `@StateObject` conserva una sola instancia y `onReceive` procesa cada región publicada. |

El PDF usa `Map(coordinateRegion:)`. Los inicializadores de esa familia están deprecados en la documentación actual de Apple; esta versión utiliza `MapCameraPosition.region` y `Map(position:)`, manteniendo `CLLocationCoordinate2D`, `MKCoordinateSpan` y `MKCoordinateRegion`. Una extensión menor muestra un área menor. Los límites efectivos de acercamiento dependen del mapa; no se usa una extensión de cero.

El ejemplo del profesor copia `locationManager.region` al pulsar un botón. Para cumplir el seguimiento continuo, esta versión escucha **cada** valor publicado. Crear el objeto o copiar la región una vez no basta para seguir los cambios posteriores.

La captura de configuración del PDF muestra un target macOS, pero esta práctica se preparó para iOS y su simulador. La clave de permiso ya está incluida; no hace falta agregarla otra vez.

## Estado de verificación

Los archivos del proyecto, las referencias internas, el esquema compartido, el plist de permisos y el GPX se revisan mediante `verificar_estructura.py`. Este control comprueba el empaquetado; **no compila Swift ni prueba la aplicación**.

La compilación y la ejecución en el simulador quedan pendientes de realizar en una Mac con Xcode. No se han generado capturas de ejecución ni resultados de pruebas ficticios. Sigue `PRUEBAS.md` para documentar los resultados reales antes de preparar el reporte.

Para compilar desde la Terminal de esa Mac, dentro de esta carpeta:

```sh
xcodebuild -project MapasYPermisos.xcodeproj -scheme MapasYPermisos -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
```

## Si algo no funciona

- **No hay simuladores disponibles:** instala un runtime de iOS desde los ajustes de Xcode y crea o selecciona un simulador compatible.
- **Se queda buscando ubicación:** asigna una ubicación simulada; autorizar el acceso no crea una lectura automáticamente.
- **Aparece otro país:** revisa la ubicación configurada en el simulador. No es un error del selector.
- **Permiso denegado:** usa el botón de Ajustes y cambia el permiso; vuelve a la app y pulsa **Mi ubicación**. El sistema no repite indefinidamente el diálogo de permiso.
- **Servicios de localización apagados:** actívalos en los ajustes del simulador y vuelve a intentar.
- **Mapa sin calles:** comprueba conexión, acceso a los servidores de mapas y el estado del simulador.
- **Xcode antiguo:** esta implementación necesita las APIs de iOS 17; no basta con bajar el deployment target.

## Fuentes y atribución

- Aguilar Canepa, J. Material del ejercicio: `Ejercicio2.pdf` y `LocationManager.swift`, compartidos en Classroom. La copia original del Swift conserva la fecha del encabezado del profesor.
- Apple. [Map y sus inicializadores](https://developer.apple.com/documentation/mapkit/map).
- Apple. [CLLocationManager](https://developer.apple.com/documentation/corelocation/cllocationmanager).
- Apple. [Solicitud de permiso durante el uso](https://developer.apple.com/documentation/corelocation/cllocationmanager/requestwheninuseauthorization()).
- Apple. [StateObject y conservación del objeto observable](https://developer.apple.com/documentation/swiftui/stateobject).

