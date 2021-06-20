//
//  Set+toggleMatching.swift
//  EmojiArt
//
//  Created by Jim's MacBook Pro on 6/19/21.
//

import Foundation

extension Set where Element: Identifiable {
    mutating func toggleMatching(of element: Element) {
        if let index = self.firstIndex(matching: element) {
            self.remove(at: index)
        } else {
            self.insert(element)
        }
    }
}
