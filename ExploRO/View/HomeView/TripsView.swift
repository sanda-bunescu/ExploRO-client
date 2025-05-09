import SwiftUI

struct TripsView: View {
    var body: some View {
        NavigationLink(destination: TripPlanListView()) {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 57/255, green: 133/255, blue: 72/255), Color(red: 175/255, green: 197/255, blue: 179/255)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(radius: 5)

                // Content inside the card
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("View Your Trip Plans")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Explore and manage your adventures")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundColor(.white)
                        .font(.title)
                }
                .padding()
            }
            .frame(height: 120)
            .padding(.horizontal)
        }
    }
}

#Preview {
    TripsView()
}
