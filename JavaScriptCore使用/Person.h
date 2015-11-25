//
//  Person.h
//  JavaScriptCore使用
//
//  Created by archerLj on 15/11/20.
//  Copyright © 2015年 archerLj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

/**
 *  所有继承了JSExport协议的协议里面的变量和方法都可以在js中直接调用
 */

//--------------------------//--------------------------//--------------------------//--------------------------//--------------------------

@protocol JSUITextFieldExport <JSExport>
@property(nonatomic,copy) NSString *text;
@end

//--------------------------//--------------------------//--------------------------//--------------------------//--------------------------

@protocol PersonProtocol <JSExport>
@property (nonatomic, strong) NSDictionary *urls;
- (NSString *)fullName;
- (void)doFoo:(id)foo withBar:(id)bar; // js中用doFooWithBar(foo, bar);来调用
JSExportAs(testArgumentTypes,   // js中用testArgumentTypes(i, d, b, s, n, a, dic);来调用就可以了
           - (NSString *)testArgumentTypesWithInt:(int)i double:(double)d boolean:(BOOL)b string:(NSString *)s number:(NSNumber *)n array:(NSArray *)a dictionary:(NSDictionary *)o );
@end

//--------------------------//--------------------------//--------------------------//--------------------------//--------------------------
@interface Person : NSObject <PersonProtocol>
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@end
