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

extension PHPickerResult {
  public struct ImageError: Error {
    let message: String
  }

  func loadImage() -> Future<UIImage, ImageError> {
    return Future { promise in
      guard case let itemProvider = self.itemProvider,
        itemProvider.canLoadObject(ofClass: UIImage.self)
      else {
        return promise(.failure(ImageError(message: "Unable to load image.")))
      }

      itemProvider.loadObject(of: UIImage.self) { result in
        switch result {
        case let .success(image):
          return promise(.success(image))
        case let .failure(error):
          return promise(.failure(
            ImageError(message: "\(error.localizedDescription) Asset is not an image.")
          ))
        }
      }
    }
  }
}

public struct ImagePickerReducer: ReducerProtocol {
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

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .setSheet(isPresented: presented):
              state.showingImagePicker = presented
              return .none

            case let .imagePicked(image: image):
              state.image = image
              return .none

            case let .pickerResultReceived(result: result):

              return result.loadImage()
                .receive(on: DispatchQueue.main)
                .catchToEffect(ImagePickerReducer.Action.picked(result:))

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
        self.viewStore = ViewStore(store)
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
