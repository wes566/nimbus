//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

extension WKWebView {
    /**
     Broadcast a message to subscribers listening on Javascript side.  Message can be
     delivered with an argument so that subscriber can use that pass useful data.

     - Parameter name: Message name.  Listeners are keying on unique message names on Javascript side.
     There can be multiple listeners listening on same message.
     - Parameter arg: Any encodable object to pass to Javascript as useful data.  If there is nothing to be
     passed don't specify the parameter since it has nil as default parameter.
     - Parameter completionHandler: A block to invoke when script evaluation completes or fails. You do not
     have to pass a closure if you are not interested in getting the callback.
     */
    public func broadcastMessage(name: String, arg: Encodable? = nil, completionHandler: ((Int, Error?) -> Void)? = nil) {
        var script = ""
        if let validArg = arg {
            let wrappedValue = EncodableValue.value(validArg)
            let jsonEncoder = JSONEncoder()
            var jsonString = "{v:undefined}"
            if let jsonData = try? jsonEncoder.encode(wrappedValue) {
                jsonString = String(data: jsonData, encoding: .utf8)!
            }
            script = """
                try {
                    var jsonData = \(jsonString);
                    var unwrappedArg = jsonData.v;
                    if (unwrappedArg) {
                        window.__nimbus.broadcastMessage('\(name)', unwrappedArg);
                    } else {
                        window.__nimbus.broadcastMessage('\(name)');
                    }
                } catch(e) {
                    console.log('Error parsing JSON during a call to broadcastMessage:' + e.toString());
                }
            """
        } else {
            script = """
                window.__nimbus.broadcastMessage('\(name)');
            """
        }
        evaluateJavaScript(script) { (result: Any?, error: Error?) in
            if let handler = completionHandler {
                if error == nil {
                    let completedCount = result as? Int ?? 0
                    handler(completedCount, nil)
                } else {
                    handler(0, error!)
                }
            }
        }
    }
}
