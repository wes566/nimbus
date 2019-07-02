package com.salesforce.nimbus

@Extension(name = "callbackTestExtension")
class CallbackTestExtension : NimbusExtension {
    @ExtensionMethod
    fun callbackWithSingleParam(arg: (param0: MochaTests.MochaMessage) -> Unit) {
        arg(MochaTests.MochaMessage())
    }

    @ExtensionMethod
    fun callbackWithTwoParams(arg: (param0: MochaTests.MochaMessage, param1: MochaTests.MochaMessage) -> Unit) {
        var mochaMessage = MochaTests.MochaMessage("int param is 6", 6)
        arg(MochaTests.MochaMessage(), mochaMessage)
    }

    @ExtensionMethod
    fun callbackWithSinglePrimitiveParam(arg: (param0: Int) -> Unit) {
        arg(777)
    }

    @ExtensionMethod
    fun callbackWithTwoPrimitiveParams(arg: (param0: Int, param1: Int) -> Unit) {
        arg(777, 888)
    }

    @ExtensionMethod
    fun callbackWithPrimitiveAndUddtParams(arg: (param0: Int, param1: MochaTests.MochaMessage) -> Unit) {
        arg(777, MochaTests.MochaMessage())
    }
}
