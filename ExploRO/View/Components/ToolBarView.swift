import SwiftUI

enum TabItem {
    case home
    case trips
    case groups
    case profile
}


struct ToolbarContainer<Content: View>: View {
    @Binding var selectedTab: TabItem
    let content: () -> Content

    init(selectedTab: Binding<TabItem>, @ViewBuilder content: @escaping () -> Content) {
        self._selectedTab = selectedTab
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            content()
            ToolBarView(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


struct ToolBarView: View {
    @Binding var selectedTab: TabItem
    let screenWidth = UIScreen.main.bounds.size.width

    var body: some View {
        ZStack {
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                .foregroundStyle(Color(red: 57/255, green: 133/255, blue: 72/255))

            HStack {
                ToolbarItemView(systemImage: "house", label: "Home") {
                    selectedTab = .home
                }
                Spacer()
                ToolbarItemView(systemImage: "map", label: "Trips") {
                    selectedTab = .trips
                }
                Spacer()
                ToolbarItemView(systemImage: "person.3", label: "Groups") {
                    selectedTab = .groups
                }
                Spacer()
                ToolbarItemView(systemImage: "person.crop.circle", label: "My profile") {
                    selectedTab = .profile
                }
            }
            .padding(.horizontal, 20)
            .foregroundStyle(.white)
        }
        .frame(width: screenWidth, height: 90)
        .ignoresSafeArea()
    }
}

struct ToolbarItemView: View {
    let systemImage: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
                Text(label)
                    .font(.system(size: 13))
            }
        }
    }
}

#Preview {
    ToolBarView(selectedTab: .constant(.home))
}

