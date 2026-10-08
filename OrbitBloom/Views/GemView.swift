import SwiftUI
import UIKit

enum BotanicalSprites {
    static let images: [UIImage] = {
        guard let sheet = UIImage(named:"BotanicalAtlas")?.cgImage else { return [] }
        let width = sheet.width / 4, height = sheet.height / 3
        return (0..<12).compactMap { id in
            sheet.cropping(to:CGRect(x:(id%4)*width,y:(id/4)*height,width:width,height:height)).map { UIImage(cgImage:$0) }
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
