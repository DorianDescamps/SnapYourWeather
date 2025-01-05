import SwiftUI

struct NavigationBar: View {
    @Binding var selectedTab: MainView.Tab

    struct TabItem {
        let tab: MainView.Tab
        let imageName: String
        let title: String
    }

    private let tabs: [TabItem] = [
        TabItem(tab: .camera, imageName: "camera", title: "Caméra"),
        TabItem(tab: .map, imageName: "map", title: "Carte")
    ]

    var body: some View {
        HStack {
            ForEach(tabs, id: \.tab) { tabItem in
                Button(action: {
                    if selectedTab != tabItem.tab {
                        withAnimation {
                            selectedTab = tabItem.tab
                        }
                    }
                }) {
                    VStack {
                        Image(systemName: tabItem.imageName)
                            .font(.system(size: 24))
                        Text(tabItem.title)
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == tabItem.tab ? .blue : .gray)
            }
        }
        .frame(height: 70)
    }
}
