//
//  BookItemViewDelegate.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>

@protocol BookItemViewDelegate <NSObject>

- (void)buyButtonOnBookItemTouchedWithBookID:(int)bookID;

- (void)deleteButtonOnBookItemTouchedWithBookID:(int)bookID;

- (void)bookItemTouchedWithBookID:(int)bookID;

@end
