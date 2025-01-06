import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Binding var navigationPath: NavigationPath
    @Binding var shouldRefresh: Bool

    @State private var selectedTab: Tab = .camera
    @State private var showSettings = false
    @State private var showUserNameAlert = false

    enum Tab {
        case camera
        case map
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                CameraEntry()
                    .tag(Tab.camera)
                MapView()
                    .tag(Tab.map)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                authViewModel.fetchUserDetails { success, datas, errorMessage in
                    if success {
                        if datas?["user_name"] is NSNull {
                            showUserNameAlert = true
                        }
                    } else {
                        UserRepository.unpersistToken()
                        navigationPath = NavigationPath()
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
                    .sheet(isPresented: Binding(
                        get: { showSettings },
                        set: { showSettings = $0 }
                    )) {
                        SettingsView(navigationPath: $navigationPath, shouldRefresh: $shouldRefresh)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                
                UserNameAlert(isPresented: $showUserNameAlert)
                    .frame(width: 0, height: 0)
            }
        }
        .onChange(of: shouldRefresh) { _, newValue in
            if newValue {
                shouldRefresh = false
                navigationPath = NavigationPath()
            }
        }
    }
}
