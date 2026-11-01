import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let args = CommandLine.arguments
let bezelURL = URL(fileURLWithPath: args[1])
let shotURL = URL(fileURLWithPath: args[2])
let outURL = URL(fileURLWithPath: args[3])

guard let bs = CGImageSourceCreateWithURL(bezelURL as CFURL, nil),
      let bezel = CGImageSourceCreateImageAtIndex(bs, 0, nil),
      let ss = CGImageSourceCreateWithURL(shotURL as CFURL, nil),
      let shot = CGImageSourceCreateImageAtIndex(ss, 0, nil) else { fatalError("load") }

let w = 3000, h = 2300
let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.interpolationQuality = .high
// 官方边框：屏幕透明区 (124,118) 2752×2064
ctx.draw(shot, in: CGRect(x: 124, y: 118, width: 2752, height: 2064))
ctx.draw(bezel, in: CGRect(x: 0, y: 0, width: w, height: h))
let dest = CGImageDestinationCreateWithURL(outURL as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
CGImageDestinationFinalize(dest)
