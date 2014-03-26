//
//  FB2TitleInfo.h
//  NewspaperWorld

#import "GDataXMLNode.h"
#import "FB2Item.h"

@interface FB2TitleInfo : FB2Item

- (void)loadFromXMLElement:(GDataXMLElement*)element;

@property(nonatomic,readonly) NSString *authorFirstName;

@property(nonatomic,readonly) NSString *authorMiddleName;

@property(nonatomic,readonly) NSString *authorLastName;

@property(nonatomic,readonly) NSString *bookTitle;

@property(nonatomic,readonly) NSString *bookCoverHref;

@end
