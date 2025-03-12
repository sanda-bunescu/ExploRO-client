import SwiftUI

struct CreateTripPlanView: View {
    var groupName: String?
    @StateObject private var groupViewModel = GroupViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var tripName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var selectedGroup: String? = nil
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Create New Trip Plan")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            if let group = groupName {
                VStack {
                    Text("Traveling with: \(group)")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                }
                .padding(.horizontal)
            } else {
                HStack {
                    Text("Traveling with:")
                        .font(.headline)
                    Spacer()
                    if groupViewModel.groups.isEmpty {
                        ProgressView()
                    } else {
                        Picker("Select Group", selection: $selectedGroup) {
                            ForEach(groupViewModel.groups, id: \.id) { group in
                                Text(group.groupName)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                    }
                }
            }
            
            
            VStack(alignment: .leading) {
                Text("Enter Trip Plan Name:")
                TextField("", text: $tripName)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).fill(Color(.systemGray6)))
            }
            
            DatePicker("Start Date: ", selection: $startDate, displayedComponents: .date)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).fill(Color(.systemGray6)))
            
            DatePicker("End Date:", selection: $endDate, displayedComponents: .date)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).fill(Color(.systemGray6)))
            
            Button{
                Task {
                    // createTripPlan
                }
            } label:{
                Text("Create")
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onAppear {
            Task{
                await groupViewModel.fetchGroupsByUserId(user: authViewModel.user)
            }
        }
    }
}

#Preview {
    NavigationStack{
        CreateTripPlanView(groupName: "Alone")
            .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
    }
}
