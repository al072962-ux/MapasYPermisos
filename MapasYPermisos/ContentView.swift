import SwiftUI
import MapKit
import CoreLocation
import UIKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var locationManager = LocationManager()
    @State private var selectedPlaceID = Place.examples[0].id
    @State private var camera: MapCameraPosition = .region(Place.examples[0].region)
    @State private var visibleSpan = Place.examples[0].region.span

    private var selectedPlace: Place {
        Place.examples.first { $0.id == selectedPlaceID } ?? Place.examples[0]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                placeControls
                Map(position: $camera) {
                    ForEach(Place.examples) { place in
                        Marker(place.name, coordinate: place.coordinate)
                            .tint(place.id == selectedPlaceID ? .orange : .blue)
                    }
                    if locationManager.isAuthorized && locationManager.isTracking {
                        UserAnnotation()
                    }
                }
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    visibleSpan = context.region.span
                }
                .accessibilityLabel("Mapa con ubicaciones predefinidas y tu posición autorizada")

                locationControls
            }
            .navigationTitle("Mapas y permisos")
            .navigationBarTitleDisplayMode(.inline)
        }
        // Recibir cada región publicada evita copiar una ubicación solo una vez.
        .onReceive(locationManager.$region) { newRegion in
            guard locationManager.isTracking else { return }
            camera = .region(MKCoordinateRegion(center: newRegion.center, span: visibleSpan))
        }
        .onChange(of: selectedPlaceID) { _, _ in
            showSelectedPlace()
        }
        .onChange(of: scenePhase) { _, newPhase in
            locationManager.setAppActive(newPhase == .active)
        }
        .onDisappear {
            locationManager.stopFollowing()
        }
    }

    private var placeControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Lugar", selection: $selectedPlaceID) {
                ForEach(Place.examples) { place in
                    Text(place.name).tag(place.id)
                }
            }
            .pickerStyle(.menu)
            .accessibilityHint("Cambia el centro del mapa al lugar seleccionado")

            Text(selectedPlace.detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Button("Ir al lugar", systemImage: "mappin.and.ellipse") {
                    showSelectedPlace()
                }
                Button("Ver todos", systemImage: "map") {
                    locationManager.stopFollowing()
                    // Enmarca solamente los lugares: el seguimiento se detiene.
                    withAnimation { camera = .automatic }
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    private var locationControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(
                locationManager.statusMessage,
                systemImage: locationManager.isTracking ? "location.fill" : "location"
            )
            .font(.subheadline)
            .accessibilityIdentifier("locationStatus")

            if let location = locationManager.lastLocation {
                Text("Última lectura: \(location.coordinate.latitude, specifier: "%.6f"), \(location.coordinate.longitude, specifier: "%.6f")")
                    .font(.caption.monospacedDigit())
                    .textSelection(.enabled)
                HStack {
                    Text("Precisión estimada: ±\(location.horizontalAccuracy, specifier: "%.0f") m")
                    Text(location.timestamp, style: .time)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            HStack {
                Button("Mi ubicación", systemImage: "location.fill") {
                    // Volver a una escala local, aunque se estuvieran viendo todos.
                    visibleSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    locationManager.startFollowing()
                }
                .buttonStyle(.borderedProminent)
                .disabled(locationManager.isTracking)

                if locationManager.isTracking {
                    Button("Detener", systemImage: "pause.fill") {
                        locationManager.stopFollowing()
                    }
                    .buttonStyle(.bordered)
                }
            }

            if locationManager.needsSettings {
                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
    }

    private func showSelectedPlace() {
        locationManager.stopFollowing()
        visibleSpan = selectedPlace.region.span
        withAnimation { camera = .region(selectedPlace.region) }
    }
}
