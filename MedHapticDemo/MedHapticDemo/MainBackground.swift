//
//  MainBackground.swift
//  MedHapticDemo
//
//  Created by Andrii Halushka on 16.08.2021.
//

import SwiftUI

struct MainBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.07, green: 0.76, blue: 0.91, opacity: 0.4),
                    Color(red: 0.77, green: 0.44, blue: 0.93, opacity: 0.4),
                    Color(red: 0.96, green: 0.31, blue: 0.35, opacity: 0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

struct MainBackground_Previews: PreviewProvider {
    static var previews: some View {
        MainBackground()
    }
}
