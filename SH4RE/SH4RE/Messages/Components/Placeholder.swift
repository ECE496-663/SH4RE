//
//  Placeholder.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-02-09.
//

import SwiftUI

struct Placeholder: View {
    var body: some View {
        HStack {
            Text("Message")
                .keyboardType(.numberPad)
                .foregroundColor(.darkGrey)
                .font(.body)
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}
