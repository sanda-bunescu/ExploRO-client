import SwiftUI

struct LandmarkRecognitionView: View {
    @State private var showImagePicker = false
    @State private var image: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @StateObject private var viewModel = LandmarkPredictionViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Image Preview or Placeholder
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                        Text("No image selected")
                            .foregroundColor(.secondary)
                    }
                }
            }

            // MARK: - Action Buttons
            HStack(spacing: 16) {
                Button(action: {
                    sourceType = .camera
                    showImagePicker = true
                }) {
                    Label("Take Photo", systemImage: "camera")
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                Button(action: {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }) {
                    Label("Choose Photo", systemImage: "photo")
                }
                .buttonStyle(.bordered)
            }

            // MARK: - Upload Button
            if image != nil {
                Button(action: {
                    if let selectedImage = image {
                        Task {
                            await viewModel.uploadImage(selectedImage)
                            
                            // Logic: clear opposite message
                            if viewModel.prediction != nil {
                                viewModel.errorMessage = nil
                            } else if viewModel.errorMessage != nil {
                                viewModel.prediction = nil
                            }
                        }
                    }
                }) {
                    Label("Send to Backend", systemImage: "paperplane")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.top, 10)
            }

            // MARK: - Results
            if let prediction = viewModel.prediction {
                VStack(alignment: .leading, spacing: 6) {
                    Text("🏷 Label: \(prediction.label)")
                    Text("📍 Address: \(prediction.address ?? "N/A")")
                    Text("🌐 Coordinates: \(prediction.lat ?? 0.0), \(prediction.lon ?? 0.0)")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }

            if let error = viewModel.errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }

            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $image)
        }
        .padding()
        .navigationTitle("Landmark Recognition")
    }
}


#Preview {
    LandmarkRecognitionView()
}
