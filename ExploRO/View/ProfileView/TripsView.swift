import SwiftUI

struct TripsView: View {
    @State private var isPressed = false
    var body: some View {
            Image("Intro")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding(.bottom)
                .overlay{
                    VStack{
                        Spacer()
                        NavigationLink(destination: TripPlanListView()) {
                            HStack {
                                Text("View your Trip Plans >")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.white.opacity(0.7))
                                    )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                        }
                        
                    }
                }
            .frame(maxWidth: .infinity)
            
        
    }
}

#Preview {
    TripsView()
}
