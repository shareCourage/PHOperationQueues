//
//  ViewController.m
//  OperationQueues
//
//  Created by leichunfeng on 15/8/1.
//  Copyright (c) 2015年 leichunfeng. All rights reserved.
//



#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "OQCreateInvocationOperation.h"
#import "OQCreateBlockOperation.h"
#import "OQNonConcurrentOperation.h"

static NSString *kimageUrl1 = @"http://s17.mogucdn.com/b7/bao/131012/vud8_kqywordekfbgo2dwgfjeg5sckzsew_310x426.jpg_200x999.jpg";
static NSString *kimageUrl2 = @"http://s6.mogujie.cn/b7/bao/131008/q2o17_kqyvcz3ckfbewv3wgfjeg5sckzsew_330x445.jpg_200x999.jpg";
static NSString *kimageUrl3 = @"http://s6.mogujie.cn/b7/bao/131011/zovz9_kqyuwtdykfbgo2dwgfjeg5sckzsew_290x383.jpg_200x999.jpg";
static NSString *kimageUrl4 = @"http://s12.mogujie.cn/b7/bao/131010/ws4e5_kqyvs3swkfbfcvtwgfjeg5sckzsew_400x540.jpg_200x999.jpg";
static NSString *kimageUrl5 = @"http://s6.mogujie.cn/b7/bao/131008/ynbuu_kqyxqrcdkfbgo6cugfjeg5sckzsew_259x458.jpg_200x999.jpg";
static NSString *kimageUrl6 = @"http://s12.mogujie.cn/b7/bao/131011/1jix9_kqywmrcdkfbg26dwgfjeg5sckzsew_400x540.jpg_200x999.jpg";

@interface ViewController ()
{
    OQNonConcurrentOperation *_nonOperation;
}
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *myImageViews;
@property (strong, nonatomic) NSArray *kimageUrls;

@property (strong, nonatomic) NSMutableArray *imageUrls;
@property (strong, nonatomic) NSMutableArray *imageViews;
@end

@implementation ViewController
- (NSMutableArray *)imageUrls {
    if (!_imageUrls) {
        _imageUrls = [NSMutableArray array];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"3.plist" ofType:nil];
        NSArray *goodsArray = [NSArray arrayWithContentsOfFile:path];
        for (NSDictionary *dict in goodsArray) {
            NSString *image = dict[@"img"];
//            NSURL *imageUrl = [NSURL URLWithString:image];
            [_imageUrls addObject:image];
        }
    }
    return _imageUrls;
}
- (IBAction)clearButton:(id)sender {
    
    [_nonOperation cancel];

}
- (IBAction)startButton:(id)sender {
    [self definitionOperation];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    self.myScrollView.contentSize = CGSizeMake(375, 1900);
    self.imageViews = [NSMutableArray array];
    int k = 0;
    for (NSUInteger i = 0; i < 16; i ++) {
        for (NSUInteger j = 0; j < 3; j ++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.tag = k + 1000;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255.f) / 255.f green:arc4random_uniform(255.f) / 255.f blue:arc4random_uniform(255.f) / 255.f alpha:1];
            imageView.frame = CGRectMake(j * 100 + 10 *j + 30, i * 100 + 10 * i, 100, 100);
            [self.myScrollView addSubview:imageView];
            [self.imageViews addObject:imageView];
            k ++;
        }
    }
    
    self.imageUrls; //只是为了调用他的getter方法
    
    self.kimageUrls = @[kimageUrl1,kimageUrl2,kimageUrl3,kimageUrl4,kimageUrl5,kimageUrl6];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self blockOperationMethod2];
    [self blockOperationMethod3];
}

- (void)method1 {
    OQCreateInvocationOperation *invo = [[OQCreateInvocationOperation alloc] init];
    NSInvocationOperation *invoOpe = [invo invocationOperationWithData:@"hehe"];
    [invoOpe start];
}
- (void)method2 {
    OQCreateInvocationOperation *invo = [[OQCreateInvocationOperation alloc] init];
    NSInvocationOperation *invoOpe =[invo invocationOperationWithData:@"hahaha" userInput:nil];
    [invoOpe start];
}
- (void)method3 {
    OQCreateInvocationOperation *invo = [[OQCreateInvocationOperation alloc] init];
    NSInvocationOperation *invoOpe =[invo invocationOperationWithTarget:self selector:@selector(downloadMethod3:) data:@"method3"];
    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
    [opQueue addOperation:invoOpe];
//    [invoOpe start]; //如果是这样启动NSInvocationOperation，则不会开启子线程，直接在当前线程下执行
}

- (void)downloadMethod3:(id)data {
    [self.myImageView setImageWithURL:[NSURL URLWithString:kimageUrl1]];
    self.myImageView.contentMode = UIViewContentModeScaleAspectFit;
    NSLog(@"\n%@ data -> %@ \nmainThread: %@, currentThread: %@",NSStringFromSelector(_cmd),data,  [NSThread mainThread], [NSThread currentThread]);
}

- (void)blockOperationMethod1 {
    OQCreateBlockOperation *block = [[OQCreateBlockOperation alloc] init];
    NSBlockOperation *blockOpe = [block blockOperation];
    [blockOpe start];
}
- (void)blockOperationMethod2 {
    __weak typeof(self) weakSelf = self;
    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
    NSMutableArray *blocks = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.imageViews.count; i ++) {
        NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
            NSString *imageUrl = weakSelf.imageUrls[i];
            UIImageView *imageView = weakSelf.imageViews[i];
            NSLog(@"~~~~~~~~~imageView->tag -> %ld",imageView.tag);
            [imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
        }];
        [blocks addObject:block];
        if (i > 0) {
            NSBlockOperation *blockPrevious = blocks[i - 1];
            NSBlockOperation *blockNow = blocks[i];
            [blockNow addDependency:blockPrevious];
        }
    }
    
    opQueue.maxConcurrentOperationCount = 1;
    [opQueue addOperations:blocks waitUntilFinished:YES];//使用NSOperationQueue一定能保证在子线程执行
    [opQueue waitUntilAllOperationsAreFinished];
}

- (void)blockOperationMethod3 {
    __weak typeof(self) weakSelf = self;
    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
    NSMutableArray *blocks = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.myImageViews.count; i ++) {
        NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
            NSString *imageUrl = weakSelf.kimageUrls[i];
            UIImageView *imageView = weakSelf.myImageViews[i];
            [imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
            NSLog(@"\n_cmd -> %@ \n: %ld, currentThread: %@",NSStringFromSelector(_cmd),  imageView.tag, [NSThread currentThread]);
        }];
        [blocks addObject:block];
        if (i > 0) {
            NSBlockOperation *blockPrevious = blocks[i - 1];
            NSBlockOperation *blockNow = blocks[i];
            [blockNow addDependency:blockPrevious];
        }
        if (i == 0) {
            block.completionBlock = ^{
                sleep(3.f);
                NSLog(@"\n~~~~~~~~~~~completionBlock -> %ld", i);
            };
        }
    }
    
    opQueue.maxConcurrentOperationCount = 2;
    [opQueue addOperations:blocks waitUntilFinished:YES];//使用NSOperationQueue一定能保证在子线程执行
    //    [self.blockOpe start];//里面的block可能在主线程执行，并不能保证
    NSLog(@"~~~~~~~~~~~++++++++++++++++++++++++++++");
}

- (void)definitionOperation {
    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
    _nonOperation = [[OQNonConcurrentOperation alloc] initWithData:@"nonOperation"];
    
    [opQueue addOperation:_nonOperation];
}



@end












