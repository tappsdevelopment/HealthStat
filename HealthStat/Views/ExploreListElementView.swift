//
//  ExploreListElementView.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 05.02.24.
//

import SwiftUI

struct ExploreListElementView: View {
    var elementLabel: String
    var elementValue: String
    var elementColor: Color
    
    var body: some View {
        HStack {
            Text(elementLabel)
            Spacer()
            Text(elementValue)
        }
        .padding(.all, 5)
        //.padding(.vertical, 10)
        .background(elementColor)
        //.cornerRadius(5.0)
        
        
    }
}

#Preview {
    Group {
        ExploreListElementView(elementLabel: "Workouts", elementValue: "2400", elementColor: Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.4))
        ExploreListElementView(elementLabel: "Distance", elementValue: "3,4", elementColor: Color(red: 0.0, green: 0.0, blue: 1.0, opacity: 0.4))
    }
}
