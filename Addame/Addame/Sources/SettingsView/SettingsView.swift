//
//  SwiftUIView.swift
//  
//
//  Created by Saroar Khandoker on 09.04.2021.
//

import SwiftUI
import KeychainService

public struct SettingsView: View {

//  @EnvironmentObject var uvm: UserViewModel
  @AppStorage(AppUserDefaults.Key.distance.rawValue) var distance: Double = 250.0

  @State private var showingTermsSheet = false
  @State private var showingPrivacySheet = false

  public var body: some View {
    Text("Hello Setting")
//    VStack(alignment: .leading, spacing: 20) {
//
//      Text("Settings")
//        .font(.title)
//        .bold()
//        .padding()
//
//      DistanceFilterView(distance: self.$distance)
//        .padding([.top, .bottom], 20)
//        .transition(.opacity)
//
//      HStack {
//        Spacer()
//        Button(action: {
//          showingTermsSheet = true
//        }, label: {
//          Text("Terms")
//            .font(.title)
//            .bold()
//            .foregroundColor(.blue)
//        })
//        .sheet(isPresented: $showingTermsSheet) {
//          TermsAndPrivacyWebView(urlString: "" + "/terms") // EnvironmentKeys.rootURL.absoluteString
//        }
//
//        Text("&")
//          .font(.title3)
//          .bold()
//          .padding([.leading, .trailing], 10)
//
//        Button(action: {
//          showingPrivacySheet = true
//        }, label: {
//          Text("Privacy")
//            .font(.title)
//            .bold()
//            .foregroundColor(.blue)
//        })
//        .sheet(isPresented: $showingPrivacySheet) {
//          TermsAndPrivacyWebView(urlString: "" + "/privacy") // EnvironmentKeys.rootURL.absoluteString
//        }
//
//        Spacer()
//      }
//      //.frame(width: .infinity, height: 100, alignment: .center)
//      .background(Color.yellow)
//      .clipShape(Capsule.init())
//      .padding()
//
//      Spacer()
//
//    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}

public struct DistanceFilterView: View {

  @Binding var distance: Double
  @AppStorage(AppUserDefaults.Key.distance.rawValue) var distanceValue: Double = 250.0

  var minDistance = 5.0
  var maxDistance = 250.0

  public var body: some View {
    VStack(alignment: .leading) {

      Text("Near by distance \(Int(distance)) km")
        .font(.title3)
        .bold()
        .onChange(of: "Value"/*@END_MENU_TOKEN@*/, perform: { _ in
          distanceValue = distance
        })
        .font(.system(.headline, design: .rounded))

      HStack {
        Slider(
          value: $distance,
          in: minDistance...maxDistance,
          step: 1, onEditingChanged: {
          changing in self.update(changing)

          })
        .accentColor(.green)
      }

      HStack {
        Text("\(Int(minDistance))")
          .font(.system(.footnote, design: .rounded))

        Spacer()

        Text("\(Int(maxDistance))")
          .font(.system(.footnote, design: .rounded))
      }

    }
    .onAppear {
      update(true)
    }
    .padding(.horizontal)
    .padding(.bottom, 10)
  }

  func update(_ changing: Bool) {
    distanceValue = distance == 0 ? 249 : distance
  }

}

struct DistanceFilterView_Previews: PreviewProvider {
  static var previews: some View {
    DistanceFilterView(distance: .constant(250))
  }
}
