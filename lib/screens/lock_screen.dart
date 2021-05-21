import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/notifier/lock_notifier.dart';
import 'package:storypad/screens/home/home_screen.dart';
import 'package:storypad/screens/setting_screen.dart';
import 'package:storypad/storages/is_unlocked_storage.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';
import 'package:storypad/widgets/w_icon_button.dart';

enum LockFlowType {
  RESET,
  REPLACE,
  SET,
  UNLOCK,
}

class LockScreenWrapper extends HookWidget {
  static const routeName = '/lockscreen';

  final LockDetail? lockDetail;
  final LockFlowType flowType;
  LockScreenWrapper(this.flowType, {this.lockDetail});

  @override
  Widget build(BuildContext context) {
    print("Build LockScreenWrapper");
    final notifier = useProvider(lockProvider(flowType));
    Map<int, List<int?>> map = {
      1: [1, 2, 3],
      2: [4, 5, 6],
      3: [7, 8, 9],
      4: [null, 0, 10]
    };

    final LockFlowType type = notifier.type ?? flowType;
    String? _headerText;
    if (notifier.type == LockFlowType.UNLOCK) {
      _headerText = tr("msg.passcode.unlock");
    }
    if (type == LockFlowType.SET) {
      _headerText = notifier.firstStepLockNumberMap != null
          ? tr("msg.passcode.set.step2")
          : tr("msg.passcode.set.step1");
    }
    if (type == LockFlowType.REPLACE) {
      _headerText = tr("msg.passcode.replace");
    }

    if (type == LockFlowType.RESET) {
      _headerText = tr("msg.passcode.reset");
    }

    if (notifier.errorMessage != null) {
      _headerText = notifier.errorMessage!;
    }

    return WillPopScope(
      onWillPop: () async {
        if (type != LockFlowType.UNLOCK) {
          ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
          Navigator.of(context)..pop()..pop();
        } else {
          if (Platform.isAndroid) {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        }
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: type != LockFlowType.UNLOCK
              ? WIconButton(
                  iconData: Icons.arrow_back,
                  onPressed: () {
                    ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
                    Navigator.of(context)..pop()..pop();
                  },
                )
              : null,
          actions: type == LockFlowType.UNLOCK
              ? [
                  WIconButton(
                    iconData: Icons.settings,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return SettingScreen(locked: true);
                          },
                        ),
                      );
                    },
                  )
                ]
              : null,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: ConfigConstant.duration * 2,
              opacity: notifier.opacity,
              child: Text(
                _headerText ?? "",
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: notifier.errorMessage != null
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) {
                  return Container(
                    height: kToolbarHeight * 1.5 - 21.5,
                    width: kToolbarHeight * 1.5 - 21.5,
                    margin: EdgeInsets.all(1.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.horizontal(
                        left: index == 0
                            ? Radius.circular(ConfigConstant.radius2)
                            : Radius.zero,
                        right: index == 3
                            ? Radius.circular(ConfigConstant.radius2)
                            : Radius.zero,
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 80),
                      height:
                          notifier.lockNumberMap["$index"] != null ? 12.0 : 0,
                      width:
                          notifier.lockNumberMap["$index"] != null ? 12.0 : 0,
                      decoration: BoxDecoration(
                        color: notifier.lockNumberMap["$index"] != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: map.entries.map((e) {
                final row = e.value;
                return IgnorePointer(
                  ignoring: notifier.ignoring,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((value) {
                      return GestureDetector(
                        onLongPress: value == 10
                            ? () {
                                notifier.setLockNumberMap(null);
                              }
                            : null,
                        child: VTOnTapEffect(
                          onTap: () async {
                            onTapVibrate();
                            if (value == null) return;
                            Map<String, String?> newMap =
                                notifier.lockNumberMap;
                            if (value == 10) {
                              int index = 0;
                              for (int i = 0; i < newMap.length; i++) {
                                if (newMap["$i"] != null) {
                                  index = i;
                                }
                              }
                              newMap["$index"] = null;
                              notifier.setLockNumberMap(newMap);
                              return;
                            } else {
                              if (notifier.isMax) return;
                              int index = 0;
                              for (int i = 0; i < newMap.length; i++) {
                                if (newMap["$i"] == null) {
                                  index = i;
                                  break;
                                }
                              }
                              newMap["$index"] = "$value";
                            }
                            notifier.setLockNumberMap(newMap);

                            /// above code is to get password as map, eg.
                            /// ```
                            /// map = { 0: 1, 1: 3, 2: 6, 3: 9 }
                            /// ```

                            if (type == LockFlowType.UNLOCK) {
                              if (notifier.isMax) {
                                if ("${notifier.storageLockNumberMap}" ==
                                    "${notifier.lockNumberMap}") {
                                  /// duration here need to be bigger than
                                  /// animatedContainer duration above
                                  /// to make it smoother
                                  Future.delayed(Duration(milliseconds: 100))
                                      .then(
                                    (value) {
                                      if (lockDetail != null &&
                                          lockDetail?.fromLaunch == false) {
                                        Navigator.of(context).pop();
                                      } else {
                                        Navigator.of(context).pushReplacement(
                                          PageTransition(
                                            child: HomeScreen(),
                                            type: PageTransitionType.fade,
                                            duration: ConfigConstant.duration,
                                          ),
                                        );
                                      }
                                      IsUnlockStorage().setBool(value: true);
                                    },
                                  );
                                } else {
                                  await notifier.setLockNumberMap(null,
                                      fadeLock: true);
                                  notifier.setErrorMessage(
                                    tr("msg.passcode.incorrect"),
                                  );
                                }
                              } else {
                                notifier.setErrorMessage(null);
                              }
                            }

                            if (type == LockFlowType.SET) {
                              if (notifier.isMax) {
                                bool completeStep1 =
                                    notifier.firstStepLockNumberMap != null;
                                if (completeStep1) {
                                  bool match =
                                      "${notifier.firstStepLockNumberMap}" ==
                                          "${notifier.lockNumberMap}";

                                  if (match) {
                                    var map2 = notifier.lockNumberMap;
                                    await notifier.service.setLock(map2);
                                    Navigator.of(context)..pop()..pop();
                                  } else {
                                    await notifier.setLockNumberMap(null,
                                        fadeLock: true);
                                    notifier.setErrorMessage(
                                      tr("msg.passcode.confirm_incorrect"),
                                    );
                                  }
                                } else {
                                  notifier.setfirstStepLockNumberMap(
                                      Map.fromIterable(
                                    notifier.lockNumberMap.entries,
                                    key: (e) => "${e.key}",
                                    value: (e) => "${e.value}",
                                  ));
                                  notifier.setLockNumberMap(null);
                                  notifier.fadeOpacity();
                                }
                              } else {
                                notifier.setErrorMessage(null);
                              }
                            }

                            if (type == LockFlowType.REPLACE) {
                              if (notifier.isMax) {
                                bool match =
                                    "${notifier.storageLockNumberMap}" ==
                                        "${notifier.lockNumberMap}";
                                if (match) {
                                  notifier.setFlowType(
                                    LockFlowType.SET,
                                    false,
                                  );
                                  notifier.setLockNumberMap(null);
                                  notifier.fadeOpacity();
                                } else {
                                  await notifier.setLockNumberMap(
                                    null,
                                    fadeLock: true,
                                  );
                                  notifier.setErrorMessage(
                                    tr("msg.passcode.incorrect"),
                                  );
                                }
                              } else {
                                notifier.setErrorMessage(null);
                              }
                            }

                            if (type == LockFlowType.RESET) {
                              if (notifier.isMax) {
                                bool match =
                                    "${notifier.storageLockNumberMap}" ==
                                        "${notifier.lockNumberMap}";
                                if (match) {
                                  await notifier.service.clearLock();
                                  Navigator.of(context)..pop()..pop();
                                } else {
                                  await notifier.setLockNumberMap(null,
                                      fadeLock: true);
                                  notifier.setErrorMessage(
                                      tr("msg.passcode.incorrect"));
                                }
                              } else {
                                notifier.setErrorMessage(null);
                              }
                            }
                          },
                          child: Container(
                            height: kToolbarHeight * 1.5,
                            width: kToolbarHeight * 1.5,
                            margin: EdgeInsets.all(1.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.only(
                                topLeft: value == 1
                                    ? Radius.circular(ConfigConstant.radius2)
                                    : Radius.zero,
                                topRight: value == 3
                                    ? Radius.circular(ConfigConstant.radius2)
                                    : Radius.zero,
                                bottomLeft: value == null
                                    ? Radius.circular(ConfigConstant.radius2)
                                    : Radius.zero,
                                bottomRight: value == 10
                                    ? Radius.circular(ConfigConstant.radius2)
                                    : Radius.zero,
                              ),
                            ),
                            child: value != null
                                ? value == 10
                                    ? Icon(Icons.arrow_back)
                                    : Text(
                                        "$value",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
