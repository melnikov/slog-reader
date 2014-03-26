//
//  UnzipOperation.m
//  NewspaperWorld
//

#import "UnzipOperation.h"
#import "ZipFile.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"
#import "Utils.h"

@implementation UnzipOperation

@synthesize delegate;
@synthesize zipFilepath = _path;
@synthesize needDeleteSource;

- (id)initWithPath:(NSString*)path
{
    self = [super init];
    if (self)
    {
        _path = [path copy];
        delegate = nil;        
    }
    return self;
}

- (void)dealloc
{
    [_path release];
    [delegate release];
    [super dealloc];
}


- (void)main
{    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    @try
    {
        if (![Utils fileExistsAtPath:_path])
            return;
        
        ZipFile*       zipFile    = [[ZipFile alloc] initWithFileName:_path mode:ZipFileModeUnzip];
        ZipReadStream* readStream = [zipFile readCurrentFileInZip];
        FileInZipInfo* info       = [zipFile getCurrentFileInZipInfo];
        
        NSMutableData* buffer = [NSMutableData dataWithLength:info.length];
        [readStream readDataWithBuffer:buffer];
        [zipFile release];
        
        if ([delegate respondsToSelector:@selector(unzipOperationFinished:withData:)])
            [delegate unzipOperationFinished:self withData:buffer];
    }
    @catch (NSException *exception) {
        if ([delegate respondsToSelector:@selector(unzipOperationFailed:)])
            [delegate unzipOperationFailed:self];
    }
    @finally {
        [pool release];        
    }
}
@end
