
import SwiftUI

struct ProfileRow<Destination: View>: View {
    var icon: String
    var color: Color
    var title: String
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(color)
                    )
                
                Text(title)
                    .font(.system(size: 16))
                    .padding(.leading, 5)
                    .foregroundStyle(Color.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

#Preview {
    ProfileRow(icon: "person.circle", color: .blue, title: "My Profile", destination: MyProfileView())
}
