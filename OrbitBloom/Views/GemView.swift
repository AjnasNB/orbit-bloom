import SwiftUI
import UIKit

enum BotanicalSprites {
    static let images: [UIImage] = {
        guard let sheet = UIImage(named:"BotanicalAtlas")?.cgImage else { return [] }
        // The original artwork is packed with uneven gutters, rather than exact square cells.
        // Crop each sprite's actual bounds so neighboring leaves/wheels cannot bleed into tools.
        let bounds:[CGRect] = [
            CGRect(x:26,y:25,width:323,height:322), CGRect(x:423,y:18,width:244,height:330),
            CGRect(x:743,y:12,width:307,height:336), CGRect(x:1077,y:20,width:369,height:329),
            CGRect(x:24,y:378,width:355,height:307), CGRect(x:407,y:347,width:313,height:353),
            CGRect(x:742,y:350,width:321,height:347), CGRect(x:1102,y:345,width:346,height:351),
            CGRect(x:37,y:704,width:336,height:339), CGRect(x:401,y:704,width:297,height:342),
            CGRect(x:764,y:699,width:282,height:362), CGRect(x:1098,y:709,width:316,height:337)
        ]
        let sx = CGFloat(sheet.width)/1448, sy = CGFloat(sheet.height)/1086
        return bounds.compactMap { rect in
            sheet.cropping(to:CGRect(x:rect.minX*sx,y:rect.minY*sy,width:rect.width*sx,height:rect.height*sy)).map { UIImage(cgImage:$0) }
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
