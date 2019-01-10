//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.webkit.WebView

interface NimbusExtension {
    fun preload(config: Map<String, String>, callback: (Boolean) -> Unit)

    fun load(config: Map<String, String>, webView: WebView, callback: (Boolean) -> Unit)

    // TODO: add bridge lifecycle hooks...
}