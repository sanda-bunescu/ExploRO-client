import SwiftUI

struct ItineraryTouristicAttractionView: View {
    let itinerary: ItineraryResponse
    let tripPlan: TripPlanResponse
    @StateObject private var stopPointViewModel = StopPointViewModel()
    @StateObject private var itineraryViewModel = ItineraryViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var showAttractionList = false
    @Binding var itineraryList: [ItineraryResponse]

    var body: some View {
        HStack{
            //left divider
            VStack{
                Image(systemName: "circle")
                    .foregroundStyle(.gray)
                    .opacity(0.5)
                HStack{
                    Divider()
                        .overlay(.gray)
                        .opacity(0.5)
                        .frame(minWidth: 10)
                }
                .padding()
                Image(systemName: "circle")
                    .foregroundStyle(.gray)
                    .opacity(0.5)
            }
            //Content
            VStack(alignment: .leading){
                HStack{
                    Text("Day \(itinerary.dayNr)")
                        .font(.title)
                    Spacer()
                    Button {
                        Task{
                            await itineraryViewModel.removeItinerary(itineraryId: itinerary.id, tripPlanId: tripPlan.id, user: authViewModel.user)
                            
                            if let index = itineraryList.firstIndex(where: { $0.id == itinerary.id }) {
                                itineraryList.remove(at: index)
                            }
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .padding(.trailing)
                }
                Button{
                    showAttractionList.toggle()
                }label: {
                    HStack{
                        Image(systemName: "plus")
                        Text("Add Stop Points")
                    }
                    .foregroundStyle(.gray)
                    .font(.headline)
                    .opacity(0.7)
                }.sheet(isPresented: $showAttractionList) {
                    CityAttractionsView(stopPointViewModel: stopPointViewModel, cityId: tripPlan.cityId, itineraryId: itinerary.id, tripPlanId: tripPlan.id)
                }
                if stopPointViewModel.stopPoints.isEmpty{
                    Button{
                        //add stopPoints
                        showAttractionList.toggle()
                    }label:{
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .stroke(Color.gray, lineWidth: 0.3)
                            .overlay(
                                HStack{
                                    Image(systemName: "plus")
                                    Text("Select Stop Points")
                                }
                                    .font(.footnote)
                                    .bold()
                                    .foregroundColor(.gray)
                            )
                            .frame(height: 100)
                    }
                    .padding(.bottom, 40)
                    .sheet(isPresented: $showAttractionList) {
                        CityAttractionsView(stopPointViewModel: stopPointViewModel, cityId: tripPlan.cityId, itineraryId: itinerary.id, tripPlanId: tripPlan.id)
                    }
                }else{
                    ForEach(stopPointViewModel.stopPoints, id: \.id){ stopPoint in
                        TouristicAttractionView(stopPoint: stopPoint,itineraryId: itinerary.id, stopPointViewModel: stopPointViewModel, stopPointsList: $stopPointViewModel.stopPoints)
                    }
                }
            }
        }
        .padding(.bottom)
        .ignoresSafeArea()
        .task {
            await stopPointViewModel.fetchStopPoints(itineraryId: itinerary.id, user: authViewModel.user)
        }
    }
}


#Preview {
    @Previewable @State var emptyItineraryList: [ItineraryResponse] = []

    ItineraryTouristicAttractionView(
        itinerary: ItineraryResponse(id: 1, dayNr: 1),
        tripPlan: TripPlanResponse(id: 1, tripName: "Test trip", startDate: Date(), endDate: Date(), groupName: "TestGroup", cityName: "Bucharest", cityId: 57),
        itineraryList: $emptyItineraryList // Pass a binding to the state variable
    )
}

