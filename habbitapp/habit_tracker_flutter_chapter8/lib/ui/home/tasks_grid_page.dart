// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:habit_tracker_flutter/models/app_theme_settings.dart';
import 'package:habit_tracker_flutter/models/task.dart';
import 'package:habit_tracker_flutter/ui/home/home_page_bottom_options.dart';
import 'package:habit_tracker_flutter/ui/home/tasks_grid.dart';
import 'package:habit_tracker_flutter/ui/sliding_panel/sliding_panel.dart';
import 'package:habit_tracker_flutter/ui/sliding_panel/sliding_panel_animator.dart';
import 'package:habit_tracker_flutter/ui/sliding_panel/theme_selection_close.dart';
import 'package:habit_tracker_flutter/ui/sliding_panel/theme_selection_list.dart';
import 'package:habit_tracker_flutter/ui/theming/animanted_app_theme.dart';
import 'package:habit_tracker_flutter/ui/theming/app_theme.dart';

class TasksGridPage extends StatelessWidget {
  const TasksGridPage({
    Key? key,
    required this.leftAnimator,
    required this.rightAnimator,
    required this.tasks,
    this.onFlip,
    required this.themeSettings,
    this.onColorIndexSelected,
    this.onVariantIndexSelected,
  }) : super(key: key);
  final GlobalKey<SlidingPanelAnimatorState> leftAnimator;
  final GlobalKey<SlidingPanelAnimatorState> rightAnimator;
  final List<Task> tasks;
  final VoidCallback? onFlip;
  final AppThemeSettings themeSettings;
  final ValueChanged<int>? onColorIndexSelected;
  final ValueChanged<int>? onVariantIndexSelected;

  void _onEnterEditMode() {
    leftAnimator.currentState?.slideIn();
    rightAnimator.currentState?.slideIn();
  }

  void _exitEditMode() {
    leftAnimator.currentState?.slideOut();
    rightAnimator.currentState?.slideOut();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAppTheme(
      data: themeSettings.themeData,
      duration: Duration(milliseconds: 300),
      child: Builder(builder: (context) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.of(context).overlayStyle,
          child: Scaffold(
            backgroundColor: AppTheme.of(context).primary,
            body: SafeArea(
                child: Stack(
              children: [
                TasksGridContents(
                  tasks: tasks,
                  onFlip: onFlip,
                  onEnterEditMode: _onEnterEditMode,
                ),
                Positioned(
                  bottom: 6,
                  left: 0,
                  width: SlidingPanel.leftPanelFixedWidth,
                  child: SlidingPanelAnimator(
                    key: leftAnimator,
                    direction: SlideDirection.leftToRight,
                    child: ThemeSelectionClose(
                      onClose: _exitEditMode,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 0,
                  width: MediaQuery.of(context).size.width -
                      SlidingPanel.leftPanelFixedWidth,
                  child: SlidingPanelAnimator(
                    key: rightAnimator,
                    direction: SlideDirection.rightToLeft,
                    child: ThemeSelectionList(
                      currentThemeSettings: themeSettings,
                      availableWidth: MediaQuery.of(context).size.width -
                          SlidingPanel.leftPanelFixedWidth -
                          SlidingPanel.paddingWidth,
                      onColorIndexSelected: onColorIndexSelected,
                      onVariantIndexSelected: onVariantIndexSelected,
                    ),
                  ),
                ),
              ],
            )),
          ),
        );
      }),
    );
  }
}

class TasksGridContents extends StatelessWidget {
  const TasksGridContents({
    Key? key,
    required this.tasks,
    this.onFlip,
    this.onEnterEditMode,
  }) : super(key: key);
  final List<Task> tasks;
  final VoidCallback? onFlip;
  final VoidCallback? onEnterEditMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: TasksGrid(
              tasks: tasks,
            ),
          ),
        ),
        HomePageBottomOptions(
          onFlip: onFlip,
          onEnterEditMode: onEnterEditMode,
        ),
      ],
    );
  }
}
