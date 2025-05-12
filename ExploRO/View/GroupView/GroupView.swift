import SwiftUI

struct GroupView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @ObservedObject var groupViewModel: GroupViewModel
    @State private var showSheet = false
    @State private var showTripPlans = false
    @State private var showExpensesView = false
    @State private var selectedMember: GroupUserResponse?
    let group: GroupResponse
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var expenseViewModel = ExpenseViewModel()
    @StateObject private var tripPlanViewModel = TripPlanViewModel()
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topTrailing) {
                GeometryReader { geo in
                    let offset = geo.frame(in: .global).minY
                    AsyncImage(url: URL(string: group.imageUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: offset > 0 ? 200 + offset : 200)
                            .clipped()
                            .offset(y: offset > 0 ? -offset : 0)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                            .frame(height: 200)
                    }
                }
                .frame(height: 200)
                
                HStack {
                    AsyncImage(url: URL(string: group.imageUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } placeholder: {
                        ZStack {
                            Circle().fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text(group.groupName)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 100),
                    alignment: .bottom
                )
            }
            
            VStack(spacing: 32) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Latest Expenses")
                            .font(.title.bold())
                            .foregroundColor(.primary)
                        Spacer()
                        NavigationLink(destination: ExpenseListView(groupId: group.id)) {
                            HStack(spacing: 4) {
                                Text("See All")
                                Image(systemName: "chevron.right")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            
                        }
                    }
                    
                    if expenseViewModel.expenses.isEmpty {
                        Text("No expenses added yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(expenseViewModel.expenses.prefix(3), id: \.id) { expense in
                            NavigationLink(destination: ExpenseView(expense: expense, expenseViewModel: expenseViewModel)) {
                                ExpenseRowView(expense: expense)
                            }
                            
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Upcoming Trip Plans")
                            .font(.title.bold())
                            .foregroundColor(.primary)
                        Spacer()
                        NavigationLink(destination: TripPlanListView()) {
                            HStack(spacing: 4) {
                                Text("See All")
                                Image(systemName: "chevron.right")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            
                        }
                    }
                    
                    if tripPlanViewModel.tripPlans.isEmpty {
                        Text("No trips planned yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(tripPlanViewModel.tripPlans.prefix(3), id: \.id) { trip in
                            NavigationLink(destination: TripPlanDetailView(group: group, tripPlan: trip, tripViewModel: tripPlanViewModel)) {
                                TripCardView(trip: trip)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
        }
        .background(Color(hex: "#E2F1E5").ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .onAppear {
            Task {
                await groupViewModel.fetchUsersByGroupId(groupId: group.id, user: authViewModel.user)
                await expenseViewModel.loadExpenses(forGroup: group.id, user: authViewModel.user)
                await tripPlanViewModel.fetchTripPlansByGroupId(user: authViewModel.user, groupId: group.id)
            }
        }
        .navigationBarBackButtonHidden(true)

        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Capsule())
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: GroupSettings(groupViewModel: groupViewModel, group: group)) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        }


    }
}

#Preview {
    NavigationStack {
        GroupView(groupViewModel: GroupViewModel(), group: GroupResponse(id: 87, groupName: "TestGroup", imageUrl: "http://localhost:3000/static/groupImages/Three Friends Walking in the City.jpeg"))
            .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
    }
}
