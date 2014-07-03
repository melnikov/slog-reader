//
//  HttpClient.m
//  NewspaperWorld
//

#import "NWApiClient.h"
#import "NWModelConstants.h"
#import "NWApiConstants.h"
#import "NWApiErrors.h"
#import "Utils.h"
#import "AFNetworking.h"
#import "NWCategories.h"
#import "NWBooksList.h"
#import "SBJson.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "NWPurchaseManager.h"
#import "Constants.h"
#import "NWLocalizationManager.h"
#import "NSString+MD5Addition.h"

static NWApiClient* _instance = nil;

/// Blocks for http responses
typedef void (^SuccessResponseBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON);
typedef void (^FailureResponseBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON);

/*
 Function removes static instance of class
 */
static void singleton_remover()
{
    [_instance release]; _instance = nil;
}

/*
 Private declarations
 */
@interface NWApiClient(Private)

/*
 @brief This method generate url and send get request
 @param methodName - string constant enumerated in NWAPIConstants.h
 @param parameters - dictionary with method parameters if it's needed. must be nil
 @param delegate - user specified delegate
 */
- (void)invokeMethodNamed:(NSString*)methodName parameters:(NSDictionary*)parameters delegate:(NSObject<NWApiClientDelegate>*)delegate;

/*
 @brief This method sends get request to specified url
 @param url - string with url
 @param delegate - user specified delegate
*/
- (void)sendRequest:(NSURLRequest*)urlRequest delegate:(NSObject<NWApiClientDelegate>*)delegate;

///Temporary dummy method
- (void)dummyInvoke:(NSArray*)params;

- (NSString*)generateSecretKeyForUID:(NSString*)UID;

- (void)handleJSON:(id)json delegate:(NSObject<NWApiClientDelegate>*)delegate;

- (void)handleMethodNamed:(NSString*)methodName responseData:(NSObject*)responseData delegate:(NSObject<NWApiClientDelegate>*)delegate;

@end


@implementation NWApiClient

@synthesize applicationAuthorized = _applicationAuthorized;

#pragma mark Memory managment

- (id)init
{
    self = [super init];
    if (self)
    {
        _token = nil;
        _applicationAuthorized = NO;
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

- (void)dealloc
{
    [_token release];
    [super dealloc];
}

#pragma mark Singleton method

+ (NWApiClient*)sharedClient
{
    if (!_instance)
    {
        _instance = [[NWApiClient alloc] init];
        atexit(singleton_remover);
    }
    return _instance;
}

#pragma mark Public methods

- (void)authorizeApplicationWithUID:(NSString*)UID
                           delegate:(NSObject<NWApiClientDelegate>*)delegate
{
	NSString * filePath = [[Utils documentsDirectoryPath] stringByAppendingPathComponent:@"access"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NO])
	{
		NSStringEncoding encoding = 0;
		
		UID = [[NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:NULL] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
	}
	
	NSString * secretKey = [self generateSecretKeyForUID:UID];
	
	NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    UID,       NWApiRequestParameterUID,
                                    secretKey, NWApiRequestParameterSecretKey, nil];
	
    [self invokeMethodNamed:NWApiMethodAuthorize parameters:parameters delegate:delegate];
}

- (void)getCategoriesWithDelegate:(NSObject<NWApiClientDelegate>*)delegate
{
    NSString* lang = [NWLocalizationManager sharedManager].interfaceLanguage;
    [self getCategoriesWithDelegate:delegate language:lang];
}

- (void)getCategoriesWithDelegate:(NSObject<NWApiClientDelegate> *)delegate
                         language:(NSString *)language
{
        NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                        _token,     NWApiRequestParameterToken,
                                        language,   NWApiRequestParameterLanguage, nil];
#warning iOS7 need fix
//    if ([Utils isiOS7]){
//        parameters = nil;
//    }
 
    
    [self invokeMethodNamed:NWApiMethodGetCategories parameters:parameters delegate:delegate];
}

- (void)getBooksInCategoryWithID:(int)ID
                        delegate:(NSObject<NWApiClientDelegate>*)delegate
{
    [self getBooksInCategoryWithID:ID
                          delegate:delegate
                         languages:NWSupportedBookLanguages
                         fileTypes:NWSupportedBookFileTypes];
}

- (void)getBooksInCategoryWithID:(int)ID
                        delegate:(NSObject<NWApiClientDelegate>*)delegate
                       languages:(NSArray*)languages
                       fileTypes:(NSArray*)fileTypes
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%d",ID], NWApiRequestParameterCategoryID,
                                _token,                               NWApiRequestParameterToken, nil];
    if (languages.count > 0)
        [parameters setObject:languages forKey:NWApiRequestParameterLanguage];
    if (fileTypes.count > 0)
        [parameters setObject:fileTypes forKey:NWApiRequestParameterFileType];

    [self invokeMethodNamed:NWApiMethodGetBooksForCategory parameters:parameters delegate:delegate];
}

- (void)findBooksWithKeyWords:(NSString*)keyWords  delegate:(NSObject<NWApiClientDelegate>*)delegate
{
    [self findBooksWithKeyWords:keyWords
                       delegate:delegate
                      languages:NWSupportedBookLanguages
                      fileTypes:NWSupportedBookFileTypes];
}

- (void)findBooksWithKeyWords:(NSString*)keyWords
                     delegate:(NSObject<NWApiClientDelegate>*)delegate
                    languages:(NSArray*)languages
                    fileTypes:(NSArray*)fileTypes
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:keyWords, NWApiRequestParameterKeyWords,
                                _token,   NWApiRequestParameterToken, nil];
    if (languages.count > 0)
        [parameters setObject:languages forKey:NWApiRequestParameterLanguage];
    if (fileTypes.count > 0)
        [parameters setObject:fileTypes forKey:NWApiRequestParameterFileType];
    [self invokeMethodNamed:NWApiMethodFindBooks parameters:parameters delegate:delegate];
}

- (void)buyBookWithID:(int)bookID  delegate:(NSObject<NWApiClientDelegate>*)delegate
{
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",bookID], NWApiRequestParameterBookID,
                                                                          _token,                                   NWApiRequestParameterToken, nil];
    [self invokeMethodNamed:NWApiMethodGetProductID
                 parameters:parameters
                   delegate:[NWPurchaseManager purchaseWithBookID:bookID token:_token delegate:delegate]];
}

- (void)getURLOfFullVersionBookWithID:(int)bookID delegate:(NSObject<NWApiClientDelegate>*)delegate
{
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",bookID], NWApiRequestParameterBookID,
                                                                          _token,                                   NWApiRequestParameterToken, nil];
    [self invokeMethodNamed:NWApiMethodGetFullVersionBookURL parameters:parameters delegate:delegate];
}

- (void)getPurchasedBooksWithDelegate:(NSObject<NWApiClientDelegate>*)delegate
{
    [self getPurchasedBooksWithDelegate:delegate
                              languages:NWSupportedBookLanguages
                              fileTypes:NWSupportedBookFileTypes];
}

- (void)getPurchasedBooksWithDelegate:(NSObject<NWApiClientDelegate>*)delegate
                            languages:(NSArray*)languages
                            fileTypes:(NSArray*)fileTypes
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:_token,  NWApiRequestParameterToken, nil];
    if (languages.count > 0)
        [parameters setObject:languages forKey:NWApiRequestParameterLanguage];
    if (fileTypes.count > 0)
        [parameters setObject:fileTypes forKey:NWApiRequestParameterFileType];
    [self invokeMethodNamed:NWApiMethodGetPurchasedBooks parameters:parameters delegate:delegate];
}

#pragma mark Private methods

- (void)invokeMethodNamed:(NSString*)methodName parameters:(NSDictionary*)parameters delegate:(NSObject<NWApiClientDelegate>*)delegate
{    
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    
    NSString* parametersString = @"";
    NSString* parameterPrefix = nil;    
    NSObject* parameterValue = nil;
    
    for (NSString* parameterName in [parameters allKeys])
    {    
        parameterPrefix = ([parametersString length] == 0) ? @"?": @"&";
        parameterValue = [parameters objectForKey:parameterName];
        
        if ([parameterValue isKindOfClass:[NSString class]])
        {
            NSString* strValue = (NSString*)parameterValue;
            parametersString = [parametersString stringByAppendingFormat:@"%@%@=%@", parameterPrefix, parameterName, strValue];
        }
        if ([parameterValue isKindOfClass:[NSArray class]])
        {
            NSArray* arrayValue = (NSArray*)parameterValue;
            for (NSString* strValue in arrayValue)            
                parametersString = [parametersString stringByAppendingFormat:@"%@%@=%@", parameterPrefix, parameterName, strValue];
            
        }
    }
    AFHTTPClient*        httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:NWApiClientBaseURL]];
    NSMutableURLRequest* request    = [httpClient requestWithMethod:@"GET" path:methodName parameters:parameters];

    
    //TODO: this is a test method
#if TEST_MODE
    [self performSelector:@selector(dummyInvoke:) withObject:[NSArray arrayWithObjects:methodName, parameters, delegate, nil] afterDelay:1];
#else
    [self sendRequest:request delegate:delegate];
#endif

}

- (NSString*)generateSecretKeyForUID:(NSString*)UID
{    
    return [Utils md5WithString:[UID stringByAppendingString:NWApiAuthorizationSalt]];
}

- (void)sendRequest:(NSURLRequest*)urlRequest delegate:(NSObject<NWApiClientDelegate>*)delegate
{    
    AFJSONRequestOperation* operation = 
        [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest
                                                        success: ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         [self handleJSON:JSON delegate:delegate];
         
         [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];         
     }
                                                        failure: ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {   
         [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
         if (!JSON)
         {
             if ( [delegate respondsToSelector:@selector(apiClientDidFailedExecuteMethod:error:)])
             {          
                 [delegate apiClientDidFailedExecuteMethod:NWApiMethodUndefined error:error];
             }   
             return;
         }  
         [self handleJSON:JSON delegate:delegate];
     }];
     [operation start];
}

- (void)handleJSON:(id)json delegate:(NSObject<NWApiClientDelegate>*)delegate;
{
    NSError* error = nil;
     
    if (![json isKindOfClass:[NSDictionary class]])
    {
        if ( [delegate respondsToSelector:@selector(apiClientDidFailedExecuteMethod:error:)])
        {
            error = [NSError errorWithDomain:NWApiErrorDomainFormat
                                        code:1
                                    userInfo:nil];
            [delegate apiClientDidFailedExecuteMethod:NWApiMethodUndefined error:error];
        }
        NSLog(@"[ERROR] json object is not dictionary");
        return;
    }
    
    NSDictionary* jsonDictionary = (NSDictionary*)json;
    
    NSString* responseMethod = [jsonDictionary  objectForKey:NWApiJSONKeyResponseMethod];
    int       responseCode   = [[jsonDictionary objectForKey:NWApiJSONKeyResponseCode] intValue];
    NSString* responseText   = [jsonDictionary  objectForKey:NWApiJSONKeyResponseText];
    NSObject* responseData   = [jsonDictionary  objectForKey:NWApiJSONKeyResponseData];
    
    if (responseCode != kNWApiResponseCodeSuccess)
    {
        if ( [delegate respondsToSelector:@selector(apiClientDidFailedExecuteMethod:error:)])
        {
            error = [NSError errorWithDomain:NWApiErrorDomainServerApi
                                        code:responseCode
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NWApiJSONKeyResponseText, responseText, nil]];
            [delegate apiClientDidFailedExecuteMethod:NWApiMethodUndefined error:error];
        }
        if ([responseMethod isEqualToString:NWApiMethodAuthorize])
        {
            _token = nil;
        }            
        NSLog(@"[ERROR] error response %@",responseText);
        return;
    }    
    [self handleMethodNamed:responseMethod responseData:responseData delegate:delegate];
}

- (void)handleMethodNamed:(NSString*)methodName responseData:(NSObject*)responseData delegate:(NSObject<NWApiClientDelegate>*)delegate
{
    if ([methodName isEqualToString:NWApiMethodAuthorize] )
    { 
        if ([responseData isKindOfClass:[NSString class]])
        {
            [_token release];
            _token = [(NSString*)responseData retain];
            if ([delegate respondsToSelector:@selector(apiClientReceivedToken:)])
                [delegate apiClientReceivedToken:(NSString*)responseData];
        }        
    }
    if ([methodName isEqualToString:NWApiMethodGetCategories])
    {
        NWCategories* categories = [NWCategories categoriesFromResponseData:responseData];
        if ([delegate respondsToSelector:@selector(apiClientReceivedCategories:)])
            [delegate apiClientReceivedCategories:categories];        
    }
    if ([methodName isEqualToString:NWApiMethodGetBooksForCategory])
    {
        NWBooksList* books = [NWBooksList booksFromResponseData:responseData];
        if ([delegate respondsToSelector:@selector(apiClientReceivedBooksForCategory:)])
            [delegate apiClientReceivedBooksForCategory:books];        
    }
    if ([methodName isEqualToString:NWApiMethodFindBooks])
    {
        NWBooksList* books = [NWBooksList booksFromResponseData:responseData];
        if ([delegate respondsToSelector:@selector(apiClientReceivedSearchResult:)])
            [delegate apiClientReceivedSearchResult:books];
    }
    if ([methodName isEqualToString:NWApiMethodGetProductID])
    {
        NSString* productID = [[(NSString*)responseData retain] autorelease];
        if ([delegate respondsToSelector:@selector(apiClientReceivedProductID:)])
            [delegate apiClientReceivedProductID:productID];
    }
    if ([methodName isEqualToString:NWApiMethodGetFullVersionBookURL])
    {
        NSString* bookURL = [[(NSString*)responseData retain] autorelease];
        if ([delegate respondsToSelector:@selector(apiClientReceivedFullVersionURL:)])
            [delegate apiClientReceivedFullVersionURL:bookURL];
    }    
    if ([methodName isEqualToString:NWApiMethodGetPurchasedBooks])
    {
        NWBooksList* books = [NWBooksList booksFromResponseData:responseData];
        if ([delegate respondsToSelector:@selector(apiClientReceivedPurchasedBooks:)])
            [delegate apiClientReceivedPurchasedBooks:books];
    }
}


#pragma mark Test temporary methods

- (void)dummyInvoke:(NSArray*)params
{
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    
    NSString* methodName                    = [params objectAtIndex:0];
    NSObject<NWApiClientDelegate>* delegate = [params objectAtIndex:2];
    
    NSString*       jsonString = nil;
    NSString*       pathToDefaultResponses = [[NSBundle mainBundle] pathForResource:@"default_responses" ofType:@"plist"];
    NSDictionary*   defaultResponses = [NSDictionary dictionaryWithContentsOfFile:pathToDefaultResponses];
    
    
    jsonString = (NSString*)[defaultResponses objectForKey:methodName];
    
    NSLog(@"json: %@", jsonString);
    
    NSError* error = nil;
    SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
    
    id result = [parser objectWithString:jsonString error:&error];
    if (error)
    {
        NSLog(@"json error: %ld %@", (long)error.code, [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        if ( [delegate respondsToSelector:@selector(apiClientDidFailedExecuteMethod:error:)])
        {
            error = [NSError errorWithDomain:NWApiErrorDomainFormat
                                        code:1
                                    userInfo:nil];
            [delegate apiClientDidFailedExecuteMethod:NWApiMethodUndefined error:error];
        }
        return;
    }
    [self handleJSON:result delegate:delegate];   
}

#pragma mark Property accessors

- (BOOL)applicationAuthorized
{
    return [_token length] > 0;
}

@end
