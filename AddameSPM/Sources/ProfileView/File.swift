////
////  File.swift
////  
////
////  Created by Saroar Khandoker on 18.10.2021.
////
//
// import SwiftUI
// import SwiftUIExtension
//
// struct ImageSlider: View {
//
//    // 1
//    private let images = ["1", "2", "3", "4"]
//
//    var body: some View {
//        // 2
//        TabView {
//            ForEach(images, id: \.self) { item in
//                 // 3
//                 Image(item)
//                    .resizable()
//                    .scaledToFill()
//            }
//        }
//        .tabViewStyle(PageTabViewStyle())
//    }
// }
//
//// struct ImageSlider_Previews: PreviewProvider {
////    static var previews: some View {
////        // 4
////        ImageSlider()
////            .previewLayout(.fixed(width: 400, height: 300))
////    }
//// }
//
//// struct ContentView: View {
////    var body: some View {
////
////        // 1
////        NavigationView {
////            // 2
////            List {
////                ImageSlider()
////                    .frame(height: 300)
////                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
////            } //: List
////            .navigationBarTitle("Image Slider", displayMode: .large)
////        } //: Navigation View
////    }
////
//// }
//
// struct ContentView: View {
//    @State var index = 0
//
//    var images = ["person", "ant", "ladybug", "leaf"]
//
//    var body: some View {
//        VStack(spacing: 0) {
//            PagingView(index: $index.animation(), maxIndex: images.count - 1) {
//                ForEach(self.images, id: \.self) { imageName in
//                  Image(systemName: imageName)
//                        .resizable()
//                        .scaledToFit()
//                        .padding()
//                }
//            }
//            .aspectRatio(3 / 4, contentMode: .fit)
//            .background(Color.red)
//          Spacer()
//
////            PagingView(index: $index.animation(), maxIndex: images.count - 1) {
////                ForEach(self.images, id: \.self) { imageName in
////                    Image(systemName: imageName)
////                        .resizable()
////                        .scaledToFill()
////                }
////            }
////            .aspectRatio(3/4, contentMode: .fit)
////            .clipShape(RoundedRectangle(cornerRadius: 15))
//
////            Stepper("Index: \(index)", value: $index.animation(.easeInOut), in: 0...images.count-1)
////                .font(Font.body.monospacedDigit())
//        }
//    }
// }
////
//// struct ContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        ContentView()
////    }
//// }
