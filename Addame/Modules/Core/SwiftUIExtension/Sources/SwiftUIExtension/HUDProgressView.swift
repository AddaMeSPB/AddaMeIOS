//
//  HUDProgressView.swift
//  
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import SwiftUI

public struct HUDProgressView: View {
  public var placeHolder: String
  @Binding public var show: Bool
  @State public var animate = false
  @Environment(\.colorScheme) var colorScheme
  
  public init(placeHolder: String, show: Binding<Bool>) {
    self.placeHolder = placeHolder
    self._show = show
  }
  
  public var body: some View {
    VStack {
      Circle()
        .stroke(AngularGradient(gradient: .init(colors: [Color(.systemBlue), Color.primary.opacity(0)]), center: .center))
        .frame(width: 80, height: 80)
        .rotationEffect(.init(degrees: animate ? 360 : 0))
      
      Text(placeHolder)
        .fontWeight(.bold)
        .foregroundColor(colorScheme == .dark ? .white : .black)
      
    }
    .padding(.vertical, 25)
    .padding(.horizontal, 35)
//    .background(BlueView())
    .cornerRadius(20)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      Color.clear
        .onTapGesture {
          withAnimation {
            show.toggle()
          }
        }
    )
    .onAppear {
      withAnimation(
        Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
      ) {
        animate.toggle()
      }
    }
  }
}

public struct BlueView: UIViewRepresentable {
  public func makeUIView(context: Context) -> some UIView {
    let effect = UIBlurEffect(style: .extraLight)
    let view = UIVisualEffectView(effect: effect)
    return view
  }
  
  public func updateUIView(_ uiView: UIViewType, context: Context) {}
}


