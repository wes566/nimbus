// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause

import XCTest
import WebKit
import SwiftCheck

@testable import Veil

class ConnectionTestBridge {

    private(set) var calledFoo = false

    func foo() {
        calledFoo = true
    }

    func callWithCallback(callback: (Int) -> ()) {
        callback(42)
    }

    func unaryWithCallback(arg0: Int, callback: (Int) -> ()) {
        callback(arg0)
    }

    func binaryWithCallback(arg0: Float, arg1: Float, callback: (Float) -> ()) {
        callback(arg0 + arg1)
    }

    func ternaryWithCallback(arg0: Int, arg1: Int, arg2: Int, callback: (Int) -> ()) {
        callback(arg0 + arg1 + arg2)
    }

    func quaternaryWithCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: (Int) -> ()) {
        callback(arg0 + arg1 + arg2 + arg3)
    }
    
    func quinaryWithCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, arg4: Int, callback: (Int) -> ()) {
        callback(arg0 + arg1 + arg2 + arg3 + arg4)
    }
}

let lowerCaseLetters : Gen<Character> = Gen<Character>.fromElements(in: "a"..."z")
let upperCaseLetters : Gen<Character> = Gen<Character>.fromElements(in: "A"..."Z")

let uppersAndLowers = Gen<Character>.one(of: [
    lowerCaseLetters,
    upperCaseLetters
    ])

class ConnectionTests: XCTestCase, WKNavigationDelegate {
    let bridge = ConnectionTestBridge()
    var webView: WKWebView!

    var loadingExpectation: XCTestExpectation?
    
    func generateJSFunction(fn: String,  values: Int...) -> String {
        var template = "ConnectionTestBridge." + fn + "("
        let sum = values.reduce(0) { (sum, value) in sum + value }
        template = values.reduce(template) { (template, value) in template + "\(value)," }
        template += "(v) => { return v; }); \(sum);"
        return String(format: template, fn, values)
    }

    override func setUp() {
        webView = WKWebView()
        webView.navigationDelegate = self
    }

    override func tearDown() {
        webView.navigationDelegate = nil
        webView = nil
    }

    func loadWebViewAndWait(html: String = "<html><body></body></html>") {
        loadingExpectation = expectation(description: "web view loaded")
        webView.loadHTMLString(html, baseURL: nil)
        wait(for: [loadingExpectation!], timeout: 5)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingExpectation?.fulfill()
    }

    func testCreatingConnectionCreatesNamespace() {
        let _ = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        loadWebViewAndWait()

        property("Test connecting creates namespace", arguments: CheckerArguments(maxAllowableSuccessfulTests: 1)) <- {
            let x = self.expectation(description: "js result")
            var namespaceExists = false
            self.webView?.evaluateJavaScript("window.webkit.messageHandlers.ConnectionTestBridge !== undefined") { (result, error) in
                if case let .some(value as Bool) = result {
                    namespaceExists = value
                }
                x.fulfill()
            }
            self.wait(for: [x], timeout: 5)
            return namespaceExists
        }
    }

    func testCreatingConnectionWithBindingCreatesStub() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.foo, as: "foo")
        loadWebViewAndWait()
        
        property("Test connection with bind creating stub", arguments: CheckerArguments(maxAllowableSuccessfulTests: 1)) <- {
            let callbackExpectation = self.expectation(description: "js result")
            var stubExists = false
            self.webView?.evaluateJavaScript("ConnectionTestBridge.foo !== undefined") { (result, error) in
                if case let .some(value as Bool) = result {
                    stubExists = value
                }
                callbackExpectation.fulfill()
            }
            self.wait(for: [callbackExpectation], timeout: 5)
            return stubExists
        }
    }

    func testCallingBoundFunctionWorks() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.foo, as: "foo")
        loadWebViewAndWait()
        
        property("Test calling bound function", arguments: CheckerArguments(maxAllowableSuccessfulTests: 1)) <- {
            let callbackExpectation = self.expectation(description: "js result")
            self.webView?.evaluateJavaScript("ConnectionTestBridge.foo();") { (result, error) in
                callbackExpectation.fulfill()
            }
            self.wait(for: [callbackExpectation], timeout: 5)
            return bridge.calledFoo
        }
    }

    func testCallWithCallback() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.callWithCallback, as: "callWithCallback")
        loadWebViewAndWait()
        
        property("Test call with a callback", arguments: CheckerArguments(maxAllowableSuccessfulTests: 1)) <- {
            let callbackExpectation = self.expectation(description: "js result")
            var callbackResult = 0
            self.webView?.evaluateJavaScript("""
                ConnectionTestBridge.callWithCallback((v) => {
                    return v;
                });
                42;
            """, completionHandler: { (result, error) in
                callbackExpectation.fulfill();
                if case let .some(value as Int) = result {
                    callbackResult = value
                }
            })
            
            self.wait(for: [callbackExpectation], timeout: 5)
            return callbackResult == 42
        }
    }
    
    func testBindingUnaryWithCallback() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.unaryWithCallback, as: "unaryWithCallback")
        loadWebViewAndWait()
        
        property("Test unary with callback") <- forAll { (n0: Int) in
            let callbackExpectation = self.expectation(description: "js result")
                
            var callbackResult = 0
            let jscall = self.generateJSFunction(fn: "unaryWithCallback", values: n0)
            self.webView?.evaluateJavaScript(jscall, completionHandler: { (result, error) in
                callbackExpectation.fulfill()
                if case let .some(value as Int) = result {
                    callbackResult = value
                }
            })
                
            self.wait(for: [callbackExpectation], timeout: 5)
            return callbackResult == n0
        }
    }

    func testBindingBinaryWithCallback() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.binaryWithCallback, as: "binaryWithCallback")
        loadWebViewAndWait()

        property("Test binary with callback") <- forAll { (n0: Int, n1: Int) in
            let callbackExpectation = self.expectation(description: "js result")
            
            var callbackResult = 0
            let jscall = self.generateJSFunction(fn: "binaryWithCallback", values: n0, n1)
            self.webView?.evaluateJavaScript(jscall, completionHandler: { (result, error) in
                callbackExpectation.fulfill()
                if case let .some(value as Int) = result {
                    callbackResult = value
                }
            })
            
            self.wait(for: [callbackExpectation], timeout: 5)
            return n0 + n1 == callbackResult
        }
    }

    func testBindingTernaryWithCallback() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.ternaryWithCallback, as: "ternaryWithCallback")
        loadWebViewAndWait()

        property("Test ternary with callback") <- forAll { (n0: Int, n1: Int, n2: Int) in
            let callbackExpectation = self.expectation(description: "js result")
            
            var callbackResult = 0
            let jscall = self.generateJSFunction(fn: "ternaryWithCallback", values: n0, n1, n2)
            self.webView?.evaluateJavaScript(jscall, completionHandler: { (result, error) in
                callbackExpectation.fulfill()
                if case let .some(value as Int) = result {
                    callbackResult = value
                }
            })
            
            self.wait(for: [callbackExpectation], timeout: 5)
            return n0 + n1 + n2 == callbackResult
        }
    }

    func testBindingQuaternaryWithCallback() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.quaternaryWithCallback, as: "quaternaryWithCallback")
        loadWebViewAndWait()

        property("Test quaternary with callback") <- forAll { (n0: Int, n1: Int, n2: Int, n3: Int) in
            let callbackExpectation = self.expectation(description: "js result")
            
            var callbackResult = 0
            let jscall = self.generateJSFunction(fn: "quaternaryWithCallback", values: n0, n1, n2, n3)
            self.webView?.evaluateJavaScript(jscall, completionHandler: { (result, error) in
                callbackExpectation.fulfill()
                if case let .some(value as Int) = result {
                    callbackResult = value
                }
            })
            self.wait(for: [callbackExpectation], timeout: 5)
            return n0 + n1 + n2 + n3 == callbackResult
        }
    }

    func testBindingQuinaryWithCallback() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.quinaryWithCallback, as: "quinaryWithCallback")
        loadWebViewAndWait()

        property("Test quinary with callback") <- forAll { (n0: Int, n1: Int, n2: Int, n3: Int, n4: Int) in
            let callbackExpectation = self.expectation(description: "js result")
            var callbackResult = 0
            let jscall = self.generateJSFunction(fn: "quinaryWithCallback", values: n0, n1, n2, n3, n4)
            self.webView?.evaluateJavaScript(jscall, completionHandler: { (result, error) in
                callbackExpectation.fulfill()
                if case let .some(value as Int) = result {
                    callbackResult = value
                }
            })

            self.wait(for: [callbackExpectation], timeout: 5)
            return n0 + n1 + n2 + n3 + n4 == callbackResult
        }
    }
    
    func testUnaryWithCallbackWithString() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.unaryWithCallback, as: "unaryWithCallback")
        loadWebViewAndWait()
        
        property("Test unary with callback timing") <- forAll { (a0: String) in
            let callbackExpectation = self.expectation(description: "js result")
            var callbackResult = ""
            
            let s = uppersAndLowers.proliferateNonEmpty.map { String($0) }.generate
            let code = """
                ConnectionTestBridge.unaryWithCallback((v) => {
                    return v;
                });
                "\(s)";
            """;

            self.webView?.evaluateJavaScript(code, completionHandler: { (result, error) in
                callbackExpectation.fulfill()
                if case let .some(value as String) = result {
                    callbackResult = value
                }
            })
            
            self.wait(for: [callbackExpectation], timeout: 5)
            return callbackResult == s
        }
    }
}
