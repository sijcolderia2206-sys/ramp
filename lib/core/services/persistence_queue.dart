import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

class PersistenceTask {
  final String id;
  final String collection;
  final String documentId;
  final Map<String, dynamic>? data;
  final bool isDelete;

  const PersistenceTask({
    required this.id,
    required this.collection,
    required this.documentId,
    this.data,
    this.isDelete = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'collection': collection,
        'documentId': documentId,
        'data': data,
        'isDelete': isDelete,
      };

  factory PersistenceTask.fromJson(Map<String, dynamic> json) =>
      PersistenceTask(
        id: json['id'] as String? ??
            'task_${DateTime.now().millisecondsSinceEpoch}',
        collection: json['collection'] as String? ?? '',
        documentId: json['documentId'] as String? ?? '',
        data: json['data'] as Map<String, dynamic>?,
        isDelete: json['isDelete'] as bool? ?? false,
      );
}

class PersistenceQueueState {
  final List<PersistenceTask> tasks;
  final bool isSyncing;
  final String? lastError;

  const PersistenceQueueState({
    this.tasks = const [],
    this.isSyncing = false,
    this.lastError,
  });

  List<PersistenceTask> get pending => tasks;

  PersistenceQueueState copyWith({
    List<PersistenceTask>? tasks,
    bool? isSyncing,
    String? lastError,
  }) {
    return PersistenceQueueState(
      tasks: tasks ?? this.tasks,
      isSyncing: isSyncing ?? this.isSyncing,
      lastError: lastError,
    );
  }
}

typedef UpsertHandler = Future<void> Function(
    String collection, String documentId, Map<String, dynamic> data);
typedef DeleteHandler = Future<void> Function(
    String collection, String documentId);

class PersistenceQueue extends ValueNotifier<PersistenceQueueState> {
  static const String _storageKey = 'ramp_persistence_queue_tasks';
  final UpsertHandler? _upsertHandler;
  final DeleteHandler? _deleteHandler;
  bool _initialized = false;

  PersistenceQueue({
    UpsertHandler? upsert,
    DeleteHandler? delete,
  })  : _upsertHandler = upsert,
        _deleteHandler = delete,
        super(const PersistenceQueueState()) {
    _initializeLocalQueue();
  }

  static final PersistenceQueue instance = PersistenceQueue();

  factory PersistenceQueue.forTesting({
    UpsertHandler? upsert,
    DeleteHandler? delete,
  }) =>
      PersistenceQueue(
        upsert: upsert,
        delete: delete,
      );

  List<PersistenceTask> get tasks => value.tasks;

  Future<void> _initializeLocalQueue() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey);
      if (rawList != null && rawList.isNotEmpty) {
        final loadedTasks = rawList
            .map((item) {
              try {
                return PersistenceTask.fromJson(
                    jsonDecode(item) as Map<String, dynamic>);
              } catch (_) {
                return null;
              }
            })
            .whereType<PersistenceTask>()
            .toList();

        if (loadedTasks.isNotEmpty) {
          value = value.copyWith(tasks: [...value.tasks, ...loadedTasks]);
          _processNext();
        }
      }
    } catch (e) {
      debugPrint('ℹ️ PersistenceQueue local queue init notice: $e');
    }
  }

  Future<void> _persistTasksToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList =
          value.tasks.map((task) => jsonEncode(task.toJson())).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      debugPrint('⚠️ Error persisting offline tasks to disk: $e');
    }
  }

  void enqueueUpsert(
      String collection, String documentId, Map<String, dynamic> data) {
    final task = PersistenceTask(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      collection: collection,
      documentId: documentId,
      data: data,
    );
    value = value.copyWith(tasks: [...value.tasks, task]);
    _persistTasksToDisk();
    _processNext();
  }

  void enqueueDelete(String collection, String documentId) {
    final task = PersistenceTask(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      collection: collection,
      documentId: documentId,
      isDelete: true,
    );
    value = value.copyWith(tasks: [...value.tasks, task]);
    _persistTasksToDisk();
    _processNext();
  }

  Future<void> retry() async {
    await _processNext();
  }

  Future<void> retryFailedTasks() async {
    await _processNext();
  }

  Future<void> _processNext() async {
    if (value.isSyncing || value.tasks.isEmpty) return;

    value = value.copyWith(isSyncing: true, lastError: null);
    final task = value.tasks.first;

    try {
      if (task.isDelete) {
        if (_deleteHandler != null) {
          await _deleteHandler!(task.collection, task.documentId);
        } else {
          await SupabaseService()
              .deleteRecord(task.collection, task.documentId);
        }
      } else if (task.data != null) {
        if (_upsertHandler != null) {
          await _upsertHandler!(task.collection, task.documentId, task.data!);
        } else {
          await SupabaseService().upsertRecord(task.collection, task.data!);
        }
      }
      value = value.copyWith(
        tasks: value.tasks.skip(1).toList(),
        isSyncing: false,
      );
      await _persistTasksToDisk();
      if (value.tasks.isNotEmpty) {
        _processNext();
      }
    } catch (e) {
      value = value.copyWith(
        isSyncing: false,
        lastError: e.toString(),
      );
    }
  }
}

final persistenceQueueProvider =
    StateNotifierProvider<PersistenceNotifier, PersistenceQueueState>((ref) {
  return PersistenceNotifier();
});

class PersistenceNotifier extends StateNotifier<PersistenceQueueState> {
  PersistenceNotifier() : super(const PersistenceQueueState());
}
