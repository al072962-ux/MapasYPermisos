# Comprobación de la práctica en Xcode

Ejecuta estas pruebas en el simulador de iPhone. Los resultados de la tabla son **comportamientos esperados**, no pruebas ya aprobadas. Registra las versiones reales de Xcode e iOS y marca cada caso únicamente después de observarlo.

Xcode utilizado: __________

Modelo e iOS del simulador: __________

Fecha de ejecución: __________

| Caso | Procedimiento | Resultado esperado | Resultado observado |
| --- | --- | --- | --- |
| 1. Inicio | Abrir la app con permisos aún sin decidir. | Mapa en las coordenadas de Campeche del ejercicio; el diálogo no aparece antes de pulsar Mi ubicación. | Pendiente |
| 2. Selector | Seleccionar Mérida y después Ciudad de México. | El mapa se centra en cada lugar y muestra su marcador. | Pendiente |
| 3. Botón | Mover el mapa y pulsar Ir al lugar. | Regresa al lugar seleccionado. | Pendiente |
| 4. Todos los puntos | Pulsar Ver todos. | Los tres marcadores quedan dentro del encuadre. | Pendiente |
| 5. Permiso aceptado | Pulsar Mi ubicación y permitir durante el uso. Asignar una posición al simulador. | Aparece la lectura con coordenadas, hora y precisión; el mapa se centra en ella. | Pendiente |
| 6. Actualización continua | Usar el GPX o cambiar dos veces la posición del simulador. | Cambian las coordenadas y la cámara sin volver a pulsar Mi ubicación. | Pendiente |
| 7. Pausa | Pulsar Detener y cambiar la posición simulada. | Las lecturas de la app dejan de actualizarse; el mapa se puede explorar. | Pendiente |
| 8. Elección durante el seguimiento | Activar seguimiento y luego seleccionar Mérida. | Detiene seguimiento y permanece en Mérida aun cuando cambie la posición simulada. | Pendiente |
| 9. Permiso denegado | Desde Ajustes del simulador cambiar el permiso de la app a Nunca. Regresar y pulsar Mi ubicación. | Mensaje de permiso denegado, sin cierre inesperado; los lugares predefinidos siguen disponibles. | Pendiente |
| 10. Permiso recuperado | Habilitar el permiso durante el uso, regresar y pulsar Mi ubicación. | Vuelve a recibir lecturas sin reinstalar la app. | Pendiente |
| 11. Ubicación aproximada | Desactivar Ubicación precisa si el simulador ofrece la opción. | Indica ubicación aproximada y muestra la precisión reportada por el sistema. | Pendiente o no disponible |
| 12. App inactiva | Con seguimiento activo, ir a inicio y después regresar a la app. | Pausa fuera de la app y reanuda al volver, siempre que el permiso continúe vigente. | Pendiente |
| 13. Sin lectura | Establecer Features > Location > None y comenzar el seguimiento. | Puede mostrar espera; la app no se cierra. Una lectura en caché puede aparecer brevemente. | Pendiente |
| 14. Servicios desactivados | Desactivar Localización globalmente en los ajustes del simulador y solicitar ubicación. | Mensaje de acceso no disponible o denegado; el mapa de lugares sigue siendo utilizable. | Pendiente |

## Capturas para el reporte posterior

Guarda capturas nítidas del **Simulator** con su opción de guardar pantalla. Usa los mismos nombres para facilitar su incorporación al reporte:

1. `01_mapa_inicial.png`: pantalla inicial del ejercicio en Campeche.
2. `02_cambio_de_lugar.png`: Mérida o Ciudad de México después de usar el selector.
3. `03_permiso_ubicacion.png`: diálogo real de iOS con la explicación configurada.
4. `04_ubicacion_primera.png`: primera lectura simulada, con coordenadas visibles.
5. `05_ubicacion_actualizada.png`: otra lectura del recorrido para demostrar el cambio.
6. `06_permiso_denegado.png`: respuesta de la aplicación al rechazar el permiso.

Al describir las capturas, identifica las posiciones como **simuladas**. El concepto de tiempo real se demuestra al recibir actualizaciones sucesivas del proveedor de ubicación. Para comprobar una posición física y movimiento real se necesita ejecutar la app en un dispositivo con servicios de ubicación.

La pantalla de Ajustes del target con la clave `NSLocationWhenInUseUsageDescription` también puede servir como evidencia de configuración. Ninguna captura del documento del profesor sustituye una captura de esta aplicación ejecutada.
