//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Jim's MacBook Pro on 5/6/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        WindowGroup {
//            EmojiArtDocumentView(document: EmojiArtDocument())
            let store = EmojiArtDocumentStore(named: "Emoji Art")
            EmojiArtDocumentChooser()
                .environmentObject(store)
//                .onAppear {
//                    store.addDocument()
//                    store.addDocument(named: "Hello World")
//                }
        }
    }
}
