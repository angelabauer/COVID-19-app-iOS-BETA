//
//  QuestionnaireCoordinator.swift
//  Sonar
//
//  Created by NHSX on 24/04/2020.
//  Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

protocol Coordinator {
    func start()
}

class QuestionnaireCoordinator: Coordinator {
    let navigationController: UINavigationController
    let statusStateMachine: StatusStateMachining
    let completion: (Symptoms) -> Void
    let questionnaireType: QuestionnaireType
    
    enum QuestionnaireType {
        case selfDiagnosis
        case checkin
    }

    init(
        navigationController: UINavigationController,
        statusStateMachine: StatusStateMachining,
        questionnaireType: QuestionnaireType,
        completion: @escaping (Symptoms) -> Void
    ) {
        self.navigationController = navigationController
        self.statusStateMachine = statusStateMachine
        self.questionnaireType = questionnaireType
        self.completion = completion
    }
    
    var symptoms = Symptoms()

    static let pageCount = 6
    
    func openQuestionVC(symptom: Symptom,
                        pageNumber: Int,
                        buttonAction: @escaping (Bool) -> Void) {
        let vc = QuestionSymptomsViewController.instantiate()
        
        let checkin = hadSymptom(symptom) ? "_CHECKIN_" : "_"
        let localizedTextPrefix = symptom.localizationPrefix
        let title = "\(localizedTextPrefix)\(checkin)QUESTION".localized
        
        
        vc.inject(
            pageNumber: pageNumber,
            pageCount: Self.pageCount,
            questionTitle: title,
            questionDetail: "\(localizedTextPrefix)_DETAIL".localized,
            questionError: "\(localizedTextPrefix)_ERROR".localized,
            questionYes: "\(localizedTextPrefix)_YES".localized,
            questionNo: "\(localizedTextPrefix)_NO".localized,
            buttonText: "Continue",
            buttonAction: buttonAction
        )
        navigationController.pushViewController(vc, animated: true)
    }
    
    func start() {
        openQuestionVC(symptom: .temperature, pageNumber: 1) { hasHighTemperature in
            self.updateSymptoms(with: .temperature, if: hasHighTemperature)
            self.openCoughView()
        }
    }
    
    func openCoughView() {
        openQuestionVC(symptom: .cough, pageNumber: 2) { hasNewCough in
            self.updateSymptoms(with: .cough, if: hasNewCough)
            self.openAnosmiaView()
        }
    }
    
    func openAnosmiaView() {
        openQuestionVC(symptom: .anosmia, pageNumber: 3) { hasAnosmia in
            self.updateSymptoms(with: .anosmia, if: hasAnosmia)
            self.openSneezeView()
        }
    }
    
    func openSneezeView() {
        openQuestionVC(symptom: .sneeze, pageNumber: 4) { hasSneeze in
            self.updateSymptoms(with: .sneeze, if: hasSneeze)
            self.openNauseaView()
        }
    }
    
    func openNauseaView() {
        openQuestionVC(symptom: .nausea, pageNumber: 5) { hasNausea in
            self.updateSymptoms(with: .nausea, if: hasNausea)
            self.finishQuestions()
        }
    }

    func finishQuestions() {
        switch questionnaireType {
        case .selfDiagnosis:
            openSubmissionView()
        case .checkin:
            completion(symptoms)
        }
    }
    
    func openSubmissionView() {
        let vc = SymptomsSummaryViewController.instantiate()
        vc.inject(
            pageNumber: 6,
            symptoms: symptoms,
            statusStateMachine: statusStateMachine,
            completion: completion
        )
        navigationController.pushViewController(vc, animated: true)
    }

    private func updateSymptoms(with symptom: Symptom, if hasSymptom: Bool) {
        if hasSymptom {
            symptoms.insert(symptom)
        } else {
            symptoms.remove(symptom)
        }
    }
    
    private func hadSymptom(_ symptom: Symptom) -> Bool {
        self.statusStateMachine.state.symptoms?.contains(symptom) ?? false
    }
}