# MapasYPermisos desde Windows

Este paquete prepara la compilación directa con GitHub Actions y la prueba posterior en Appetize. No requiere el toolkit de tu amigo ni VMware. No instala Xcode en Windows: Xcode se ejecuta en la Mac del servicio de GitHub.

## Qué contiene este paquete

Es código fuente con una configuración de compilación. Todavía no es una aplicación compilada. El ZIP de este paquete no se sube a Appetize.

El proyecto conserva la aplicación original. Se agregan `.github/workflows/ios-simulator.yml` y `scripts/build-simulator.sh`. El workflow se inicia manualmente, usa `macos-15`, compila para iOS Simulator ARM64 sin firma para dispositivos físicos y comprueba la plataforma del resultado antes de comprimirlo.

## Subir el proyecto a GitHub desde el navegador

1. Inicia sesión en tu cuenta de GitHub.
2. Crea un repositorio llamado `MapasYPermisos`, de visibilidad privada. Activa la creación de un README para disponer de una rama inicial.
3. Descomprime `MapasYPermisos-GitHub-FUENTES.zip` en Windows.
4. En el repositorio, selecciona **Add file > Upload files**.
5. Arrastra **el contenido** de la carpeta descomprimida `MapasYPermisos-GitHub`, incluidas `.github`, `scripts`, `MapasYPermisos`, `MapasYPermisos.xcodeproj`, `Pruebas` y los demás archivos. No subas el ZIP como un único archivo ni arrastres la carpeta exterior completa.
6. Confirma la carga con **Commit changes** en la rama predeterminada.
7. Comprueba que `.github` y `MapasYPermisos.xcodeproj` estén directamente en la raíz del repositorio. El archivo del workflow debe quedar en `.github/workflows/ios-simulator.yml`.

El paquete solo contiene la práctica de mapas. No subas la carpeta general de la materia, que también contiene otros trabajos.

## Compilar

1. Revisa la cuota disponible de GitHub Actions. En repositorios privados los ejecutores consumen la cuota de la cuenta y el exceso puede tener costo. No es necesario contratar un plan de pago para preparar el proyecto.
2. Abre **Actions > Compilar para Appetize > Run workflow**.
3. Selecciona la rama predeterminada y confirma **Run workflow**.
4. Espera el resultado. El límite configurado es de 20 minutos; no es una estimación de duración.
5. Si termina correctamente, abre esa ejecución y descarga el artefacto **MapasYPermisos-Appetize-N**.

Si no aparece Run workflow, verifica que el archivo esté en la rama predeterminada y en la ruta exacta. Si falla, abre el paso en rojo y conserva el registro; no descargues una compilación anterior suponiendo que corresponde a los cambios nuevos.

No se requiere GitHub CLI para este procedimiento desde el navegador. Los comandos `ios-init` e `ios-build` del PDF tampoco son necesarios.

## Subir el resultado a Appetize

1. Crea o utiliza tu cuenta de Appetize.
2. Descomprime el archivo descargado de GitHub. Dentro debe aparecer **MapasYPermisos-Simulator-IDENTIFICADOR.zip**.
3. En Appetize, utiliza la opción de subir una aplicación y selecciona **ese ZIP interior**. Contiene `MapasYPermisos.app`, compilada para simulador.
4. Elige un iPhone con iOS 17 o posterior disponible en tu cuenta e inicia una sesión.
5. Comprueba primero que se dibujen el mapa y los marcadores. Después prueba el selector, el permiso de ubicación y las lecturas sucesivas.

La arquitectura ARM64 de simulador sigue la recomendación de Appetize. El formato no es un IPA para instalar en un iPhone físico.

## Probar la ubicación

Appetize permite fijar una ubicación simulada. En el enlace de ejecución puedes añadir `?location=19.847707,-90.476276`; si el enlace ya tiene parámetros, utiliza `&location=19.847707,-90.476276`.

Ese parámetro configura la ubicación inicial de la sesión. Cambiar la URL y abrir una sesión nueva no demuestra seguimiento continuo. Para comprobar actualizaciones dentro de la misma sesión, utiliza los controles de ubicación que estén disponibles en tu cuenta o el método `session.setLocation(latitud, longitud)` de su SDK. Como segundo punto puedes usar `19.848900, -90.475100`.

Permite que la app muestre el diálogo de ubicación; no actives la concesión automática de permisos si necesitas capturarlo para el reporte. Identifica las ubicaciones como simuladas en tus evidencias.

## Estado y límites

El paquete y el script pueden revisarse desde Windows, pero una validación local de sus archivos no sustituye una compilación real en Xcode. La ejecución en GitHub y la comprobación visual del mapa quedan pendientes hasta realizar esos pasos con tu cuenta.

La ejecución en Appetize evita utilizar el adaptador gráfico de tu VMware; no garantiza de antemano que todas las funciones o servicios de mapas estén disponibles en la sesión. Si el mapa falla, conserva el registro y la captura de ese entorno.

## Documentación

- [GitHub Actions y ejecutores macOS](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)
- [Ejecución manual de workflows](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)
- [Cuotas de GitHub Actions](https://docs.github.com/en/billing/concepts/product-billing/github-actions)
- [Formato de aplicaciones iOS para Appetize](https://docs.appetize.io/platform/app-management/uploading-apps/ios)
- [Ubicación simulada en Appetize](https://docs.appetize.io/features/mock-location)
