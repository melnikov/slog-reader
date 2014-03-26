//
//  FB2DocumentInfo.m
//  NewspaperWorld

#import "FB2DocumentInfo.h"
#import "FB2Constants.h"
#import "GDataXMLElement+Utils.h"

@implementation FB2DocumentInfo

@synthesize documentID;

#pragma mark Memory management


- (void)dealloc
{
    [documentID release];    documentID = nil;
    [super dealloc];
}

#pragma mark Public methods

- (void)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementDocumentInfo])
        return;
    
    GDataXMLElement* idElement = [element firstChildElementWithName:FB2ElementID];
    if (idElement)
    {
        [documentID release];
        documentID = [[idElement stringValue] copy];
    }
}
@end
