
function showAlert() {
    DemoAppBridge.showAlert("Hello from javascript!")
        .then(() => {
            console.log('alert shown');
        });
}

function logCurrentTime() {
    DemoAppBridge.currentTime()
        .then((time) => {
            console.log(`the time is ${time}`);
        });
}

function doCallback() {
    DemoAppBridge.withCallback((v) => {
                               console.log(`callback got ${v}`);
                               });
}
