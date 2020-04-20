#import "pushbuttoncommand.h"

#import <streamwindow.h>
#import <settings.h>

#import <Cocoa/Cocoa.h>
#import <QCoreApplication>
#import <QApplication>
#import <QObject>
#import <QKeyEvent>
#import <QTimer>

StreamWindow* getStreamWindow()
{
    foreach(QWidget *widget, qApp->topLevelWidgets())
        if (StreamWindow *streamWindow = qobject_cast<StreamWindow*>(widget))
            return streamWindow;
    return NULL;
}

QMap<QString, Qt::Key> getKeyMap()
{
  Settings *settings = new Settings();
	auto map = settings->GetControllerMapping();

	QMap<QString, Qt::Key> result =
	{
    {"Cross", map[CHIAKI_CONTROLLER_BUTTON_CROSS]},
    {"Moon", map[CHIAKI_CONTROLLER_BUTTON_MOON]},
    {"Box", map[CHIAKI_CONTROLLER_BUTTON_BOX]},
    {"Pyramid", map[CHIAKI_CONTROLLER_BUTTON_PYRAMID]},
    {"D-Pad Left", map[CHIAKI_CONTROLLER_BUTTON_DPAD_LEFT]},
    {"D-Pad Right", map[CHIAKI_CONTROLLER_BUTTON_DPAD_RIGHT]},
    {"D-Pad Up", map[CHIAKI_CONTROLLER_BUTTON_DPAD_UP]},
    {"D-Pad Down", map[CHIAKI_CONTROLLER_BUTTON_DPAD_DOWN]},
    {"L1", map[CHIAKI_CONTROLLER_BUTTON_L1]},
    {"R1", map[CHIAKI_CONTROLLER_BUTTON_R1]},
    {"L3", map[CHIAKI_CONTROLLER_BUTTON_L3]},
    {"R3", map[CHIAKI_CONTROLLER_BUTTON_R3]},
    {"Options", map[CHIAKI_CONTROLLER_BUTTON_OPTIONS]},
    {"Share", map[CHIAKI_CONTROLLER_BUTTON_SHARE]},
    {"Touchpad", map[CHIAKI_CONTROLLER_BUTTON_TOUCHPAD]},
    {"PS", map[CHIAKI_CONTROLLER_BUTTON_PS]},
    {"L2", map[CHIAKI_CONTROLLER_ANALOG_BUTTON_L2]},
    {"R2", map[CHIAKI_CONTROLLER_ANALOG_BUTTON_R2]},
    {"Left Stick Right", map[static_cast<int>(ControllerButtonExt::ANALOG_STICK_LEFT_X_UP)]},
    {"Left Stick Up", map[static_cast<int>(ControllerButtonExt::ANALOG_STICK_LEFT_Y_UP)]},
    {"Right Stick Right", map[static_cast<int>(ControllerButtonExt::ANALOG_STICK_RIGHT_X_UP)]},
    {"Right Stick Up", map[static_cast<int>(ControllerButtonExt::ANALOG_STICK_RIGHT_Y_UP)]},
    {"Left Stick Left", map[static_cast<int>(ControllerButtonExt::ANALOG_STICK_LEFT_X_DOWN)]},
    {"Left Stick Down", map[static_cast<int>(ControllerButtonExt::ANALOG_STICK_LEFT_Y_DOWN)]},
    {"Right Stick Left", map[static_cast<int>(ControllerButtonExt::ANALOG_STICK_RIGHT_X_DOWN)]},
    {"Right Stick Down", map[static_cast<int>(ControllerButtonExt::ANALOG_STICK_RIGHT_Y_DOWN)]}
	};

  return result;
}

@implementation PushButtonCommand

- (id)performDefaultImplementation
{
    NSDictionary *args = [self evaluatedArguments];
    NSString *buttonToPush = @"";
    if(args.count) {
        buttonToPush = [args valueForKey:@""]; // get the direct argument
    } else {
        [self setScriptErrorNumber:-50];
        [self setScriptErrorString:@"Parameter Error: A Parameter is expected for the verb 'push' (You have to specify _what_ you want to push!)."];
        return nil;
    }

    StreamWindow *window = getStreamWindow();
    if (window == NULL) {
        [self setScriptErrorNumber:-51];
        [self setScriptErrorString:@"No active stream found. Connect to console first"];
        return nil;
    }

    auto map = getKeyMap();
    auto keyString = QString::fromNSString(buttonToPush);

    if (!map.contains(keyString)) {
      [self setScriptErrorNumber:-52];
      [self setScriptErrorString:@"Wrong key name"];
      return nil;
    }

    auto key = map[keyString];

    QKeyEvent *press = new QKeyEvent(QEvent::KeyPress, key, Qt::NoModifier, NULL);
    QCoreApplication::postEvent(window, press);
    QTimer::singleShot(100, [window, key]() {
        QKeyEvent *release = new QKeyEvent(QEvent::KeyRelease, key, Qt::NoModifier, NULL);
        QCoreApplication::postEvent(window, release);
    });

    return nil;
}

@end
