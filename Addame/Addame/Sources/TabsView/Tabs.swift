public enum Tabs: Int, CaseIterable, Equatable {
  case event
  case conversation
  case profile
}

extension Tabs: Identifiable {
  public var id: Int { rawValue }
}
