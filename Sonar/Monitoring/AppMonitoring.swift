//
//  AppMonitoring.swift
//  Sonar
//
//  Created by NHSX.
//  Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

protocol AppMonitoring {
    func report(_ event: AppEvent)
}

// Using this whilst we’re not sure how we want to handle events.
struct NoOpAppMonitoring: AppMonitoring {
    func report(_ event: AppEvent) {
    }
}