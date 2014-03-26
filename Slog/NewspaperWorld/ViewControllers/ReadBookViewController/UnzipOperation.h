//
//  UnzipOperation.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "UnzipOperationDelegate.h"

@interface UnzipOperation : NSOperation
{
    NSString* _path;
}

- (id)initWithPath:(NSString*)path;

@property (nonatomic, retain) NSObject<UnzipOperationDelegate>* delegate;

@property (nonatomic, readonly) NSString* zipFilepath;

@property (nonatomic, assign) BOOL  needDeleteSource;

@end
