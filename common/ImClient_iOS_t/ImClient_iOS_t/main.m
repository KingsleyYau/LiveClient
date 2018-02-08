//
//  main.m
//  ImClient_iOS_t
//
//  Created by  Samson on 27/en05/2017.
//  Copyright © 2017 Samson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    signal(SIGPIPE, SIG_IGN);
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
