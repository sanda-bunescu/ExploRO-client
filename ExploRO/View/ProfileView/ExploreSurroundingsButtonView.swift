import SwiftUI

struct ExploreSurroundingsButtonView: View {
    var body: some View {
            Button{
                print("Button Tapped")
            }label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.white]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        .frame(minWidth: 150, maxWidth: .infinity, minHeight: 60, maxHeight: 80)
                    HStack {
                        VStack(alignment: .leading, spacing: 5){
                            Text("Explore the surroundings")
                                .bold()
                                .font(.system(size: 20))
                            Text("A new way to discover the world")
                                .font(.system(size: 14))
                        }
                        Spacer()
                        Image(systemName: "arrow.right.circle")
                    }
                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .font(.system(size: 24))
                    .foregroundColor(.black)
                }
            }
    }
}

#Preview {
    ExploreSurroundingsButtonView()
}
