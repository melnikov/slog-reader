//
//  NWPurchaseManager.m
//  NewspaperWorld
//

#import "NWPurchaseManager.h"
#import "MKStoreManager.h"

@implementation NWPurchaseManager

#pragma mark Memory management

- (id)initWithBookID:(int)bookID token:(NSString*)token delegate:(NSObject<NWApiClientDelegate>*)delegate
{
    self = [super init];
    if (self)
    {
        _bookID = bookID;
        _delegate = [delegate retain];
        _token = [token copy];
    }
    return self;
}

- (void)dealloc
{
    [_delegate release];    _delegate = nil;
    _bookID = -1;
    [_token release];   _token = nil;
    [super dealloc];
}

#pragma mark Public methods

+ (NWPurchaseManager*)purchaseWithBookID:(int)bookID token:(NSString*)token delegate:(NSObject<NWApiClientDelegate>*)delegate
{
    return [[[NWPurchaseManager alloc] initWithBookID:bookID token:token delegate:delegate] autorelease];
}

- (void)apiClientReceivedProductID:(NSString *)productID
{
    NSString* featureID = productID;
    
    [[MKStoreManager sharedManager] buyFeature:featureID
                                        bookID:_bookID
                                         token:_token
                                    onComplete:^(NSString* purchasedFeature)
     {
         if (_delegate && [_delegate respondsToSelector:@selector(apiClientPurchaseResult:bookID:)])
         {
             [_delegate apiClientPurchaseResult:YES bookID:_bookID];
         }         
     }
                                   onCancelled:^
     {
         if (_delegate && [_delegate respondsToSelector:@selector(apiClientPurchaseResult:bookID:)])
         {
             [_delegate apiClientPurchaseResult:NO bookID:_bookID];
         }
     }];    
}

- (void)apiClientDidFailedExecuteMethod:(NSString *)methodName error:(NSError *)error
{
  if (_delegate && [_delegate respondsToSelector:@selector(apiClientPurchaseResult:bookID:)])
  {
    [_delegate apiClientPurchaseResult:NO bookID:_bookID];
  }
}
@end
