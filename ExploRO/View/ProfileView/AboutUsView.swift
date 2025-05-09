import SwiftUI

struct AboutUsView: View {
    let headerHeight: CGFloat = UIScreen.main.bounds.height * 0.35

    var body: some View {
        ScrollView {
            GeometryReader { geo in
                let yOffset = geo.frame(in: .global).minY

                Image("romania_landmark")
                    .resizable()
                    .scaledToFill()
                    .frame(height: yOffset > 0 ? headerHeight + yOffset : headerHeight)
                    .clipped()
                    .offset(y: yOffset > 0 ? -yOffset : 0)
            }
            .frame(height: headerHeight)

            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome to ExploRO")
                    .font(.title)
                    .bold()

                Text("Your ultimate travel companion for exploring Romania. Whether you're discovering hidden gems in the Carpathian Mountains, planning a trip through Transylvania, or managing group expenses with friends, ExploRO is here to guide every step of your journey.")
                    .font(.body)
                    .foregroundColor(.secondary)

                Divider()

                Text("Our Mission")
                    .font(.headline)

                Text("We aim to make travel in Romania seamless, inspiring, and unforgettable by combining local insights with smart travel tools.")
                    .font(.body)
                    .foregroundColor(.secondary)

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "map.fill", title: "Discover", description: "Find unique destinations, cultural landmarks, and nature spots across Romania.")
                    FeatureRow(icon: "calendar", title: "Plan", description: "Build custom itineraries and day-by-day schedules tailored to your interests.")
                    FeatureRow(icon: "person.3.fill", title: "Manage", description: "Easily track group expenses, split costs, and stay organized during your trip.")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(radius: 5)
            )
            .offset(y: -20)
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("About Us")
    }
}


struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    AboutUsView()
}
