//
//  SolidColor.swift
//  ArgumentParser
//
//  Created by Igor Kulman on 19.11.2020.
//

import ArgumentParser
import Foundation
import Cocoa
import SwiftHEXColors

final class SolidColor: Command, ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "SolidColor",
        abstract: "Adds solid color rectangle"
    )

    @Argument(help: "HEX color to use for the menu bar")
    private var color: String

    @Argument(help: "Wallpaper to use. If not provided the current macOS wallpaper will be used")
    private var wallpaper: String?

    override func createWallpaper(screen: NSScreen, menuBarHeight: CGFloat) -> NSImage? {
        guard let wallpaper = loadWallpaperImage(wallpaper: wallpaper, screen: screen) else {
            return nil
        }

        guard let color: NSColor = NSColor(hexString: self.color) else {
            Log.error("Invalid HEX color provided. Make sure it includes the '#' symbol, e.g: #FF0000")
            return nil
        }

        guard let resizedWallpaper = wallpaper.crop(size: screen.size) else {
            Log.error("Cannot not resize provided wallpaper to screen size")
            return nil
        }

        Log.debug("Generating solid color image")
        guard let topImage = createSolidImage(color: color, width: screen.size.width, height: menuBarHeight) else {
            return nil
        }

        return combineImages(baseImage: resizedWallpaper, addedImage: topImage)
    }
}

