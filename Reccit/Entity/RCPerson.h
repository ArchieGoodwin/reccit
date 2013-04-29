//
//  RCPerson.h
//  Reccit
//
//  Created by Lee Way on 1/28/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RCFriendSourceTwitter,
    RCFriendSourceFacebook
} RCFriendSource;

@interface RCPerson : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *photo;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) BOOL isMark;
@property (nonatomic, copy) NSString *ID;

@property (nonatomic, assign) RCFriendSource source;

@end
