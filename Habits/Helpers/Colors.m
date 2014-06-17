//
//  Colors.m
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "Colors.h"
#import <NSArray+F.h>
#import <AVHexColor.h>
@implementation Colors
+(NSDictionary*)hexCodes{
    static  NSDictionary * result = nil;
    if(result == nil){
        result = @{
                   @"green": @"#77A247",
                   @"purple": @"#875495",
                   @"orange": @"#E2804F",
                   @"yellow": @"#E7BE2B",
                   @"pink": @"#d28895",
                   @"blue": @"#488fb4",
                   @"brown": @"#7a5d35"
                   };
    }
    return result;
}


#define COLOR_ACCESSOR(name,hex) +(UIColor*)name{ static UIColor * result = nil; if(!result) result = [AVHexColor colorWithHex:hex]; return result; }
#define COLOR_FROM_HEX(name) +(UIColor*)name{ static UIColor * result = nil; if(!result) result = [AVHexColor colorWithHexString: [self hexCodes][@"key"] ]; return result; }
COLOR_ACCESSOR(dark, 0x3a4450)
COLOR_ACCESSOR(cobalt, 0x8A95A1)
COLOR_ACCESSOR(grey, 0xb3b3b3)
COLOR_ACCESSOR(red, 0xC1272D)
COLOR_ACCESSOR(infoYellow, 0xfbae17)

COLOR_FROM_HEX(green);
COLOR_FROM_HEX(purple);
COLOR_FROM_HEX(orange);
COLOR_FROM_HEX(yellow);
COLOR_FROM_HEX(pink);
COLOR_FROM_HEX(blue);
COLOR_FROM_HEX(brown);

COLOR_ACCESSOR(cellBackground, 0xd6cdbf);
COLOR_ACCESSOR(headerBackground, 0x353f4c);
COLOR_ACCESSOR(calendarTop, 0x8A95A1);

COLOR_ACCESSOR(futureColor, 0xA6B4C3);
COLOR_ACCESSOR(missedColor, 0xC1272D);
COLOR_ACCESSOR(onColor, 0xFFFFFF);
COLOR_ACCESSOR(beforeStartColor, 0x3A4450);
COLOR_ACCESSOR(notRequiredColor, 0xA6B4C3);


+(NSArray *)colorsFromMotion{
    NSArray * result = nil;
    if(result == nil){
        result = [[[self hexCodes] allValues] map:^id(id obj) {
            return [AVHexColor colorWithHexString:obj];
        }];
    }
    return result;
}
+(UIColor *)globalTint{
    return [[[UIApplication sharedApplication] keyWindow] tintColor];
}
@end
