import Foundation

let manager = FileManager.default
let fixture = manager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
try manager.createDirectory(at: fixture, withIntermediateDirectories: true)
defer { try? manager.removeItem(at: fixture) }
let trash = fixture.appendingPathComponent("Trash")
let outside = fixture.appendingPathComponent("keep.txt")
try manager.createDirectory(at: trash.appendingPathComponent("folder"), withIntermediateDirectories: true)
try Data("keep".utf8).write(to: outside)
try Data("delete".utf8).write(to: trash.appendingPathComponent(".hidden"))
try Data("nested".utf8).write(to: trash.appendingPathComponent("folder/file"))
try manager.createSymbolicLink(at: trash.appendingPathComponent("link"), withDestinationURL: outside)
let result = TrashCleaner.empty(directories: [trash, fixture.appendingPathComponent("missing")])
precondition(result.removed == 3 && result.failures.isEmpty, "Unexpected result: \(result)")
let remaining = try manager.contentsOfDirectory(atPath: trash.path)
precondition(remaining.isEmpty)
precondition(manager.fileExists(atPath: outside.path), "Symlink target was removed")
let substitute = fixture.appendingPathComponent("substituted")
try manager.createSymbolicLink(at: substitute, withDestinationURL: fixture)
let refused = TrashCleaner.empty(directories: [substitute])
precondition(refused.removed == 0 && refused.failures.count == 1)
precondition(manager.fileExists(atPath: outside.path))
print("Passed: nested and hidden items, missing trash, symlink target preservation, root symlink rejection")
