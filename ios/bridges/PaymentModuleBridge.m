#import "PaymentModuleBridge.h"

@interface RCT_EXTERN_MODULE(PaymentModule, NSObject)

RCT_EXTERN_METHOD(openPayment:(NSString *) total resolver:(RCTResponseSenderBlock) resolver)
@end
