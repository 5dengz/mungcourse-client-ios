import SwiftUI
import PhotosUI // Import PhotosUI

// MARK: - Reusable Subviews (Helper Components)

struct ProfileImageView: View {
    @Binding var image: Image?
    @Binding var selectedImageData: Data?
    var objectKey: String?
    @ObservedObject var viewModel: RegisterDogViewModel
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isDeleting: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(Color("gray100")) // Use asset color
                .frame(width: 127, height: 127)
                .overlay(alignment: .center) {
                    // Display selected image or placeholder
                    if let img = image {
                        img
                            .resizable()
                            .scaledToFill()
                            .frame(width: 127, height: 127) // Ensure frame is applied
                            .clipShape(Circle())
                    } else {
                        Image("profile_empty") // Placeholder icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 127, height: 127)
                    }
                }

            if image == nil {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        Circle()
                            .fill(Color("gray600"))
                            .frame(width: 34, height: 34)
                        Image("icon_camera")
                            .foregroundColor(Color("pointwhite"))
                            .font(.system(size: 16))
                    }
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            if let uiImage = UIImage(data: data) {
                                image = Image(uiImage: uiImage)
                            }
                        }
                    }
                }
            } else {
                Button(action: {
                    guard let objectKey = objectKey else {
                        image = nil
                        selectedImageData = nil
                        return
                    }
                    isDeleting = true
                    errorMessage = nil
                    viewModel.deleteProfileImageS3(objectKey: objectKey) { success in
                        isDeleting = false
                        if success {
                            image = nil
                            selectedImageData = nil
                        } else {
                            errorMessage = viewModel.errorMessage?.message ?? "이미지 삭제 실패"
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color("gray400"))
                            .frame(width: 32, height: 32)
                        Image(systemName: "trash")
                            .foregroundColor(Color("pointwhite"))
                            .font(.system(size: 16))
                    }
                }
                
            }
        }
        .padding(.vertical)
        .overlay(
            Group {
                if isDeleting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 32, height: 32)
                        .offset(x: 40, y: 40)
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(Color("pointRed"))
                        .font(.caption)
                        .padding(.top, 4)
                        .multilineTextAlignment(.center)
                }
            }
        )
    }
}


#Preview {
    // Define @State variable correctly within the Preview scope
    struct PreviewWrapper: View {
        @State var previewImage: Image? = nil // Or provide a default image like Image(systemName: "pawprint.fill")
        @State var imageData: Data? = nil // Add state for data in preview
        let viewModel = RegisterDogViewModel()
        var body: some View {
            ProfileImageView(
                image: $previewImage,
                selectedImageData: $imageData,
                objectKey: nil,
                viewModel: viewModel
            )
            .padding()
        }
    }
    return PreviewWrapper() // Return the wrapper view
} 