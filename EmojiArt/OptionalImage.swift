//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Jim's MacBook Pro on 6/19/21.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
