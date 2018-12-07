
// There can be many promises so creating a storage for later look-up.
var promises = {}
var callbacks = {}

// https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
function uuidv4() {
    return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
                                                (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16));
}

function cloneArguments(args) {
    var clonedArgs = []
    for (var i = 0; i < args.length; ++i) {
        if (typeof args[i] === 'function') {
            let callbackId = uuidv4();
            callbacks[callbackId] = args[i];
            clonedArgs.push({callbackId});
        } else {
            clonedArgs.push(args[i]);
        }
    }
    return clonedArgs;
}

function callCallback(callbackId, args) {
    if (callbacks[callbackId]) {
        callbacks[callbackId](...args);
    }
}

// Native side will callback this method. Match the callback to stored promise
// in the storage
function resolvePromise(promiseUuid, data, error) {
    if (error) {
        promises[promiseUuid].reject(data);
    } else {
        promises[promiseUuid].resolve(data.v);
    }
    // remove reference to stored promise
    delete promises[promiseUuid];
}
