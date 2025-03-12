import SwiftUI

struct ViewItinerariesView: View {
    var body: some View {
            Image("Intro")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding(.bottom)
                .overlay{
                    VStack{
                        Spacer()
                        Button {
                            print("Button tapped")
                        } label: {
                            VStack {
                                HStack {
                                    Text("View your itineraries >")
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
                }
            .frame(maxWidth: .infinity)
        
    }
}

#Preview {
    ViewItinerariesView()
}
