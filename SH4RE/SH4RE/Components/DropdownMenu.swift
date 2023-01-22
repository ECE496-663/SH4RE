//
//  DropdownMenu.swift
//  SH4RE
//
//  Created by Americo on 2023-01-22.
//

import SwiftUI

struct CustomDisclosureGroupStyle: DisclosureGroupStyle {
    let button: some View = Image(systemName: "chevron.up")
        .fontWeight(.medium)
        .foregroundColor(.black)
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            button
                .rotationEffect(.degrees(configuration.isExpanded ? 180 : 0))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        }
        if configuration.isExpanded {
            configuration.content
            //                .padding()//.leading, 30)
                .disclosureGroupStyle(self)
        }
    }
}

struct DropdownMenu: View {
    var label: String
    var options: Array<String>
    @Binding var selection: String
    var useClear: Bool = false
    var clearValue: String = ""
    @State var expanded: Bool = false
    var body: some View {
        GroupBox{
            DisclosureGroup(selection == clearValue ? label : selection, isExpanded: $expanded) {
                ScrollView{
                    if (useClear){
                        Divider()
                        HStack{
                            Text("Clear")
                        }
                        .onTapGesture {
                            selection = clearValue
                            withAnimation {
                                expanded.toggle()
                            }
                        }
                    }
                    ForEach(options, id: \.self){ category in
                        Divider()
                        HStack{
                            Text(category)
                        }
                        .onTapGesture {
                            selection = category
                            withAnimation {
                                expanded.toggle()
                            }
                        }
                    }
                }
                .frame(maxHeight: 140)
            }.disclosureGroupStyle(CustomDisclosureGroupStyle())
        }
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
