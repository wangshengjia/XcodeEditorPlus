//
//  SourceEditorCommand.swift
//  EditorPlusExtension
//
//  Created by Victor WANG on 02/07/2016.
//  Copyright © 2016 Victor Wang. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: (NSError?) -> Void ) -> Void {

        /// Fail fast if there is no text selected at all or there is no text in the file
        guard let textRange = invocation.buffer.selections.firstObject as? XCSourceTextRange
            where invocation.buffer.lines.count > 0 else {
                /// Usually we may want to pass a concrete error into handler block.
                /// But in this case, it's fine to let it failed silencely.
                completionHandler(nil)
                return
        }

        /// Build target range(Range<Int>) based on given text range(XCSourceTextRange)
        let targetRange = Range(uncheckedBounds: (lower: textRange.start.line, upper: min(textRange.end.line + 1, invocation.buffer.lines.count)))

        /// Switch all different commands id based which defined in Info.plist
        switch invocation.commandIdentifier {
        case "delete_lines":
            deleteLines(on: targetRange, with: invocation)
        case "duplicate_lines":
            duplicateLines(on: targetRange, with: invocation)
        default:
            break
        }

        /// Call handler to tell the system we are done here.
        completionHandler(nil)
    }
}

extension SourceEditorCommand {

    /// The method which delete lines by manipulating
    /// the given mutable text buffer.
    ///
    /// - parameter range:      range of lines should be deleted
    /// - parameter invocation: invocation which contains the text buffer invovled
    private func deleteLines(on range: Range<Int>, with invocation: XCSourceEditorCommandInvocation) {

        invocation.buffer.lines.removeObjects(at: IndexSet(integersIn: range))
    }

    /// The method which duplicate lines by manipulating
    /// the given mutable text buffer.
    ///
    /// - parameter range:      range of lines should be duplicated
    /// - parameter invocation: invocation which contains the text buffer invovled
    private func duplicateLines(on range: Range<Int>, with invocation: XCSourceEditorCommandInvocation) {

        let indexSet = IndexSet(integersIn: range)
        let selectedLines = invocation.buffer.lines.objects(at: indexSet)

        invocation.buffer.lines.insert(selectedLines, at: indexSet)
    }
}
