import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class CalendarScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const CalendarScreen({super.key, required this.onThemeChanged});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  List<Event> _events = [];
  Map<DateTime, List<Event>> _eventsByDate = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await EventService.loadEvents();
      print('CalendarScreen: ${events.length}개 일정 로드됨');
      if (mounted) {
        setState(() {
          _events = events;
          _updateEventsByDate();
          print(
            'CalendarScreen: 일정 날짜별 맵 업데이트 완료 - ${_eventsByDate.length}개 날짜',
          );
        });
      }
    } catch (e) {
      print('CalendarScreen: 일정 로드 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('일정을 불러오는 중 오류가 발생했습니다: $e')));
      }
    }
  }

  void _updateEventsByDate() {
    _eventsByDate = {};
    for (var event in _events) {
      final dateKey = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      _eventsByDate.putIfAbsent(dateKey, () => []).add(event);
    }
  }

  List<Event> _getEventsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _eventsByDate[dateKey] ?? [];
  }

  void _showAddEventDialog({DateTime? date, Event? event}) async {
    final isEdit = event != null;
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(
      text: event?.description ?? '',
    );
    DateTime selectedDate = date ?? event?.date ?? _selectedDate;
    TimeOfDay? startTime = event?.startTime != null
        ? TimeOfDay.fromDateTime(event!.startTime!)
        : null;
    TimeOfDay? endTime =
        event?.endTime != null ? TimeOfDay.fromDateTime(event!.endTime!) : null;
    String visibility = event?.visibility ?? 'private';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? '일정 수정' : '일정 추가',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '제목',
                      hintText: '일정 제목을 입력하세요',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF666666)
                          : Colors.grey.shade100,
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: '설명',
                      hintText: '일정 설명을 입력하세요',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF666666)
                          : Colors.grey.shade100,
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF666666)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text('날짜'),
                      subtitle: Text(
                        DateFormat('yyyy년 MM월 dd일').format(selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF666666)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text('시작 시간 (선택)'),
                      subtitle: Text(startTime?.format(context) ?? '시간 미설정'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: startTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            startTime = picked;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF666666)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text('종료 시간 (선택)'),
                      subtitle: Text(endTime?.format(context) ?? '시간 미설정'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: endTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            endTime = picked;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 공유 조건 설정
                  const Text(
                    '공유 설정',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('전체 공개'),
                          subtitle: const Text(
                            '모든 사용자가 볼 수 있습니다',
                            style: TextStyle(fontSize: 12),
                          ),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          value: 'public',
                          groupValue: visibility,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                visibility = value;
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('비공개'),
                          subtitle: const Text(
                            '나만 볼 수 있습니다',
                            style: TextStyle(fontSize: 12),
                          ),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          value: 'private',
                          groupValue: visibility,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                visibility = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 버튼 영역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('취소'),
                      ),
                      if (isEdit) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            try {
                              await EventService.deleteEvent(event.id);
                              if (mounted) {
                                Navigator.pop(dialogContext);
                                // 다이얼로그가 닫힌 후 부모 위젯에서 처리
                                await _loadEvents();
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('일정이 삭제되었습니다'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                Navigator.pop(dialogContext);
                                await _loadEvents();
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('삭제 중 오류가 발생했습니다: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          child: const Text(
                            '삭제',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(content: Text('제목을 입력해주세요')),
                            );
                            return;
                          }

                          final newEvent = Event(
                            id: event?.id ??
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                            title: titleController.text,
                            description: descriptionController.text,
                            date: selectedDate,
                            startTime: startTime != null
                                ? DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    startTime!.hour,
                                    startTime!.minute,
                                  )
                                : null,
                            endTime: endTime != null
                                ? DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    endTime!.hour,
                                    endTime!.minute,
                                  )
                                : null,
                            visibility: visibility,
                          );

                          try {
                            if (isEdit) {
                              await EventService.updateEvent(newEvent);
                            } else {
                              await EventService.addEvent(newEvent);
                            }

                            if (mounted) {
                              Navigator.pop(dialogContext);
                              // 다이얼로그가 닫힌 후 부모 위젯에서 처리
                              await _loadEvents();
                              if (mounted) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEdit ? '일정이 수정되었습니다' : '일정이 추가되었습니다',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              await _loadEvents();
                              if (mounted) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('오류가 발생했습니다: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Text(isEdit ? '수정' : '추가'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCalendarDays() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    // weekday는 월요일=1, 일요일=7이므로 일요일 기준으로 변환 (일요일=0, 월요일=1, ..., 토요일=6)
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> dayWidgets = [];

    // 요일 헤더
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    for (var weekday in weekdays) {
      dayWidgets.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            weekday,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ),
      );
    }

    // 빈 칸 (첫 주의 시작일 이전)
    for (var i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // 날짜들
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected = date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      final isToday = date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
      final dayEvents = _getEventsForDate(date);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : isToday
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? Colors.white
                            : Colors.black87,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (dayEvents.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Wrap(
                      spacing: 3,
                      runSpacing: 3,
                      alignment: WrapAlignment.center,
                      children: dayEvents.take(3).map((e) {
                        return Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return dayWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedDateEvents = _getEventsForDate(_selectedDate);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          DateFormat('yyyy년 MM월').format(_currentMonth),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month - 1,
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime.now();
                _selectedDate = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 캘린더
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _buildCalendarDays(),
            ),
          ),
          // 선택된 날짜의 일정 목록
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () =>
                            _showAddEventDialog(date: _selectedDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: selectedDateEvents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_note,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '등록된 일정이 없습니다',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: selectedDateEvents.length,
                            itemBuilder: (context, index) {
                              final event = selectedDateEvents[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (event.description.isNotEmpty)
                                        Text(event.description),
                                      if (event.startTime != null)
                                        Text(
                                          '${DateFormat('HH:mm').format(event.startTime!)}${event.endTime != null ? ' - ${DateFormat('HH:mm').format(event.endTime!)}' : ''}',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _showAddEventDialog(event: event),
                                  ),
                                  onTap: () =>
                                      _showAddEventDialog(event: event),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 64),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () => _showAddEventDialog(date: _selectedDate),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
