//
//  ImagePickerViewRepresentable.swift
//  
//
//  Created by Saroar Khandoker on 11.10.2021.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
import Combine
import UIKit

extension PHPickerResult {
  public struct ImageError: Error {
    let message: String
  }

    func loadImage() async throws -> UIImage {
        let itemProvider = self.itemProvider
        itemProvider.canLoadObject(ofClass: UIImage.self)

        return try await withCheckedThrowingContinuation { continuation in
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let error = error {
                    continuation.resume(throwing: ImageError(message: "\(error.localizedDescription) Asset is not an image."))
                } else if let image = image as? UIImage {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: ImageError(message: "The loaded object is not a UIImage."))
                }
            }
        }
    }

}

public struct ImagePickerReducer: Reducer {
    public struct State: Equatable {
      public var showingImagePicker: Bool
      public var image: UIImage?

      public init(showingImagePicker: Bool, image: UIImage? = nil) {
        self.showingImagePicker = showingImagePicker
        self.image = image
      }
    }

    public enum Action: Equatable {
        public static func == (lhs: ImagePickerReducer.Action, rhs: ImagePickerReducer.Action) -> Bool {
        return lhs.value == rhs.value
      }

      // only for Equatable
      var value: String? {
        return String(describing: self).components(separatedBy: "(").first
      }

      case setSheet(isPresented: Bool)

      case imagePicked(image: UIImage)

      case pickerResultReceived(result: PHPickerResult)
      case picked(result: Result<UIImage, PHPickerResult.ImageError>)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .setSheet(isPresented: presented):
              state.showingImagePicker = presented
              return .none

            case let .imagePicked(image: image):
              state.image = image
              return .none

            case let .pickerResultReceived(result: result):

                    return .run { send in
                        if let image = try? await result.loadImage() {
                            await send(.imagePicked(image: image))
                        } else {
                            
                        }
                    }

//                    result.loadImage()
//                .receive(on: DispatchQueue.main)
//                .catchToEffect(ImagePickerReducer.Action.picked(result:))

            case let .picked(result: .success(image)):
              state.image = image
              return .none

            case .picked(result: .failure):
              return .none
            }
        }
    }
}

public struct ImagePickerView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentationMode

    let viewStore: ViewStoreOf<ImagePickerReducer>

    public init(store: StoreOf<ImagePickerReducer>) {
        self.viewStore = ViewStore(store, observe: { $0 })
    }

  public func makeUIViewController(
    context: UIViewControllerRepresentableContext<ImagePickerView>
  ) -> some UIViewController {
    var config = PHPickerConfiguration()
    config.filter = PHPickerFilter.images
    config.selectionLimit = 1

    let picker = PHPickerViewController(configuration: config)
    picker.delegate = context.coordinator
    return picker
  }

  public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public class Coordinator: PHPickerViewControllerDelegate {
    let parent: ImagePickerView

    init(_ parent: ImagePickerView) {
      self.parent = parent
    }

    public func picker(
      _ picker: PHPickerViewController,
      didFinishPicking results: [PHPickerResult]
    ) {

      guard let result = results.first else {
        parent.viewStore.send(
          .picked(result: .failure(.init(message: "No image picked. or cancel button click")))
        )
        parent.presentationMode.wrappedValue.dismiss()
        return
      }

      parent.viewStore.send(.pickerResultReceived(result: result))

    }
  }
}

extension NSItemProvider {

    func loadObject<Object: NSItemProviderReading>(
      of type: Object.Type,
      completionHandler: @escaping (Result<Object, Error>) -> Void) {
        self.loadObject(ofClass: type) { object, error in
            if let error = error {
                completionHandler(.failure(error))
            } else if let object = object as? Object {
                completionHandler(.success(object))
            } else {
                let error = NSError(
                  domain: NSItemProvider.errorDomain,
                  code: NSItemProvider.ErrorCode.unknownError.rawValue)
                completionHandler(.failure(error))
            }
        }
    }

    func loadObjectPublisher<Object: NSItemProviderReading>(of type: Object.Type) -> AnyPublisher<Object, Error> {
        let subject = PassthroughSubject<Object, Error>()

        self.loadObject(of: type) { result in
            switch result {
            case .success(let object):
                subject.send(object)
            case .failure(let error):
                subject.send(completion: .failure(error))
            }
        }

        return subject.eraseToAnyPublisher()
    }
}
