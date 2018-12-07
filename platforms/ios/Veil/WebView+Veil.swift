//
//  Copyright © 2018 Salesforce.com, inc. All rights reserved.
//

import WebKit

extension WKWebView {

    /**
     Create a connection from this web view to the specified object.
     */
    public func addConnection<C>(to target: C, as namespace: String) -> Connection<C> {
        return Connection(from: self, to: target, as: namespace)
    }
}
