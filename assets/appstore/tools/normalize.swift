import Foundation
import CoreImage
import ImageIO
import UniformTypeIdentifiers

let src = URL(fileURLWithPath: CommandLine.arguments[1])
let dst = URL(fileURLWithPath: CommandLine.arguments[2])
guard let image = CIImage(contentsOf: src, options: [.applyOrientationProperty: true]) else {
    FileHandle.standardError.write(Data("cannot read\n".utf8)); exit(1)
}
let context = CIContext()
guard let cg = context.createCGImage(image, from: image.extent) else { exit(1) }
guard let dest = CGImageDestinationCreateWithURL(dst as CFURL, UTType.png.identifier as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(dest, cg, nil)
if !CGImageDestinationFinalize(dest) { exit(1) }
print("\(cg.width)x\(cg.height)")
