//
//  DirectoryFiles.swift
//  Trading
//
//  Created by Maroun Achille on 18/12/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class DirectoryFiles {
    static let appUserDir = "TradingSimulator"
    static let imageDir = "\(appUserDir)/SaveChart"
    
    static let databaseDir = "\(appUserDir)/Data"
    static let databaseName = "TradingSimu.sqlite"
                               
    
    static func createAppUserDir() throws {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let directory = paths[0]
        let docURL = URL(string: directory)!
        var dataPath = docURL.appendingPathComponent(appUserDir)
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
        }
        
        dataPath = docURL.appendingPathComponent(databaseDir)
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
        }
        
        dataPath = docURL.appendingPathComponent(imageDir)
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    
    static func prepareDatabaseFile() throws -> String {
        try createAppUserDir()
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = directory.appendingPathComponent("\(databaseDir)/\(databaseName)")
           
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            let bundleUrl = (Bundle.main.resourceURL?.appendingPathComponent(databaseName))!
            try FileManager.default.copyItem(atPath :bundleUrl.path, toPath: dataPath.path)
        }
        return dataPath.path
    }

    
    static func imageSave(image: NSImage, fileName: String) {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let w: Int = Int(image.size.width)
        let h: Int = Int(image.size.height)
        
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let resizeImage = DirectoryFiles.resizedImageTo(sourceImage: image, newSize: destSize)
        let replaced = fileName.replacingOccurrences(of: "/", with: "-") //for currency name

        let dataPath = directory.appendingPathComponent("\(imageDir)/\(replaced)")
        
        var pngData: Data? {
            guard let tiffRepresentation = resizeImage?.tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
               return bitmapImage.representation(using: .png, properties: [:])
           }
    
        do {
            try pngData?.write(to: dataPath, options: .atomic)
            Message.messageAlert("Image saved to:\n", text: dataPath.path)
        } catch {
            Message.messageAlert("Chart Save Error:\n", text: error.localizedDescription)
        }
    }
  
    static func dataSave(data: Data, fileName: String) {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let replaced = fileName.replacingOccurrences(of: "/", with: "-") //for currency name
        let dataPath = directory.appendingPathComponent("\(imageDir)/\(replaced)")
        
        do {
            try data.write(to: dataPath, options: .atomic)
            Message.messageAlert("Data Saved to:\n", text: dataPath.path)
        } catch {
            Message.messageAlert("Data Save Error:\n", text: error.localizedDescription)

        }
    }
    
    static func chartDir() -> String {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = directory.appendingPathComponent(imageDir)
        return dataPath.path
    }
    
    static func logSave(data: String, fileName: String) {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let replaced = fileName.replacingOccurrences(of: "/", with: "-") //for currency name
        let dataPath = directory.appendingPathComponent("\(appUserDir)/\(replaced)")
        
        do {
            try data.write(to: dataPath, atomically: false, encoding: .utf8)
        } catch {
            print("Log Save Error:", error.localizedDescription)

        }
    }
    
    static func chartFileName(id: String, chartType: String, quoteDate: Date) -> String{
        return "\(id)-\(chartType)-\(CDate.dateQuoteShort(quoteDate) ?? "00-00-0000").png"
    }

    static func resizedImageTo(sourceImage: NSImage, newSize: NSSize) -> NSImage? {
        if sourceImage.isValid == false {
            return nil
        }
        let representation = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)
        representation?.size = newSize
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext.init(bitmapImageRep: representation!)
        sourceImage.draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: NSZeroRect, operation: .copy, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
             
        let newImage = NSImage(size: newSize)
        newImage.addRepresentation(representation!)
             
        return newImage
             
    }
}
