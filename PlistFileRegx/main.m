//
//  main.m
//  PlistFileRegx
//
//  Created by Wang Sky on 14/10/20.
//  Copyright (c) 2014年 Wang Sky. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"The command has four options.\nThe first is the file path.\nThe second is the array key.\nThe third is the match string.\nThe forth is the replaced string");
        for (int n = 1; n < 4; n++) {
            if (!argv[n]) {
                NSLog(@"The %d option is null",n);
                exit(0);
            }
        }
        NSString *plistFilePath = [NSString stringWithUTF8String:argv[1]];
        NSString *matchKey = [NSString stringWithUTF8String:argv[2]];
        NSString *matchValue = [NSString stringWithUTF8String:argv[3]];
        NSString *replaceString = [NSString stringWithUTF8String:argv[4]];

//        NSString *plistFilePath = @"/Users/wangsky/Desktop/safriPlist.plist";
//        NSString *matchValue = @"6789";
//        NSString *matchKey = @"array";
//        NSString *replaceString = @"hello";
        NSFileManager *plistFileManager = [NSFileManager defaultManager];
        Boolean plistExist =[plistFileManager fileExistsAtPath:plistFilePath isDirectory:NO];
        if (plistExist) {
            NSLog(@"The file is exist");
            NSMutableDictionary *plistContent = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
            NSArray *plistKeyArray = [plistContent allKeys];
            for (int i = 0; i < [plistKeyArray count]; i++) {
                NSString *plistKeyName = [plistKeyArray objectAtIndex:i];

                NSRegularExpression* keyRegex=[NSRegularExpression regularExpressionWithPattern:matchKey options:NSRegularExpressionCaseInsensitive error:nil];
                NSArray *keyMatchArray = [keyRegex matchesInString:plistKeyName options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [plistKeyName length])];
                if ([keyMatchArray count]) {
                    
                    NSMutableArray *plistValueArray = [plistContent objectForKey:plistKeyName];
                    for (int j = 0; j < [plistValueArray count]; j ++) {
                        NSString *plistValue = [plistValueArray objectAtIndex:j];
                        NSRegularExpression* valueRegex=[NSRegularExpression regularExpressionWithPattern:matchValue options:NSRegularExpressionCaseInsensitive error:nil];
               
                        NSString *plistReplacedValue = [valueRegex stringByReplacingMatchesInString:plistValue options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [plistValue length]) withTemplate:replaceString];
                        [plistValueArray replaceObjectAtIndex:j withObject:plistReplacedValue];
                    }
                [plistContent setValue:plistValueArray forKey:plistKeyName];
                }
            
            }
            [plistContent writeToFile:plistFilePath atomically:YES];
            NSLog(@"the match string has been replaced by replaced string .");
        }
        else{
            NSLog(@"Notice, the file is not exist");
        
        }
        
        
    }
    return 0;
}
