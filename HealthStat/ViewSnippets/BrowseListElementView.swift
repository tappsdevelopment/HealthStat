//
//  BrowseListElementView.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 02.03.24.
//

import SwiftUI

struct BrowseListElementView: View {
    var name: String
    var picture: String
    var color1: Color
    var color2: Color
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: .trailing)
                .mask { RoundedRectangle(cornerRadius: 10, style: .continuous) }
                .frame(height: 80)
                .clipped()
                .overlay(alignment: .leading) {
                    Image(picture)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                        .clipped()
                        .padding(.leading)
                }
                .overlay {
                    Text(name)
                        .foregroundColor(Color(.black))
                        .font(.body)
                }
        }
    }
}

#Preview {
    BrowseListElementView(name: "Workout list", picture: "Workout", color1: .red, color2: .red)
}
