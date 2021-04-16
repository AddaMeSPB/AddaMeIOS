
public enum Tabs: Int, CaseIterable, Equatable {
  case event
  case chat
  case profile
}

extension Tabs: Identifiable {
  public var id: Int { rawValue }
}
