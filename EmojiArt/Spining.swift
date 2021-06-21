//
//  Spining.swift
//  EmojiArt
//
//  Created by Jim's MacBook Pro on 6/20/21.
//

import SwiftUI

struct Spining: ViewModifier {
    @State var isVisible = false
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: isVisible ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear { self.isVisible = true }
    }
}

extension View {
    func spining() -> some View {
        self.modifier(Spining())
    }
}
