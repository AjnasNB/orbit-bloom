import SwiftUI
import UIKit

enum BotanicalSprites {
    static let images: [UIImage] = {
        guard let sheet = UIImage(named:"BotanicalAtlas")?.cgImage else { return [] }
        // Cartoon atlas: four columns, three rows, with transparent gutters in every cell.
        // Preserve the existing index contract used by gems, tools, Pip and the wallet.
        return (0..<12).compactMap { index in
            let x = (index % 4) * sheet.width / 4
            let y = (index / 4) * sheet.height / 3
            let right = (index % 4 + 1) * sheet.width / 4
            let bottom = (index / 4 + 1) * sheet.height / 3
            var bounds = CGRect(x:x,y:y,width:right-x,height:bottom-y)
            // The diamond's wider safety gutter needs a closer crop to match the other pieces.
            if index == Gem.crystal.rawValue {
                bounds = bounds.insetBy(dx:bounds.width*0.11,dy:bounds.height*0.11).integral
            }
            return sheet.cropping(to:bounds).map { UIImage(cgImage:$0) }
        }
    }()
}
struct SpriteView: View {
    let index: Int
    var body: some View {
        if BotanicalSprites.images.indices.contains(index) {
            Image(uiImage:BotanicalSprites.images[index]).resizable().scaledToFit().accessibilityHidden(true)
        }
    }
}
struct GemView: View {
    let gem: Gem
    var body: some View { SpriteView(index:gem.rawValue).shadow(color:.black.opacity(0.3),radius:2,y:3) }
}
