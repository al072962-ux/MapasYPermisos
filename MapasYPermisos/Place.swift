import MapKit

struct Place: Identifiable {
    let id: String
    let name: String
    let detail: String
    let coordinate: CLLocationCoordinate2D

    var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    // El primer punto conserva exactamente las coordenadas del profesor.
    // Los otros dos son puntos de referencia aproximados de las ciudades.
    static let examples: [Place] = [
        Place(
            id: "campeche", name: "Campeche",
            detail: "Ubicación inicial del ejercicio",
            coordinate: CLLocationCoordinate2D(latitude: 19.847707, longitude: -90.476276)
        ),
        Place(
            id: "merida", name: "Mérida",
            detail: "Punto de referencia en el centro de la ciudad",
            coordinate: CLLocationCoordinate2D(latitude: 20.96737, longitude: -89.62370)
        ),
        Place(
            id: "ciudad-de-mexico", name: "Ciudad de México",
            detail: "Punto de referencia cerca del Zócalo",
            coordinate: CLLocationCoordinate2D(latitude: 19.43260, longitude: -99.13320)
        )
    ]
}
