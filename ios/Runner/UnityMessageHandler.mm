#import <Foundation/Foundation.h>

extern "C" {
    // Called by Unity when it sends a message to native iOS
    void OnUnityMessage(const char* message) {
        NSLog(@"Unity message: %s", message);
        NSString* msg = [NSString stringWithUTF8String:message];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"OnUnityMessage"
            object:nil
            userInfo:@{@"message": msg}];
    }

    // Called by Unity when a scene finishes loading
    void OnUnitySceneLoaded(const char* name, int buildIndex, bool isLoaded, bool isValid) {
        NSLog(@"Unity scene loaded: %s (index: %d)", name, buildIndex);
        NSString* sceneName = [NSString stringWithUTF8String:name];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"OnUnitySceneLoaded"
            object:nil
            userInfo:@{
                @"name": sceneName,
                @"buildIndex": @(buildIndex),
                @"isLoaded": @(isLoaded)
            }];
    }
}
