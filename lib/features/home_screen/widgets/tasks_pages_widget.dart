import 'dart:core';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swopin/data/tasks/tasks_repository.dart';
import 'package:swopin/dependency/tasks_module.dart';
import 'package:swopin/dependency/user_module.dart';
import 'package:swopin/features/home_screen/widgets/task_sheet_widget.dart';

import '../../../data/user/user_repository.dart';
import '../../../models/task_model.dart';
import '../../../models/user_model.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  _PagesState createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  final controller = PageController();

  final TaskRepository _repository = TaskModule.taskRepository();
  final UserRepository _userRepository = UserModule.userRepository();

  BehaviorSubject<List<Task>> _tasksStream = BehaviorSubject<List<Task>>();
  BehaviorSubject<User> _userStream = BehaviorSubject<User>();
  late Stream<List<Task>> _combinedStream;

  int numPages = 0;

  @override
  void initState() {
    super.initState();
    _tasksStream = _repository.fetchTasks();
    _userStream = _userRepository.user;
    _combinedStream =
        Rx.combineLatest2(_tasksStream, _userStream, (tasks, user) {
      return tasks.map((task) {
        return task.copyWith(isCompleted: user.tasks?.contains(task.id));
      }).toList()
        ..sort((a, b) => a.isCompleted == b.isCompleted
            ? 0
            : a.isCompleted
                ? 1
                : -1);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showTask(
      {required Task task, required BuildContext context}) async {
    showModalBottomSheet(
      backgroundColor: ColorsTheme.secondary,
      context: context,
      clipBehavior: Clip.antiAlias,
      isDismissible: false,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TaskSheet(task: task);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          decoration: BoxDecoration(
            color: ColorsTheme.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: StreamBuilder<List<Task>>(
            stream: _combinedStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final itemsPerPage =
                        ((constraints.maxHeight - 48) / 72.0).floor();
                    numPages = (snapshot.data!.length / itemsPerPage).ceil();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: PageView.builder(
                                controller: controller,
                                itemCount: numPages,
                                itemBuilder: (context, pageIndex) {
                                  final startIndex = pageIndex * itemsPerPage;
                                  final endIndex = (startIndex + itemsPerPage <
                                          snapshot.data!.length)
                                      ? startIndex + itemsPerPage
                                      : snapshot.data!.length;
                                  return ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: endIndex - startIndex,
                                      separatorBuilder: (context, index) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 0),
                                          child: Divider(
                                              height: 1,
                                              color: ColorsTheme.primary),
                                        );
                                      },
                                      itemBuilder: (context, index) {
                                        final task =
                                            snapshot.data![startIndex + index];
                                        return Container(
                                            alignment: Alignment.center,
                                            height: 72,
                                            child: ListTile(
                                              onTap: task.isCompleted
                                                  ? null
                                                  : () {
                                                      _showTask(
                                                          task: task,
                                                          context: context);
                                                    },
                                              enabled: !task.isCompleted,
                                              leading: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          ColorsTheme.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    height: 48,
                                                    width: 48,
                                                    child: Image.network(
                                                        task.imageUrl,
                                                        fit: BoxFit.fill,
                                                        colorBlendMode:
                                                            BlendMode.srcOver,
                                                        color: task.isCompleted
                                                            ? ColorsTheme
                                                                .primary
                                                                .withOpacity(
                                                                    0.5)
                                                            : null),
                                                  )),
                                              trailing: task.isCompleted
                                                  ? const Icon(Icons.check,
                                                      color: ColorsTheme.value)
                                                  : Text(
                                                      '+ ${task.reward}',
                                                      style: TextStyles
                                                          .tomorrowClaim,
                                                    ),
                                              title: Text(
                                                task.title,
                                                style:
                                                    TextStyles.activeTitleItem,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(
                                                task.description,
                                                style: TextStyles.subtitleItem,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ));
                                      });
                                })),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          height: 16,
                          child: SmoothPageIndicator(
                            controller: controller,
                            count: numPages,
                            effect: const WormEffect(
                              dotHeight: 16,
                              dotWidth: 16,
                              type: WormType.thinUnderground,
                              dotColor: ColorsTheme.primary,
                              activeDotColor: ColorsTheme.startGradientColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              } else {
                return Center(
                    child: snapshot.hasError
                        ? const Text(
                            'Something went wrong 😔',
                            style: TextStyles.topBarTitle,
                            textAlign: TextAlign.center,
                          )
                        : const CircularProgressIndicator(
                            color: ColorsTheme.secondary,
                          ));
              }
            },
          )),
    );
  }
}
