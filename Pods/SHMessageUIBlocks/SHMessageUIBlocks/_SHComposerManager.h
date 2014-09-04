
@protocol MFMessageComposeViewControllerDelegate;
@protocol MFMailComposeViewControllerDelegate;

@protocol SHComposerDelegate <NSObject>
@required
-(void)setMessageComposeDelegate:(id<MFMessageComposeViewControllerDelegate>)theDelegate;
-(void)setMailComposeDelegate:(id<MFMailComposeViewControllerDelegate>)theDelegate;
@end

@interface _SHComposerBlocksManager : NSObject

#pragma mark - Class selectors


#pragma mark - Setter
+(void)setComposerDelegate:(id<SHComposerDelegate>)theComposer;

+(void)setBlock:(id)theBlock forController:(UIViewController *)theController;


#pragma mark - Getter
+(id)blockForController:(UIViewController *)theController;
@end