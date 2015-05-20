//
//  PTAPIManager.h
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 2/25/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PTAPIManagerFailure)(NSError *error);
typedef void (^PTAPIManagerSuccessItems)(NSArray *items);
typedef void (^PTAPIManagerSuccessItem)(NSDictionary *item);
typedef void (^PTAPIManagerSuccessNone)();

typedef NS_ENUM(NSInteger, PTItemType) {
    PTItemTypeMovie,
    PTItemTypeShow,
    PTItemTypeAnime,
};

@interface PTAPIManager : NSObject

+ (instancetype)sharedManager;

- (void)showInfoWithType:(PTItemType)type
                  withId:(NSString *)imdbId
                 success:(PTAPIManagerSuccessItem)success
                 failure:(PTAPIManagerFailure)failure;

- (void)searchForShowWithType:(PTItemType)type
                         name:(NSString *)name
                      success:(PTAPIManagerSuccessItems)success
                      failure:(PTAPIManagerFailure)failure;

- (void)topShowsWithType:(PTItemType)type
                withPage:(NSUInteger)page
                 success:(PTAPIManagerSuccessItems)success
                 failure:(PTAPIManagerFailure)failure;

// Trakt.tv
/*
+ (NSString *)trakttvAccessToken;
+ (void)updateTrakttvAccessToken:(NSString *)accessToken;
+ (NSURL *)trakttvAuthorizationURL;
- (void)accessTokenWithAuthorizationCode:(NSString *)authorizationCode
                             success:(void(^)(NSString *accessToken))success
                             failure:(PTAPIManagerFailure)failure;

- (void)createListWithName:(NSString *)name
                   success:(PTAPIManagerSuccessNone)success
                   failure:(PTAPIManagerFailure)failure;
*/

@end
