// DateCreationStep.swift
// Enum for the typeform-style date creation flow

import Foundation

enum DateCreationStep: Int, CaseIterable {
    case pastOrFuture
    case dateTime
    case location
    case dateType
    case discussionPoints
    case feelings
    case journalEntry
    case gifts
    case physicalTouch

    static func steps(forPastDate: Bool) -> [DateCreationStep] {
        if forPastDate {
            return [.pastOrFuture, .dateTime, .location, .dateType, .discussionPoints, .feelings, .journalEntry, .gifts, .physicalTouch]
        } else {
            return [.pastOrFuture, .dateTime, .location, .dateType]
        }
    }
}
