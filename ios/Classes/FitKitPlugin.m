#import "FitKitPlugin.h"
#import <fit_kit/fit_kit-Swift.h>

@implementation FitKitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFitKitPlugin registerWithRegistrar:registrar];
}
@end
