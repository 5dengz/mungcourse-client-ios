import SwiftUI
import PhotosUI // Import PhotosUI

// MARK: - Reusable Subviews (Helper Components)

struct ProfileImageView: View {
    @Binding var image: Image?
    @Binding var selectedImageData: Data? // Add binding for image data
    @State private var selectedItem: PhotosPickerItem? = nil // State for the picker item

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
                            .foregroundColor(.white)
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
                    image = nil
                    selectedImageData = nil
                }) {
                    ZStack {
                        Circle()
                            .fill(Color("gray400"))
                            .frame(width: 32, height: 32)
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                }
                
            }
        }
        .padding(.vertical) // Add some vertical padding
    }
}

#Preview {
    // Define @State variable correctly within the Preview scope
    struct PreviewWrapper: View {
        @State var previewImage: Image? = nil // Or provide a default image like Image(systemName: "pawprint.fill")
        @State var imageData: Data? = nil // Add state for data in preview

        var body: some View {
            ProfileImageView(image: $previewImage, selectedImageData: $imageData) // Pass the data binding
                .padding()
        }
    }
    return PreviewWrapper() // Return the wrapper view
} 