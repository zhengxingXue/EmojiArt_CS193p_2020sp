//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Jim's MacBook Pro on 5/6/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    var body: some View {
        VStack {
            HStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(EmojiArtDocument.palette.map{ String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: defaultEmojiSize))
                                .onDrag { return NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
                Spacer()
                Button(action: {
                    for emoji in document.selectedEmojiSet {
                        document.removeEmoji(emoji)
                    }
                    document.selectedEmojiSet.removeAll()
                }, label: {
                    Image(systemName: "trash.fill")
                        .font(Font.system(size: defaultTrashSize))
                })
                    .disabled(document.selectedEmojiSet.isEmpty)
            }
                .padding(.horizontal)
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.document.selectedEmojiSet.isEmpty ? self.zoomScale : self.steadyStateZoomScale)
                            .offset(self.panOffSet)
                    )
                    .gesture(self.doubleTapToZoom(in: geometry.size).exclusively(before: self.oneTapToDeselect()))
                    ForEach(self.document.emojis) { emoji in
                        Group {
                            if self.document.selectedEmojiSet.contains(matching: emoji) {
                                Text(emoji.text)
                                    .font(animatableWithSize: emoji.fontSize * self.getZoomScale(of: emoji))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(self.document.selectedEmojiSet.contains(matching: emoji) ? Color.black : Color.clear, lineWidth: 2)
                                    )
                                    .position(self.position(for: emoji, in: geometry.size))
                                    .onTapGesture {
                                        self.document.selectedEmojiSet.toggleMatching(of: emoji)
                                    }
                                    .gesture(self.selectedEmojiPanGesture())
                            } else {
                                Text(emoji.text)
                                    .font(animatableWithSize: emoji.fontSize * self.getZoomScale(of: emoji))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(self.document.selectedEmojiSet.contains(matching: emoji) ? Color.black : Color.clear, lineWidth: 2)
                                    )
                                    .position(self.position(for: emoji, in: geometry.size))
                                    .onTapGesture {
                                        self.document.selectedEmojiSet.toggleMatching(of: emoji)
                                    }
//                                    .gesture(unselectedEmojiPanGesture(for: emoji))
                            }
                        }
                    }
                }
                .clipped()
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffSet.width, y: location.y - self.panOffSet.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
            }
        }
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func getZoomScale (of emoji: EmojiArt.Emoji) -> CGFloat {
        if self.document.selectedEmojiSet.isEmpty {
            return zoomScale
        } else {
            if self.document.selectedEmojiSet.contains(matching: emoji) {
                return zoomScale
            } else {
                return steadyStateZoomScale
            }
        }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                if self.document.selectedEmojiSet.isEmpty {
                    self.steadyStateZoomScale *= finalGestureScale
                } else {
                    for emoji in self.document.selectedEmojiSet {
                        self.document.scaleEmoji(emoji, by: finalGestureScale)
                    }
                }
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    
    private func oneTapToDeselect() -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                self.document.selectedEmojiSet.removeAll()
            }
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffSet: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * (self.document.selectedEmojiSet.isEmpty ? zoomScale : steadyStateZoomScale)
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            }
    }
    
    @GestureState private var gestureEmojiPanOffset: CGSize = .zero
    
    private func selectedEmojiPanGesture() -> some Gesture {
        DragGesture()
            .updating($gestureEmojiPanOffset) { latestDragGestureValue, gestureEmojiPanOffset, transaction in
                gestureEmojiPanOffset = latestDragGestureValue.translation
            }
            .onEnded { finalDragGestureValue in
                for emoji in self.document.selectedEmojiSet {
                    self.document.moveEmoji(emoji, by: finalDragGestureValue.translation / self.zoomScale)
                }
            }
    }
    
//    @GestureState private var unselectedEmojiPanOffset: CGSize = .zero
//
//    private func unselectedEmojiPanGesture(for emoji: EmojiArt.Emoji) -> some Gesture {
//        DragGesture()
//            .updating($unselectedEmojiPanOffset) { latestDragGestureValue, unselectedEmojiPanOffset, transaction in
//                unselectedEmojiPanOffset = latestDragGestureValue.translation
//            }
//            .onEnded { finalDragGestureValue in
//                self.document.moveEmoji(emoji, by: finalDragGestureValue.translation / self.zoomScale)
//            }
//    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyStatePanOffset = .zero
            self.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        if self.document.selectedEmojiSet.isEmpty {
            location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        } else {
            location = CGPoint(x: location.x * steadyStateZoomScale, y: location.y * steadyStateZoomScale)
        }
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffSet.width, y: location.y + panOffSet.height)
        if self.document.selectedEmojiSet.contains(matching: emoji) {
            location = CGPoint(x: location.x + gestureEmojiPanOffset.width, y: location.y + gestureEmojiPanOffset.height)
        }

//        location = CGPoint(x: location.x + unselectedEmojiPanOffset.width, y: location.y + unselectedEmojiPanOffset.height)

        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            print("dropped \(url)")
            self.document.setBackgroundURL(url)
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
    private let defaultTrashSize: CGFloat = 30
}
