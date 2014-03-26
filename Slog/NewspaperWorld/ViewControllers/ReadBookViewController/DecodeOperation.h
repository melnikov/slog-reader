//
//  DecodeOperation.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "DecodeOperationDelegate.h"

@interface DecodeOperation : NSOperation
{
    NSString* _path;
    
    NSString* _salt;
}

- (id)initWithPath:(NSString*)path salt:(NSString*)salt;

@property (nonatomic, retain) NSObject<DecodeOperationDelegate>* delegate;


@end
