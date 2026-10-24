// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'probe_database.dart';

// ignore_for_file: type=lint
class $FoundationProbesTable extends FoundationProbes
    with TableInfo<$FoundationProbesTable, FoundationProbe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoundationProbesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _writesMeta = const VerificationMeta('writes');
  @override
  late final GeneratedColumn<int> writes = GeneratedColumn<int>(
    'writes',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('writes > 0'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, writes, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foundation_probes';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoundationProbe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('writes')) {
      context.handle(
        _writesMeta,
        writes.isAcceptableOrUnknown(data['writes']!, _writesMeta),
      );
    } else if (isInserting) {
      context.missing(_writesMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoundationProbe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoundationProbe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      writes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}writes'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FoundationProbesTable createAlias(String alias) {
    return $FoundationProbesTable(attachedDatabase, alias);
  }
}

class FoundationProbe extends DataClass implements Insertable<FoundationProbe> {
  final int id;
  final int writes;
  final DateTime updatedAt;
  const FoundationProbe({
    required this.id,
    required this.writes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['writes'] = Variable<int>(writes);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FoundationProbesCompanion toCompanion(bool nullToAbsent) {
    return FoundationProbesCompanion(
      id: Value(id),
      writes: Value(writes),
      updatedAt: Value(updatedAt),
    );
  }

  factory FoundationProbe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoundationProbe(
      id: serializer.fromJson<int>(json['id']),
      writes: serializer.fromJson<int>(json['writes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'writes': serializer.toJson<int>(writes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FoundationProbe copyWith({int? id, int? writes, DateTime? updatedAt}) =>
      FoundationProbe(
        id: id ?? this.id,
        writes: writes ?? this.writes,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FoundationProbe copyWithCompanion(FoundationProbesCompanion data) {
    return FoundationProbe(
      id: data.id.present ? data.id.value : this.id,
      writes: data.writes.present ? data.writes.value : this.writes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoundationProbe(')
          ..write('id: $id, ')
          ..write('writes: $writes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, writes, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoundationProbe &&
          other.id == this.id &&
          other.writes == this.writes &&
          other.updatedAt == this.updatedAt);
}

class FoundationProbesCompanion extends UpdateCompanion<FoundationProbe> {
  final Value<int> id;
  final Value<int> writes;
  final Value<DateTime> updatedAt;
  const FoundationProbesCompanion({
    this.id = const Value.absent(),
    this.writes = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FoundationProbesCompanion.insert({
    this.id = const Value.absent(),
    required int writes,
    required DateTime updatedAt,
  }) : writes = Value(writes),
       updatedAt = Value(updatedAt);
  static Insertable<FoundationProbe> custom({
    Expression<int>? id,
    Expression<int>? writes,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (writes != null) 'writes': writes,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FoundationProbesCompanion copyWith({
    Value<int>? id,
    Value<int>? writes,
    Value<DateTime>? updatedAt,
  }) {
    return FoundationProbesCompanion(
      id: id ?? this.id,
      writes: writes ?? this.writes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (writes.present) {
      map['writes'] = Variable<int>(writes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoundationProbesCompanion(')
          ..write('id: $id, ')
          ..write('writes: $writes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$ProbeDatabase extends GeneratedDatabase {
  _$ProbeDatabase(QueryExecutor e) : super(e);
  $ProbeDatabaseManager get managers => $ProbeDatabaseManager(this);
  late final $FoundationProbesTable foundationProbes = $FoundationProbesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [foundationProbes];
}

typedef $$FoundationProbesTableCreateCompanionBuilder =
    FoundationProbesCompanion Function({
      Value<int> id,
      required int writes,
      required DateTime updatedAt,
    });
typedef $$FoundationProbesTableUpdateCompanionBuilder =
    FoundationProbesCompanion Function({
      Value<int> id,
      Value<int> writes,
      Value<DateTime> updatedAt,
    });

class $$FoundationProbesTableFilterComposer
    extends Composer<_$ProbeDatabase, $FoundationProbesTable> {
  $$FoundationProbesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get writes => $composableBuilder(
    column: $table.writes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoundationProbesTableOrderingComposer
    extends Composer<_$ProbeDatabase, $FoundationProbesTable> {
  $$FoundationProbesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get writes => $composableBuilder(
    column: $table.writes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoundationProbesTableAnnotationComposer
    extends Composer<_$ProbeDatabase, $FoundationProbesTable> {
  $$FoundationProbesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get writes =>
      $composableBuilder(column: $table.writes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FoundationProbesTableTableManager
    extends
        RootTableManager<
          _$ProbeDatabase,
          $FoundationProbesTable,
          FoundationProbe,
          $$FoundationProbesTableFilterComposer,
          $$FoundationProbesTableOrderingComposer,
          $$FoundationProbesTableAnnotationComposer,
          $$FoundationProbesTableCreateCompanionBuilder,
          $$FoundationProbesTableUpdateCompanionBuilder,
          (
            FoundationProbe,
            BaseReferences<
              _$ProbeDatabase,
              $FoundationProbesTable,
              FoundationProbe
            >,
          ),
          FoundationProbe,
          PrefetchHooks Function()
        > {
  $$FoundationProbesTableTableManager(
    _$ProbeDatabase db,
    $FoundationProbesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoundationProbesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoundationProbesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoundationProbesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> writes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FoundationProbesCompanion(
                id: id,
                writes: writes,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int writes,
                required DateTime updatedAt,
              }) => FoundationProbesCompanion.insert(
                id: id,
                writes: writes,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoundationProbesTable, FoundationProbe>(table),
                  BaseReferences<
                    _$ProbeDatabase,
                    $FoundationProbesTable,
                    FoundationProbe
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoundationProbesTableProcessedTableManager =
    ProcessedTableManager<
      _$ProbeDatabase,
      $FoundationProbesTable,
      FoundationProbe,
      $$FoundationProbesTableFilterComposer,
      $$FoundationProbesTableOrderingComposer,
      $$FoundationProbesTableAnnotationComposer,
      $$FoundationProbesTableCreateCompanionBuilder,
      $$FoundationProbesTableUpdateCompanionBuilder,
      (
        FoundationProbe,
        BaseReferences<
          _$ProbeDatabase,
          $FoundationProbesTable,
          FoundationProbe
        >,
      ),
      FoundationProbe,
      PrefetchHooks Function()
    >;

class $ProbeDatabaseManager {
  final _$ProbeDatabase _db;
  $ProbeDatabaseManager(this._db);
  $$FoundationProbesTableTableManager get foundationProbes =>
      $$FoundationProbesTableTableManager(_db, _db.foundationProbes);
}
