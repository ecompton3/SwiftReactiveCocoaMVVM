//
//  ViewModel.swift
//  ReactiveTest
//
//  Created by Evan Compton on 4/4/16.

/**************************************
*
*  Licensed Materials - Property of IBM
*  © Copyright IBM Corporation 2015. All Rights Reserved.
*  This sample program is provided AS IS and may be used, executed, copied and modified without royalty payment by customer
*  (a) for its own instruction and study, (b) in order to develop applications designed to run with an IBM product,
*  either for customer's own internal use or for redistribution by customer, as part of such an application, in customer's
*  own products.
*
***************************************/

import Foundation
import ReactiveCocoa
import enum Result.NoError

enum TestError: ErrorType {
    case SignalError
}

class FunViewModel : NSObject {
    
    let funModel : FunNumbers
    let pollSignalProducer: SignalProducer<NSDate, NoError>
    var action: Action<NSControl, Int, NSError>?
    let (signal, observer) = Signal<Int, TestError>.pipe()
    let pollUpdatedSignal : Signal<Int, NoError>
    var completed = false
    override init() {
        funModel = FunNumbers()
        pollUpdatedSignal = funModel.pollNum.signal
        let scheduler = QueueScheduler(qos: QOS_CLASS_DEFAULT)
        pollSignalProducer = timer(2, onScheduler: scheduler)
        super.init()
        action = Action<NSControl, Int, NSError> { action in
            return SignalProducer { observer, disposable in
                print(action)
                self.funModel.actionClicks += 1
                observer.sendNext(self.funModel.actionClicks)
                observer.sendCompleted()
            }
        }
        startPoll()
    }
    
    func startPoll() {
        let disposable = pollSignalProducer.start() { event in
            switch event {
            case let .Next(date):
                self.pollSignalFired(date)
            case .Completed:
                self.completed = true
            case .Failed:
                print("Error")
            default:
                break
            }
        }
    }
    
    func pollSignalFired(date : NSDate) {
        let newVal = funModel.pollNum.value + 1
        funModel.pollNum.modify({ _ in newVal })
    }
    
    func manButtonClicked() {
        funModel.manualClicks += 1
        observer.sendNext(funModel.manualClicks)
    }
    
}