//
//  BluetoothNurseryTests.swift
//  CoLocateTests
//
//  Created by NHSX.
//  Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import CoLocate

class BluetoothNurseryTests: TestCase {
    func testCreatesStateObserverOnceUserHasBeenPromptedForPermissions() {
        let nursery = ConcreteBluetoothNursery(persistence: PersistenceDouble(),
                                               userNotificationCenter: UserNotificationCenterDouble(),
                                               notificationCenter: NotificationCenter())
        XCTAssertNil(nursery.stateObserver)
        
        nursery.startBluetooth(registration: nil)
        XCTAssertNotNil(nursery.stateObserver)
    }
    
    func testStartsBroadcastingOnceRegistrationIsPersisted() {
        let persistence = PersistenceDouble()
        let nursery = ConcreteBluetoothNursery(persistence: persistence,
                                               userNotificationCenter: UserNotificationCenterDouble(),
                                               notificationCenter: NotificationCenter())
        
        XCTAssertNil(nursery.broadcastIdGenerator.sonarId)
        
        let registration = Registration.fake
        persistence.delegate?.persistence(persistence, didUpdateRegistration: registration)

        XCTAssertEqual(nursery.broadcastIdGenerator.sonarId, registration.id)
    }

    func test_whenRegistrationIsSaved_theBroadcasterIsInformedToUpdate() throws {
        throw XCTSkip("This test can't be written until the nursery's functional behavior is decoupled from the creation of objects.")
    }
}