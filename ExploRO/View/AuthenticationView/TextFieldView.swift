
import SwiftUI

struct TextFieldView: View {
    let fieldName: String
    @Binding var fieldData: String
    var body: some View {
        VStack{
            VStack(alignment: .leading){
                Text(fieldName)
                TextField(fieldName, text: $fieldData)
                    .padding()
                    .background(Color(red: 241/255.0, green: 241/255.0, blue: 241/255.0))
                    .clipShape(RoundedRectangle(cornerRadius: 15.0))
                    .shadow(radius: 2, x: 0, y: 4)
                
                
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    TextFieldView(fieldName: "Full Name", fieldData: .constant(""))
}
