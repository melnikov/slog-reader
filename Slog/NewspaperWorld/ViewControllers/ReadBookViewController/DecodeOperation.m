//
//  DecodeOperation.m
//  NewspaperWorld
//

#import "DecodeOperation.h"
#import "Utils.h"

@implementation DecodeOperation

@synthesize delegate;

- (id)initWithPath:(NSString*)path salt:(NSString*)salt
{
    self = [super init];
    if (self)
    {
        
        delegate = nil;
        _path = [path copy];
        _salt = [salt copy];
        delegate = nil;
    }
    return self;
    
}

- (void)dealloc
{
    [_path release];
    [_salt release];
    [delegate release];
    [super dealloc];
}

- (void)main
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    @try
    {
        NSData* sourceData = [NSData dataWithContentsOfFile:_path];        
        NSString* strKey = [[Utils md5WithString: _salt] substringToIndex:16];
        NSData* keyData = [strKey dataUsingEncoding:NSUTF8StringEncoding];
        NSData* decrypted = [sourceData AES128DecryptWithKey:keyData];
        if ([delegate respondsToSelector:@selector(decodeOperationFinishedWithData:)])
            [delegate decodeOperationFinishedWithData:decrypted];
    }
    @catch (NSException *exception) {
        if ([delegate respondsToSelector:@selector(decodeOperationFailed)])
            [delegate decodeOperationFailed];
            
    }
    @finally {
        [pool release];
    }
}

@end
