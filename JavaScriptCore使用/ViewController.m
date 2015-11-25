//
//  ViewController.m
//  JavaScriptCore使用
//
//  Created by archerLj on 15/11/20.
//  Copyright © 2015年 archerLj. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "Person.h"
#import <objc/runtime.h>

@interface ViewController () <UIWebViewDelegate>
@property (strong, nonatomic) JSContext *context;
@property (strong, nonatomic) JSContext *contextWeb;
@property (strong, nonatomic) UIWebView *tempVIew;
@property (strong, nonatomic) NSDictionary *rightIconAction;
@property (strong, nonatomic) Person *p;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tempVIew = [[UIWebView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height-100)];
    self.tempVIew.delegate = self;
    [self.view addSubview:self.tempVIew];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *htmlStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.tempVIew loadHTMLString:htmlStr baseURL:nil];
    
    
    UIButton *testButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    [testButton setBackgroundColor:[UIColor redColor]];
    [testButton setTitle:@"点我来调用js方法" forState:UIControlStateNormal];
    [self.view addSubview:testButton];
    [testButton addTarget:self action:@selector(doFoo) forControlEvents:UIControlEventTouchUpInside];
//    [self dataTransform];
//    [self createJsFunc];
//        [self.context evaluateScript:@"function add(a, b) { return a + b; }"];
//    [self useJSFunc];
//    [self exceptionHandler];
//    [self ocDictAndJsObject];
//    [self ocClassAndJs];
//    [self addProtocolForSystermClassAndThirClass];
}

//*****************************************************************************/
#pragma mark - Js 与 OC的交互Mehods
//*****************************************************************************/

//-----------------------
//  1.数据类型转换
//-----------------------
-(void)dataTransform {
    
    // 整型
    JSValue *jsVal = [self.context evaluateScript:@"21+7"];
    int iVal = [jsVal toInt32];
    NSLog(@"JSValue:%@,  intValue:%d",jsVal,iVal);
    
    
    // 数组
     [self.context evaluateScript:@"var arr = [21, 7 , 'iderzheng.com'];"];
     JSValue *jsArr = self.context[@"arr"]; // Get array from JSContext
     NSLog(@"JS Array: %@; Length: %@", jsArr, jsArr[@"length"]); //通过JSValue还可以获取JavaScript对象上的属性，比如例子中通过"length"就获取到了JavaScript数组的长度
     jsArr[1] = @"blog"; // Use JSValue as array
     jsArr[7] = @7;
     NSLog(@"JS Array: %@; Length: %d", jsArr, [jsArr[@"length"] toInt32]);
    NSArray *nsArr = [jsArr toArray];
    NSLog(@"NSArray: %@", nsArr);
}

//-----------------------
//  2.创建js方法
//-----------------------
-(void)createJsFunc { // Objective-C的Block也可以传入JSContext中当做JavaScript的方法使用
    
        self.context[@"fucna"] = ^() {
            NSLog(@"+++++++Begin Log+++++++");

            NSArray *args = [JSContext currentArguments];
            for (JSValue *jsVal in args) {
              NSLog(@"%@", jsVal);
            }

            JSValue *this = [JSContext currentThis];
            NSLog(@"this: %@",this);
            NSLog(@"-------End Log-------");
        };
         [self.context evaluateScript:@"fucna('ider', [7, 21], { hello:'world', js:100 });"];
}

//-----------------------
//  3.调用js方法
//-----------------------
-(void)useJSFunc {
    
    [self.context evaluateScript:@"function add(a, b) { return a + b; }"];
    JSValue *add = self.context[@"add"];
    NSLog(@"Func: %@", add);

    JSValue *sum = [add callWithArguments:@[@(7), @(21)]];
    NSLog(@"Sum: %d",[sum toInt32]);
    
//    [sum invokeMethod:<#(NSString *)#> withArguments:<#(NSArray *)#>];
}

//-----------------------
// 4.js执行异常处理
//-----------------------
-(void)exceptionHandler {

     [self.context evaluateScript:@"ider.zheng = 21"];
}

//----------------------------------------
// 5.OC字典和js对象之间的转换
//----------------------------------------
-(void)ocDictAndJsObject {
    
    JSValue *obj =[self.context evaluateScript:@"var jsObj = { number:7, name:'Ider' }; jsObj"];
    NSLog(@"%@, %@", obj[@"name"], obj[@"number"]);
    NSDictionary *dic = [obj toDictionary];
    NSLog(@"%@, %@", dic[@"name"], dic[@"number"]);
    
    NSDictionary *dict = @{@"name": @"Ider", @"#":@(21)};
    self.context[@"dic"] = dict;
    [self.context evaluateScript:@"log(dic.name, dic['#'])"];

}

//----------------------------------------
// 6.OC自定义类和js
//----------------------------------------
-(void)ocClassAndJs {
    // initialize person object
    Person *person = [[Person alloc] init];
    self.context[@"p"] = person;
    person.firstName = @"Ider";
    person.lastName = @"Zheng";
    person.urls = @{@"site": @"http://www.iderzheng.com"};

    
    // ok to get fullName
    [self.context evaluateScript:@"log(p.fullName());"];
    // cannot access firstName
    [self.context evaluateScript:@"log(p.firstName);"];
    // ok to access dictionary as object
    [self.context evaluateScript:@"log('site:', p.urls.site, 'blog:', p.urls.blog);"];
    // ok to change urls property
    [self.context evaluateScript:@"p.urls = {blog:'http://blog.iderzheng.com'}"];
    [self.context evaluateScript:@"log('-------AFTER CHANGE URLS-------')"];
    [self.context evaluateScript:@"log('site:', p.urls.site, 'blog:', p.urls.blog);"];
    
    // affect on Objective-C side as well
    NSLog(@"%@", person.urls);
}

//--------------------------------------------------
// 7.为系统类或第三方框架类动态添加协议
//--------------------------------------------------
-(void)addProtocolForSystermClassAndThirClass {
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
    [self.view addSubview:textField];
    textField.text = @"70";
    class_addProtocol([UITextField class], @protocol(JSUITextFieldExport));
    
    self.context[@"textField"] = textField;
    NSString *script = @"textField.text = 33";
    [self.context evaluateScript:script];
    [self.context evaluateScript:@"log(textField.text)"];
    NSLog(@"%@",textField.text);
}

//--------------------------------------------------
// 7.为context设置js异常处理和Log
//--------------------------------------------------
-(JSContext *)context {
    
    if (!_context) {
        
        _context = [[JSContext alloc] init];
        _context.exceptionHandler = ^(JSContext *con, JSValue *exception) {
            NSLog(@"%@", exception);
            con.exception = exception;
        };
        
        _context[@"log"] = ^() {
            NSArray *args = [JSContext currentArguments];
            for (id obj in args) {
                NSLog(@"%@",obj);
            }
        };
    }
    return _context;
}

//*****************************************************************************/
#pragma mark - webView Delegate Methods
//*****************************************************************************/
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
    //创建JSContext 对象
    self.contextWeb =[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    /* 注意：
     在《iOS7新JavaScriptCore框架入门介绍》有提到JSVirtualMachine为整个JavaScriptCore的执行提供资源，所以当将一个JSValue转成JSManagedValue后，就可以添加到JSVirtualMachine中，这样在运行期间就可以保证在Objective-C和JavaScript两侧都可以正确访问对象而不会造成不必要的麻烦。
     */
    self.p = [[Person alloc] init];
    JSValue *pValue = [JSValue valueWithObject:self.p inContext:self.contextWeb];
    JSManagedValue *pManage = [JSManagedValue managedValueWithValue:pValue];
    [self.contextWeb.virtualMachine addManagedReference:pManage withOwner:self];
    
    // 将Person对象和js中的person变量绑定
    self.contextWeb[@"person"] = self.p;
    
    // 调用js中的方法，获取返回json (json中包含native按钮要执行的js动作)
    JSValue *testFunc = self.contextWeb[@"textFunc"];
    JSValue *result = [testFunc callWithArguments:nil];
    self.rightIconAction = [result toDictionary];
}

//*****************************************************************************/
#pragma mark - UIButton Action Methods
//*****************************************************************************/
-(void)doFoo {
    
    // native按钮执行js中的function
    JSValue *action = self.contextWeb[self.rightIconAction[@"action"]];
    [action callWithArguments:nil];
}
@end
