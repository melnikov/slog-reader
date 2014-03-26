//
//  FB2File.m
//

#import "FB2File.h"
#import "FB2Description.h"
#import "FB2Body.h"
#import "FB2Constants.h"
#import "FB2Binary.h"
#import "FB2Section.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement+Utils.h"

static int  _IDCounter = 0;

@interface FB2File()

- (void)loadBinaryFromRootElement:(GDataXMLElement*)rootElement;

- (void)loadBodyFromRootElement:(GDataXMLElement *)rootElement;

- (void)loadDescriptionFromRootElement:(GDataXMLElement *)rootElement;

@end

@implementation FB2File

@synthesize bookTitle;
@synthesize bookAuthor;
@synthesize notes;

#pragma mark Public methods

- (NSData*)dataForBinaryID:(NSString*)binaryID
{
    for (FB2Binary* binary in _binaries)
    {
        if ([binary.ID isEqualToString:binaryID])
        {
            return [[binary.decodedData retain] autorelease];
        }
    }
    return nil;

}

- (BOOL)openFb2File:(NSString *)filePath
{
    NSData *xmlData = [[[NSMutableData alloc] initWithContentsOfFile:filePath] autorelease];
    return [self openFb2FileWithData:xmlData];
}

- (BOOL)openFb2FileWithData:(NSData *)fb2Data
{
    NSError *error = nil;
    _IDCounter = 0;
    GDataXMLDocument * doc = [[[GDataXMLDocument alloc] initWithData:fb2Data
                                                            options:0
                                                              error:&error] autorelease];
    if (error != nil)
        return NO;
    
    GDataXMLElement* rootNode = doc.rootElement;
    if (![rootNode.name isEqualToString:FB2ElementFictionBook])
        return NO;
   
   
    [self loadDescriptionFromRootElement:rootNode];
    if (!_description)
        return NO;
    
    [self loadBodyFromRootElement:rootNode];
    if (_bodies.count == 0)
        return NO;
    
    [self loadBinaryFromRootElement:rootNode];
   
    return YES;
}

#pragma mark Memory management

- (id)init
{
    self = [super init];
    if (self)
    {   
        _bodies = [[NSMutableArray alloc] init];
        _description = nil;
        _binaries = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_bodies release];
    [_description release];
    [_binaries release];
    
    [super dealloc];
}


+ (int)nextID
{
    return _IDCounter++;
}

#pragma mark - Read description methods

- (void)loadDescriptionFromRootElement:(GDataXMLElement *)rootElement
{
    if (rootElement == nil)
        return;    
    
    GDataXMLElement* descriptionElement = [rootElement firstChildElementWithName:FB2ElementDescription];
    if (descriptionElement)
    {
        if (_description == nil)
            _description = [[FB2Description alloc] init];
        
        [_description loadFromXMLElement:descriptionElement];
    }    
}

#pragma mark - Read body methods

- (void)loadBodyFromRootElement:(GDataXMLElement *)rootElement
{
    if (rootElement == nil)
        return;
    
    NSArray* bodyElements = [rootElement elementsForName:FB2ElementBody];
    for (GDataXMLElement* bodyElement in bodyElements)
    {
        FB2Body* newBody = [[FB2Body alloc] init];
        [newBody loadFromXMLElement:bodyElement];        
        [_bodies addObject:newBody];
        [newBody release];
    }    
}


#pragma mark Read binary methods

- (void)loadBinaryFromRootElement:(GDataXMLElement*)rootElement
{
    if (rootElement == nil)
        return;
    
    NSArray* binaryElements = [rootElement elementsForName:FB2ElementBinary];
    for (GDataXMLElement* binaryElement in binaryElements)
    {
        FB2Binary* newBinary = [[FB2Binary alloc] init];
        [newBinary loadFromXMLElement:binaryElement];
        [_binaries addObject:newBinary];
        [newBinary release];
    }
}

#pragma mark Property accessors

- (NSString *)bookTitle
{
    return [_description.titleInfo bookTitle];
}

- (NSString*)bookAuthor
{
    NSString* fio = [NSString string];
    if (_description.titleInfo.authorFirstName)
        fio = [fio stringByAppendingString:_description.titleInfo.authorFirstName];
    if ([fio length]>0)
        fio = [fio stringByAppendingString:@" "];
    if (_description.titleInfo.authorLastName)
        fio = [fio stringByAppendingString:_description.titleInfo.authorLastName];    
    return fio;
}

- (NSArray*)bodies
{
    return [NSArray arrayWithArray:_bodies];
}

- (NSArray*)binaries
{
    return [NSArray arrayWithArray:_binaries];
}

- (UIImage*)bookCover
{    
    NSString* coverID = [_description.titleInfo.bookCoverHref stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    NSData* imgData = [self dataForBinaryID:coverID];
    if (imgData)
        return [UIImage imageWithData:imgData];  
    return nil;
    
}

- (FB2Body*)notes
{
    for (FB2Body* body in _bodies)
    {
        if ([body.title isEqual:FB2BodyNameNotes])
        {
            return body;
        }
    }
    return nil;
}

@end
