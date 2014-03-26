//
//  FB2TitleInfo.m
//  NewspaperWorld

#import "FB2TitleInfo.h"
#import "FB2Constants.h"
#import "GDataXMLElement+Utils.h"
#import "FB2Image.h"

@implementation FB2TitleInfo

@synthesize authorFirstName;
@synthesize authorMiddleName;
@synthesize authorLastName;
@synthesize bookTitle;
@synthesize bookCoverHref;

#pragma mark Memory management

- (id)init
{
    self = [super init];
    if (self)
    {
        authorFirstName = nil;
        authorMiddleName = nil;
        authorLastName = nil;
        bookTitle = nil;
        bookCoverHref = nil;
    }
    return self;
}
- (void)dealloc
{
    [authorFirstName release];  authorFirstName = nil;
    [authorMiddleName release]; authorMiddleName = nil;
    [authorLastName release];   authorLastName = nil;
    [bookTitle release];        bookTitle = nil;
    [bookCoverHref release];    bookCoverHref = nil;
    [super dealloc];
}

#pragma mark Public methods

- (void)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementTitleInfo])
        return;

    GDataXMLElement* bookTitleElement = [element firstChildElementWithName:FB2ElementBookTitle];
    if (bookTitleElement)
    {
        [bookTitle release];
        bookTitle = [[bookTitleElement stringValue] copy];
    }
    GDataXMLElement* authorElement = [element firstChildElementWithName:FB2ElementAuthor];
    if (authorElement)
    {
        GDataXMLElement* firstNameElement  = [authorElement firstChildElementWithName:FB2ElementFirstName];
        if (firstNameElement)
        {
            [authorFirstName release];
            authorFirstName  = [[firstNameElement stringValue] copy];
        }
        GDataXMLElement* middleNameElement = [authorElement firstChildElementWithName:FB2ElementMiddleName];
        if (middleNameElement)
        {
            [authorMiddleName release];
            authorMiddleName = [[middleNameElement stringValue] copy];
        }
        GDataXMLElement* lastNameElement   = [authorElement firstChildElementWithName:FB2ElementLastName];
        if (lastNameElement)
        {
            [authorLastName release];
            authorLastName   = [[lastNameElement stringValue] copy];
        }
    }
    GDataXMLElement* coverElement = [element firstChildElementWithName:FB2ElementCoverPage];
    if (coverElement)
    {
        GDataXMLElement* imageElement  = [coverElement firstChildElementWithName:FB2ElementImage];
        if (imageElement)
        {
            [bookCoverHref release];
            bookCoverHref = [[FB2Image imageFromXMLElement:imageElement].href copy];
        }
    }
        
}
@end
