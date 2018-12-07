//
//  FUIWait.swift
//  ForceUITestSDK
//
//  Created by Eric Engelking on 10/3/17.
//  Copyright © 2017 salesforce.com. All rights reserved.
//

//  The converted code is limited by 4 KB.
//  Upgrade your plan to remove this limitation.

import XCTest
import Foundation

let kDefaultTimeout: Int = 10
let kDefaultStep: Int = 1

@objc public class FUIWait: NSObject {
    public typealias ExpressionBlock = () -> Bool
    
    var timeout: Int = kDefaultTimeout
    var step: Int = kDefaultStep
    
    override public init() {}
    
    /**
     @param timeout Amount of time before the wait will throw an exception
     */
    public convenience init(timeout: Int) {
        self.init(timeout: timeout, withStep: kDefaultStep)
    }
    
    /**
     @param timeout Amount of time before the wait will throw an exception
     @param step Amount of time to wait before evaluating expression again
     */
    public convenience init(timeout: Int, withStep step: Int) {
        self.init()
        self.timeout = timeout
        self.step = step
    }
    
    /**
     Waits for an expression to be true.  The expression will be evaluated until a timeout is reached. If the expression is
     still false when then timeout is reached then an exception will throw which should fail the test.
     */
    public func waitForExpressionTrue(_ expression: ExpressionBlock){
        var currentStep: Int = step
        while currentStep < timeout {
            if expression() == true {
                print("Expression evaluated as true")
                return
            }
            currentStep += step
            RunLoop.current.run(until: Date(timeIntervalSinceNow: TimeInterval(step)))
        }
        XCTFail("Expression never became true before timeout\n\(Thread.callStackSymbols)")
        
    }
    
    /**
     Waits for an element to contain a specific accessibility label.  If the expression is
     still false when then timeout is reached then an exception will throw which should fail the test.
     */
    public func waitForElement(_ element: XCUIElement, withExpectedLabel expectedLabel: String) {
        waitForExpressionTrue() { () -> Bool in
            return element.label == expectedLabel
        }
    }
    
    /**
     Waits for an element to contain a specific accessibility identifer.  If the expression is
     still false when then timeout is reached then an exception will throw which should fail the test.
     */
    public func waitForElement(_ element: XCUIElement, withExpectedIdentifier expectedIdentifier: String) {
        waitForExpressionTrue { () -> Bool in
            return element.identifier == expectedIdentifier
        }
    }
    
    /**
     Waits for an element to exist. If the expression is still false when then timeout is reached then an exception will
     throw which should fail the test.
     */
    public func waitForElementExists(_ element: XCUIElement) {
        waitForExpressionTrue { () -> Bool in
            return element.exists
        }
    }
    
    /**
     Waits for an element to no longer exist. If the expression is still false when then timeout is reached then an
     exception will throw which should fail the test.
     */
    public func waitForElementDoesNotExist(_ element: XCUIElement) {
        waitForExpressionTrue { () -> Bool in
            return !element.exists
        }
    }
    
    /**
     Waits for an element to be enabled. If the expression is still false when then timeout is reached then an exception
     will throw which should fail the test.
     */
    public func waitForElementEnabled(_ element: XCUIElement) {
        waitForExpressionTrue { () -> Bool in
            return element.isEnabled
        }
    }
    
    /**
     Waits for an element to no longer be enabled. If the expression is still false when then timeout is reached then an
     exception will throw which should fail the test.
     */
    public func waitForElementNotEnabled(_ element: XCUIElement) {
        waitForExpressionTrue { () -> Bool in
            return !element.isEnabled
        }
    }
}
