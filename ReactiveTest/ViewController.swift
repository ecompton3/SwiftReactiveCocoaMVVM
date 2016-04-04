//
//  ViewController.swift
//  ReactiveTest
//
//  Created by Evan Compton on 3/31/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Cocoa
import ReactiveCocoa
import enum Result.NoError

class ViewController: NSViewController {
    
    @IBOutlet weak var button : NSButton!
    @IBOutlet weak var manualButton : NSButton!
    @IBOutlet weak var label : NSTextField!
    @IBOutlet weak var manualLabel : NSTextField!
    @IBOutlet weak var pollLabel : NSTextField!
   
    var completed = false;
    var funViewModel : FunViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        funViewModel = FunViewModel()
        let uiScheduler = UIScheduler()
        funViewModel.signal.observeOn(uiScheduler).observe { event in
            switch event {
            case let .Next(num):
                self.manSignalFired(num)
            case .Completed:
                self.completed = true
            case .Failed:
                print("Error")
            default:
                break
            }
        }
        if let action = funViewModel.action {
            action.values.observeOn(uiScheduler).observe(Observer<Int, Result.NoError> {clicks in
                self.signalFiredHandler(clicks)
                })
            button.target = action.unsafeCocoaAction
            button.action = CocoaAction.selector
        }
        
        funViewModel.pollUpdatedSignal.observeNext(pollUpdated)
        
        
        
    }
    
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func signalFiredHandler(numClicked : Int) {
        print(numClicked)
        label.stringValue = "Action Pressed \(numClicked) times"
    }
    
    @IBAction func manBtnPressed(sender : AnyObject) {
        funViewModel.manButtonClicked()
    }
    
    func manSignalFired(manNumClicked: Int) {
        manualLabel.stringValue = "Manual Pressed \(manNumClicked) times"
    }
    
    func pollUpdated(pollFired : Int) {
        pollLabel.stringValue = "Poll Fired \(pollFired) times"
    }


}

