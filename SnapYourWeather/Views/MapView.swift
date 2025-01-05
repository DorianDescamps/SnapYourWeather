// MapView.swift

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var picturesVM: PicturesViewModel
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
        )
    )
    
    @State private var isDetailPresented: Bool = false
    @State private var pictureSelected: Picture? = nil
    
    init(authViewModel: AuthViewModel) {
        // On crée le viewModel ici pour le stocker dans @StateObject
        _picturesVM = StateObject(wrappedValue: PicturesViewModel(authViewModel: authViewModel))
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                // Pour chaque photo récupérée, on place une annotation
                ForEach(picturesVM.pictures) { picture in
                    if let lat = Double(picture.latitude),
                       let lon = Double(picture.longitude) {
                        Annotation(picture.fileName,
                                   coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                            // Ici on peut personnaliser l’icône
                            // On met un bouton pour détecter le clic
                            Button(action: {
                                pictureSelected = picture
                                isDetailPresented = true
                            }) {
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .mapStyle(.standard(elevation: .realistic))
        }
        .navigationBarTitle("Carte", displayMode: .inline)
        // Quand la vue apparaît, on lance la requête
        .onAppear {
            picturesVM.fetchPictures()
        }
        // Présentation de la popup
        .sheet(isPresented: $isDetailPresented) {
            if let selected = pictureSelected {
                PictureDetailView(picturesVM: picturesVM, picture: selected)
            }
        }
    }
}
