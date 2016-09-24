//
//  SpotifyAuth.m
//  spotifyModule
//
//  Created by Jack on 8/8/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <Spotify/Spotify.h>
#import "SpotifyAuth.h"
#import "SpotifyLoginViewController.h"
#import "AppDelegate.h"

@interface SpotifyAuth ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSArray *requestedScopes;
@property (nonatomic, strong) NSURL *tokenSwapURL;
@property (nonatomic, strong) NSURL *tokenRefreshURL;
@end

@implementation SpotifyAuth

RCT_EXPORT_MODULE()

//Start session
RCT_EXPORT_METHOD(login:(NSDictionary *) options
                  callback:(RCTResponseSenderBlock)callback)
{
  NSString *clientID = options[@"clientID"];
  NSArray *requestedScopes = options[@"requestedScopes"];
  NSURL *redirectURL = [NSURL URLWithString:options[@"redirectURL"]];
  NSURL *tokenSwapURL = [NSURL URLWithString:options[@"tokenSwapURL"]];
  NSURL *tokenRefreshURL = [NSURL URLWithString:options[@"tokenRefreshURL"]];
  
  SpotifyAuth *sharedManager = [SpotifyAuth sharedManager];

  //set the sharedManager properties
  [sharedManager setClientID:clientID];
  [sharedManager setRequestedScopes:requestedScopes];
  [sharedManager setRedirectURL:redirectURL];
  [sharedManager setTokenSwapURL:tokenSwapURL];
  [sharedManager setTokenRefreshURL:tokenRefreshURL];

  [self ensureSession];
}

/////////////////////////////////
////  AUTH
/////////////////////////////////

- (BOOL)startAuth {
  SpotifyAuth *sharedManager = [SpotifyAuth sharedManager];
  NSMutableArray *scopes = [NSMutableArray array];
  
  //Turn scope arry of strings into an array of SPTAuth...Scope objects
  for (int i = 0; i < [sharedManager.requestedScopes count]; i++) {
    if([sharedManager.requestedScopes[i]  isEqual: @"playlist-read-private"]){
      [scopes addObject: SPTAuthPlaylistReadPrivateScope];
    } else if([sharedManager.requestedScopes[i]  isEqual: @"playlist-modify-private"]){
      [scopes addObject: SPTAuthPlaylistModifyPrivateScope];
    } else if([sharedManager.requestedScopes[i]  isEqual: @"playlist-modify-public"]){
      [scopes addObject: SPTAuthPlaylistModifyPublicScope];
    } else if([sharedManager.requestedScopes[i]  isEqual: @"user-follow-modify"]){
      [scopes addObject: SPTAuthUserFollowModifyScope];
    } else if([sharedManager.requestedScopes[i]  isEqual: @"user-follow-read"]){
      [scopes addObject: SPTAuthUserFollowReadScope];
    } else if([sharedManager.requestedScopes[i]  isEqual: @"user-library-read"]){
      [scopes addObject: SPTAuthUserLibraryReadScope];
    } else if([sharedManager.requestedScopes[i]  isEqual: @"user-library-modify"]){
      [scopes addObject: SPTAuthUserLibraryModifyScope];
    } else if([sharedManager.requestedScopes[i]  isEqual: @"user-read-private"]){
      [scopes addObject: SPTAuthUserReadPrivateScope];
    } else if([sharedManager.requestedScopes[i]  isEqual: @"user-read-birthdate"]){
      [scopes addObject: SPTAuthUserReadBirthDateScope];
    } else if([sharedManager.requestedScopes[i]  isEqual: @"user-read-email"]){
      [scopes addObject: SPTAuthUserReadEmailScope];
    } else if([sharedManager.requestedScopes[i]  isEqual: @"streaming"]){
      [scopes addObject: SPTAuthStreamingScope];
    }
  }
    
  [[SPTAuth defaultInstance] setClientID:sharedManager.clientID];
  [[SPTAuth defaultInstance] setTokenSwapURL:sharedManager.tokenSwapURL];
  [[SPTAuth defaultInstance] setTokenRefreshURL:sharedManager.tokenRefreshURL];
  [[SPTAuth defaultInstance] setRedirectURL:sharedManager.redirectURL];
  [[SPTAuth defaultInstance] setRequestedScopes:scopes];
  //[[SPTAuth defaultInstance] setAllowNativeLogin:false];
  
  // Construct a login URL
  NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  
  // init the webView with the loginURL
  SpotifyLoginViewController *loginWebView =[[SpotifyLoginViewController alloc] initWithURL:loginURL];
  UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController: loginWebView];
  
  //Present the webView over the rootView
  [delegate.window.rootViewController presentViewController: controller animated:YES completion:nil];
  
  return YES;
}

-(void)urlCallback: (NSURL *)url {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  NSMutableDictionary *loginRes =  [NSMutableDictionary dictionary];
  
  if ([[SPTAuth defaultInstance] canHandleURL:url]) {
    [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
      
      if (error != nil) {
        NSLog(@"*** Auth error: %@", error);
        loginRes[@"error"] = @"error while attempting to login!";
        
      } else {
        
        // Create a new player if needed
        if (self.player == nil) {
          //Set the session property to the seesion we got from the login Url
          _session = session;
          [self setSession: session];
          SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
          [sharedIn startWithClientId:[SPTAuth defaultInstance].clientID error:nil];
          self.player = sharedIn;
          //keep this one
          [[SpotifyAuth sharedManager] setSession:session];
          
        }
        
        [self.player loginWithAccessToken:_session.accessToken];
      }
      
    }];
  } else {
    loginRes[@"error"] = @"error while attempting to login!";
  }
  [center postNotificationName:@"loginRes" object:nil userInfo:loginRes];
  [center removeObserver:self name:@"loginRes" object:nil];
  
}

//Check if session is valid and renew it if not
-(void)ensureSession {
  NSLog(@"ENSURING SESSION");
  SpotifyAuth *sharedManager = [SpotifyAuth sharedManager];
  
  if (![[sharedManager session] isValid]){
    NSLog(@"SESSION IS NOT VALID");

    [[SPTAuth defaultInstance] renewSession:[sharedManager session] callback:^(NSError *error, SPTSession *session) {
      if(error != nil){
        NSLog(@"Error: %@", error);
        [sharedManager startAuth];
      } else if ([session isValid]) {
        NSLog(@"RENEWED SESSION");
        [sharedManager setSession:session];
        [[sharedManager player] loginWithAccessToken:session.accessToken];
      } else {
        NSLog(@"NO RENEWED SESSION");
        [sharedManager startAuth];
      }
    }];
  } else {
    NSLog(@"SESSION IS VALID");
  }
}

//Returns the session's access token
RCT_EXPORT_METHOD(getAccessToken:(RCTResponseSenderBlock)callback)
{
  SpotifyAuth *sharedManager = [SpotifyAuth sharedManager];

  if([[sharedManager session] isValid]){
    callback(@[[[sharedManager session] accessToken]]);
  }else{
    callback(@[[NSNull null]]);
    [self ensureSession];
  }
}


/////////////////////////////////
////  SPTAudioStreamingController
/////////////////////////////////

///-----------------------------
/// Properties
///-----------------------------

//Returns true when SPTAudioStreamingController is initialized, otherwise false
RCT_EXPORT_METHOD(initialized:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  callback(@[@([sharedIn initialized])]);
}

//Returns true if the receiver is logged into the Spotify service, otherwise false
RCT_EXPORT_METHOD(loggedIn:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  callback(@[@([sharedIn loggedIn])]);
}

//Returns the volume, as a value between 0.0 and 1.0.
RCT_EXPORT_METHOD(volume:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  callback(@[@([sharedIn volume])]);
}

//Returns the current streaming bitrate the receiver is using
RCT_EXPORT_METHOD(targetBitrate:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  callback(@[@([sharedIn targetBitrate])]);
}

/////////////////////////////////
////  SPTAudioStreamingController
/////////////////////////////////

///-----------------------------
/// PlaybackState
///-----------------------------

RCT_EXPORT_METHOD(playbackState:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  NSDictionary *playbackState = @{
                                 @"isPlaying" : @(sharedIn.playbackState.isPlaying),
                                 @"isShuffling" : @(sharedIn.playbackState.isShuffling),
                                 @"isRepeating" : @(sharedIn.playbackState.isRepeating),
                                 @"position" : @(sharedIn.playbackState.position),
                                 };
  callback(@[playbackState]);
}


///-----------------------------
/// PlaybackMetadata
///-----------------------------

RCT_EXPORT_METHOD(metadata:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  NSDictionary *currentTrack = [self getTrackMetadata : sharedIn.metadata.currentTrack];
  NSDictionary *prevTrack = [self getTrackMetadata : sharedIn.metadata.prevTrack];
  NSDictionary *nextTrack = [self getTrackMetadata : sharedIn.metadata.nextTrack];
  
  NSDictionary *metadata = @{
                             @"currentTrack" : currentTrack ? currentTrack : [NSNull null],
                             @"previousTrack" : prevTrack ? prevTrack : [NSNull null],
                             @"nextTrack" : nextTrack ? nextTrack : [NSNull null],
                            };
  callback(@[metadata]);
}

- (NSDictionary *)getTrackMetadata:(SPTPlaybackTrack *) track {
  if (track == nil) {
    return nil;
  }

  NSDictionary *metadata = @{
                             @"name" : track.name,
                             @"uri" : track.uri,
                             @"playbackSourceUri" : track.playbackSourceUri,
                             @"playbackSourceName" : track.playbackSourceName,
                             @"artistName" : track.artistName,
                             @"artistUri" : track.artistUri,
                             @"artistName" : track.artistName,
                             @"albumName" : track.albumName,
                             @"albumUri" : track.albumUri,
                             @"albumCoverArtUri" : track.albumCoverArtUri,
                             @"duration" : [NSNumber numberWithDouble:track.duration],
                             @"indexInContext" : [NSNumber numberWithInteger:track.indexInContext]
                             };
  return metadata;
}

///-----------------------------
/// Methods
///-----------------------------

//Logout from Spotify
RCT_EXPORT_METHOD(logout)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  [sharedIn logout];
}

//Set playback volume to the given level. Volume is a value between `0.0` and `1.0`.
RCT_EXPORT_METHOD(setVolume:(CGFloat)volume callback:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  [sharedIn setVolume:volume callback:^(NSError *error) {
    if(error == nil){
      callback(@[[NSNull null]]);
    }else{
      callback(@[error]);
      [self ensureSession];
    }
    return;
  }];
}

//Set the target streaming bitrate. 0 for low, 1 for normal and 2 for high
RCT_EXPORT_METHOD(setTargetBitrate:(NSInteger)bitrate callback:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  [sharedIn setTargetBitrate:bitrate callback:^(NSError *error) {
    if(error == nil){
      callback(@[[NSNull null]]);
    }else{
      callback(@[error]);
      [self ensureSession];
    }
    return;
  }];
}

//Seek playback to a given location in the current track (in secconds).
RCT_EXPORT_METHOD(seekTo:(CGFloat)offset callback:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  [sharedIn seekTo:offset callback:^(NSError *error) {
    if(error == nil){
      callback(@[[NSNull null]]);
    }else{
      callback(@[error]);
      [self ensureSession];
    }
    return;
  }];
}

//Set the "playing" status of the receiver. Pass true to resume playback, or false to pause it.
RCT_EXPORT_METHOD(setIsPlaying:(BOOL)playing callback:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  [sharedIn setIsPlaying: playing callback:^(NSError *error) {
    if(error == nil){
      callback(@[[NSNull null]]);
    }else{
      callback(@[error]);
      [self ensureSession];
    }
    return;
  }];
}


//Play a Spotify URI.
RCT_EXPORT_METHOD(play:(NSString *)uri
                  startingWithIndex:(NSUInteger)index
                  startingWithPosition:(NSTimeInterval)position
                  callback:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  [sharedIn playSpotifyURI:uri startingWithIndex:index startingWithPosition:position callback:^(NSError *error) {
    if(error == nil){
      callback(@[[NSNull null]]);
    }else{
      callback(@[error]);
      [self ensureSession];
    }
    return;
  }];
}

//Queue a Spotify URI.
RCT_EXPORT_METHOD(queue:(NSString *)uri callback:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  [sharedIn queueSpotifyURI:uri callback:^(NSError *error) {
    if(error == nil){
      callback(@[[NSNull null]]);
    }else{
      callback(@[error]);
      [self ensureSession];
    }
    return;
  }];
}

//Go to the next track in the queue
RCT_EXPORT_METHOD(skipNext:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  [sharedIn skipNext:^(NSError *error) {
    if(error == nil){
      callback(@[[NSNull null]]);
    }else{
      callback(@[error]);
      [self ensureSession];
    }
    return;
  }];
}

//Go to the previous track in the queue
RCT_EXPORT_METHOD(skipPrevious:(RCTResponseSenderBlock)callback)
{
  SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
  [sharedIn skipPrevious:^(NSError *error) {
    if(error == nil){
      callback(@[[NSNull null]]);
    }else{
      callback(@[error]);
      [self ensureSession];
    }
    return;
  }];
}

/////////////////////////////////
////  END SPTAudioStreamingController
/////////////////////////////////


/////////////////////////////////
////  Search
/////////////////////////////////

//Performs a search with a given query, offset and market filtering, returns an Array filled with json Objects
RCT_EXPORT_METHOD(performSearchWithQuery:(NSString *)searchQuery
                  queryType:(NSString *)searchQueryType
                  offset:(NSInteger)offset
                  market:(NSString *)market
                  callback:(RCTResponseSenderBlock)callback)
{
  SPTSearchQueryType parm;
  //set the SPTSearchQueryType depending on searchQueryType
  if ([searchQueryType  isEqual: @"track"]){
    parm = SPTQueryTypeTrack;
  } else if ([searchQueryType  isEqual: @"artist"]){
    parm = SPTQueryTypeArtist;
  } else if ([searchQueryType  isEqual: @"album"]){
    parm = SPTQueryTypeAlbum;
  } else if ([searchQueryType  isEqual: @"playList"]){
    parm = SPTQueryTypePlaylist;
  }
  
  [SPTSearch performSearchWithQuery:searchQuery queryType:parm offset:offset accessToken:[[[SpotifyAuth sharedManager] session] accessToken] market:market callback:^(NSError *error, id object) {
    
    NSMutableDictionary *resObj = [NSMutableDictionary dictionary];
    NSMutableArray *resArr = [NSMutableArray array];
    for (int i; i < [[object items] count]; i++){
      SPTPartialArtist *temp = (SPTPartialArtist *)[object items][i];
      resObj[[temp name]] = [temp decodedJSONObject];
      [resArr addObject:[temp decodedJSONObject]];
    }
    NSLog(@"ret %@ ret", [object nextPageURL]);
    callback(@[[NSNull null],resArr]);
    return;
  }];
  
}

/////////////////////////////////
////  END Search
/////////////////////////////////


-(void)setSession:(SPTSession *)session{
  _session = session;
}

-(void)setRedirectURL:(NSURL *)redirectURL{
  _redirectURL = redirectURL;
}

-(void)setClientID:(NSString *)clientID{
  _clientID = clientID;
}

-(void)setRequestedScopes:(NSArray *)requestedScopes{
  _requestedScopes = requestedScopes;
}

-(void)setTokenSwapURL:(NSURL *)tokenSwapURL{
  _tokenSwapURL = tokenSwapURL;
}

-(void)setTokenRefreshURL:(NSURL *)tokenRefreshURL{
  _tokenRefreshURL = tokenRefreshURL;
}

+ (id)sharedManager {
  static SpotifyAuth *sharedMyManager = nil;
  @synchronized(self) {
    if (sharedMyManager == nil)
      sharedMyManager = [[self alloc] init];
  }
  return sharedMyManager;
}

@end
