//
//  FB2Description.h
//
#import "GDataXMLNode.h"
#import "FB2TitleInfo.h"
#import "FB2DocumentInfo.h"
#import "FB2PublishInfo.h"
#import "FB2Item.h"

@interface FB2Description : FB2Item
{
    FB2TitleInfo* _titleInfo;
    
    FB2DocumentInfo* _documentInfo;
    
    FB2PublishInfo* _publishInfo;
}

- (void)loadFromXMLElement:(GDataXMLElement*)element;

@property (nonatomic, readonly) FB2TitleInfo* titleInfo;

@property (nonatomic, readonly) FB2DocumentInfo* documentInfo;

@property (nonatomic, readonly) FB2PublishInfo* publishInfo;

@end
