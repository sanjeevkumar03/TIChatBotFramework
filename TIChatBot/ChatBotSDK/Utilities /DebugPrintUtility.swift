// DebugPrintUtility.swift
// Copyright © 2021 Telus International. All rights reserved.

import Foundation

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.print(items, separator: separator, terminator: terminator)
    #endif
}
func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.debugPrint(items, separator: separator, terminator: terminator)
    #endif
}
