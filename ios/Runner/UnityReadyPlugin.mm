#import <Foundation/Foundation.h>

extern "C" {
    void postUnityReady() {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"UnityReady"
            object:nil];
    }
}
