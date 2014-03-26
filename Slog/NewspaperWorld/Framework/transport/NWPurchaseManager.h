//
//  NWPurchaseManager.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "NWApiClientDelegate.h"

@interface NWPurchaseManager : NSObject<NWApiClientDelegate>
{
    int _bookID;
    
    NSString* _token;
    
    NSObject<NWApiClientDelegate>* _delegate;
}

+(NWPurchaseManager*)purchaseWithBookID:(int)bookID token:(NSString*)token delegate:(NSObject<NWApiClientDelegate>*)delegate;

@end
