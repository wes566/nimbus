// Copyright (c) 2018, salesforce.com, inc.    //
// All rights reserved.    //  Copyright © 2018 Salesforce.com, inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause    //
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause

import XCTest
import SwiftCheck

@testable import Veil

class CallableTests: XCTestCase {

    let testable = Testable()

    func testNullaryCallback() {
        property("Test nullary") <- {
            let c = make_callable(Testable.nullary(testable))
            let r = try? c.call(args: []) as? Int
            return r == 0
        }
    }

    func testUnaryCallable() {
        property("Test unary") <- forAll { (n: Int) in
            let c = make_callable(Testable.unary(self.testable))
            let r = try? c.call(args: [n]) as? Int
            return r == n
        }
    }

    func testBinaryCallable() {
        property("Test binary") <- forAll { (n0: Int, n1: Int) in
            let c = make_callable(Testable.binary(self.testable))
            let r = try? c.call(args: [n0, n1]) as? Int
            return r == n0 + n1
        }
    }

    func testTernaryCallable() {
        property("Test ternary") <- forAll { (n0: Int, n1: Int, n2: Int) in
            let c = make_callable(Testable.ternary(self.testable))
            let r = try? c.call(args: [n0, n1, n2]) as? Int
            return r == n0 + n1 + n2
        }
    }

    func testQuaternaryCallable() {
        property("Test quarternary") <- forAll { (n0: Int, n1: Int, n2: Int, n3: Int) in
            let c = make_callable(Testable.quaternary(self.testable))
            let r = try? c.call(args: [n0, n1, n2, n3]) as? Int
            return r == n0 + n1 + n2 + n3
        }
    }

    func testQuinaryCallable() {
        property("Test quinary") <- forAll { (n0: Int, n1: Int, n2: Int, n3: Int, n4: Int) in
            let c = make_callable(Testable.quinary(self.testable))
            let r = try? c.call(args: [n0, n1, n2, n3, n4]) as? Int
            return r == n0 + n1 + n2 + n3 + n4
        }
    }

    func testCallbackable() {
        property("Test callback") <- forAll { (n: Int) in
            let c = make_callable(Testable.callbackable(self.testable))
            let x = self.expectation(description: "called callback")
            
            let cb: (Int) -> () = { (i: Int) in
                x.fulfill()
            }
            _ = try? c.call(args: [n, cb])
            self.wait(for: [x], timeout: 5)
            return true
        }
    }
}

class Testable {

    func nullary() -> Int {
        return 0
    }

    func unary(a0: Int) -> Int {
        return a0
    }

    func binary(a0: Int, a1: Int) -> Int {
        return a0 + a1
    }

    func ternary(a0: Int, a1: Int, a2: Int) -> Int {
        return a0 + a1 + a2
    }

    func quaternary(a0: Int, a1: Int, a2: Int, a3: Int) -> Int {
        return a0 + a1 + a2 + a3
    }

    func quinary(a0: Int, a1: Int, a2: Int, a3: Int, a4: Int) -> Int {
         return a0 + a1 + a2 + a3 + a4
    }

    func callbackable(a0: Int, a1: (Int) -> ()) {
        a1(a0)
    }
}
