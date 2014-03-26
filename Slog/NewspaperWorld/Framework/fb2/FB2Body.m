//
//  FB2Body.m
//
#import "FB2Section.h"
#import "FB2Epigraph.h"
#import "FB2Body.h"
#import "FB2Constants.h"
#import "GDataXMLElement+Utils.h"
#import "FB2ItemFactory.h"
#import "FB2BodyGenerator.h"

@interface FB2Body()

- (void)readEpigraphsFromBodyElement:(GDataXMLElement*)bodyElement;

- (void)readSectionsFromBodyElement:(GDataXMLElement *)bodyElement;

@end

@implementation FB2Body
@synthesize title       = _title;
@synthesize image       = _image;
@synthesize epigraphs;
@synthesize sections;

#pragma mark - Init and Dealloc
- (id)init
{
    if (self = [super init])
    {
        _sections = [[NSMutableArray alloc] init];
        _epigraphs = [[NSMutableArray alloc] init];
        _title = nil;
        _image = nil;
        self.generator = [[[FB2BodyGenerator alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [_epigraphs     release];
    [_title         release];
    [_image         release];
    [_sections release];
    [super dealloc];
}


- (void)loadFromXMLElement:(GDataXMLElement*)bodyElement
{
    if (!bodyElement || ![bodyElement.name isEqualToString:FB2ElementBody])
        return;
    
    GDataXMLElement* titleElement = [bodyElement firstChildElementWithName:FB2ElementTitle];
    if (titleElement)
    {
        [_title release];
        _title = [[FB2Title itemFromXMLElement:titleElement] retain];
    }
    GDataXMLElement* imageElement = [bodyElement firstChildElementWithName:FB2ElementImage];
    if (imageElement)
    {
        if (!_image)
            _image = [[FB2Image alloc] init];
        [_image loadFromXMLElement:imageElement];
    }
    [self readEpigraphsFromBodyElement:bodyElement];
    [self readSectionsFromBodyElement:bodyElement];
}

#pragma mark - Read data

- (void)readEpigraphsFromBodyElement:(GDataXMLElement*)bodyElement
{
    if (bodyElement == nil)
        return;
    
    NSArray* epigraphElements = [bodyElement elementsForName:FB2ElementEpigraph];
    for (GDataXMLElement* epigraphElement in epigraphElements)
    {
        FB2Epigraph * newEpigraph = [[FB2Epigraph alloc] init];
        [newEpigraph loadFromXMLElement:epigraphElement];
        [_epigraphs addObject:newEpigraph];
        [newEpigraph release];
    }

}

- (void)readSectionsFromBodyElement:(GDataXMLElement *)bodyElement
{
    if (bodyElement == nil)
        return;
    
    NSArray* sectionElements = [bodyElement elementsForName:FB2ElementSection];
    for (GDataXMLElement* sectionElement in sectionElements)
    {
        FB2Section * newSection = [[FB2Section alloc] init];        
        [newSection loadFromXMLElement:sectionElement];        
        [_sections addObject:newSection];
        [newSection release];
    }
}


#pragma mark Property accessors

- (NSArray*)sections
{
    return [NSArray arrayWithArray:_sections];
}

- (NSArray*)epigraphs
{
    return [NSArray arrayWithArray:_epigraphs];
}

@end
