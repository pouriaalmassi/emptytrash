import Foundation
import Darwin

struct CleaningResult {
    var removed = 0
    var failures: [String] = []
}

struct TrashCleaner {
    static func trashDirectories() -> [URL] {
        let manager = FileManager.default
        var directories = [manager.homeDirectoryForCurrentUser.appendingPathComponent(".Trash", isDirectory: true)]
        for volume in manager.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: []) ?? [] {
            directories.append(volume.appendingPathComponent(".Trashes", isDirectory: true)
                .appendingPathComponent(String(getuid()), isDirectory: true))
        }
        var seen = Set<String>()
        return directories.filter { seen.insert($0.standardizedFileURL.path).inserted }
    }

    // The caller supplies only the current user's trash directories in production.
    static func empty(directories: [URL]) -> CleaningResult {
        let manager = FileManager.default
        var result = CleaningResult()
        for directory in directories {
            do {
                // Never follow a substituted symlink at the trash directory itself.
                let attributes = try manager.attributesOfItem(atPath: directory.path)
                guard attributes[.type] as? FileAttributeType == .typeDirectory else {
                    result.failures.append("Refused non-directory trash: \(directory.path)")
                    continue
                }
                let items = try manager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
                for item in items {
                    do {
                        // removeItem unlinks symbolic links without deleting their targets.
                        try manager.removeItem(at: item)
                        result.removed += 1
                    } catch {
                        result.failures.append("\(item.path): \(error.localizedDescription)")
                    }
                }
            } catch {
                let nsError = error as NSError
                if nsError.domain == NSCocoaErrorDomain && nsError.code == NSFileReadNoSuchFileError {
                    continue // Most mounted volumes have no trash for this user.
                }
                result.failures.append("\(directory.path): \(error.localizedDescription)")
            }
        }
        return result
    }
}
