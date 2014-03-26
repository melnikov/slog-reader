//
//  FB2Pages.m
//  NewspaperWorld
//

#import "FB2PagesGenerator.h"
#import "FB2PageData.h"
#import "FB2PageDataItem.h"
#import "FB2Body.h"
#import "FB2Section.h"
#import "NWSettings.h"
#import "Utils.h"
#import "FB2PageGenerationOperation.h"

@implementation FB2PagesGenerator

@synthesize generatingPages;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initializeDefaults];        
    }

    return self;
}

- (void)dealloc
{
    [self clear];
    [_context release];
    [_operations release];
    
    [super dealloc];
}


#pragma mark  Public methods

- (void)generatePagesWithFB2:(FB2File*)file pageSize:(CGSize)size delegate:(NSObject<FB2PagesGeneratorDelegate>*)delegate;
{
    [self clear];

    _context.pageWidth  = size.width;
    _context.pageHeight = size.height;
    _context.fb2File    = file;

    FB2PageGenerationOperation* operation  = [[FB2PageGenerationOperation alloc] initWithGenerator:self delegate:delegate];
    [_operations addOperation:operation];
    [operation release];
}

- (void)clear
{
    [_operations cancelAllOperations];

    [_context clear];
}

- (int)pageIndexForFB2ItemID:(int)ID
{
    for (int i = 0; i < _context.pages.count; i++)
    {
        FB2PageData* page = [_context.pages objectAtIndex:i];
        FB2PageDataItem* firstPageItem = nil;
        FB2PageDataItem* lastPageItem = nil;
        
        if (page.items.count > 0)
        {
            firstPageItem = [page.items itemAtIndex:0];
            lastPageItem = [page.items itemAtIndex:page.items.count - 1];
        }
        if (firstPageItem && lastPageItem)
        {
            if ((ID <= lastPageItem.fb2ItemID && ID >= firstPageItem.fb2ItemID) ||
                (i == 0 && ID < firstPageItem.fb2ItemID) ||
                (i == _context.pages.count - 1 && ID > lastPageItem.fb2ItemID))
                return i;
        }
    }    
    return -1;
}

- (int)pageIndexForFB2ItemID:(int)ID offset:(int)offset
{    
    NSMutableArray* arrayOfAllFoundPages = [[NSMutableArray alloc] init];
    NSMutableArray* arrayOfFoundNumbers = [[NSMutableArray alloc] init];
    int output = -1;
    
    for (int i = 0; i < _context.pages.count; i++)
    {
        FB2PageData* page = [_context.pages objectAtIndex:i];
        FB2PageDataItem* curItem = nil;
            
        for(int j = 0; j < page.items.count; j++) {
            curItem = [page.items itemAtIndex:j];
                
            if (curItem.fb2ItemID == ID) {
                if ([curItem.data isKindOfClass:[NSString class]]) {
                    NSString* txt = (NSString*)curItem.data;
                    
                    if (txt.length == 0) {
                        continue;
                    }
                }
                
                [arrayOfAllFoundPages addObject:curItem];
                [arrayOfFoundNumbers addObject:[NSNumber numberWithInt:i]];
            }
        }
    }
    
    if (arrayOfFoundNumbers.count > 0) {
        if ((offset == 0) || (arrayOfFoundNumbers.count == 1)) {
            output = [[arrayOfFoundNumbers objectAtIndex:0] intValue];
        } else {
            int overallOffset = 0;
            for(int i = 0; i < arrayOfAllFoundPages.count; i++) {
                FB2PageDataItem* item = [arrayOfAllFoundPages objectAtIndex:i];
                
                if ([item.data isKindOfClass:[NSString class]]) {
                    NSString* txt = (NSString*)item.data;
                    
                    if ((txt.length+overallOffset) > offset) {
                        output = [[arrayOfFoundNumbers objectAtIndex:i] intValue];
                        break;
                    } else {
                        overallOffset+=txt.length;
                    }
                }
            }    
        }
    } 
    
    [arrayOfAllFoundPages release];  
    [arrayOfFoundNumbers release];  
    
    return output;
}


- (FB2PageData*)pageAtIndex:(int)index
{
    if (index < 0 || index >= _context.pages.count)
        return nil;
    
    return (FB2PageData*)[_context.pages objectAtIndex:index];
}

#pragma mark Property accessors


- (int)pagesCount
{
    return _context.pages.count;
}

- (BOOL)generatingPages
{
    return _operations.operationCount != 0;
}

#pragma mark Private methods

- (void)initializeDefaults
{
    _context = [[FB2PageGeneratorContext alloc] init];    
    _operations = [[NSOperationQueue alloc] init];
}
- (void)generatePagesForAllBook
{   
    for (FB2Body* body in _context.fb2File.bodies)
    {
        [body generatePagesWithContext:_context parentStyle:nil];
    }
}

@end
