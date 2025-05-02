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

            // Integrate PhotosPicker with the existing button's appearance
            PhotosPicker(
                selection: $selectedItem,
                matching: .images, // Only allow images
                photoLibrary: .shared() // Use the shared photo library
            ) {
                // Use the existing button label content
                ZStack {
                    Circle()
                        .fill(Color("gray600")) // Use asset color
                        .frame(width: 34, height: 34)
                    Image("icon_camera")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
            }
            // Add task modifier to handle selection change
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    // Retrieve image data
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data // Update the bound data
                        if let uiImage = UIImage(data: data) {
                            image = Image(uiImage: uiImage) // Update the preview image
                        }
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