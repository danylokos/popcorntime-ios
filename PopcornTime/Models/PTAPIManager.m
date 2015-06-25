//
//  PTAPIManager.m
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 2/25/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

#import "PTAPIManager.h"

#import <UIKit/UIKit.h>

NSUInteger const PTAPIManagerResultsLimit = 30;
NSString *const PTAPIManagerMoviesEndPoint = @"http://cloudflare.com/api/v2";
NSString *const PTAPIManagerShowsEndPoint = @"http://eztvapi.re";
NSString *const PTAPIManagerAnimeEndPoint = @"http://ptp.haruhichan.com";

@implementation PTAPIManager

static NSDictionary *YTSHTTPHeaders;

#pragma mark - Public API

+ (void)initialize
{
    YTSHTTPHeaders = @{@"Host": @"eqwww.image.yt"};
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static PTAPIManager *sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [[PTAPIManager alloc] init];
    });
    return sharedManager;
}

- (void)showInfoWithType:(PTItemType)type
                  withId:(NSString *)imdbId
                 success:(PTAPIManagerSuccessItem)success
                 failure:(PTAPIManagerFailure)failure
{
    switch (type) {
        case PTItemTypeMovie: { [self movieInfoWithId:imdbId success:success failure:failure]; break; }
        case PTItemTypeShow: { [self tvSeriesInfoWithId:imdbId success:success failure:failure]; break; }
        case PTItemTypeAnime: { [self animeInfoWithId:imdbId success:success failure:failure]; break; }
        default: break;
    }
}

- (void)searchForShowWithType:(PTItemType)type
                        name:(NSString *)name
                      success:(PTAPIManagerSuccessItems)success
                      failure:(PTAPIManagerFailure)failure
{
    switch (type) {
        case PTItemTypeMovie: { [self searchForMovieWithName:name success:success failure:failure]; break; }
        case PTItemTypeShow: { [self searchForTVSeriesWithName:name success:success failure:failure]; break; }
        case PTItemTypeAnime: { [self searchForAnimeWithName:name success:success failure:failure]; break; }
        default: break;
    }
}

- (void)topShowsWithType:(PTItemType)type
                withPage:(NSUInteger)page
                 success:(PTAPIManagerSuccessItems)success
                 failure:(PTAPIManagerFailure)failure{
    switch (type) {
        case PTItemTypeMovie: { [self topMoviesWithPage:page success:success failure:failure]; break; }
        case PTItemTypeShow: { [self topTVSeriesWithPage:page success:success failure:failure]; break; }
        case PTItemTypeAnime: { [self topAnimeWithPage:page success:success failure:failure]; break; }
        default: break;
    }
}

#pragma mark - Private Methods

- (void)dataFromURL:(NSURL *)URL
            success:(void(^)(id JSONObject))success
            failure:(PTAPIManagerFailure)failure
{
    return [self dataFromURL:URL HTTPheaders:nil success:success failure:failure];
}

- (void)dataFromURL:(NSURL *)URL
            HTTPheaders:(NSDictionary *)HTTPheaders
            success:(void(^)(id JSONObject))success
            failure:(PTAPIManagerFailure)failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    if (HTTPheaders) {
        for (NSString *key in HTTPheaders.allKeys) {
            [request addValue:HTTPheaders[key] forHTTPHeaderField:key];
        }
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          dispatch_async(dispatch_get_main_queue(), ^{

            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
              
              void (^handleError)(NSError *) = ^(NSError *error) {
                  if (error) { NSLog(@"%@", error); if (failure) { failure(error); } return; }
              };
              
              handleError(error);
              
              NSError *JSONError;
              id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
              handleError(JSONError);
              
              if (success) { success(JSONObject); };
          });
      }] resume];
}

#pragma mark Movies

- (void)topMoviesWithPage:(NSUInteger)page
                  success:(PTAPIManagerSuccessItems)success
                  failure:(PTAPIManagerFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"list_movies.json?"
                      "page=%ld&limit=%ld&order_by=desc&sort_by=seeds", (long)page + 1, (long)PTAPIManagerResultsLimit];
    
    NSString *URLString = [PTAPIManagerMoviesEndPoint stringByAppendingPathComponent:path];
    [self dataFromURL:[NSURL URLWithString:URLString] HTTPheaders:YTSHTTPHeaders success:^(id JSONObject) {
        if (success) {
            NSArray *items = [[((NSDictionary *)JSONObject) objectForKey:@"data"] objectForKey:@"movies"];
            success(items);
        }
    } failure:failure];
}
- (void)movieInfoWithId:(NSString *)imdbId
                success:(PTAPIManagerSuccessItem)success
                failure:(PTAPIManagerFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"movie_details.json?movie_id=%@", imdbId];
    NSString *URLString = [PTAPIManagerMoviesEndPoint stringByAppendingPathComponent:path];
    [self dataFromURL:[NSURL URLWithString:URLString] HTTPheaders:YTSHTTPHeaders success:^(id JSONObject) {
        if (success) {
            NSDictionary *item = [((NSDictionary *)JSONObject) objectForKey:@"data"];
            success(item);
        }
    } failure:failure];
}

- (void)searchForMovieWithName:(NSString *)name
                       success:(PTAPIManagerSuccessItems)success
                       failure:(PTAPIManagerFailure)failure
{
    NSString *path = [[NSString stringWithFormat:@"list_movies.json?limit=%ld&query_term=%@", (long)PTAPIManagerResultsLimit, name]
                      stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *URLString = [PTAPIManagerMoviesEndPoint stringByAppendingPathComponent:path];
    [self dataFromURL:[NSURL URLWithString:URLString] HTTPheaders:YTSHTTPHeaders success:^(id JSONObject) {
        if (success) {
            NSArray *items = [[((NSDictionary *)JSONObject) objectForKey:@"data"] objectForKey:@"movies"];
            success(items);
        }
    } failure:failure];
}

#pragma mark TVSeries

- (void)topTVSeriesWithPage:(NSUInteger)page
                 success:(PTAPIManagerSuccessItems)success
                 failure:(PTAPIManagerFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"shows/%ld?limit=%lu&order=desc&sort=seeds", (long)page + 1, (long)PTAPIManagerResultsLimit];
    NSString *URLString = [PTAPIManagerShowsEndPoint stringByAppendingPathComponent:path];
    [self dataFromURL:[NSURL URLWithString:URLString]success:^(id JSONObject) {
        if (success) {
            success((NSArray *)JSONObject);
        }
    } failure:failure];
}

- (void)tvSeriesInfoWithId:(NSString *)imdbId
                   success:(PTAPIManagerSuccessItem)success
                   failure:(PTAPIManagerFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"show/%@", imdbId];
    NSString *URLString = [PTAPIManagerShowsEndPoint stringByAppendingPathComponent:path];
    [self dataFromURL:[NSURL URLWithString:URLString]success:^(id JSONObject) {
        if (success) {
            success((NSDictionary *)JSONObject);
        }
    } failure:failure];
}

- (void)searchForTVSeriesWithName:(NSString *)name
                      success:(PTAPIManagerSuccessItems)success
                      failure:(PTAPIManagerFailure)failure
{
    NSString *path = [[NSString stringWithFormat:@"shows/1?limit=%ld&keywords=%@&sort=seeds", (long)PTAPIManagerResultsLimit, name]
                      stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *URLString = [PTAPIManagerShowsEndPoint stringByAppendingPathComponent:path];
    [self dataFromURL:[NSURL URLWithString:URLString]success:^(id JSONObject) {
        if (success) {
            success((NSArray *)JSONObject);
        }
    } failure:failure];
}

#pragma mark Anime

- (void)topAnimeWithPage:(NSUInteger)page
                 success:(PTAPIManagerSuccessItems)success
                 failure:(PTAPIManagerFailure)failure
{
    NSString *path = [[NSString stringWithFormat:@"list.php?page=%ld&limit=%ld&sort=popularity&type=All", (long)page, (long)PTAPIManagerResultsLimit]
                      stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *URLString = [PTAPIManagerAnimeEndPoint stringByAppendingPathComponent:path];

    [self dataFromURL:[NSURL URLWithString:URLString]success:^(id JSONObject) {
        if (success) {
            success((NSArray *)JSONObject);
        }
    } failure:failure];
}

- (void)animeInfoWithId:(NSString *)imdbId
                success:(PTAPIManagerSuccessItem)success
                failure:(PTAPIManagerFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"anime.php?id=%@", imdbId];
    NSString *URLString = [PTAPIManagerAnimeEndPoint stringByAppendingPathComponent:path];
    [self dataFromURL:[NSURL URLWithString:URLString]success:^(id JSONObject) {
        if (success) {
            success((NSDictionary *)JSONObject);
        }
    } failure:failure];
}

- (void)searchForAnimeWithName:(NSString *)name
                       success:(PTAPIManagerSuccessItems)success
                       failure:(PTAPIManagerFailure)failure {
    
    NSString *path = [[NSString stringWithFormat:@"/list.php?search=%@&limit=%ld&sort=popularity&type=All",
                       [name stringByReplacingOccurrencesOfString:@" " withString:@"+"], (long)PTAPIManagerResultsLimit]
                      stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *URLString = [PTAPIManagerAnimeEndPoint stringByAppendingPathComponent:path];
    
    [self dataFromURL:[NSURL URLWithString:URLString]success:^(id JSONObject) {
        if (success) {
            success((NSArray *)JSONObject);
        }
    } failure:failure];
}

#pragma mark - Trakt.tv

NSString *const PTAPIManagerTrakttvAccessTokenKey = @"TrakttvAccessToken";

NSString *const PTAPIManagerTrakttvAPIEndPoint = @"http://api.trakt.tv";
NSString *const PTAPIManagerTrakttvAPIKey = @"df8d400233727be104e5caf40e07d785b6963c0e194dcbd24f806e8a4e243167";
NSString *const PTAPIManagerTrakttvAPIVersion = @"2";

NSString *const PTAPIManagerTrakttvClientId = @"df8d400233727be104e5caf40e07d785b6963c0e194dcbd24f806e8a4e243167";
NSString *const PTAPIManagerTrakttvClientSecret = @"1a98885c5271f7162ac51b2c1dd09decc55df127f5e1b29af533d35eee5df9b2";
NSString *const PTAPIManagerTrakttvRedirectURL = @"urn:ietf:wg:oauth:2.0:oob";

+ (NSString *)trakttvAccessToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PTAPIManagerTrakttvAccessTokenKey];
}

+ (void)updateTrakttvAccessToken:(NSString *)accessToken
{
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:PTAPIManagerTrakttvAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSURL *)trakttvAuthorizationURL
{
    NSString *authPath = [NSString stringWithFormat:@"http://trakt.tv/oauth/authorize?client_id=%@&redirect_uri=%@&response_type=code",
                          PTAPIManagerTrakttvClientId,
                          PTAPIManagerTrakttvRedirectURL];
    return [NSURL URLWithString:authPath];
}

- (void)trakttvPerformRequestWithAPIMethod:(NSString *)APIMethod
                                HTTPMethod:(NSString *)HTTPMethod
                           HTTPBodyPayload:(NSDictionary *)HTTPBodyPayload
                             OAuthRequired:(BOOL)OAuthRequired
                                   success:(void(^)(id JSONObject))success
                                   failure:(PTAPIManagerFailure)failure
{
    NSString *path = [PTAPIManagerTrakttvAPIEndPoint stringByAppendingPathComponent:APIMethod];
    NSURL *URL = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = HTTPMethod;
    
    // Configure headers
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request addValue:PTAPIManagerTrakttvAPIKey forHTTPHeaderField:@"trakt-api-key"];
    [request addValue:PTAPIManagerTrakttvAPIVersion forHTTPHeaderField:@"trakt-api-version"];
    
    if (OAuthRequired) {
        NSString *bearerToken = [NSString stringWithFormat:@"Bearer [%@]", [PTAPIManager trakttvAccessToken]];
        [request addValue:bearerToken forHTTPHeaderField:@"Authorization"];
    }

    void (^handleError)(NSError *) = ^(NSError *error) {
        if (error) { NSLog(@"%@", error); if (failure) { failure(error); } return; }
    };
    
    // Configure body
    NSError *JSONError;
    NSData *JSONBody = [NSJSONSerialization dataWithJSONObject:HTTPBodyPayload options:0 error:&JSONError];
    handleError(JSONError);
    request.HTTPBody = JSONBody;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          dispatch_async(dispatch_get_main_queue(), ^{
              handleError(error);
              
              NSError *JSONError;
              id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
              handleError(JSONError);
              
              if (success) { success(JSONObject); }
          });
      }] resume];
}

- (void)accessTokenWithAuthorizationCode:(NSString *)authorizationCode
                                 success:(void(^)(NSString *accessToken))success
                                 failure:(PTAPIManagerFailure)failure
{
    NSString *APIMethod = @"oauth/token";
    NSDictionary *HTTPBodyPayload = @{@"code": authorizationCode,
                                      @"client_id": PTAPIManagerTrakttvClientId,
                                      @"client_secret": PTAPIManagerTrakttvClientSecret,
                                      @"redirect_uri": PTAPIManagerTrakttvRedirectURL,
                                      @"grant_type": @"authorization_code"};
    
    [self trakttvPerformRequestWithAPIMethod:APIMethod
                                  HTTPMethod:@"POST"
                             HTTPBodyPayload:HTTPBodyPayload
                               OAuthRequired:NO
                                     success:^(id JSONObject) {
                                         if (success) {
                                             success([((NSDictionary *)JSONObject) objectForKey:@"access_token"]);
                                         }
                                     }
                                     failure:failure];
}

- (void)createListWithName:(NSString *)name
                   success:(PTAPIManagerSuccessNone)success
                   failure:(PTAPIManagerFailure)failure
{
    NSString *APIMethod = @"users/me/lists";
    NSDictionary *HTTPBodyPayload = @{@"name": @"ololo",
                                      @"description": @"ololo",
                                      @"privacy": @"private",
                                      @"display_numbers": @"false",
                                      @"allow_comments": @"true"};

    [self trakttvPerformRequestWithAPIMethod:APIMethod
                                  HTTPMethod:@"POST"
                             HTTPBodyPayload:HTTPBodyPayload
                               OAuthRequired:YES
    success:nil failure:failure];
}

@end
