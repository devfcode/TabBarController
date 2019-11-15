//
//  MyTabBarController.m
//  TabBarController
//
//  Created by hello on 2019/10/5.
//  Copyright © 2019 Dio. All rights reserved.
//

#import "MyTabBarController.h"
#import "MyNavgationController.h"
#import "OneViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"
#import "FourViewController.h"

@interface MyTabBarController ()<UITabBarControllerDelegate>

/** 四个tabbar对应的动画图片数组 */
@property (strong, nonatomic) NSMutableArray <UIImage *>*homeImages;
@property (strong, nonatomic) NSMutableArray <UIImage *>*c2cImages;
@property (strong, nonatomic) NSMutableArray <UIImage *>*teamImages;
@property (strong, nonatomic) NSMutableArray <UIImage *>*mineImages;
/** 所有图片数组 */
@property (strong, nonatomic) NSMutableArray *allImages;
/** 当前的选中的tabbar按钮对应的图片容器 */
@property (strong, nonatomic) UIImageView *currentImageView;
/** 当前选中的tabbar下标 */
@property (assign, nonatomic) NSInteger currentIndex;

@end

@implementation MyTabBarController
// 动画图片个数
static NSInteger const ImageCount = 51;


- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.1 首页
    OneViewController *oneVC = [[OneViewController alloc] init];
    [self addOneViewController:oneVC image:@"tab_home_normal" selectedImage:@"tab_home_50" title:@"首页"];
    // 1.2 CTC
    TwoViewController *twoVC = [[TwoViewController alloc] init];
    [self addOneViewController:twoVC image:@"tab_c2c_normal" selectedImage:@"tab_c2c_50" title:@"CTC"];
    // 1.3 团队
    ThreeViewController *threeVC = [[ThreeViewController alloc] init];
    [self addOneViewController:threeVC image:@"tab_team_normal" selectedImage:@"tab_team_50" title:@"团队"];
    // 1.4 我的
    FourViewController *fourVC = [[FourViewController alloc] init];
    [self addOneViewController:fourVC image:@"tab_mine_normal" selectedImage:@"tab_mine_50" title:@"我的"];
    
    // 设置代理监听tabBar的点击
    self.delegate = self;
    
    //添加做动画所需的图片
    [self.allImages addObject:self.homeImages];
    [self.allImages addObject:self.c2cImages];
    [self.allImages addObject:self.teamImages];
    [self.allImages addObject:self.mineImages];
    //当前被点击的item
    self.currentIndex = 0;
    
    //设置文字属性(让选中前后文字和图片的颜色统一)
    [self setItemFont];
}

#pragma mark - 1.1.添加一个子控制器的方法
- (void)addOneViewController:(UIViewController *)childViewController image:(NSString *)imageName selectedImage:(NSString *)selectedImageName title:(NSString *)title {
    MyNavgationController *nav = [[MyNavgationController alloc] initWithRootViewController:childViewController];
    
    // 设置图片和文字之间的间距
    nav.tabBarItem.imageInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
    nav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -4);
    
    // 1.1.1 设置tabBar文字
    nav.tabBarItem.title = title;
    // 1.1.2 设置正常状态下的图标
    if (imageName.length) { // 图片名有具体
        nav.tabBarItem.image = [self oriRenderingImage:imageName];
        // 1.1.3 设置选中状态下的图标
        nav.tabBarItem.selectedImage = [self oriRenderingImage:selectedImageName];
    }
    
    // 1.1.5 添加tabBar为控制器的子控制器
    [self addChildViewController:nav];
}
//获取原始图片
-(UIImage *)oriRenderingImage:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - 2.设置tabBarItems的文字属性
-(void)setItemFont{
    // 2.0 设置TabBar的背景图片
    UITabBar *tabBarAppearance = [UITabBar appearance];
    [tabBarAppearance setShadowImage:[UIImage new]];
    [tabBarAppearance setBackgroundColor:[UIColor blackColor]];
    tabBarAppearance.translucent = NO;
    
    // 2.1 正常状态下的文字
    NSMutableDictionary *normalAttr = [NSMutableDictionary dictionary];
    normalAttr[NSForegroundColorAttributeName] = [UIColor colorWithRed:169 / 255.0 green:172 / 255.0 blue:174 / 255.0 alpha:1.0];
    normalAttr[NSFontAttributeName] = [UIFont systemFontOfSize:10];
    
    // 2.2 选中状态下的文字
    NSMutableDictionary *selectedAttr = [NSMutableDictionary dictionary];
    selectedAttr[NSForegroundColorAttributeName] = [UIColor colorWithRed:101 / 255.0 green:216 / 255.0 blue:255 / 255.0 alpha:1.0];
    selectedAttr[NSFontAttributeName] = [UIFont systemFontOfSize:10];
    
    // 2.3 统一设置UITabBarItem的文字属性
    UITabBarItem *item = [UITabBarItem appearance];
    // 2.3.1 设置UITabBarItem的正常状态下的文字属性
    [item setTitleTextAttributes:normalAttr forState:UIControlStateNormal];
    // 2.3.2 设置UITabBarItem的选中状态下的文字属性
    [item setTitleTextAttributes:selectedAttr forState:UIControlStateSelected];
}

//拦截tabBar的点击事件 - 通过代理实现
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSInteger index = [tabBarController.childViewControllers indexOfObject:viewController];
    
    //取到选中的tabBar 上的button
    UIButton *tabBarBtn = tabBarController.tabBar.subviews[index+1];
    //取到button上的imageView
    UIView *imageViewOrigin = [self findViewWithClassName:@"UITabBarSwappableImageView" inView:tabBarBtn];
    if (imageViewOrigin != nil) {
        UIImageView *imageView = (UIImageView *)imageViewOrigin;
        
        // 切换过了,就停止上一个动画
        if (self.currentIndex != index) {
            // 把上一个图片的动画停止
            [self.currentImageView stopAnimating];
            // 把上一个图片的动画图片数组置为空
            self.currentImageView.animationImages = nil;
        } else {//如果点击的还是当前item则不响应
            return NO;
        }
        
        imageView.animationImages = self.allImages[index];
        imageView.animationRepeatCount = 1;
        imageView.animationDuration = ImageCount * 0.025;
        
        // 开始动画
        [imageView startAnimating];
        
        // 记录当前选中的按钮的图片视图
        self.currentImageView = imageView;
        // 记录当前选中的下标
        self.currentIndex = index;
    }
    
    return YES;
}

//遍历获取指定类型的属性
- (UIView *)findViewWithClassName:(NSString *)className inView:(UIView *)view{
    Class specificView = NSClassFromString(className);
    if ([view isKindOfClass:specificView]) {
        return view;
    }

    if (view.subviews.count > 0) {
        for (UIView *subView in view.subviews) {
            UIView *targetView = [self findViewWithClassName:className inView:subView];
            if (targetView != nil) {
                return targetView;
            }
        }
    }
    
    return nil;
}

//系统方法,点击tabBar后响应(无法拦截点击事件)
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    NSLog(@"item name = %@", item.title);
}

/*********************************************** 点击动画素材加载 ***************************************************/
#pragma mark - 懒加载
- (NSMutableArray *)allImages {
    if (!_allImages) {
        _allImages = [NSMutableArray array];
    }
    return _allImages;
}

- (NSMutableArray<UIImage *> *)homeImages {
    if (!_homeImages) {
        _homeImages = [self addImage:@"home"];
    }
    return _homeImages;
}

- (NSMutableArray<UIImage *> *)c2cImages {
    if (!_c2cImages) {
        _c2cImages = [self addImage:@"c2c"];
    }
    return _c2cImages;
}

- (NSMutableArray<UIImage *> *)teamImages {
    if (!_teamImages) {
        _teamImages = [self addImage:@"team"];
    }
    return _teamImages;
}

- (NSMutableArray<UIImage *> *)mineImages {
    if (!_mineImages) {
        _mineImages = [self addImage:@"mine"];
    }
    return _mineImages;
}

- (NSMutableArray <UIImage *>*)addImage:(NSString *)imageName {
    NSMutableArray <UIImage *>*images = [NSMutableArray arrayWithCapacity:ImageCount];
    for (int i = 0; i < ImageCount; i++) {
        NSString *name = [NSString stringWithFormat:@"tab_%@_%02d", imageName, i];
        UIImage *img = [UIImage imageNamed:name];
        [images addObject:img];
    }
    return images;
}
/*********************************************** 做点击动画 ***************************************************/

@end
