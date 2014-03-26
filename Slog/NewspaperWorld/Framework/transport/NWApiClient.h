//
//  NWAPIClient.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "NWApiClientDelegate.h"

/*
 This class needed for sending responses to server
 and getting results
 */
@interface NWApiClient : NSObject
{
@private
    
    NSString* _token;
    
    BOOL _applicationAuthorized;
}

+ (NWApiClient*)sharedClient;

/*
 @brief This method send request for application token
 @param UDID - unical identifier of user device
 @param delegate - delegate for responses
 */
- (void)authorizeApplicationWithUID:(NSString*)UID delegate:(NSObject<NWApiClientDelegate>*)delegate;

/*
 @brief This method send request for book categories
 @param delegate - delegate for responses
 @param language - ISO639-1 language code (ru, en, etc...)
 */
- (void)getCategoriesWithDelegate:(NSObject<NWApiClientDelegate>*)delegate;
- (void)getCategoriesWithDelegate:(NSObject<NWApiClientDelegate>*)delegate language:(NSString*)language;

/*
 @brief This method send request for books for specified category
 @param ID -  identifier of books category.Special categoies enumerated in NWCategories.h
 @param delegate - delegate for responses
 @param languages - array of strings with ISO639-1 language codes
 @param fileTypes - array of strings with file type constants
 */
- (void)getBooksInCategoryWithID:(int)ID delegate:(NSObject<NWApiClientDelegate>*)delegate;
- (void)getBooksInCategoryWithID:(int)ID delegate:(NSObject<NWApiClientDelegate>*)delegate languages:(NSArray*)languages fileTypes:(NSArray*)fileTypes;

/*
 @brief This method send request for find books with specified key words
 @param keyWords -  string for search
 @param delegate - delegate for responses
 @param languages - array of strings with ISO639-1 language codes
 @param fileTypes - array of strings with file type constants
 */
- (void)findBooksWithKeyWords:(NSString*)keyWords delegate:(NSObject<NWApiClientDelegate>*)delegate;
- (void)findBooksWithKeyWords:(NSString*)keyWords delegate:(NSObject<NWApiClientDelegate>*)delegate languages:(NSArray*)languages fileTypes:(NSArray*)fileTypes ;

/*
 @brief This method send request to iTunes and our server for making in-app Purchase
 @param bookID - identifier of book
 @param delegate - delegate for responses
 */
- (void)buyBookWithID:(int)bookID  delegate:(NSObject<NWApiClientDelegate>*)delegate;

/*
 @brief This method send request for URL of full version
 @param bookID - identifier of book
 @param delegate - delegate for responses
 */
- (void)getURLOfFullVersionBookWithID:(int)bookID delegate:(NSObject<NWApiClientDelegate>*)delegate;

/*
 @brief This method send request to retrieve list of purchased books
 @param delegate - delegate for responses
 @param languages - array of strings with ISO639-1 language codes
 @param fileTypes - array of strings with file type constants
 */
- (void)getPurchasedBooksWithDelegate:(NSObject<NWApiClientDelegate>*)delegate;
- (void)getPurchasedBooksWithDelegate:(NSObject<NWApiClientDelegate>*)delegate languages:(NSArray*)languages fileTypes:(NSArray*)fileTypes;

/*
 @brief This flag indicate that application authorized and has session token
 */
@property (nonatomic, readonly) BOOL applicationAuthorized;

@end
