//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbusdemoapp

import android.webkit.CookieManager
import android.webkit.WebView
import com.salesforce.nimbus.NimbusExtension

class CookieExtension : NimbusExtension {
    override fun preload(config: Map<String, String>, callback: (Boolean) -> Unit) {
        callback(true)
    }

    override fun load(config: Map<String, String>, webView: WebView, callback: (Boolean) -> Unit) {
        val cookieString = "mycookie=cookieValue"
        CookieManager.getInstance().setCookie("10.0.2.2:3000", cookieString)

        callback(true)
    }
}