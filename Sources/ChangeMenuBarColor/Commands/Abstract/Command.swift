//
//  Command.swift
//  ChangeMenuBarColor
//
//  Created by Igor Kulman on 19.11.2020.
//

import ArgumentParser
import Files
import Foundation
import Cocoa
import SwiftHEXColors

class Command {
    func createWallpaper(screen: NSScreen, menuBarHeight: CGFloat) -> NSImage? {
        return nil
    }

    func run() {
        Log.info("Starting up")
        
        guard NSScreen.screens.count > 0 else {
            Log.error("Could not detect any screens")
            return
        }
        
        guard let menuBarHeight = NSScreen.main?.menuBarHeight else {
            Log.error("Could not get menu bar height of main screen")
            return
        }
        
        NSScreen.screens.forEach { (screen) in
            guard let adjustedWallpaper = createWallpaper(screen: screen, menuBarHeight: menuBarHeight), let data = adjustedWallpaper.jpgData else {
                Log.error("Could not generate new wallpaper fr screen \(screen.localizedName)")
                return
            }
            
            setWallpaper(screen: screen, wallpaper: data)
        }
        
        Log.info("All done!")
    }

    func loadWallpaperImage(wallpaper: String?, screen: NSScreen) -> NSImage? {
        if let path = wallpaper {
            guard let wallpaper = NSImage(contentsOfFile: path) else {
                Log.error("Cannot read the provided wallpaper file as image. Check if the path is correct and if it is a valid image file")
                return nil
            }

            Log.debug("Loaded \(path) to be used as wallpaper image")
            return wallpaper
        }

        guard let path = NSWorkspace.shared.desktopImageURL(for: screen), let wallpaper = NSImage(contentsOf: path) else {
            Log.error("Cannot read the currently set macOS wallpaper. Try providing a specific wallpaper as a parameter instead.")
            return nil
        }

        Log.debug("Using currently set macOS wallpaper \(path)")

        return wallpaper
    }

    private func setWallpaper(screen: NSScreen, wallpaper: Data) {
        guard let supportFiles = try? Folder.library?.subfolder(at: "Application Support"), let workingDirectory = try? supportFiles.createSubfolderIfNeeded(at: "ChangeMenuBarColor") else {
            Log.error("Cannot access Application Support folder")
            return
        }

        do {
            let generatedWallpaperFile = workingDirectory.url.appendingPathComponent("/wallpaper-screen-adjusted-\(UUID().uuidString).jpg")
            try? FileManager.default.removeItem(at: generatedWallpaperFile)

            try wallpaper.write(to: generatedWallpaperFile)
            Log.debug("Created new wallpaper for screen \(screen.localizedName) in \(generatedWallpaperFile.absoluteString)")

            try NSWorkspace.shared.setDesktopImageURL(generatedWallpaperFile, for: screen, options: [:])
            Log.info("Wallpaper set")
        } catch {
            Log.error("Writing new wallpaper file failed with \(error.localizedDescription) for screen \(screen.localizedName)")
        }
    }
}
