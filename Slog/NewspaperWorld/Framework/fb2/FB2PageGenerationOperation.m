//
//  FB2PageGenerationOperation.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 19.11.12.
//
//

#import "FB2PageGenerationOperation.h"
#import "FB2Body.h"

@interface FB2PagesGenerator(Operation)

- (void)generatePagesForAllBook;

@end

@implementation FB2PageGenerationOperation

- (id)initWithGenerator:(FB2PagesGenerator*)generator delegate:(NSObject<FB2PagesGeneratorDelegate> *)delegate
{
    self = [super init];
    if (self)
    {
        _generator  = [generator retain];
        _delegate   = [delegate retain];
    }
    return self;
}

- (void)dealloc
{
    [_delegate release];
    _delegate = nil;
    
    [_generator release];
    _generator = nil;   
    
    [super dealloc];
}


- (void)main
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    @try
    {
        [_generator generatePagesForAllBook];
        if ([_delegate respondsToSelector:@selector(pageGeneratingFinished)])
        {
            [_delegate performSelectorOnMainThread:@selector(pageGeneratingFinished) withObject:nil waitUntilDone:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"[Exception: Page generating error: %@]", exception.description);
    }
    @finally {
        [pool release];
    }
}
@end
