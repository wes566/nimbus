package com.salesforce.nimbus

import org.junit.Test
import kompile.testing.kotlinc

interface NimbusExtension{}

class NimbusProcessorTest {
    @Test
    fun generate_Extension(){
        kotlinc().
                withProcessors(NimbusProcessor())
                .addKotlin("input.kt", """
            package com.salesforce.nimbus

//            @Extension(name = "ExtensionTestName")
            class ExtensionTestClass : NimbusExtension {
                @ExtensionMethod
                fun testExtensionMethod(): String {
                    return "pass"
                }
            }
        """.trimIndent())
                .compile()
                .succeededWithoutWarnings()
                .generatedFile("generatedKtFile.kt")
                .hasSourceEquivalentTo("""
            package com.salesforce.nimbus;

            import static com.salesforce.nimbus.WebViewExtensionsKt.callJavascript;

            import android.webkit.JavascriptInterface;
            import android.webkit.WebView;
            import java.lang.Override;
            import java.lang.String;
            import org.json.JSONObject;

            public class ExtensionTestClassBinder implements NimbusBinder {
                private final ExtensionTestClass target;

                private WebView webView;

                private final String extensionName = "ExtensionTestName";

                public ExtensionTestClassBinder(ExtensionTestClass target) {
                    this.target = target;
                }

                @Override
                public NimbusExtension getExtension() {
                    return target;
                }

                @Override
                public String getExtensionName() {
                    return extensionName;
                }

                @Override
                public void setWebView(WebView webView) {
                    this.webView = webView;
                }

                @JavascriptInterface
                public String testExtensionMethod() {
                    return JSONObject.quote(target.testExtensionMethod());
                }
            }
        """.trimIndent())

    }

}