import SwiftUI

// MARK: - Reusable Subviews (Helper Components)

struct ProfileImageView: View {
    @Binding var image: Image?
    // TODO: Add logic to present image picker
    
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
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "photo.fill") // Placeholder icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .foregroundColor(Color("gray400"))
                    }
                }

            Button {
                // TODO: Add action to show image picker
                print("Select image tapped")
            } label: {
                ZStack {
                    Circle()
                        .fill(Color("gray600")) // Use asset color
                        .frame(width: 34, height: 34)
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
            }
            .offset(x: 5, y: 5) // Adjust offset slightly
        }
        .padding(.vertical) // Add some vertical padding
    }
}

#Preview {
    // Define @State variable correctly within the Preview scope
    struct PreviewWrapper: View {
        @State var previewImage: Image? = nil // Or provide a default image like Image(systemName: "pawprint.fill")
        
        var body: some View {
            ProfileImageView(image: $previewImage)
                .padding()
        }
    }
    return PreviewWrapper() // Return the wrapper view
} 