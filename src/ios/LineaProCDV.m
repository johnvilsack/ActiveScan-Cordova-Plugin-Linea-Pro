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
			// check prefs every connection load
			[self applicationPreferences];
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

	NSError *error=nil;

	// Get Preferences
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString* URLString = [defaults stringForKey:@"URLString"]; // This is the initial page load
	BOOL ScanWhileCharging = [defaults boolForKey:@"ScanWhileCharging"]; 
	BOOL FastCharge = [defaults boolForKey:@"FastCharge"];

// @@ DefaultURL
	if (URLString == nil || [URLString isEqual:@"index.html"]) {
		NSString* URLString = @"index.html";
		NSLog(@"URL: %@ (Default)", URLString);
	} else {
		NSLog(@"URL: %@", URLString);
	}
// !@ DefaultURL

// @@ PassThroughSync
	// EnablePassThroughSync is unintuitive. Option to "Scan While Charging" passed as the preference
	if (!ScanWhileCharging) {
		NSLog(@"ScanWhileCharging: FALSE (Default)");
		// You can scan while charging or connected to pistol grip, but you can't sync
		[dtdev setPassThroughSync:true error:&error];
	} else {
		// This puts the scanner back in sync mode, so iTunes, XCode, etc. work
		if (![dtdev setPassThroughSync:false error:&error]) {
			NSLog(@"ScanWhileCharging: TRUE");
		}
	}
// !@ PassThroughSync

// @@ USBChargeCurrent
int current;
// See if current is set.  If it's not, assume lower (default)
if (![dtdev getUSBChargeCurrent:&current error:&error]) {
	current = 500;
	NSLog(@"Parameter for USBChargeCurrent Not Set");
}

	if (!FastCharge) {
		// FastCharge is not set or FALSE.  Default to 500ma
		NSLog(@"FastCharge: FALSE (Default)");
		if (current != 500) {
			int newCurrent = 500;
			[dtdev setUSBChargeCurrent:newCurrent error:&error];
		} 
	} else {
		// FastCharge is set to TRUE.  Set to 1A
		NSLog(@"FastCharge: TRUE");
		if (current != 1000) {
			int newCurrent = 1000;
			[dtdev setUSBChargeCurrent:newCurrent error:&error];
		} 
	}
// !@ USBChargeCurrent

	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
