//
//  DropdownMenu.swift
//  SH4RE
//
//  Created by Americo on 2023-01-22.
//

import SwiftUI


struct DropdownStyle: DisclosureGroupStyle {
    let button: some View = Image(systemName: "chevron.up")
        .fontWeight(.medium)
        .foregroundColor(.black)
    var border: some View {
      RoundedRectangle(cornerRadius: 8)
        .strokeBorder(
            .gray,
          lineWidth: 1
        )
    }
    func makeBody(configuration: Configuration) -> some View {
        ZStack (alignment: .topLeading){
            if configuration.isExpanded {
                VStack {
                    //Spacer makes the drop down content visible from behind main label
                    Spacer().frame(height: 52)
                    configuration.content
                }
                
                .disclosureGroupStyle(self)
                .background(border)
                .background(.white)
                .cornerRadius(8)
            }
            HStack {
                configuration.label
                Spacer()
                button
                    .rotationEffect(.degrees(configuration.isExpanded ? 180 : 0))
            }
            // Text alignment.
            .multilineTextAlignment(.leading)
            // Cursor color.
            .accentColor(.primaryDark)
            // Text color.
            .foregroundColor(.black)
            // TextField spacing.
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            // TextField border
            .background(border)
            .background(.white)
            .cornerRadius(8)
            
            
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            }
        }
    }
}

struct DropdownMenu: View {
    var label: String
    var options: Array<String>
    @Binding var selection: String
    var useClear: Bool = false
    var clearValue: String = ""
    @State var expanded: Bool = true
    var body: some View {
        DisclosureGroup(selection == clearValue ? label : selection, isExpanded: $expanded) {
            ScrollView{
                if (useClear){
                    Divider().opacity(0)
                    HStack{
                        Text("Clear")
                    }
                    //The frame is to make the whole width of the button clickable
                    .frame(maxWidth: screenSize.width)
                    //The frame alone is not enough, to make the frame clickable, a background must be added
                    .background(Color.white.opacity(0.001))
                    .onTapGesture {
                        selection = clearValue
                        withAnimation {
                            expanded.toggle()
                        }
                    }
                    Divider()
                }
                ForEach(options, id: \.self){ category in
                    HStack{
                        Text(category)
                            .scaledToFill()
                    }
                    .frame(maxWidth: screenSize.width)
                    .background(Color.white.opacity(0.001))
                    .onTapGesture {
                        selection = category
                        withAnimation {
                            expanded.toggle()
                        }
                    }
                    Divider()
                }
            }
            .frame(maxHeight: 140)
        }.disclosureGroupStyle(DropdownStyle())
    }
}



struct DropdownMenu_PreviewsHelper: View {
    @State var dropDownSelection:String = ""
    var body: some View {
        DropdownMenu(label: "Categories", options: ["op1","op2","op3","op4","op5"], selection: $dropDownSelection, useClear: true, clearValue: "")
    }
}

struct DropdownMenu_Previews: PreviewProvider {
    static var previews: some View {
        DropdownMenu_PreviewsHelper()
    }
}
