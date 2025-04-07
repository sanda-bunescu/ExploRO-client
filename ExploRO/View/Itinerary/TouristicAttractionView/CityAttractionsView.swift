import SwiftUI

struct CityAttractionsView: View {
    @StateObject private var viewModel = TouristicAttractionViewModel()
    @ObservedObject var stopPointViewModel: StopPointViewModel
    @State private var selectedAttractions: Set<Int> = []
    let cityId: Int
    let itineraryId: Int
    let tripPlanId: Int
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.attractions, id: \.id) { attraction in
                        AttractionCardView(attraction: attraction)
                            .onTapGesture {
                                // Toggle the selection of this attraction
                                if selectedAttractions.contains(attraction.id) {
                                    selectedAttractions.remove(attraction.id)
                                } else {
                                    selectedAttractions.insert(attraction.id)
                                }
                            }
                            .overlay(
                                selectedAttractions.contains(attraction.id)
                                    ? RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue, lineWidth: 2)
                                    : nil
                            )
                    }
                }
                .padding()
            }

            // Button to confirm selection and add stop points
            Button(action: {
                Task {
                    await addSelectedStopPoints()
                }
            }) {
                Text("Add Selected Stop Points")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .task {
            await viewModel.fetchTouristicAttractionsNotInTripPlan(cityId: cityId, user: authViewModel.user, tripPlanId: tripPlanId)
        }
    }

    private func addSelectedStopPoints() async {
        
        await stopPointViewModel.addStopPoints(ids: Array(selectedAttractions), itineraryId: itineraryId, user: authViewModel.user)
    }
}

struct AttractionCardView: View {
    let attraction: TouristicAttractionResponse
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: attraction.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            } placeholder: {
                Image(systemName: "building.2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(attraction.attractionName)
                    .font(.headline)
                Text(attraction.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("Open hours: \(attraction.openHours)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(radius: 2))
    }
}

#Preview {
    CityAttractionsView(stopPointViewModel: StopPointViewModel(), cityId: 29, itineraryId: 1, tripPlanId: 39)
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
