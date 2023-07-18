import 'package:drift/drift.dart';

part 'database.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tagName => text().nullable().references(Tags, #name)();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

class Tags extends Table {
  TextColumn get name => text().withLength(min: 1, max: 10)();
  IntColumn get color => integer()();

  @override
  Set<Column> get primaryKey => {name};
}

class TaskWithTag {
  final Task? task;
  final Tag? tag;

  TaskWithTag({required this.task, required this.tag});
}

// To generate the database.g.dart:
// RUN: flutter packages pub run build_runner watch
@DriftDatabase(tables: [Tasks, Tags], daos: [TaskDao, TagDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from == 2) {
            await migrator.createTable(tags);
            await migrator.addColumn(tasks, tasks.tagName);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

@DriftAccessor(
  tables: [Tasks, Tags],
  // 2nd version - Using SQL directly and code generated
  // To call: completedTasksGenerated.get() or .watch()
  queries: {
    'completedTasksGenerated':
        'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;'
  },
)
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  final AppDatabase db;

  TaskDao(this.db) : super(db);

  Future<List<Task>> getAllTasks() => select(tasks).get();

  // 1st version watchAllTasks, watchCompletedTasks
  // using the fluent API
  Stream<List<TaskWithTag>> watchAllTasks() {
    return (select(tasks)
          ..orderBy([
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .join(
          [
            leftOuterJoin(tags, tags.name.equalsExp(tasks.tagName)),
          ],
        )
        .watch()
        .map((rows) {
          return rows.map(
            (row) {
              return TaskWithTag(
                task: row.readTableOrNull(tasks),
                tag: row.readTableOrNull(tags),
              );
            },
          ).toList();
        });
  }

  Stream<List<Task>> watchCompletedTasks() {
    return (select(tasks)
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.dueDate, mode: OrderingMode.desc),
            (tbl) => OrderingTerm(expression: tbl.name),
          ])
          ..where((tbl) => tbl.completed.equals(true)))
        .watch();
  }

  // 3rd version - Using SQL directly in the code
  Stream<List<Task>> watchCompletedTasksCustom() {
    return customSelect(
      'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;',
      readsFrom: {tasks},
    ).watch().map((rows) {
      return rows
          .map(
            (row) => Task(
              id: row.read('id'),
              name: row.read('name'),
              completed: row.read('completed'),
              dueDate: row.read('due_date'),
            ),
          )
          .toList();
    });
  }

  Future<int> insertTask(Insertable<Task> task) => into(tasks).insert(task);
  Future updateTask(Insertable<Task> task) => update(tasks).replace(task);
  Future deleteTask(Insertable<Task> task) => delete(tasks).delete(task);
}

@DriftAccessor(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  final AppDatabase db;

  TagDao(this.db) : super(db);

  Stream<List<Tag>> watchTags() => select(tags).watch();
  Future<int> insertTag(Insertable<Tag> tag) => into(tags).insert(tag);
}
