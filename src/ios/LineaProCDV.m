//
//  LineaProCDV.m
//
//  Created by Timofey Tatarinov on 27.01.14.
//  Citronium
//  http://citronium.com
//

#import "LineaProCDV.h"

@interface LineaProCDV()

+ (NSString*) getPDF417ValueByCode: (NSArray*) codesArr code:(NSString*)code;

@end

@implementation LineaProCDV

-(void) scannerConect:(NSString*)num {

    NSString *jsStatement = [NSString stringWithFormat:@"reportConnectionStatus('%@');", num];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];

}

-(void) scannerBattery:(NSString*)num {

    int percent;
    float voltage;

	if([dtdev getBatteryCapacity:&percent voltage:&voltage error:nil])
    {
        NSString *status = [NSString stringWithFormat:@"Bat: %.2fv, %d%%",voltage,percent];

        // send to web view
        NSString *jsStatement = [NSString stringWithFormat:@"reportBatteryStatus('%@');", status];
        [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];

    }
}

- (void)initDT:(CDVInvokedUrlCommand*)command
{
    // runInBackground Fix
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;

        if (!dtdev) {
            dtdev = [DTDevices sharedDevice];
            [dtdev addDelegate:self];
            [dtdev connect];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// Preferences settings fro Lineas
- (void) readFromSettingsFile:(CDVInvokedUrlCommand*)command
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    //bundle path
    NSString *bPath = [[NSBundle mainBundle] bundlePath];
    NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *plistFile = [settingsPath stringByAppendingPathComponent:@"Root.plist"];   

    // Dictionary and Primary Array
    NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];

    //Preferences Array
    NSDictionary *pref;

    // BOOL latestNews = ![[NSUserDefaults standardUserDefaults] boolForKey:@"notLatestNews"];

    for(pref in preferencesArray)
    {
        //get the key
        NSString *keyValue = [pref objectForKey:@"Key"];
        //get the default
        id defaultValue = [pref objectForKey:@"DefaultValue"];

        NSLog(@"%@, %@", defaultValue, keyValue);
        
        // if we have both, set in defaults
        if (keyValue && defaultValue)
        [standardUserDefaults setObject:defaultValue forKey:keyValue];
    }

    int retPassThroughSync = [[standardUserDefaults objectForKey:@"PassThroughSync"] intValue];

    NSLog(@"%i", retPassThroughSync);

    // keep the in-memory cache in sync with the database
   [standardUserDefaults synchronize];

    //FIGURE OUT HOW TO GET RESULTS BACK TO HTML.
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:retPassThroughSync];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getConnectionStatus:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[dtdev connstate]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)startBarcode:(CDVInvokedUrlCommand *)command
{
    [dtdev barcodeStartScan:nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[dtdev connstate]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)stopBarcode:(CDVInvokedUrlCommand *)command
{
    [dtdev barcodeStopScan:nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[dtdev connstate]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)connectionState: (int)state {
    NSLog(@"connectionState: %d", state);

    switch (state) {
		case CONN_DISCONNECTED:
		case CONN_CONNECTING:
                break;
		case CONN_CONNECTED:
		{
			NSLog(@"PPad connected!\nSDK version: %d.%d\nHardware revision: %@\nFirmware revision: %@\nSerial number: %@", dtdev.sdkVersion/100,dtdev.sdkVersion%100,dtdev.hardwareRevision,dtdev.firmwareRevision,dtdev.serialNumber);
			break;
		}
	}

    NSString* retStr = [ NSString stringWithFormat:@"LineaProCDV.connectionChanged(%d);", state];
    [[super webView] stringByEvaluatingJavaScriptFromString:retStr];
}

- (void) deviceButtonPressed: (int) which {
    NSLog(@"deviceButtonPressed: %d", which);
}

- (void) deviceButtonReleased: (int) which {
    NSLog(@"deviceButtonReleased: %d", which);
}

- (void) barcodeData: (NSString *) barcode type:(int) type {
    NSLog(@"barcodeData: barcode - %@, type - %@", barcode, [dtdev barcodeType2Text:type]);
    NSString* retStr = [ NSString stringWithFormat:@"LineaProCDV.onBarcodeData('%@', '%@');", barcode, [dtdev barcodeType2Text:type]];
    [[super webView] stringByEvaluatingJavaScriptFromString:retStr];
}

- (void) barcodeNSData: (NSData *) barcode isotype:(NSString *) isotype {
    NSLog(@"barcodeNSData: barcode - %@, type - %@", [[NSString alloc] initWithData:barcode encoding:NSUTF8StringEncoding], isotype);
    NSString* retStr = [ NSString stringWithFormat:@"LineaProCDV.onBarcodeData('%@', '%@');", [[NSString alloc] initWithData:barcode encoding:NSUTF8StringEncoding], isotype];
    [[super webView] stringByEvaluatingJavaScriptFromString:retStr];
}

- (void)setPassThroughSync:(CDVInvokedUrlCommand *)command
{
    NSError *error=nil;

    BOOL dtResult = [dtdev setPassThroughSync:true error:&error];
    NSLog(@"setPassThroughSync: %d", dtResult);

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)unsetPassThroughSync:(CDVInvokedUrlCommand *)command
{
    NSError *error=nil;

    if (![dtdev setPassThroughSync:false error:&error])
        NSLog(@"unsetPassThroughSync: %i %@", 0, error.description);
    else
        NSLog(@"unsetPassThroughSync: %i", 1);

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

+ (NSString*) getPDF417ValueByCode: (NSArray*) codesArr code:(NSString*)code {
    for (NSString* currStr in codesArr) {
        // do something with object
        NSRange range = [currStr rangeOfString:code];
        if (range.length == 0) continue;
        NSString *substring = [[currStr substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return substring;
    }
    return NULL;
}

+ (NSString*) generateStringForArrayEvaluationInJS: (NSArray*) stringsArray {
    NSString* arrayJSString = [NSString stringWithFormat:@"["];
    BOOL isFirst = TRUE;
    for (int i = 0; i < stringsArray.count; ++i) {
        NSString* currString = [stringsArray objectAtIndex:i];
        if (currString.length <= 1) continue;
        arrayJSString = [NSString stringWithFormat:@"%@%@\"%@\"", arrayJSString, isFirst ? @"" : @",", currString];
        isFirst = FALSE;
    }
    arrayJSString = [NSString stringWithFormat:@"%@]", arrayJSString];
    return arrayJSString;
}

- (void) barcodeNSData: (NSData *) barcode type:(int) type {
    NSLog(@"barcodeNSData: barcode - %@, type - %@", [[NSString alloc] initWithData:barcode encoding:NSUTF8StringEncoding], [dtdev barcodeType2Text:type]);
    NSArray *codesArr = [[[NSString alloc] initWithData:barcode encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:
                        [NSCharacterSet characterSetWithCharactersInString:@"\n\r"]];
    NSString* substrDateBirth = @"DBB";
    NSString* dateBirth = [LineaProCDV getPDF417ValueByCode:codesArr code: substrDateBirth];
    NSString* substrName = @"DAC";
    NSString* name = [LineaProCDV getPDF417ValueByCode:codesArr code: substrName];
    NSString* substrLastName = @"DCS";
    NSString* lastName = [LineaProCDV getPDF417ValueByCode:codesArr code: substrLastName];
    NSString* substrEye = @"DAY";
    NSString* eye = [LineaProCDV getPDF417ValueByCode:codesArr code: substrEye];
    NSString* substrState = @"DAJ";
    NSString* state = [LineaProCDV getPDF417ValueByCode:codesArr code: substrState];
    NSString* substrCity = @"DAI";
    NSString* city = [LineaProCDV getPDF417ValueByCode:codesArr code: substrCity];
    NSString* substrHeight = @"DAU";
    NSString* height = [LineaProCDV getPDF417ValueByCode:codesArr code: substrHeight];
    NSString* substrWeight = @"DAW";
    NSString* weight = [LineaProCDV getPDF417ValueByCode:codesArr code: substrWeight];
    NSString* substrGender = @"DBC";
    NSString* gender = [LineaProCDV getPDF417ValueByCode:codesArr code: substrGender];
    NSString* substrHair = @"DAZ";
    NSString* hair = [LineaProCDV getPDF417ValueByCode:codesArr code: substrHair];
    NSString* substrExpires = @"DBA";
    NSString* expires = [LineaProCDV getPDF417ValueByCode:codesArr code: substrExpires];
    NSString* substrLicense = @"DAQ";
    NSString* license = [LineaProCDV getPDF417ValueByCode:codesArr code: substrLicense];
    NSLog(@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@", dateBirth, name, lastName, eye, state, city, height, weight, gender, hair, expires, license);

    NSString* rawCodesArrJSString = [LineaProCDV generateStringForArrayEvaluationInJS:codesArr];
    //LineaProCDV.onBarcodeData(scanId, dob, state, city, expires, gender, height, weight, hair, eye)
    NSString* retStr = [ NSString stringWithFormat:@"var rawCodesArr = %@; LineaProCDV.onBarcodeData(rawCodesArr, '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@');", rawCodesArrJSString, license, dateBirth, state, city, expires, gender, height, weight, hair, eye, name, lastName];
    [[super webView] stringByEvaluatingJavaScriptFromString:retStr];
}

@end
