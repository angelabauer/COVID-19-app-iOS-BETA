//
//  ContactEventService.swift
//  CoLocate
//
//  Created by NHSX.
//  Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct ContactEvent: Equatable, Codable {
    let uuid: UUID
}

class ContactEventService {
    
    let fileURL: URL

    public private(set) var contactEvents: [ContactEvent] = []

    init() {
        if let dirUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            fileURL = dirUrl.appendingPathComponent("contactEvents.plist")
        } else {
            preconditionFailure("\(#file).\(#function) couldn't open file for writing contactEvents.plist")
        }
        readContactEvents()
    }
    
    private func readContactEvents() {
        guard FileManager.default.isReadableFile(atPath: fileURL.path) else {
            contactEvents = []
            return
        }
        
        let decoder = PropertyListDecoder()
        do {
            let data = try Data(contentsOf: fileURL)
            contactEvents = try decoder.decode([ContactEvent].self, from: data)
        } catch {
            assertionFailure("\(#file).\(#function) error reading contact events from disk: \(error)")
        }
    }
    
    func record(_ contactEvent: ContactEvent) { // probably also timestamp and distance
        print("\(#file).\(#function) recording contactEvent with UUID: \(contactEvent.uuid)")
        
        contactEvents.append(contactEvent)
        writeContactEvents()
    }
    
    private func writeContactEvents() {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        do {
            // TODO: These writing options mean if we reboot and are woken from background by a
            // BTLE event before the user unlocks their phone, we won't be able to record any data.
            // Can this happen in practice? Does it matter?
            let data = try encoder.encode(contactEvents)
            try data.write(to: fileURL, options: [.completeFileProtectionUntilFirstUserAuthentication])
        } catch {
            assertionFailure("\(#file).\(#function) error writing contact events to disk: \(error)")
        }
    }
    
    func reset() {
        contactEvents = []
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            assertionFailure("\(#file).\(#function) error removing file at '\(fileURL)': \(error)")
        }
    }
    
}
