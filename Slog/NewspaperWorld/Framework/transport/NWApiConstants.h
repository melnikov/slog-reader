//
//  NWApiConstants.h
//  NewspaperWorld
//

#ifndef NWWorld_NWApiConstants_h
#define NWWorld_NWApiConstants_h

///languages
static NSString * const  NWLanguageEnglish = @"en";
static NSString * const  NWLanguageRussian = @"ru";

#define NWSupportedBookLanguages [NSArray arrayWithObjects:NWLanguageRussian, NWLanguageEnglish, nil]
#define NWSupportedBookFileTypes [NSArray arrayWithObjects:NWLanguageRussian, NWLanguageEnglish, nil]

/// consumable key
static NSString * const  NWApiAuthorizationSalt = @"0ad20cec16fd9bf8eaa17020c030df04";

/// base URL
static NSString * const  NWApiClientBaseURL = @"http://app.gmi.ru/mobile/";
/// test URL
//static NSString * const  NWApiClientBaseURL = @"http://89.28.195.227:1010/mobile/";

/// methods names
static NSString * const  NWApiMethodUndefined     = @"undefined";
static NSString * const  NWApiMethodAuthorize     = @"authorization";
static NSString * const  NWApiMethodGetCategories = @"get_categories";
static NSString * const  NWApiMethodGetBooksForCategory = @"get_books_for_category";
static NSString * const  NWApiMethodFindBooks           = @"find_books";
static NSString * const  NWApiMethodGetProductID        = @"get_product_id";
static NSString * const  NWApiMethodRegisterPurchase      = @"add_purchase";
static NSString * const  NWApiMethodGetFullVersionBookURL = @"get_book_url";
static NSString * const  NWApiMethodGetPurchasedBooks     = @"get_purchased_books";

/// request parameters
static NSString * const  NWApiRequestParameterUID       = @"device_id";
static NSString * const  NWApiRequestParameterSecretKey = @"secret_key";
static NSString * const  NWApiRequestParameterToken     = @"token";
static NSString * const  NWApiRequestParameterCategoryID = @"category_id";
static NSString * const  NWApiRequestParameterKeyWords   = @"key_words";
static NSString * const  NWApiRequestParameterBookID     = @"book_id";
static NSString * const  NWApiRequestParameterQuittance  = @"quittance";
static NSString * const  NWApiRequestParameterLanguage   = @"language";
static NSString * const  NWApiRequestParameterFileType   = @"file_type";

#endif
