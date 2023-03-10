// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import GoogleMaps
import SwiftUI

/// The root view of the application displaying a map that the user can interact with and a
/// button where the user
struct MapViewBase: View {
    
  @State var zoomInCenter: Bool = false
  @State var expandList: Bool = false
  @State var selectedMarker: GMSMarker?
  @State var yDragTranslation: CGFloat = 0

  var body: some View {

    let scrollViewHeight: CGFloat = 80

    GeometryReader { geometry in
      ZStack(alignment: .top) {
        // Map
        let diameter = zoomInCenter ? geometry.size.width : (geometry.size.height * 2)
        MapViewControllerBridge(onAnimationEnded: {
          self.zoomInCenter = true
        }, mapViewWillMove: { (isGesture) in
          guard isGesture else { return }
          self.zoomInCenter = false
        })
        .clipShape(
          Circle()
            .size(
              width: diameter,
              height: diameter
            )
            .offset(
              CGPoint(
                x: (geometry.size.width - diameter) / 2,
                y: (geometry.size.height - diameter) / 2
              )
            )
        )
        .animation(.easeIn)
        .background(Color(red: 254.0/255.0, green: 1, blue: 220.0/255.0))
      }
    }
  }
}

struct MapViewBase_Previews: PreviewProvider {
    static var previews: some View {
        MapViewBase()
    }
}
