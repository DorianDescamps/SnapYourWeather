import Foundation

struct Picture: Codable, Identifiable {
    var id: String { fileName } 
    
    let datetime: String
    let fileName: String
    let latitude: String
    let longitude: String
    let user: PictureUser
    let weatherDetails: WeatherDetails
    
    var dateFormatted: String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: datetime) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            outputFormatter.timeStyle = .short
            return outputFormatter.string(from: date)
        } else {
            return datetime
        }
    }
}

struct PictureUser: Codable {
    let user_name: String
}

struct WeatherDetails: Codable {
    let city: String
    let description: String
    let icon_url: String
    let large_icon_url: String
    let feltTemperature: String
}
