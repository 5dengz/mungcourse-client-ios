import SwiftUI

public struct CommonDatePickerSheet: View {
    @Binding public var selection: Date
    public var onConfirm: (() -> Void)? = nil
    public var onDismiss: (() -> Void)? = nil
    public var title: String = "날짜 선택"
    public var confirmButtonTitle: String = "확인"
    public init(selection: Binding<Date>,
                onConfirm: (() -> Void)? = nil,
                onDismiss: (() -> Void)? = nil,
                title: String = "날짜 선택",
                confirmButtonTitle: String = "확인") {
        self._selection = selection
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
        self.title = title
        self.confirmButtonTitle = confirmButtonTitle
    }
    public var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 24)
            DatePicker(
                title,
                selection: $selection,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding()
            .tint(Color("main"))
            CommonFilledButton(title: confirmButtonTitle, action: {
                onConfirm?()
            })
            .padding(.horizontal)
            .padding(.bottom, 16)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 8) }
            Spacer()
        }
        .presentationDetents([.height(500)])
        .presentationCornerRadius(20)
        .onDisappear {
            onDismiss?()
        }
    }
}

#if DEBUG
struct CommonDatePickerSheet_Previews: PreviewProvider {
    static var previews: some View {
        struct PreviewWrapper: View {
            @State var date = Date()
            var body: some View {
                CommonDatePickerSheet(selection: $date) {}
            }
        }
        return PreviewWrapper()
    }
}
#endif

// 날짜 선택기를 모디파이어로 사용하기 위한 확장
extension View {
    func commonDatePickerSheet(
        isPresented: Binding<Bool>, 
        selection: Binding<Date>, 
        onConfirm: (() -> Void)? = nil, 
        onDismiss: (() -> Void)? = nil,
        title: String = "날짜 선택",
        confirmButtonTitle: String = "확인"
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            CommonDatePickerSheet(
                selection: selection,
                onConfirm: {
                    onConfirm?()
                    isPresented.wrappedValue = false
                },
                onDismiss: onDismiss,
                title: title,
                confirmButtonTitle: confirmButtonTitle
            )
        }
    }
}
