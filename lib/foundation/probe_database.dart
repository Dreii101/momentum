import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'probe_database.g.dart';

class FoundationProbes extends Table {
  IntColumn get id => integer()();
  IntColumn get writes =>
      integer().check(const CustomExpression<bool>('writes > 0'))();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [FoundationProbes])
class ProbeDatabase extends _$ProbeDatabase {
  ProbeDatabase(File file) : super(NativeDatabase.createInBackground(file));
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (_, from, to) async => throw StateError(
      'Probe database version $from is unsupported by version $to. '
      'The file was preserved; no reset was attempted.',
    ),
  );

  Future<FoundationProbe?> readProbe() => (select(
    foundationProbes,
  )..where((row) => row.id.equals(1))).getSingleOrNull();

  Future<int> writeProbe() => transaction(() async {
    final previous = await readProbe();
    final count = (previous?.writes ?? 0) + 1;
    await into(foundationProbes).insertOnConflictUpdate(
      FoundationProbesCompanion.insert(
        id: const Value(1),
        writes: count,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    return count;
  });
}
