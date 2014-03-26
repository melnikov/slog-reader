//
//  FB2Poem.h
//  NewspaperWorld
//

#import "FB2TextItem.h"
#import "FB2Date.h"
#import "FB2TextAuthor.h"

@interface FB2Poem : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@property (nonatomic, readonly) FB2TextAuthor* textAuthor;
@property (nonatomic, readonly) FB2Date* date;

@end
