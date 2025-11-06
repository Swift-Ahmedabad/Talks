//
//  AppGroup.swift
//  AppIntentDemo
//
//  Created by Jay Kothadia on 15/12/24.
//


import Foundation

/// Represents an app group.
public struct AppGroup: Hashable, Codable, Sendable {
    
    //// App Group keys
    public enum AppGroupKeys: String {
        case controlCentre  = "group.JAY.controlWidget"
    }
    
    /// The identifier of the app group. Usually starts with `group.`.
    public let identifier: String

    /// The user defaults for this app group. `nil` if the app group is not valid.
    public var userDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }

    /// The file system for this app group. `nil` if the app group is not valid.
    public var fileSystem: FileSystem? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: identifier)
            .map(FileSystem.init)
    }

    /// Creates a new app group with the given identifier.
    /// - Parameter identifier: The identifier of the new app group.
    public init(identifier: AppGroupKeys) {
        self.identifier = identifier.rawValue
    }

    public init(from decoder: Decoder) throws {
        try self.init(identifier: AppGroupKeys(rawValue: decoder.singleValueContainer().decode(String.self))!)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifier)
    }
}

extension AppGroup {
    /// Computes paths for the file system inside an app group.
    public struct FileSystem: Hashable {
        /// The root directory of the app group.
        public let root: URL

        /// The "Library" directory inside the app group.
        public var library: URL {
            root._appendingDirectory("Library")
        }

        /// The "Application Support" directory inside the "Library" folder.
        /// - SeeAlso: ``library``
        public var applicationSupport: URL {
            library._appendingDirectory("Application Support")
        }

        /// The "Caches" directory inside the "Library" folder.
        /// - SeeAlso: ``library``
        public var caches: URL {
            library._appendingDirectory("Caches")
        }

        /// The "Preferences" directory inside the "Library" folder.
        /// - SeeAlso: ``library``
        public var preferences: URL {
            library._appendingDirectory("Preferences")
        }
    }
}

fileprivate extension URL {
    func _appendingDirectory(_ dirName: String) -> URL {
#if canImport(Darwin) && compiler(>=5.7.1)
            if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
                return appending(component: dirName, directoryHint: .isDirectory)
            } else {
                return appendingPathComponent(dirName, isDirectory: true)
            }
#else
            return appendingPathComponent(dirName, isDirectory: true)
#endif
    }
}

#if compiler(>=5.7)
extension AppGroup.FileSystem: Sendable {}
#endif
