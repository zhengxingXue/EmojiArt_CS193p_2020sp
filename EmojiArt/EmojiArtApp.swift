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
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let store = EmojiArtDocumentStore(directory: url)
            EmojiArtDocumentChooser()
                .environmentObject(store)
//                .onAppear {
//                    store.addDocument()
//                    store.addDocument(named: "Hello World")
//                }
        }
    }
}
