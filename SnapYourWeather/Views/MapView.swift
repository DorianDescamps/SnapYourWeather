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
        _picturesVM = StateObject(wrappedValue: PicturesViewModel(authViewModel: authViewModel))
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                ForEach(picturesVM.pictures) { picture in
                    if let lat = Double(picture.latitude),
                       let lon = Double(picture.longitude),
                       let iconURL = URL(string: picture.weatherDetails.icon_url) {
                        Annotation("", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                            AsyncImage(url: iconURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 40, height: 40)
                                case .success(let image):
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                case .failure:
                                    Image(systemName: "xmark.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .onTapGesture {
                                pictureSelected = picture
                                isDetailPresented = true
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
        .onAppear {
            picturesVM.fetchPictures()
        }
        .sheet(isPresented: $isDetailPresented) {
            if let selected = pictureSelected {
                PictureDetailView(picturesVM: picturesVM, picture: selected)
            }
        }
    }
}
