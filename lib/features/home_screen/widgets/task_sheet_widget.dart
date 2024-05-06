import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swopin/data/user/user_repository.dart';
import 'package:swopin/dependency/user_module.dart';
import 'package:swopin/features/common/widgets/back_button.dart';
import 'package:swopin/features/home_screen/widgets/task_buttons.dart';
import 'package:swopin/utils/analytics_service.dart';

import '../../../data/tasks/tasks_repository.dart';
import '../../../data/telegram/telegram_app.dart';
import '../../../dependency/tasks_module.dart';
import '../../../models/task_model.dart';
import '../../../theme/button_style.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/toast_helper.dart';
import '../../common/widgets/gradient_with_state.dart';

class TaskSheet extends StatefulWidget {
  final Task task;

  const TaskSheet({super.key, required this.task});

  @override
  _TaskSheetState createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> {
  final TaskRepository _repository = TaskModule.taskRepository();
  final UserRepository _userRepository = UserModule.userRepository();

  final List<Timer?> _taskTimers = List.generate(
    5,
    (index) => null,
  );

  final List<bool?> _isClaimed = List.generate(5, (index) => null);
  bool _isClaimInProgress = false;
  bool _isClaimAvailable = false;

  @override
  void initState() {
    telegram.showConfirm(show: true);
    super.initState();
  }

  @override
  void dispose() {
    for (final timer in _taskTimers) {
      timer?.cancel();
    }
    telegram.showConfirm(show: false);
    super.dispose();
  }

  void _updateUser() {
    _userRepository.fetchUserByUid(
        id: Supabase.instance.client.auth.currentUser!.id,
        onError: (onError) {},
        onSuccess: (user) {});
  }

  Future<void> _claimTask({required int reward, required int taskId}) async {
    setState(() {
      _isClaimInProgress = true;
    });

    void enableButtons() {
      if (mounted) {
        setState(() {
          _isClaimAvailable = false;
          _isClaimInProgress = false;
        });
      }
    }

    void handleResult(String message) {
      ToastHelper.showSnackBar(text: message, context: context);
      enableButtons();
    }

    await Future.delayed(const Duration(seconds: 0), () {
      final stream = _repository.claim(
          userId: Supabase.instance.client.auth.currentUser!.id,
          reward: reward,
          taskId: taskId);

      stream.listen((value) {
        if (value.isNotEmpty) {
          handleResult(value);
          stream.close();
          _updateUser();
          analytics.logTaskSolve();
          Navigator.of(context).pop();
        }
      }, onError: (e) {
        handleResult(e);
        stream.close();
        analytics.logTaskSolve(error: e.toString());
      });
    });

  }

  Widget _task({required Task task, required int index}) {
    return Container(
        decoration: BoxDecoration(
          color: ColorsTheme.background,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(task.subTasks[index].title,
                    style: TextStyles.sheetSubTaskTitle),
              ],
            ),
            _isClaimed[index] == null
                ? StartTaskButton(onTap: () {
                    task.subTasks[index].openLink();
                    setState(() {
                      _isClaimed[index] = false;
                      _taskTimers[index] =
                          Timer(const Duration(seconds: 3), () {});
                    });
                  })
                : _isClaimed[index] == false
                    ? CheckTaskButton(onTap: () {
                        if (_taskTimers[index]?.isActive == true) {
                          setState(() {
                            _isClaimed[index] = null;
                          });
                          ToastHelper.showSnackBar(
                              text: 'You did not complete the task',
                              context: context);
                        } else {
                          setState(() {
                            _isClaimed[index] = true;
                            _isClaimAvailable = _isClaimed
                                    .where((element) => element == true)
                                    .toList()
                                    .length ==
                                task.subTasks.length;
                          });
                        }
                      })
                    : const DoneTaskButton(),
          ],
        ));
  }

  Widget _tasksList({required Task task}) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: task.subTasks.length,
      itemBuilder: (context, index) {
        return _task(task: task, index: index);
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 16);
      },
    );
  }

  Widget _claimButton() {
    return GradientWithState(
      isActive: _isClaimAvailable,
      activeGradient: ColorsTheme.gradientDefault,
      inactiveGradient: const LinearGradient(
          colors: [ColorsTheme.subTitleComColor, ColorsTheme.subTitleComColor]
      ),
      borderRadius: BorderRadius.circular(8),
      child: ElevatedButton(
          onPressed: _isClaimInProgress || !_isClaimAvailable
              ? null
              : () {
                  _claimTask(reward: widget.task.reward, taskId: widget.task.id);
                },
          style: ButtonsTheme.claimTaskButtonStyle,
          child: _isClaimInProgress
              ? const CircularProgressIndicator(color: ColorsTheme.primary)
              : const Text('Claim', style: TextStyles.claimButton),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: ColorsTheme.gradientDefault
      ),
      child: Padding(
          padding: const EdgeInsets.only(
            top: 4.0,
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: ColorsTheme.gradientForDialog,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Center(
                        child: Column(children: [
                      const SizedBox(
                        height: 32,
                      ),
                      Container(
                          decoration: BoxDecoration(
                              color: ColorsTheme.primary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ColorsTheme.secondary,
                                width: 1,
                              )),
                          height: 100,
                          width: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(widget.task.imageUrl,
                                fit: BoxFit.fill),
                          )),
                      const SizedBox(
                        height: 24,
                      ),
                    ])),
                    Positioned(
                      right: 0,
                      child: CustomBackButton(
                        isActive: !_isClaimInProgress,
                        arrowAngle: -90.0,
                        arrowColor: ColorsTheme.endGradientColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Text(
                  widget.task.description,
                  style: TextStyles.sheetTaskDescription,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/coin.svg',
                      width: 36,
                      height: 36,
                    ),
                    const SizedBox(width: 8),
                    Text('${widget.task.reward}', style: TextStyles.balanceOnRefValue),
                  ],
                ),
                const SizedBox(height: 16.0),
                _tasksList(task: widget.task),
                const SizedBox(height: 32.0),
                Row(
                  children: [Expanded(child: _claimButton())],
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          )),
    );
  }
}
