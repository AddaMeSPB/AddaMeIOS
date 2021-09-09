//
//  Shape+Extension.swift
//
//
//  Created by Saroar Khandoker on 13.04.2021.
//

import SwiftUI

public struct CornerRadiusStyle: ViewModifier {
  var radius: CGFloat
  var corners: UIRectCorner

  public struct CornerRadiusShape: Shape {
    var radius = CGFloat.infinity
    var corners = UIRectCorner.allCorners

    public func path(in rect: CGRect) -> Path {
      let path = UIBezierPath(
        roundedRect: rect,
        byRoundingCorners: corners,
        cornerRadii: CGSize(width: radius, height: radius)
      )
      return Path(path.cgPath)
    }
  }

  public func body(content: Content) -> some View {
    content
      .clipShape(CornerRadiusShape(radius: radius, corners: corners))
  }
}

extension View {
  public func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
    ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
  }
}

public struct AnyShape: Shape {
  public init<S: Shape>(_ wrapped: S) {
    _path = { rect in
      print("rect=\(rect)")
      let path = wrapped.path(in: rect)
      print("path=\(path)")
      return path
    }
  }

  public func path(in rect: CGRect) -> Path {
    return _path(rect)
  }

  private let _path: (CGRect) -> Path
}
