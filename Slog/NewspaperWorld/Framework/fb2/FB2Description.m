//
//  FB2Description.m
//

#import "FB2Description.h"
#import "FB2Constants.h"
#import "GDataXMLElement+Utils.h"

@implementation FB2Description

@synthesize titleInfo = _titleInfo;

@synthesize publishInfo = _publishInfo;

@synthesize documentInfo = _documentInfo;

- (id)init
{
    if (self = [super init])
    {
        _titleInfo = [[FB2TitleInfo alloc] init];
        _documentInfo = [[FB2DocumentInfo alloc] init];
        _publishInfo = [[FB2PublishInfo alloc] init];
        return self;
    }
    return nil;
}

- (void)dealloc
{
    [_titleInfo release];
    [_documentInfo release];
    [_publishInfo release];
    [super dealloc];
}

#pragma mark Public methods

- (void)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementDescription])
        return;
    
    GDataXMLElement *titleInfoElement = [element firstChildElementWithName:FB2ElementTitleInfo];
    [_titleInfo loadFromXMLElement:titleInfoElement];
    
    GDataXMLElement *documentInfoElement = [element firstChildElementWithName:FB2ElementDocumentInfo];
    [_documentInfo loadFromXMLElement:documentInfoElement];   
    
    GDataXMLElement *publishInfoElement = [element firstChildElementWithName:FB2ElementPublishInfo];
    [_publishInfo loadFromXMLElement:publishInfoElement];   
}

@end
