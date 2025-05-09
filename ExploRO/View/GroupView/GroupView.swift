import SwiftUI

struct GroupView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @ObservedObject var groupViewModel: GroupViewModel
    @Environment(\.dismiss) private var dismiss
    let group: GroupResponse
    @State private var showSheet = false
    @State private var showTripPlans = false
    @State private var showExpensesView = false
    @State private var selectedMember: GroupUserResponse?
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

                HStack(spacing: 12) {
                    Button(action: {
                        dismiss() // custom back
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                            Text("Back")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Capsule())
                    }
                    Spacer()
                    NavigationLink(destination: GroupSettings(groupViewModel: groupViewModel, group: group)) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(16)


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

            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Button {
                        showTripPlans = true
                    } label: {
                        Text("Trip Plans")
                            .font(.title3)
                            .bold()
                            .padding(.vertical, 15)
                            .padding(.horizontal, 20)
                            .foregroundColor(.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .sheet(isPresented: $showTripPlans) {
                        TripPlanListView(group: group)
                    }
                    Button {
                        showExpensesView = true
                    } label: {
                        Text("Expenses")
                            .font(.title3)
                            .bold()
                            .padding(.vertical, 15)
                            .padding(.horizontal, 20)
                            .foregroundColor(.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }.sheet(isPresented: $showExpensesView) {
                        ExpenseListView(groupId: group.id)
                    }
                }
            }
            .padding(.top)
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            Task {
                await groupViewModel.fetchUsersByGroupId(groupId: group.id, user: authViewModel.user)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    NavigationStack {
        GroupView(groupViewModel: GroupViewModel(), group: GroupResponse(id: 66, groupName: "TestGroup", imageUrl: "http://localhost:3000/static/groupImages/Three Friends Walking in the City.jpeg"))
            .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
    }
}
