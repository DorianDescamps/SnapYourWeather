import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State public var  token: String
    @State private var selectedTab: Tab = .camera
    @State private var showSettings = false
    @State private var showUserNameAlert = false

    enum Tab {
        case camera
        case map
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CameraEntry()
                .tag(Tab.camera)
            MapView(authViewModel: authViewModel)
                .tag(Tab.map)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear {
            authViewModel.fetchUserDetails { success, datas, errorMessage in
                if (success) {
                    if (datas!["user_name"] is NSNull) {
                        showUserNameAlert = true
                    }
                } else {
                    authViewModel.logout()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
        ZStack {
            NavigationBar(selectedTab: $selectedTab)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .edgesIgnoringSafeArea(.bottom)

            UserNameAlert(isPresented: $showUserNameAlert)
                .frame(width: 0, height: 0)
        }
    }
}
