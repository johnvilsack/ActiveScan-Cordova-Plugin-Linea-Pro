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

		NSLog(@"Linea initDT Complete");
	}];
}

- (void)getConnectionStatus:(CDVInvokedUrlCommand*)command
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

	NSString* retStr = [ NSString stringWithFormat:@"LineaProCDV.connectionChanged(%d);", state];
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

@end
