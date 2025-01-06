import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var picturesViewModel = PicturesViewModel()
    
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
        )
    )
    
    @State private var pictures: [Picture] = []
    @State private var isDetailPresented: Bool = false
    @State private var pictureSelected: Picture? = nil
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                ForEach(pictures) { picture in
                    if let latitude = Double(picture.latitude),
                       let longitude = Double(picture.longitude),
                       let weatherIconURL = URL(string: picture.weatherDetails.icon_url) {
                        Annotation("@\(picture.user.user_name)", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                            AsyncImage(url: weatherIconURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 40, height: 40)
                                case .success(let image):
                                    image
                                        .resizable()
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
            .mapStyle(.standard(elevation: .realistic))
        }
        .navigationBarTitle("Carte", displayMode: .inline)
        .onAppear {
            picturesViewModel.getPictures() { success, pictures, _ in
                if success {
                    self.pictures = pictures!
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { isDetailPresented },
            set: { isDetailPresented = $0 }
        )) {
            if let pictureSelected = pictureSelected {
                PictureDetailView(picture: pictureSelected)
            }
        }
    }
}
