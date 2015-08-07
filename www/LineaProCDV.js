var argscheck = require('cordova/argscheck'),
    channel = require('cordova/channel'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec'),
    cordova = require('cordova');

 function LineaProCDV() {
    this.results = [];
    this.connCallback = null;
    this.errorCallback = null;
    this.cancelCallback = null;
    this.barcodeCallback = null;
}

LineaProCDV.prototype.initDT = function(connectionCallback, barcCallback, cancelCallback, errorCallback) {
    this.results = [];
    this.connCallback = connectionCallback;
    this.barcodeCallback = barcCallback;

    exec(null, errorCallback, "LineaProCDV", "initDT", []);
    console.log("Initialized");
    console.log("Connection Callback");
    console.log(connectionCallback);
};

LineaProCDV.prototype.barcodeStart = function() {
    exec(null, null, "LineaProCDV", "startBarcode", []);
};

LineaProCDV.prototype.barcodeStop = function() {
    exec(null, null, "LineaProCDV", "stopBarcode", []);
};

LineaProCDV.prototype.connectionChanged = function(state) {
    this.connCallback(state);
};

LineaProCDV.prototype.setPassThroughSync = function() {
    exec(null, null, "LineaProCDV", "setPassThroughSync", []);
}

LineaProCDV.prototype.unsetPassThroughSync = function() {
    exec(null, null, "LineaProCDV", "unsetPassThroughSync", []);
}

LineaProCDV.prototype.onBarcodeData = function(rawCodesArr, scanId, dob, state, city, expires, gender, height, weight, hair, eye, firstName, lastName) {
    var data = {
               rawCodesArr: rawCodesArr,
               scanId: scanId,
               dob: dob,
               state: state,
               city: city,
               expires: expires,
               gender: gender,
               height: height,
               weight: weight,
               hair: hair,
               eye: eye,
               firstName: firstName,
               lastName: lastName
               };
    this.barcodeCallback(data);
};

module.exports = new LineaProCDV();
