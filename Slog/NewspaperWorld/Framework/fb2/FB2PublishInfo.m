//
//  FB2PublishInfo.m
//  NewspaperWorld

#import "FB2PublishInfo.h"
#import "FB2Constants.h"
#import "GDataXMLElement+Utils.h"

@implementation FB2PublishInfo

@synthesize publisher;

@synthesize originalBookName;

- (id)init
{
    self = [super init];
    if (self)
    {
        publisher = nil;
        originalBookName = nil;
    }
    return self;
}

- (void)dealloc
{
    [publisher release]; 
    [originalBookName release];
    
    [super dealloc];
}
#pragma mark Public methods

- (void)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementPublishInfo])
        return;
    
    GDataXMLElement* publisherElement = [element firstChildElementWithName:FB2ElementPublisher];
    if (publisherElement)
    {
        [publisher release];
        publisher = [[publisherElement stringValue] copy];
    }
    
    GDataXMLElement* bookNameElement = [element firstChildElementWithName:FB2ElementBookName];
    if (bookNameElement)    
    {
        [originalBookName release];
        originalBookName = [[bookNameElement stringValue] copy];
    }
}

@end
