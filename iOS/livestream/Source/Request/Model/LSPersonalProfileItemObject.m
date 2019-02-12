//
//  LSPersonalProfileItemObject.m
//  dating
//
//  Created by test on 18/9/21.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSPersonalProfileItemObject.h"
@interface LSPersonalProfileItemObject () <NSCoding>
@end

@implementation LSPersonalProfileItemObject

- (id)init {
    if( self = [super init] ) {
        self.manId = @"";
        self.age = 0;
        self.birthday = @"";
        self.firstname = @"";
        self.lastname = @"";
        self.email = @"";
        self.gender = 0;
        self.country = 0;
        self.marry = 0;
        self.height = 0;
        self.weight = 0;
        self.smoke = 0;
        self.drink = 0;
        self.language = 0;
        self.religion = 0;
        self.education = 0;
        self.profession = 0;
        self.ethnicity = 0;
        self.income = 0;
        self.children = 0;
        self.resume = @"";
        self.resume_content = @"";
        self.resume_status = 0;
        self.address1 = @"";
        self.address2 = @"";
        self.city = @"";
        self.province = @"";
        self.zipcode = @"";
        self.telephone = @"";
        self.fax = @"";
        self.alternate_email = @"";
        self.money = @"";
        self.v_id = 0;
        self.photoStatus = 0;
        self.photoUrl = @"";
        self.integral = 0;
        self.mobile = @"";
        self.mobileZoom = 0;
        self.mobileStatus = 0;
        self.landline = @"";
        self.landlineZoom = 0;
        self.landlineLocation = 0;
        self.landlineStatus = 0;
        self.zodiac = 0;
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.manId = [coder decodeObjectForKey:@"manId"];
        self.age = [coder decodeIntForKey:@"age"];
        self.birthday = [coder decodeObjectForKey:@"birthday"];
        self.firstname = [coder decodeObjectForKey:@"firstname"];
        self.lastname = [coder decodeObjectForKey:@"lastname"];
        self.email = [coder decodeObjectForKey:@"email"];
        self.gender = [coder decodeIntForKey:@"gender"];
        self.country = [coder decodeIntForKey:@"country"];
        self.marry = [coder decodeIntForKey:@"marry"];
        self.height = [coder decodeIntForKey:@"height"];
        self.weight = [coder decodeIntForKey:@"weight"];
        self.smoke = [coder decodeIntForKey:@"smoke"];
        self.drink = [coder decodeIntForKey:@"drink"];
        self.language = [coder decodeIntForKey:@"language"];
        self.religion = [coder decodeIntForKey:@"religion"];
        self.education = [coder decodeIntForKey:@"education"];
        self.profession = [coder decodeIntForKey:@"profession"];
        self.ethnicity = [coder decodeIntForKey:@"ethnicity"];
        self.income = [coder decodeIntForKey:@"income"];
        self.children = [coder decodeIntForKey:@"children"];
        self.resume = [coder decodeObjectForKey:@"resume"];
        self.resume_content = [coder decodeObjectForKey:@"resume_content"];
        self.resume_status = [coder decodeIntForKey:@"resume_status"];
        self.address1 = [coder decodeObjectForKey:@"address1"];
        self.address2 = [coder decodeObjectForKey:@"address2"];
        self.city = [coder decodeObjectForKey:@"city"];
        self.province = [coder decodeObjectForKey:@"province"];
        self.zipcode = [coder decodeObjectForKey:@"zipcode"];
        self.telephone = [coder decodeObjectForKey:@"telephone"];
        self.fax = [coder decodeObjectForKey:@"fax"];
        self.alternate_email = [coder decodeObjectForKey:@"alternate_email"];
        self.money = [coder decodeObjectForKey:@"money"];
        self.v_id = [coder decodeIntForKey:@"v_id"];
        self.photoStatus = [coder decodeIntForKey:@"photoStatus"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.integral = [coder decodeIntForKey:@"integral"];
        self.mobile = [coder decodeObjectForKey:@"mobile"];
        self.mobileZoom = [coder decodeIntForKey:@"mobileZoom"];
        self.mobileStatus = [coder decodeIntForKey:@"mobileStatus"];
        self.landline = [coder decodeObjectForKey:@"landline"];
        self.landlineZoom = [coder decodeIntForKey:@"landlineZoom"];
        self.landlineLocation = [coder decodeObjectForKey:@"landlineLocation"];
        self.landlineStatus = [coder decodeIntForKey:@"landlineStatus"];
        self.interests = [coder decodeObjectForKey:@"interests"];
        self.zodiac = [coder decodeIntForKey:@"zodiac"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.manId forKey:@"manId"];
    [coder encodeInt:self.age forKey:@"age"];
    [coder encodeObject:self.birthday forKey:@"birthday"];
    [coder encodeObject:self.firstname forKey:@"firstname"];
    [coder encodeObject:self.lastname forKey:@"lastname"];
    [coder encodeObject:self.manId forKey:@"manId"];
    [coder encodeInt:self.gender forKey:@"gender"];
    [coder encodeInt:self.country forKey:@"country"];
    [coder encodeInt:self.marry forKey:@"marry"];
    [coder encodeInt:self.height forKey:@"height"];
    [coder encodeInt:self.weight forKey:@"weight"];
    [coder encodeInt:self.smoke forKey:@"smoke"];
    [coder encodeInt:self.drink forKey:@"drink"];
    [coder encodeInt:self.language forKey:@"language"];
    [coder encodeInt:self.religion forKey:@"religion"];
    [coder encodeInt:self.education forKey:@"education"];
    [coder encodeInt:self.profession forKey:@"profession"];
    [coder encodeInt:self.ethnicity forKey:@"ethnicity"];
    [coder encodeInt:self.income forKey:@"income"];
    [coder encodeInt:self.children forKey:@"children"];
    [coder encodeObject:self.resume forKey:@"resume"];
    [coder encodeObject:self.resume_content forKey:@"resume_content"];
    [coder encodeInt:self.resume_status forKey:@"resume_status"];
    [coder encodeObject:self.address1 forKey:@"address1"];
    [coder encodeObject:self.address2 forKey:@"address2"];
    [coder encodeObject:self.city forKey:@"city"];
    [coder encodeObject:self.province forKey:@"province"];
    [coder encodeObject:self.zipcode forKey:@"zipcode"];
    [coder encodeObject:self.telephone forKey:@"telephone"];
    [coder encodeObject:self.fax forKey:@"fax"];
    [coder encodeObject:self.alternate_email forKey:@"alternate_email"];
    [coder encodeObject:self.money forKey:@"money"];
    [coder encodeInt:self.v_id forKey:@"v_id"];
    [coder encodeInt:self.photoStatus forKey:@"photoStatus"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeInt:self.integral forKey:@"integral"];
    [coder encodeObject:self.mobile forKey:@"mobile"];
    [coder encodeInt:self.mobileZoom forKey:@"mobileZoom"];
    [coder encodeInt:self.mobileStatus forKey:@"mobileStatus"];
    [coder encodeObject:self.landline forKey:@"landline"];
    [coder encodeInt:self.landlineZoom forKey:@"landlineZoom"];
    [coder encodeObject:self.landlineLocation forKey:@"landlineLocation"];
    [coder encodeInt:self.landlineStatus forKey:@"landlineStatus"];
    [coder encodeObject:self.interests forKey:@"interests"];
    [coder encodeInt:self.zodiac forKey:@"zodiac"];
}

- (BOOL)canUpdatePhoto {
    BOOL bFlag = NO;
    VType vType = (VType)self.v_id;
    
    PhotoStatus photoStatus = (PhotoStatus)self.photoStatus;
    if( vType == VType_Verifing && photoStatus == Yes ) {
    } else if( vType == VType_Yes && photoStatus == Yes ) {
    } else if( photoStatus == Verifing ) {
    } else {
        bFlag = YES;
    }
    return bFlag;
}

- (BOOL)canUpdateResume {
    BOOL bFlag = NO;
    ResumeStatus resume_status = (ResumeStatus)self.resume_status;
    switch (resume_status) {
        case UnVerify:{
        }break;
        case Verified:
        case NotVerified:{
            bFlag = YES;
        }break;
        default:
            break;
    }
    return bFlag;
}
@end
