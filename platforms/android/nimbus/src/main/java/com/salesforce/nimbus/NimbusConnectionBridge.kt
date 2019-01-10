//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.webkit.JavascriptInterface
import android.webkit.WebView
import java.lang.ref.WeakReference

/**
 * The NimbusConnectionBridge contains some helper methods for integration
 * of native and javascript.
 */
class NimbusConnectionBridge(webView: WebView) {

    private val webView: WeakReference<WebView> = WeakReference(webView)

    internal val connections: MutableCollection<Connection> = ArrayList()

    init {
        webView.addJavascriptInterface(this, "_nimbus")
    }

    internal fun addConnection(connection: Connection) {
        connections.add(connection)
    }

    @JavascriptInterface
    fun makeCallback(callbackId: String): Callback? {
        webView.get()?.let {
            return Callback(it, callbackId)
        }
        return null
    }

}
