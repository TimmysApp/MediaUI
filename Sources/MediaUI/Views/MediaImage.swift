//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/17/22.
//
#if canImport(UIKit) || canImport(Charts)
import SwiftUI
import PhotosUI
import STools

///MediaUI: A MediaImage is a View that displays a default Image which can be tapped in order to present a PhotosPicker & dynamically display the picked Image in a Downsampled style.
@available(iOS 16.0, macOS 13.0, *)
public struct MediaImage<Media: Mediable>: View {
//MARK: - Properties
    @Binding private var overridenPickerItem: PhotosPickerItem?
    @Binding private var mediable: Media
    @State private var presentable = PresentableMedia()
    private var overridePicker = false
    private let disabledPicker: Bool
    public var settings = ImageSettings()
//MARK: - View
    public var body: some View {
        Button(action: {
            presentable.isPresented.toggle()
        }) {
            if let mediable = mediable, mediable.data != Data() {
                DownsampledImage(media: mediable, settings: settings)
            }else {
                switch presentable.mediaState {
                    case .failure(let error):
                        Text(error.localizedDescription)
                    case .loading:
                        ProgressView()
                    case .success(let anyImage):
                        DownsampledImage(image: anyImage.unImage, settings: settings)
                    default:
                        settings.placeHolder
                }
            }
        }.disabled(disabledPicker)
        .stateModifier(overridePicker) { view in
            view
                .onChange(of: overridenPickerItem) { newValue in
                    updateState(pickerItem: newValue)
                }
        }.stateModifier(!overridePicker) { view in
            view
                .photosPicker(isPresented: $presentable.isPresented, selection: $presentable.pickerItem, matching: .images)
                .onChange(of: presentable.pickerItem) { newValue in
                    updateState(pickerItem: newValue)
                }
        }
    }
}

//MARK: - Public Initializer
@available(iOS 16.0, macOS 13.0, *)
public extension MediaImage {
///MediaUI: Initialize a DownsampledImage from a Mediabley, or a Binding one.
    init(mediable: Binding<Media>) {
        self._mediable = mediable
        self.disabledPicker = false
        self.overridePicker = false
        self._overridenPickerItem = .constant(nil)
    }
}

//MARK: - Private Initializer
@available(iOS 16.0, macOS 13.0, *)
private extension MediaImage {
    init(mediable: Binding<Media>, height: CGFloat?, width: CGFloat?, squared: Bool, aspectRatio: (CGFloat?, ContentMode)?, resizable: Bool, disabled: Bool, content: AnyView?, item: Binding<PhotosPickerItem?>, override: Bool) {
        self._mediable = mediable
        self.disabledPicker = disabled
        self.overridePicker = override
        self._overridenPickerItem = item
        self.settings = ImageSettings(height: height, width: width, placeHolder: content, squared: squared, resizable: resizable, aspectRatio: aspectRatio)
    }
}

//MARK: - Private Functions
@available(iOS 16.0, macOS 13.0, *)
private extension MediaImage {
    func updateState(pickerItem: PhotosPickerItem?) {
        presentable.mediaState = .loading
        guard let pickerItem = pickerItem else {return}
        Task {
            do {
                guard let image = try await pickerItem.loadTransferable(type: Data.self) else {
                    return
                }
                DispatchQueue.main.async { [self] in
                    withAnimation() {
                        self.mediable.data = image
                        self.presentable.mediaState = .success(AnyImage(image))
                    }
                }
            }catch {
                DispatchQueue.main.async { [self] in
                    withAnimation() {
                        self.presentable.mediaState = .failure(error)
                    }
                }
            }
        }
    }
}

//MARK: - Public Modifiers
@available(iOS 16.0, macOS 13.0, *)
public extension MediaImage {
///MediaImage: Make the Image take the Shape of a square.
    func squaredImage() -> Self {
        MediaImage(mediable: $mediable, height: settings.height, width: settings.width, squared: true, aspectRatio: settings.aspectRatio, resizable: settings.resizable, disabled: disabledPicker, content: settings.placeHolder, item: $overridenPickerItem, override: overridePicker)
    }
////MediaImage: Sets the mode by which SwiftUI resizes an Image to fit it's space.
    func isResizable() -> Self {
        MediaImage(mediable: $mediable, height: settings.height, width: settings.width, squared: settings.squared, aspectRatio: settings.aspectRatio, resizable: true, disabled: disabledPicker, content: settings.placeHolder, item: $overridenPickerItem, override: overridePicker)
    }
///MediaImage: Constrains this View's dimesnions to the specified aspect rario.
    func aspect(_ ratio: CGFloat? = nil, contentMode: ContentMode) -> Self {
        MediaImage(mediable: $mediable, height: settings.height, width: settings.width, squared: settings.squared, aspectRatio: (ratio, contentMode), resizable: settings.resizable, disabled: disabledPicker, content: settings.placeHolder, item: $overridenPickerItem, override: overridePicker)
    }
///MediaImage: Positions this View within an invisible frame with the specified size.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        MediaImage(mediable: $mediable, height: height, width: width, squared: settings.squared, aspectRatio: settings.aspectRatio, resizable: settings.resizable, disabled: disabledPicker, content: settings.placeHolder, item: $overridenPickerItem, override: overridePicker)
    }
///MediaImage: Adds a placeholder View if no Image can be displayed.
    func placeHolder(@ViewBuilder placeholder: () -> some View) -> Self {
        MediaImage(mediable: $mediable, height: settings.height, width: settings.width, squared: settings.squared, aspectRatio: settings.aspectRatio, resizable: settings.resizable, disabled: disabledPicker, content: AnyView(placeholder()), item: $overridenPickerItem, override: overridePicker)
    }
///MediaImage: Disables the PhotosPicker button.
    func disabledPicker(_ disabled: Bool = true) -> Self {
        MediaImage(mediable: $mediable, height: settings.height, width: settings.width, squared: settings.squared, aspectRatio: settings.aspectRatio, resizable: settings.resizable, disabled: disabled, content: settings.placeHolder, item: $overridenPickerItem, override: overridePicker)
    }
    func using(item: Binding<PhotosPickerItem?>) -> Self {
        MediaImage(mediable: $mediable, height: settings.height, width: settings.width, squared: settings.squared, aspectRatio: settings.aspectRatio, resizable: settings.resizable, disabled: disabledPicker, content: settings.placeHolder, item: item, override: true)
    }
}
#endif
