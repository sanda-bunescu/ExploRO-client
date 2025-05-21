import SwiftUI

struct LandmarkRecognitionView: View {
    @State private var showImagePicker = false
    @State private var image: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @StateObject private var viewModel = LandmarkPredictionViewModel()
    
    var body: some View {
        ZStack{
            Color(hex: "#E2F1E5").ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Upload or take a photo of a landmark. Our system will analyze it and give you detailed information including its label, address, and coordinates.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
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
                
                VStack{
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
                    NavigationLink("Start AR Mode") {
                        LandmarkARView()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }
                
                if image != nil {
                    Button(action: {
                        if let selectedImage = image {
                            Task {
                                await viewModel.uploadImage(selectedImage)
                                
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
                
                if let prediction = viewModel.prediction {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🏷 Label: \(prediction.label)")
                        Text("📍 Address: \(prediction.address ?? "N/A")").fixedSize(horizontal: false, vertical: true)
                        if let lat = prediction.lat, let lon = prediction.lon {
                            Button(action: {
                                let urlString = "http://maps.apple.com/?ll=\(lat),\(lon)"
                                if let url = URL(string: urlString) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "map")
                                    Text("Open in Maps")
                                }
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }

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
            .padding()
        }
        .navigationTitle("Landmark Recognition")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $image)
        }
        
    }
}


struct LandmarkARView: View {
    @State private var isCapturing = false
    @State private var infoText = ""
    @State private var predictionLabel = ""
    @State private var predictionLat: Double?
    @State private var predictionLon: Double?

    var body: some View {
        ZStack(alignment: .bottom) {
            ARCameraView()
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    NotificationCenter.default.addObserver(forName: .predictionResult, object: nil, queue: .main) { notification in
                        if let label = notification.userInfo?["label"] as? String {
                            predictionLabel = label
                        }
                        if let lat = notification.userInfo?["lat"] as? Double,
                           let lon = notification.userInfo?["lon"] as? Double {
                            predictionLat = lat
                            predictionLon = lon
                        }
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self, name: .predictionResult, object: nil)
                }

            VStack {
                Spacer()

                if !infoText.isEmpty {
                    Text(infoText)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                }

                if !predictionLabel.isEmpty {
                    VStack(spacing: 10) {
                        Text("Prediction: \(predictionLabel)")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.yellow)
                            .cornerRadius(10)

                        if let lat = predictionLat, let lon = predictionLon, lat != 0.0, lon != 0.0  {
                            Button(action: {
                                let urlString = "http://maps.apple.com/?ll=\(lat),\(lon)"
                                if let url = URL(string: urlString) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "map")
                                    Text("Open in Maps")
                                }
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                            }
                        } else {
                            Text("⚠️ No valid location available.")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.bottom, 20)
                }

                Button(action: {
                    startCapture()
                }) {
                    Text(isCapturing ? "Capturing..." : "Detect Landmark")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isCapturing ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(isCapturing)
            }
        }
    }

    func startCapture() {
        infoText = "Hold still for 2 seconds..."
        predictionLabel = ""
        predictionLat = nil
        predictionLon = nil
        isCapturing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NotificationCenter.default.post(name: .captureARImage, object: nil)
            infoText = ""
            isCapturing = false
        }
    }
}



#Preview {
    LandmarkRecognitionView()
}
