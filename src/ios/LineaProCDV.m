#import "LineaProCDV.h"

@implementation LineaProCDV

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

		// Get App Preferences internally
		[self applicationPreferences];

		NSLog(@"Linea initDT Complete");

	}];
}

- (void)getConnState:(CDVInvokedUrlCommand*)command
{
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[dtdev connstate]];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Required for init
- (void)connectionState: (int)state {

	switch (state) {
		case CONN_DISCONNECTED:
		case CONN_CONNECTING:
			break;
		case CONN_CONNECTED:
			break;
	}

	NSString* retStr = [ NSString stringWithFormat:@"LineaProCDV.changedConnState(%d);", state];
	[[super webView] stringByEvaluatingJavaScriptFromString:retStr];
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

- (void) barcodeData: (NSString *) barcode type:(int) type {
	NSString* retStr = [ NSString stringWithFormat:@"LineaProCDV.barcodeData('%@', '%@');", barcode, [dtdev barcodeType2Text:type]];
	[[super webView] stringByEvaluatingJavaScriptFromString:retStr];
}

//Common Linea Settings are grabbed from Settings.bundle.
- (void)applicationPreferences {

	// Get Defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString* URLString = [defaults stringForKey:@"URLString"]; // This is the initial page load
	BOOL ScanWhileCharging = [defaults boolForKey:@"ScanWhileCharging"]; 
	BOOL FastCharge = [defaults boolForKey:@"FastCharge"];

	if (URLString == nil || [URLString isEqual:@"index.html"]) {
		NSString* URLString = @"index.html";
		NSLog(@"URL: %@ (Default)", URLString);
	} else {
		NSLog(@"URL: %@", URLString);
	}

	// EnablePassThroughSync is unintuitive. Option to "Scan While Charging" passed as the preference
	if (!ScanWhileCharging) {
		NSLog(@"ScanWhileCharging: FALSE (Default)");
	} else {
		NSLog(@"ScanWhileCharging: TRUE");
	}

	if (!FastCharge) {
		NSLog(@"FastCharge: FALSE (Default)");
	} else {
		NSLog(@"FastCharge: TRUE");
	}

//	[[NSUserDefaults standardUserDefaults] synchronize];
}



@end
