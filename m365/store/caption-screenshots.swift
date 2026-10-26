// Builds the Partner Center screenshots: each raw capture of screenshots-en/
// under a caption band, at 1366x768 and 1:1 scale (the capture is cropped
// vertically, never resized, so its text stays sharp).
//
// Usage, from m365/store:  swift caption-screenshots.swift
// Reads captions.json, writes listing/en/ and listing/fr/.
// The caption font is Inter SemiBold when installed, the system font otherwise.

import AppKit

let width = 1366
let height = 768
let navy = NSColor(srgbRed: 0x0A / 255, green: 0x29 / 255, blue: 0x61 / 255, alpha: 1)
let sidePadding: CGFloat = 56

let storeDir = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ".")
let config = try JSONSerialization.jsonObject(
  with: Data(contentsOf: storeDir.appendingPathComponent("captions.json"))) as! [String: Any]
let bandHeight = config["bandHeight"] as! Int
let screenshots = config["screenshots"] as! [[String: Any]]

func captionFont(size: CGFloat) -> NSFont {
  NSFont(name: "Inter-SemiBold", size: size) ?? NSFont.systemFont(ofSize: size, weight: .semibold)
}

// Largest size from 30 px down that fits the caption on one line.
func captionAttributes(_ text: String) -> [NSAttributedString.Key: Any] {
  var size: CGFloat = 30
  while size > 20 {
    let attributes: [NSAttributedString.Key: Any] = [.font: captionFont(size: size), .foregroundColor: NSColor.white]
    if (text as NSString).size(withAttributes: attributes).width <= CGFloat(width) - 2 * sidePadding {
      return attributes
    }
    size -= 1
  }
  return [.font: captionFont(size: size), .foregroundColor: NSColor.white]
}

func render(source: CGImage, cropTop: Int, caption: String, to output: URL) throws {
  guard source.width == width, source.height == height else {
    throw NSError(domain: "caption", code: 1, userInfo: [NSLocalizedDescriptionKey:
      "\(output.lastPathComponent): capture is \(source.width)x\(source.height), expected \(width)x\(height)"])
  }
  let shownHeight = height - bandHeight
  guard let cropped = source.cropping(to: CGRect(x: 0, y: cropTop, width: width, height: shownHeight)) else {
    throw NSError(domain: "caption", code: 2, userInfo: [NSLocalizedDescriptionKey: "crop failed"])
  }

  let context = CGContext(
    data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  // CGContext origin is bottom-left: the capture fills the bottom, the band the top.
  context.interpolationQuality = .none
  context.draw(cropped, in: CGRect(x: 0, y: 0, width: width, height: shownHeight))
  context.setFillColor(navy.cgColor)
  context.fill(CGRect(x: 0, y: shownHeight, width: width, height: bandHeight))

  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
  let attributes = captionAttributes(caption)
  let textSize = (caption as NSString).size(withAttributes: attributes)
  let origin = CGPoint(
    x: (CGFloat(width) - textSize.width) / 2,
    y: CGFloat(shownHeight) + (CGFloat(bandHeight) - textSize.height) / 2)
  (caption as NSString).draw(at: origin, withAttributes: attributes)
  NSGraphicsContext.restoreGraphicsState()

  let image = context.makeImage()!
  let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])!
  try png.write(to: output)
}

for language in ["en", "fr"] {
  let outputDir = storeDir.appendingPathComponent("listing/\(language)")
  try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
  for screenshot in screenshots {
    let file = screenshot["file"] as! String
    let sourceURL = storeDir.appendingPathComponent("screenshots-en/\(file)")
    guard let imageSource = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
      let source = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    else {
      fatalError("cannot read \(sourceURL.path)")
    }
    let output = outputDir.appendingPathComponent(file)
    try render(
      source: source, cropTop: screenshot["cropTop"] as! Int,
      caption: screenshot[language] as! String, to: output)
    print("\(language)/\(file)")
  }
}
