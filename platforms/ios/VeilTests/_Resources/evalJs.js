var veilTestNamespace = veilTestNamespace || {};
veilTestNamespace.TestObject = function(name) {
    this.testObjectName = name;
}
veilTestNamespace.TestObject.prototype.getName = function() {
    return this.testObjectName;
}
var testObject = new veilTestNamespace.TestObject('veil');

function methodWithNoParam() {
    return "methodWithNoParam called.";
}

function methodWithMultipleParams(boolParam, intParam, optionalIntParam, stringParam, userDefinedTypeParam) {
    const boolParamFormatted = boolParam.toString();
    const intParamFormatted = intParam.toString();
    var optionalIntParamFormatted = "null";
    if (optionalIntParam != null) {
        optionalIntParamFormatted = optionalIntParam.toString();
    }
    const userDefinedTypeParamFormatted = userDefinedTypeParam.toString();
    return boolParamFormatted + ', ' + intParamFormatted + ', ' + optionalIntParamFormatted + ', ' + stringParam + ', ' + userDefinedTypeParamFormatted;
}

function methodExpectingNewline(newline) {
    return "received newline character: " + newline;
}
