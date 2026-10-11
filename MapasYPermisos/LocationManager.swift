// Adaptación del archivo LocationManager.swift de Jose Aguilar (15/10/2024).
// Se conserva la región inicial y el uso de CLLocationManagerDelegate.
// Se agregan control de permisos, errores, pausa y actualización observable.

import Combine
import CoreLocation
import MapKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var wantsLocation = false
    private var isAppActive = true

    @Published private(set) var region = Place.examples[0].region
    @Published private(set) var lastLocation: CLLocation?
    @Published private(set) var isTracking = false
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var statusMessage = "Elige un lugar o pulsa Mi ubicación."

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    var needsSettings: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    override init() {
        // ContentView crea el StateObject en el hilo principal. Core Location
        // entrega sus callbacks en el RunLoop del hilo que crea el manager.
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        authorizationStatus = manager.authorizationStatus
        // No solicitar permisos al abrir: esperar una acción del usuario.
    }

    func startFollowing() {
        wantsLocation = true
        authorizationStatus = manager.authorizationStatus
        updateTrackingForAuthorization(requestIfNeeded: true)
    }

    func stopFollowing() {
        wantsLocation = false
        manager.stopUpdatingLocation()
        isTracking = false
        statusMessage = "Seguimiento detenido. Puedes explorar el mapa."
    }

    func setAppActive(_ active: Bool) {
        isAppActive = active
        if active {
            authorizationStatus = manager.authorizationStatus
            // No presentar un nuevo diálogo solo por regresar a la app.
            updateTrackingForAuthorization(requestIfNeeded: false)
        } else {
            manager.stopUpdatingLocation()
            isTracking = false
            if wantsLocation {
                statusMessage = "Seguimiento pausado mientras la app no está activa."
            }
        }
    }

    private func updateTrackingForAuthorization(requestIfNeeded: Bool) {
        guard wantsLocation, isAppActive else { return }

        switch authorizationStatus {
        case .notDetermined:
            statusMessage = "Se necesita tu permiso para mostrar tu ubicación."
            if requestIfNeeded {
                manager.requestWhenInUseAuthorization()
            }
        case .authorizedWhenInUse, .authorizedAlways:
            guard !isTracking else { return }
            isTracking = true
            statusMessage = "Buscando tu ubicación…"
            manager.startUpdatingLocation()
        case .denied:
            stopForUnavailableAuthorization(
                "Permiso denegado. Puedes habilitar la ubicación en Ajustes."
            )
        case .restricted:
            stopForUnavailableAuthorization(
                "El sistema restringe el acceso a la ubicación."
            )
        @unknown default:
            stopForUnavailableAuthorization("La ubicación no está disponible.")
        }
    }

    private func stopForUnavailableAuthorization(_ message: String) {
        manager.stopUpdatingLocation()
        isTracking = false
        // Evitar que vuelva a arrancar sin otra pulsación del usuario.
        wantsLocation = false
        lastLocation = nil
        statusMessage = message
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if !isAuthorized {
            self.manager.stopUpdatingLocation()
            isTracking = false
            lastLocation = nil
        }
        updateTrackingForAuthorization(requestIfNeeded: false)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard wantsLocation, isAppActive, isTracking, isAuthorized,
              let location = locations.last,
              location.horizontalAccuracy >= 0,
              abs(location.timestamp.timeIntervalSinceNow) <= 30 else { return }

        lastLocation = location
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        if manager.accuracyAuthorization == .reducedAccuracy {
            statusMessage = "Siguiendo tu ubicación aproximada."
        } else {
            statusMessage = "Siguiendo tu ubicación mientras la app está activa."
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard wantsLocation, isAppActive else { return }
        if let locationError = error as? CLError, locationError.code == .locationUnknown {
            // Este error suele ser temporal. Esperar la siguiente lectura.
            statusMessage = "Aún no hay una lectura válida. Esperando ubicación…"
            return
        }
        self.manager.stopUpdatingLocation()
        isTracking = false
        wantsLocation = false
        lastLocation = nil
        if let locationError = error as? CLError, locationError.code == .denied {
            statusMessage = "Ubicación no disponible. Revisa los permisos y Localización en Ajustes."
        } else {
            statusMessage = "No se pudo obtener la ubicación. Pulsa Mi ubicación para reintentar."
        }
    }
}

