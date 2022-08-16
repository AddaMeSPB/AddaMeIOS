import Foundation

extension JSONDecoder {
  public static let iso8601: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()
}
