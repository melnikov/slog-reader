//
//  NWAPIClientDelegate.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>

@class NWCategories;
@class NWBooksList;

@protocol NWApiClientDelegate <NSObject>

@optional

- (void)apiClientReceivedToken:(NSString*)token;

- (void)apiClientReceivedCategories:(NWCategories*)categories;

- (void)apiClientReceivedBooksForCategory:(NWBooksList*)books;

- (void)apiClientReceivedSearchResult:(NWBooksList*)books;

- (void)apiClientReceivedProductID:(NSString*)productID;

- (void)apiClientPurchaseResult:(BOOL)purchase bookID:(int)bookID;

- (void)apiClientReceivedFullVersionURL:(NSString*)bookURL;

- (void)apiClientReceivedPurchasedBooks:(NWBooksList*)books;

- (void)apiClientDidFailedExecuteMethod:(NSString*)methodName error:(NSError*)error;

@end
