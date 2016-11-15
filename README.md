# React Native Spotify Module (IOS) 


##Intro
A native module that allows you to use the Spotify SDK API (IOS [beta 23](https://github.com/spotify/ios-sdk/releases/tag/beta-23)) with JavaScript through react-native.

___

## Overview

* [Set-up](#set-up)
* [How to use](#how-to-use)
* [Exposed API](#exposed-api)
	* [Auth](#auth)
	* [SPTAudioStreamingController Class](#sptaudiostreamingcontroller-class)
	* [SPTSearch Class](#sptsearch-class)
* [Demo](#demo) 

___

##Set-up:
###Using npm
>Recomended

1. Use `npm install react-native-spotify` from the directory of your project in your command line.

2. Download the Spotify IOS SDK beta 23 [here](https://github.com/spotify/ios-sdk/releases/tag/beta-23) and unzip it.

3. Open your react native project in Xcode and drag the unzipped `Spotify.framework` file into the `Frameworks` group in your Xcode project (create the group if it doesn’t already exist). In the import dialog, tick the box for **Copy items into destinations group folder** (or **Destination: Copy items if needed**).

4. Please folow the instructions on the **"Creating Your Client ID, Secret and Callback URI"** and **"Setting Up Your Build Environment"** sections of the [*Spotify iOS SDK Tutorial*](https://developer.spotify.com/technologies/spotify-ios-sdk/tutorial/) 
>**Important Note!** When adding frameworks to the list in the "**Link Binary With Libraries**" section you wll need to add `WebKit.framework` in addition to those mentioned in the tutorial.

5. Go to `node-modules/react-native-spotify/` and copy the following files to the `ios` directory of your project:
	* `SpotifyLoginViewController.m`
	* `SpotifyLoginViewController.h`
	* `SpotifyAuth.m`
	* `SpotifyAuth.h`

___

###Using git
1. Fork and clone the repo.

2. Download the Spotify IOS SDK beta 17 [here](https://github.com/spotify/ios-sdk/releases/tag/beta-17) and unzip it.

3. Open your react native project in Xcode and drag the unzipped `Spotify.framework` file into the `Frameworks` group in your Xcode project (create the group if it doesn’t already exist). In the import dialog, tick the box for **Copy items into destinations group folder** (or **Destination: Copy items if needed**).

4. Please folow the instructions on the **"Creating Your Client ID, Secret and Callback URI"** and **"Setting Up Your Build Environment"** sections of the [*Spotify iOS SDK Tutorial*](https://developer.spotify.com/technologies/spotify-ios-sdk/tutorial/) 
>**Important Note!** When adding frameworks to the list in the "**Link Binary With Libraries**" section you wll need to add `WebKit.framework` in addition to those mentioned in the tutorial.

5. From this project directory, go to `react-native-spotify/spotifyModule/ios` and copy the following files to the `ios` directory of your project:
	* `SpotifyLoginViewController.m`
	* `SpotifyLoginViewController.h`
	* `SpotifyAuth.m`
	* `SpotifyAuth.h`

___

##How to use:
```javascript
//You need to import NativeModules to your view
import { NativeModules } from 'react-native';

//Assign our module from NativeModules and assign it to a variable
var SpotifyAuth = NativeModules.SpotifyAuth;

class yourComponent extends Component {
	//Some code ...

	someMethod(){
    //You need this to Auth a user, without it you cant use any method!

    const options = {
		clientID: 'your-clientID',
		redirectURL: 'your-app-schema://callback',
		requestedScopes: ['streaming',...]
	};

	SpotifyAuth.login(options, (error) => {
		if (error) {
          //handle error
        } else {
          //handle success
        }
	});
}
```  

___


##Exposed API:

###Auth:

**options:callback**

> **You need this to Auth a user, without it you cant use any other methods!**

Set your Client ID, Redirect URL, Scopes and **start the auth process**


| Option |description|
| ------ |:-------------------------------|
|clientID|`(String)` The client ID of your [registered Spotify app](https://developer.spotify.com/my-applications/#!/applications)|
|redirectURL|`(String)` The Redirect URL of your [registered Spotify app](https://developer.spotify.com/my-applications/#!/applications)|
|requestedScopes|`(Array)` list of scopes of your app, [see here](https://developer.spotify.com/web-api/using-scopes/)  |
|tokenSwapURL|`(String)` Backend URL to exchange authorization code for access token (only Authorization Code Flow [see here](https://developer.spotify.com/web-api/authorization-guide/#supported-authorization-flows))|
|tokenRefreshURL|`(String)` Backend URL to refresh an access token (only Authorization Code Flow [see here](https://developer.spotify.com/web-api/authorization-guide/#supported-authorization-flows))|
|callback|`(Function)`a callback to handle the login success/error|

### Implicit Grant Flow

`````
const options = {
	clientID: 'your-clientID',
	redirectURL: 'your-app-schema://callback',
	requestedScopes: ['streaming',...]
};

SpotifyAuth.login(options,(error)=>{console.log(error)});
`````

### Authorization Code Flow

`````
const options = {
	clientID: 'your-clientID',
	redirectURL: 'your-app-schema://callback',
	requestedScopes: ['streaming',...],
	tokenSwapURL: 'http://your.backend.com/token/swap',
	tokenRefreshURL: 'http://your.backend.com/token/refresh'
};

SpotifyAuth.login(options,(error)=>{console.log(error)});
`````

###SPTAudioStreamingController Class:
### *Properties:*
**initialized**

Returns true when SPTAudioStreamingController is initialized, otherwise false


| Parameter |description|
| ------ |:-------------------------------|
|Callback|`(Function)`a callback to handle the response|

Example:

`SpotifyAuth.initialized((res)=>{console.log(res);});`

**[loggedIn](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTAudioStreamingController.html#//api/name/loggedIn)**

Returns true if the receiver is logged into the Spotify service, otherwise false


| Parameter |description|
| ------ |:-------------------------------|
|Callback|`(Function)`a callback to handle the response|

Example:

`SpotifyAuth.loggedIn((res)=>{console.log(res);});`

**[volume](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTAudioStreamingController.html#//api/name/volume)**

Returns the volume


| Parameter |description|
| ------ |:-------------------------------|
|Callback|`(Function)`a callback to handle the response|

Example:

`SpotifyAuth.volume((res)=>{console.log(res);});`


### playbackState
Returns the playback state of the current track


| Parameter |description|
| ------ |:-------------------------------|
|Callback|`(Function)`a callback to handle the response|

Example:

`SpotifyAuth.playbackState((res)=>{console.log(res);});`


### metadata(callback)
Returns the metadata of the previous, current and next track

| Parameter |description|
| ------ |:-------------------------------|
|Callback|`(Function)`a callback to handle the response|

Example:

`SpotifyAuth.metadata((res)=>{console.log(res);});`


Returns the current streaming bitrate the receiver is using


| Parameter |description|
| ------ |:-------------------------------|
|Callback|`(Function)`a callback to handle the response|

Example:

`SpotifyAuth.targetBitrate((res)=>{console.log(res);});`

### *Methods:*

**[-logout:](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTAudioStreamingController.html#//api/name/logout:)**

Logout from Spotify

| Parameter |description|
| ------ |:-------------------------------|
|N/A|N/A|

Example:

`SpotifyAuth.logout();`

**[-setVolume:callback:](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTAudioStreamingController.html#//api/name/setVolume:callback:)**

Set playback volume to the given level. Volume is a value between `0.0` and `1.0`.

| Parameter |description|
| ------ |:-------------------------------|
|volume  |`(Number)`The volume to change to, value between `0.0` and `1.0`|
|Callback|`(Function)`a callback that will pass back an `NSError` object if an error ocurred|

Example:

`SpotifyAuth.setVolume(0.8,(error)=>{console.log(error);});`

**[-setTargetBitrate:callback:](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTAudioStreamingController.html#//api/name/setTargetBitrate:callback:)**

Set the target streaming bitrate. `0` for low, `1` for normal and `2` for high

| Parameter |description|
| ------ |:-------------------------------|
|bitrate|`(Number)`The bitrate to target            |
|Callback|`(Function)`a callback that will pass back an `NSError` object if an error ocurred|

Example:

`SpotifyAuth.setTargetBitrate(2,(error)=>{console.log(error);});`

**[-seekTo:callback:](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTAudioStreamingController.html#//api/name/seekTo:callback:)**

Seek playback to a given location in the current track (in secconds).

| Parameter |description|
| ------ |:-------------------------------|
| offset |`(Number)`The time in seconds to seek to|
|Callback|`(Function)`a callback that will pass back an `NSError` object if an error ocurred|

Example:

`SpotifyAuth.seekTo(110,(error)=>{console.log(error);});`

**[-playSpotifyURI:callback:](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTAudioStreamingController.html#//api/name/playSpotifyURI:callback:)**

Play a Spotify URI.

| Parameter |description|
| ------ |:-------------------------------|
| uri |`(String)`The URI to play|
| index |`(Number)`The index to play|
| offset |`(Number)`The time in seconds to start playing|
|Callback|`(Function)`a callback that will pass back an `NSError` object if an error ocurred|

Example:

`SpotifyAuth.playURI("spotify:track:6HxIUB3fLRS8W3LfYPE8tP",(error)=>{console.log(error);});`

**[-queueSpotifyURI:callback:](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTAudioStreamingController.html#//api/name/queueSpotifyURI:callback:)**

Queue a Spotify URI.

| Parameter |description|
| ------ |:-------------------------------|
| uri |`(String)`The URI to queue|
|Callback|`(Function)`a callback that will pass back an `NSError` object if an error ocurred|

Example:

`SpotifyAuth.queueURI("spotify:track:6HxIUB3fLRS8W3LfYPE8tP",(error)=>{console.log(error);});`

**[-setIsPlaying:callback:](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTAudioStreamingController.html#//api/name/setIsPlaying:callback:)**

Set the "playing" status of the receiver.

| Parameter |description|
| ------ |:-------------------------------|
| playing |`(Boolean)`Pass true to resume playback, or false to pause it|
|Callback|`(Function)`a callback that will pass back an `NSError` object if an error ocurred|

Example:

`SpotifyAuth.setIsPlaying(true,(error)=>{console.log(error);});`


**[-skipNext:](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTAudioStreamingController.html#//api/name/skipNext:)**

Go to the next track in the queue

| Parameter |description|
| ------ |:-------------------------------|
|Callback|`(Function)`a callback that will pass back an `NSError` object if an error ocurred|

Example:

`SpotifyAuth.skipNext((error)=>{console.log(error);});`

**[-skipPrevious:(RCTResponseSenderBlock)block](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTAudioStreamingController.html#//api/name/skipPrevious:)**

Go to the previous track in the queue

| Parameter |description|
| ------ |:-------------------------------|
|Callback|`(Function)`a callback that will pass back an `NSError` object if an error ocurred|

Example:

`SpotifyAuth.skipPrevious((error)=>{console.log(error);});`

___

###SPTSearch Class:
### *Methods:*

**[+performSearchWithQuery:queryType:offset:accessToken:market:callback:](https://developer.spotify.com/ios-sdk-docs/Documents/Classes/SPTSearch.html#//api/name/performSearchWithQuery:queryType:offset:accessToken:market:callback:)**

Go to the previous track in the queue *You need to have a session first*

| Parameter |description|
| ------ |:-------------------------------|
| searchQuery |`(String)`The query to pass to the search|
| searchQueryType |`(String)`The type of search to do ('track', 'artist', 'album' or 'playList')|
| offset |`(Number)`The index at which to start returning results|
| market |`(String)`Either a ISO 3166-1 country code to filter the results to, or “from_token” |
|Callback|`(Function)`callback to be called when the operation is complete. The block will pass an Array filled with json Objects on success, otherwise an error.|

Example:
```javascript
SpotifyAuth.performSearchWithQuery('lacri','artist',0,'US',(err, res)=>{
      console.log('error', err);
      console.log('result', res);
    });
```

___


##Demo:
>Included in the repo.


![alt text](https://github.com/viestat/react-native-spotify/blob/master/SpotifyAuthDemoEdit.gif?raw=true = 250x "Demo")

___

