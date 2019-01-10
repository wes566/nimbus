//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.support.v4.app.Fragment
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.webkit.WebView
import android.widget.RelativeLayout

class NimbusBridge(val context: Context, val appUrl: String) {
    enum class State {
        NOTREADY,
        PREINITIALIZING,
        INITIALIZING,
        LOADING,
        READY,
        ERROR
    }

    class NimbusFragment() : Fragment() {
        private var webView: WebView? = null

        override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
            val relLayout = RelativeLayout(context)
            relLayout.layoutParams = ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT)
            relLayout.addView(this.webView)

            return relLayout
        }

        fun addWebView(webView: WebView?) {
            this.webView = webView
            val container = this.view as RelativeLayout?
            container?.removeAllViews()
            container?.addView(webView)
        }
    }

    val fragment: Fragment = NimbusFragment()
    private val nimbusFragment: NimbusFragment
        get() = this.fragment as NimbusFragment;

    // TODO: do we need to start with a null webview? See if we can get rid
    // of the preinitializing state and just start with an instantiated webview
    private var webView: WebView? = null

    var state: State = State.NOTREADY
        private set

    val extensions: MutableCollection<NimbusExtension> = ArrayList()

    fun <T : NimbusExtension> addExtension(extension: T) {
        this.extensions.add(extension)
    }

    // TODO: this name stinks, but what is a better one? ¯\_(ツ)_/¯
    fun initialize() {
        this.state = State.PREINITIALIZING
        preinitializeExtensions(extensions)
    }

    private fun preinitializeExtensions(extensions: Collection<NimbusExtension>) {
        val ext = extensions.firstOrNull()
        if (ext == null) {
            preinitializingExtensionsSucceeded()
            return
        }

        ext.preload(config = mapOf(), callback = { succeeded ->
            if (succeeded) {
                this.preinitializeExtensions(extensions.drop(1))
            } else {
                this.preinitializingExtensionsFailed()
            }
        })
    }

    private fun initializeExtensions(extensions: Collection<NimbusExtension>) {
        val ext = extensions.firstOrNull()
        if (ext == null) {
            initializingExtensionsSucceeded()
            return
        }

        ext.load(config = mapOf(), webView = this.webView!!, callback = { succeeded ->
            if (succeeded) {
                this.initializeExtensions(extensions.drop(1))
            } else {
                this.initializingExtensionsFailed()
            }
        })
    }

    private fun preinitializingExtensionsSucceeded() {
        state = State.INITIALIZING

        this.webView = WebView(this.context)
        this.webView!!.layoutParams = ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT)
        this.webView!!.settings.javaScriptEnabled = true
        this.nimbusFragment.addWebView(this.webView)

        this.initializeExtensions(this.extensions)
    }

    private fun preinitializingExtensionsFailed() {
        state = State.ERROR
    }

    private fun initializingExtensionsSucceeded() {
        state = State.READY
        webView?.loadUrl(this.appUrl)

    }

    private fun initializingExtensionsFailed() {
        state = State.ERROR
    }

}