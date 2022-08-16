import Foundation

extension String {
    public var urlOptional: URL? {
        return URL(string: self)
    }

    public var url: URL {
        return URL(string: self)!
    }
}
