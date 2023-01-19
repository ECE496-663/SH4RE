////
////  RatingPicker.swift
////  SH4RE
////
////  Created by Americo on 2023-01-19.
////
////  Created with the help of the following tutorial:  https://www.hackingwithswift.com/books/ios-swiftui/adding-a-custom-star-rating-component
//
//
//
//import SwiftUI
//
//struct Segment {
//    let outerCenter: CGPoint
//    let outerAngle: Double
//    let outerRadius: Double
//    let innerCenter: CGPoint
//    let innerAngle: Double
//
//    var line: CGPoint {
//        get {
//            let pt = Cartesian(length: outerRadius, angle: outerStartAngle)
//            return CGPoint(x: pt.x + outerCenter.x, y: pt.y + outerCenter.y)
//        }
//    }
//
//    var line2: CGPoint {
//        get {
//            let pt = Cartesian(length: outerRadius, angle: innerStartAngle)
//            return CGPoint(x: pt.x + innerCenter.x, y: pt.y + innerCenter.y)
//        }
//    }
//
//    var outerStartAngle: Double {
//        get { self.outerAngle - (Double.pi * (0.45)) }
//    }
//    var outerEndAngle: Double {
//        get { self.outerAngle + (Double.pi * (0.45)) }
//    }
//
//    var innerStartAngle: Double {
//        get { self.innerAngle - (Double.pi * (0.7)) }
//    }
//    var innerEndAngle: Double {
//        get { self.innerAngle + (Double.pi * (0.7)) }
//    }
//}
//
//
//func Cartesian(length: Double, angle: Double) -> CGPoint {
//    return CGPoint(x: length * cos(angle),
//                   y: length * sin(angle))
//}
//
//struct StarShape: Shape {
//    var points = 5
//    var cornerRadius = 3.0
//    var isCutout = false
//    var isCircleOutline = false
//
//    func path(in rect: CGRect) -> Path {
//        // centre of the containing rect
//        var center = CGPoint(x: rect.width/2.0, y: rect.height/2.0)
//        // Adjust center down for odd number of sides less than 8
//        if points%2 == 1 && points < 8 && !isCircleOutline {
//            center = CGPoint(x: center.x, y: center.y * ((Double(points) * (-0.04)) + 1.3))
//        }
//
//        // radius of a circle that will fit in the rect with some padding
//        let outerRadius = (Double(min(rect.width,rect.height)) / 2.0) * 0.9
//        let innerRadius = outerRadius * 0.4
//        let offsetAngle = Double.pi * (-0.5)
//
//        var starSegments:[Segment] = []
//        for i in 0..<(points){
//            let angle1 = (2.0 * Double.pi/Double(points)) * Double(i)  + offsetAngle
//            let outerPoint = Cartesian(length: outerRadius, angle: angle1)
//            let angle2 = (2.0 * Double.pi/Double(points)) * (Double(i) + 0.5)  + offsetAngle
//            let innerPoint = Cartesian(length: (innerRadius), angle: (angle2))
//
//            let segment = Segment(
//                outerCenter: CGPoint(x: outerPoint.x + center.x,
//                                     y: outerPoint.y + center.y),
//                outerAngle: angle1,
//                outerRadius: cornerRadius,
//                innerCenter: CGPoint(x: innerPoint.x + center.x,
//                                     y: innerPoint.y + center.y),
//                innerAngle: angle2)
//            starSegments.append(segment)
//        }
//
//        let path = Path() { path in
//            if isCutout {
//                if isCircleOutline {
//                    path.addPath(Circle().path(in: rect))
//
//                } else {
//                    path.addPath(Rectangle().path(in: rect))
//                }
//            }
//            for (n, seg) in starSegments.enumerated() {
//                n == 0 ? path.move(to: seg.line) : path.addLine(to: seg.line)
//                path.addArc(center: seg.outerCenter,
//                            radius: seg.outerRadius,
//                            startAngle: Angle(radians: seg.outerStartAngle),
//                            endAngle: Angle(radians: seg.outerEndAngle),
//                            clockwise: false)
//                path.addLine(to: seg.line2)
//                path.addArc(center: seg.innerCenter,
//                            radius: seg.outerRadius,
//                            startAngle: Angle(radians: seg.innerStartAngle),
//                            endAngle: Angle(radians: seg.innerEndAngle),
//                            clockwise: true)
//            }
//            path.closeSubpath()
//        }
//        return path
//    }
//}
//
//
//struct StarRatingView: View {
//    @Binding var value: Double
//    var stars: Int = 5
//
//    @State var lastCoordinateValue: CGFloat = 0.0
//
//    var body: some View {
//        GeometryReader { gr in
//            let ratingWidth = gr.size.width * value / Double(stars)
//            let starWidth = gr.size.width / Double(stars)
//            let radius = starWidth * 0.01
//
//            let maxValue = gr.size.width
//            let scaleFactor = maxValue / Double(stars)
//
//            ZStack {
//                HStack(spacing:0) {
//                    Rectangle()
//                        .fill(.yellow)
//                        .frame(width: ratingWidth)
//                    Rectangle()
//                        .fill(.clear)
//                }
//
//                HStack(spacing:0) {
//                    ForEach(1...stars, id:\.self) { _ in
//                        StarShape(points: 5, cornerRadius: radius, isCutout: true)
//                            .fill(Color.gray, style: FillStyle(eoFill: true, antialiased: true))
//                            .frame(width: starWidth, height: gr.size.height, alignment: .center)
//                    }
//                }
//                .gesture(
//                    DragGesture(minimumDistance: 0)
//                        .onChanged { v in
//                            if (abs(v.translation.width) < 0.1) {
//                                self.lastCoordinateValue = v.location.x
//                            }
//                            if v.translation.width > 0 {
//                                let nextCoordinateValue = min(maxValue, self.lastCoordinateValue + v.translation.width)
//                                self.value = (nextCoordinateValue / scaleFactor)
//                            } else {
//                                let nextCoordinateValue = max(0.0, self.lastCoordinateValue + v.translation.width)
//                                self.value = (nextCoordinateValue / scaleFactor)
//                            }
//                        }
//                )
//            }
//        }
//    }
//}
//
//
//struct FiveStarView_Previews: PreviewProvider {
//
//    @State static var rating1 = 2.5
//        @State static var rating2 = 6.3
//        @State static var rating3 = 2.4
//        @State static var rating4 = 2.4
//    static var previews: some View {
//        ZStack {
//            Color(red: 214/255, green: 232/255, blue: 248/255)
//                .edgesIgnoringSafeArea(.all)
//
//            VStack(spacing:40) {
//                VStack(spacing:0) {
//                    Text("Star Rating = \(rating1, specifier: "%.1F") out of 5")
//                    StarRatingView(value: $rating1, stars: 5)
//                        .frame(width: 250, height: 50, alignment: .center)
//                }
//
//                VStack(spacing:0) {
//                    Text("Star Rating = \(rating2, specifier: "%.1F") out of 10")
//                    StarRatingView(value: $rating2, stars: 10)
//                        .frame(width: 250, height: 30, alignment: .center)
//                }
//
//                VStack(spacing:0) {
//                    Text("Star Rating = \(rating3, specifier: "%.1F") out of 3")
//                    StarRatingView(value: $rating3, stars: 3)
//                        .frame(width: 250, height: 100, alignment: .center)
//                }
//
//                HStack(spacing:10) {
//                    StarRatingView(value: $rating4, stars: 5)
//                        .frame(width: 200, height: 40, alignment: .center)
//                    Circle()
//                        .fill(.gray)
//                        .frame(width: 40, height: 40, alignment: .center)
//                        .overlay(
//                            Text("\(rating4, specifier: "%.1F")")
//                                .foregroundColor(.white)
//                                .fontWeight(.bold)
//                        )
//                }
//
//                Spacer()
//            }
//        }
//    }
//}

import SwiftUI


struct ratingPickerView: View {
    @Binding var rating: Int
    
    var maximumRating = 5
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color.gray
    var onColor = Color.yellow
    
    func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
    var body: some View {
        
        HStack {
            ForEach(1..<maximumRating + 1, id: \.self) { number in
                image(for: number)
                    .foregroundColor(number > rating ? offColor : onColor)
                    .onTapGesture {
                        rating = number
                    }
            }
        }
    }
}


struct RatingsView: View {
    let ratingsArray: [Double]
    let color: Color
    @Binding var rating: Double
    
    init(rating: Binding<Double>, maxRating: Int = 5, starColor: Color = .yellow) {
        _rating = rating
        ratingsArray = Array(stride(from: 0.0, through: Double(max(1, maxRating)), by: 0.5))
        color = starColor
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(ratingsArray, id: \.self) { ratingElement in
                    if ratingElement > 0 {
                        if Int(exactly: ratingElement) != nil && ratingElement <= rating {
                            Image(systemName: "star.fill")
                                .foregroundColor(color)
                        } else if Int(exactly: ratingElement) == nil && ratingElement == rating {
                            Image(systemName: "star.leadinghalf.fill")
                                .foregroundColor(color)
                        } else if Int(exactly: ratingElement) != nil && rating + 0.5 != ratingElement {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.gray)
                        }
                    }
                }
            }
            .overlay(
                GeometryReader { geometry in
                    Slider(value: $rating, in: 0.0...ratingsArray.last!, step: 0.5)
                        .tint(.clear)
                        .opacity(0.1)
                        .gesture(DragGesture(minimumDistance: 0).onChanged{ value in
                            let percent = min(max(0, Float(value.location.x / geometry.size.width * 1)), 1)
                            let newValue = (0.0...ratingsArray.last!).lowerBound + round(Double(percent) * (((0.0...ratingsArray.last!).upperBound - (0.0...ratingsArray.last!).lowerBound)*2))/2
                            $rating.wrappedValue = newValue
                            print(newValue)
                        })
                }
            )
        }
        .onAppear {
            rating = Int(exactly: rating) != nil ? rating : Double(Int(rating)) + 0.5
        }
    }
}


struct ratingPickerView_PreviewHelper: View {
    @State private var rating = 3
    @State private var ratingDoub = 3.2

    var body: some View {
        VStack {
            Text(String(rating))
            ratingPickerView(rating: self.$rating)
//            Spacer()
            RatingsView(rating: self.$ratingDoub)
//            Spacer()
            Text(String(ratingDoub))
        }

    }
}

struct FiveStarView_Previews: PreviewProvider {
    static var previews: some View {
        ratingPickerView_PreviewHelper()
    }
}
