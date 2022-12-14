//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/17/22.
//

import SwiftUI
import STools

///MediaUI: Type erased Image.
public struct AnyImage: View {
//MARK: - Properties
    public static var empty = AnyImage()
    public var data: Data?
    public var image: Image?
    public var unImage: UNImage?
//MARK: - View
    public var body: some View {
        image ?? Image("photo.fill")
    }
}

//MARK: - Public Initializers
public extension AnyImage {
///MediaUI: Craetes Image, UNImage & View from some Data.
    init(_ data: Data?) {
        guard let data = data else {return}
        self.data = data
        self.unImage = UNImage(data: data)
        if let unImage = unImage {
            self.image = Image(unImage: unImage)
        }else {
            self.image = nil
        }
    }
///MediaUI: Creates Data, UNImage & View from an Image.
    init(_ image: Image?) {
        guard let image = image else {return}
        self.image = image
        self.unImage = image.unImage
        self.data = unImage?.asData(.high)
    }
///MediaUI: Creates Data, Image & View from an UNImage.
    init(_ unImage: UNImage?) {
        guard let unImage = unImage else {return}
        self.unImage = unImage
        self.image = Image(unImage: unImage)
        self.data = unImage.asData(.high)
    }
}

//MARK: - Equatable
extension AnyImage: Equatable {
    public static func ==(lhs: AnyImage, rhs: AnyImage) -> Bool {
        return lhs.data == rhs.data
    }
}

//MARK: - Hashable
extension AnyImage: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(data ?? Data())
    }
}
