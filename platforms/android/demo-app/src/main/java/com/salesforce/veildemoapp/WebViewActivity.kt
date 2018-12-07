package com.salesforce.veildemoapp

import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.webkit.WebView

class WebViewActivity : AppCompatActivity() {

    lateinit var webView: WebView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_web_view)

        webView = findViewById(R.id.webView) as WebView
        webView.settings.javaScriptEnabled = true
        webView.loadData("<html><body></body></html>", "text/html", null)

    }
}
