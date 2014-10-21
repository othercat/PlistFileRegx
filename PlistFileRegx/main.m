//
//  main.m
//  PlistFileRegx
//
//  Created by Wang Sky on 14/10/20.
//  Copyright (c) 2014 Richard Li. All rights reserved.
//

#import <Foundation/Foundation.h>

void recurrenceArraryValue(NSMutableArray *plistArray,NSString *matchValue,NSString *replaceString)
{
    for (int i = 0; i < [plistArray count]; i++) {
        
        NSString *strName = [[plistArray objectAtIndex:i] className];
        if ([strName isEqualTo:@"__NSArrayM"])
            recurrenceArraryValue([plistArray objectAtIndex:i],matchValue,replaceString);
        else if ([strName isEqualTo:@"__NSCFConstantString"]||[strName isEqualTo:@"__NSCFString"]||[strName isEqualTo:@"NSTaggedPointerString"]) {
            NSString *plistValue = [plistArray objectAtIndex:i];
            NSRegularExpression* valueRegex=[NSRegularExpression regularExpressionWithPattern:matchValue options:NSRegularExpressionCaseInsensitive error:nil];
            NSString *plistReplacedValue = [valueRegex stringByReplacingMatchesInString:plistValue options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [plistValue length]) withTemplate:replaceString];
            [plistArray replaceObjectAtIndex:i withObject:plistReplacedValue];
        }
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        for (int n = 1; n < 4; n++) {
            if (!argv[n]) {
                printf("The %d option is null!\n",n);
                exit(0);
            }
        }

        NSString *matchKey = [NSString stringWithUTF8String:argv[1]]; //array keyword
        NSString *matchValue = [NSString stringWithUTF8String:argv[2]]; //value keyword
        NSString *replaceString = [NSString stringWithUTF8String:argv[3]]; //replace string
        NSString *plistFilePath = [NSString stringWithUTF8String:argv[4]]; //path to plist

        NSFileManager *plistFileManager = [NSFileManager defaultManager];
        Boolean plistExist =[plistFileManager fileExistsAtPath:plistFilePath isDirectory:NO];
        if (plistExist) {
            
            NSMutableDictionary *plistContent = [NSMutableDictionary dictionaryWithContentsOfFile:plistFilePath];
            NSArray *plistKeyArray = [plistContent allKeys];
            
            for (int i = 0; i < [plistKeyArray count]; i++) {
                NSString *plistKeyName = [plistKeyArray objectAtIndex:i];
                NSRegularExpression *keyRegex=[NSRegularExpression regularExpressionWithPattern:matchKey options:NSRegularExpressionCaseInsensitive error:nil];
                NSArray *keyMatchArray = [keyRegex matchesInString:plistKeyName options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [plistKeyName length])];
                
                if (([keyMatchArray count])||([matchKey isEqual: @"EntireString"] ))  {
                    
                    NSMutableArray *plistValueArray = [plistContent objectForKey:plistKeyName];
                    NSString *strName = [plistValueArray className];
                    if ([strName isNotEqualTo:@"__NSArrayM"])
                        continue;
                    
                    recurrenceArraryValue(plistValueArray,matchValue,replaceString);

                    [plistContent setValue:plistValueArray forKey:plistKeyName];
                }
            
            }

            [plistContent writeToFile:plistFilePath atomically:YES];
        }
        
    }
    return 0;
}
