//
//  LineaProCDV.h
//
//  Created by Timofey Tatarinov on 27.01.14.
//  Citronium
//  http://citronium.com
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

#import "DTDevices.h"

@interface LineaProCDV : CDVPlugin
{
    DTDevices *dtdev;
}

- (void)initDT:(CDVInvokedUrlCommand*)command;
- (void)getConnectionStatus:(CDVInvokedUrlCommand*)command;
- (void)startBarcode:(CDVInvokedUrlCommand*)command;
- (void)stopBarcode:(CDVInvokedUrlCommand*)command;

- (void)setPassThroughSync:(CDVInvokedUrlCommand*)command;
- (void)unsetPassThroughSync:(CDVInvokedUrlCommand*)command;

- (void)discoverDevices:(CDVInvokedUrlCommand*)command;

- (void)btConnect:(CDVInvokedUrlCommand*)command;
- (void)btDisconnect:(CDVInvokedUrlCommand*)command;

- (void)btGetDeviceName:(CDVInvokedUrlCommand*)command;

- (void)btWrite:(CDVInvokedUrlCommand*)command;
- (void)prnPrintText:(CDVInvokedUrlCommand*)command;
- (void)prnPrintZPL:(CDVInvokedUrlCommand*)command;

@end
