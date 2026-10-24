// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CoursesTable extends Courses with TableInfo<$CoursesTable, Course> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CoursesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CoursesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CoursesTable.$converterdeletedAtn);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => const CustomExpression("length(trim(name)) BETWEEN 1 AND 200"),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String> termStart =
      GeneratedColumn<String>(
        'term_start',
        aliasedName,
        true,
        check: () => CustomExpression(validDateSql('term_start')),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>($CoursesTable.$convertertermStartn);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String> termEnd =
      GeneratedColumn<String>(
        'term_end',
        aliasedName,
        true,
        check: () => CustomExpression(validDateSql('term_end')),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>($CoursesTable.$convertertermEndn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> archivedAt =
      GeneratedColumn<int>(
        'archived_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CoursesTable.$converterarchivedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    color,
    termStart,
    termEnd,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Course> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Course map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Course(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: $CoursesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $CoursesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $CoursesTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      termStart: $CoursesTable.$convertertermStartn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}term_start'],
        ),
      ),
      termEnd: $CoursesTable.$convertertermEndn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}term_end'],
        ),
      ),
      archivedAt: $CoursesTable.$converterarchivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}archived_at'],
        ),
      ),
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<CalendarDate, String> $convertertermStart =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate?, String?> $convertertermStartn =
      NullAwareTypeConverter.wrap($convertertermStart);
  static TypeConverter<CalendarDate, String> $convertertermEnd =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate?, String?> $convertertermEndn =
      NullAwareTypeConverter.wrap($convertertermEnd);
  static TypeConverter<DateTime, int> $converterarchivedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterarchivedAtn =
      NullAwareTypeConverter.wrap($converterarchivedAt);
}

class Course extends DataClass implements Insertable<Course> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String? color;
  final CalendarDate? termStart;
  final CalendarDate? termEnd;
  final DateTime? archivedAt;
  const Course({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    this.color,
    this.termStart,
    this.termEnd,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['created_at'] = Variable<int>(
        $CoursesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $CoursesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $CoursesTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || termStart != null) {
      map['term_start'] = Variable<String>(
        $CoursesTable.$convertertermStartn.toSql(termStart),
      );
    }
    if (!nullToAbsent || termEnd != null) {
      map['term_end'] = Variable<String>(
        $CoursesTable.$convertertermEndn.toSql(termEnd),
      );
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(
        $CoursesTable.$converterarchivedAtn.toSql(archivedAt),
      );
    }
    return map;
  }

  CoursesCompanion toCompanion(bool nullToAbsent) {
    return CoursesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      termStart: termStart == null && nullToAbsent
          ? const Value.absent()
          : Value(termStart),
      termEnd: termEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(termEnd),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Course.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Course(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
      termStart: serializer.fromJson<CalendarDate?>(json['termStart']),
      termEnd: serializer.fromJson<CalendarDate?>(json['termEnd']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
      'termStart': serializer.toJson<CalendarDate?>(termStart),
      'termEnd': serializer.toJson<CalendarDate?>(termEnd),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Course copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> color = const Value.absent(),
    Value<CalendarDate?> termStart = const Value.absent(),
    Value<CalendarDate?> termEnd = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => Course(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
    termStart: termStart.present ? termStart.value : this.termStart,
    termEnd: termEnd.present ? termEnd.value : this.termEnd,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Course copyWithCompanion(CoursesCompanion data) {
    return Course(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      termStart: data.termStart.present ? data.termStart.value : this.termStart,
      termEnd: data.termEnd.present ? data.termEnd.value : this.termEnd,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Course(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('termStart: $termStart, ')
          ..write('termEnd: $termEnd, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    color,
    termStart,
    termEnd,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Course &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.color == this.color &&
          other.termStart == this.termStart &&
          other.termEnd == this.termEnd &&
          other.archivedAt == this.archivedAt);
}

class CoursesCompanion extends UpdateCompanion<Course> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String?> color;
  final Value<CalendarDate?> termStart;
  final Value<CalendarDate?> termEnd;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.termStart = const Value.absent(),
    this.termEnd = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoursesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    this.termStart = const Value.absent(),
    this.termEnd = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<Course> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? termStart,
    Expression<String>? termEnd,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (termStart != null) 'term_start': termStart,
      if (termEnd != null) 'term_end': termEnd,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoursesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String?>? color,
    Value<CalendarDate?>? termStart,
    Value<CalendarDate?>? termEnd,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return CoursesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      color: color ?? this.color,
      termStart: termStart ?? this.termStart,
      termEnd: termEnd ?? this.termEnd,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $CoursesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $CoursesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $CoursesTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (termStart.present) {
      map['term_start'] = Variable<String>(
        $CoursesTable.$convertertermStartn.toSql(termStart.value),
      );
    }
    if (termEnd.present) {
      map['term_end'] = Variable<String>(
        $CoursesTable.$convertertermEndn.toSql(termEnd.value),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(
        $CoursesTable.$converterarchivedAtn.toSql(archivedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('termStart: $termStart, ')
          ..write('termEnd: $termEnd, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TasksTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TasksTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TasksTable.$converterdeletedAtn);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    check: () =>
        const CustomExpression("length(trim(title)) BETWEEN 1 AND 200"),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nextActionMeta = const VerificationMeta(
    'nextAction',
  );
  @override
  late final GeneratedColumn<String> nextAction = GeneratedColumn<String>(
    'next_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES courses (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        check: () =>
            const CustomExpression("status IN ('todo','doing','done')"),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TaskStatus>($TasksTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<TaskPriority, String> priority =
      GeneratedColumn<String>(
        'priority',
        aliasedName,
        false,
        check: () =>
            const CustomExpression("priority IN ('low','normal','high')"),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TaskPriority>($TasksTable.$converterpriority);
  @override
  late final GeneratedColumnWithTypeConverter<DeadlineKind, String>
  deadlineKind = GeneratedColumn<String>(
    'deadline_kind',
    aliasedName,
    false,
    check: () =>
        const CustomExpression("deadline_kind IN ('none','dateOnly','timed')"),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DeadlineKind>($TasksTable.$converterdeadlineKind);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String>
  deadlineDate = GeneratedColumn<String>(
    'deadline_date',
    aliasedName,
    true,
    check: () => CustomExpression(validDateSql('deadline_date')),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<CalendarDate?>($TasksTable.$converterdeadlineDaten);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deadlineUtc =
      GeneratedColumn<int>(
        'deadline_utc',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TasksTable.$converterdeadlineUtcn);
  static const VerificationMeta _deadlineZoneMeta = const VerificationMeta(
    'deadlineZone',
  );
  @override
  late final GeneratedColumn<String> deadlineZone = GeneratedColumn<String>(
    'deadline_zone',
    aliasedName,
    true,
    check: () =>
        const CustomExpression('length(deadline_zone) BETWEEN 1 AND 100'),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int>
  deadlineBoundaryUtc = GeneratedColumn<int>(
    'deadline_boundary_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  ).withConverter<DateTime?>($TasksTable.$converterdeadlineBoundaryUtcn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> targetUtc =
      GeneratedColumn<int>(
        'target_utc',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TasksTable.$convertertargetUtcn);
  static const VerificationMeta _remainingMinutesMeta = const VerificationMeta(
    'remainingMinutes',
  );
  @override
  late final GeneratedColumn<int> remainingMinutes = GeneratedColumn<int>(
    'remaining_minutes',
    aliasedName,
    true,
    check: () => const CustomExpression('remaining_minutes >= 0'),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> completedAt =
      GeneratedColumn<int>(
        'completed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TasksTable.$convertercompletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> archivedAt =
      GeneratedColumn<int>(
        'archived_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TasksTable.$converterarchivedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    title,
    description,
    nextAction,
    courseId,
    status,
    priority,
    deadlineKind,
    deadlineDate,
    deadlineUtc,
    deadlineZone,
    deadlineBoundaryUtc,
    targetUtc,
    remainingMinutes,
    completedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('next_action')) {
      context.handle(
        _nextActionMeta,
        nextAction.isAcceptableOrUnknown(data['next_action']!, _nextActionMeta),
      );
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    }
    if (data.containsKey('deadline_zone')) {
      context.handle(
        _deadlineZoneMeta,
        deadlineZone.isAcceptableOrUnknown(
          data['deadline_zone']!,
          _deadlineZoneMeta,
        ),
      );
    }
    if (data.containsKey('remaining_minutes')) {
      context.handle(
        _remainingMinutesMeta,
        remainingMinutes.isAcceptableOrUnknown(
          data['remaining_minutes']!,
          _remainingMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: $TasksTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $TasksTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $TasksTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      nextAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_action'],
      ),
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      ),
      status: $TasksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      priority: $TasksTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}priority'],
        )!,
      ),
      deadlineKind: $TasksTable.$converterdeadlineKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deadline_kind'],
        )!,
      ),
      deadlineDate: $TasksTable.$converterdeadlineDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deadline_date'],
        ),
      ),
      deadlineUtc: $TasksTable.$converterdeadlineUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deadline_utc'],
        ),
      ),
      deadlineZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deadline_zone'],
      ),
      deadlineBoundaryUtc: $TasksTable.$converterdeadlineBoundaryUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deadline_boundary_utc'],
        ),
      ),
      targetUtc: $TasksTable.$convertertargetUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}target_utc'],
        ),
      ),
      remainingMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_minutes'],
      ),
      completedAt: $TasksTable.$convertercompletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}completed_at'],
        ),
      ),
      archivedAt: $TasksTable.$converterarchivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}archived_at'],
        ),
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static JsonTypeConverter2<TaskStatus, String, String> $converterstatus =
      const EnumNameConverter<TaskStatus>(TaskStatus.values);
  static JsonTypeConverter2<TaskPriority, String, String> $converterpriority =
      const EnumNameConverter<TaskPriority>(TaskPriority.values);
  static JsonTypeConverter2<DeadlineKind, String, String>
  $converterdeadlineKind = const EnumNameConverter<DeadlineKind>(
    DeadlineKind.values,
  );
  static TypeConverter<CalendarDate, String> $converterdeadlineDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate?, String?> $converterdeadlineDaten =
      NullAwareTypeConverter.wrap($converterdeadlineDate);
  static TypeConverter<DateTime, int> $converterdeadlineUtc =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterdeadlineUtcn =
      NullAwareTypeConverter.wrap($converterdeadlineUtc);
  static TypeConverter<DateTime, int> $converterdeadlineBoundaryUtc =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterdeadlineBoundaryUtcn =
      NullAwareTypeConverter.wrap($converterdeadlineBoundaryUtc);
  static TypeConverter<DateTime, int> $convertertargetUtc =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $convertertargetUtcn =
      NullAwareTypeConverter.wrap($convertertargetUtc);
  static TypeConverter<DateTime, int> $convertercompletedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $convertercompletedAtn =
      NullAwareTypeConverter.wrap($convertercompletedAt);
  static TypeConverter<DateTime, int> $converterarchivedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterarchivedAtn =
      NullAwareTypeConverter.wrap($converterarchivedAt);
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String title;
  final String description;
  final String? nextAction;
  final String? courseId;
  final TaskStatus status;
  final TaskPriority priority;
  final DeadlineKind deadlineKind;
  final CalendarDate? deadlineDate;
  final DateTime? deadlineUtc;
  final String? deadlineZone;

  /// Derived boundary: exclusive for dateOnly, inclusive for timed.
  final DateTime? deadlineBoundaryUtc;
  final DateTime? targetUtc;
  final int? remainingMinutes;
  final DateTime? completedAt;
  final DateTime? archivedAt;
  const Task({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.title,
    required this.description,
    this.nextAction,
    this.courseId,
    required this.status,
    required this.priority,
    required this.deadlineKind,
    this.deadlineDate,
    this.deadlineUtc,
    this.deadlineZone,
    this.deadlineBoundaryUtc,
    this.targetUtc,
    this.remainingMinutes,
    this.completedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['created_at'] = Variable<int>(
        $TasksTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $TasksTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $TasksTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || nextAction != null) {
      map['next_action'] = Variable<String>(nextAction);
    }
    if (!nullToAbsent || courseId != null) {
      map['course_id'] = Variable<String>(courseId);
    }
    {
      map['status'] = Variable<String>(
        $TasksTable.$converterstatus.toSql(status),
      );
    }
    {
      map['priority'] = Variable<String>(
        $TasksTable.$converterpriority.toSql(priority),
      );
    }
    {
      map['deadline_kind'] = Variable<String>(
        $TasksTable.$converterdeadlineKind.toSql(deadlineKind),
      );
    }
    if (!nullToAbsent || deadlineDate != null) {
      map['deadline_date'] = Variable<String>(
        $TasksTable.$converterdeadlineDaten.toSql(deadlineDate),
      );
    }
    if (!nullToAbsent || deadlineUtc != null) {
      map['deadline_utc'] = Variable<int>(
        $TasksTable.$converterdeadlineUtcn.toSql(deadlineUtc),
      );
    }
    if (!nullToAbsent || deadlineZone != null) {
      map['deadline_zone'] = Variable<String>(deadlineZone);
    }
    if (!nullToAbsent || deadlineBoundaryUtc != null) {
      map['deadline_boundary_utc'] = Variable<int>(
        $TasksTable.$converterdeadlineBoundaryUtcn.toSql(deadlineBoundaryUtc),
      );
    }
    if (!nullToAbsent || targetUtc != null) {
      map['target_utc'] = Variable<int>(
        $TasksTable.$convertertargetUtcn.toSql(targetUtc),
      );
    }
    if (!nullToAbsent || remainingMinutes != null) {
      map['remaining_minutes'] = Variable<int>(remainingMinutes);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(
        $TasksTable.$convertercompletedAtn.toSql(completedAt),
      );
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(
        $TasksTable.$converterarchivedAtn.toSql(archivedAt),
      );
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      title: Value(title),
      description: Value(description),
      nextAction: nextAction == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAction),
      courseId: courseId == null && nullToAbsent
          ? const Value.absent()
          : Value(courseId),
      status: Value(status),
      priority: Value(priority),
      deadlineKind: Value(deadlineKind),
      deadlineDate: deadlineDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineDate),
      deadlineUtc: deadlineUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineUtc),
      deadlineZone: deadlineZone == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineZone),
      deadlineBoundaryUtc: deadlineBoundaryUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineBoundaryUtc),
      targetUtc: targetUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(targetUtc),
      remainingMinutes: remainingMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(remainingMinutes),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      nextAction: serializer.fromJson<String?>(json['nextAction']),
      courseId: serializer.fromJson<String?>(json['courseId']),
      status: $TasksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      priority: $TasksTable.$converterpriority.fromJson(
        serializer.fromJson<String>(json['priority']),
      ),
      deadlineKind: $TasksTable.$converterdeadlineKind.fromJson(
        serializer.fromJson<String>(json['deadlineKind']),
      ),
      deadlineDate: serializer.fromJson<CalendarDate?>(json['deadlineDate']),
      deadlineUtc: serializer.fromJson<DateTime?>(json['deadlineUtc']),
      deadlineZone: serializer.fromJson<String?>(json['deadlineZone']),
      deadlineBoundaryUtc: serializer.fromJson<DateTime?>(
        json['deadlineBoundaryUtc'],
      ),
      targetUtc: serializer.fromJson<DateTime?>(json['targetUtc']),
      remainingMinutes: serializer.fromJson<int?>(json['remainingMinutes']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'nextAction': serializer.toJson<String?>(nextAction),
      'courseId': serializer.toJson<String?>(courseId),
      'status': serializer.toJson<String>(
        $TasksTable.$converterstatus.toJson(status),
      ),
      'priority': serializer.toJson<String>(
        $TasksTable.$converterpriority.toJson(priority),
      ),
      'deadlineKind': serializer.toJson<String>(
        $TasksTable.$converterdeadlineKind.toJson(deadlineKind),
      ),
      'deadlineDate': serializer.toJson<CalendarDate?>(deadlineDate),
      'deadlineUtc': serializer.toJson<DateTime?>(deadlineUtc),
      'deadlineZone': serializer.toJson<String?>(deadlineZone),
      'deadlineBoundaryUtc': serializer.toJson<DateTime?>(deadlineBoundaryUtc),
      'targetUtc': serializer.toJson<DateTime?>(targetUtc),
      'remainingMinutes': serializer.toJson<int?>(remainingMinutes),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Task copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? title,
    String? description,
    Value<String?> nextAction = const Value.absent(),
    Value<String?> courseId = const Value.absent(),
    TaskStatus? status,
    TaskPriority? priority,
    DeadlineKind? deadlineKind,
    Value<CalendarDate?> deadlineDate = const Value.absent(),
    Value<DateTime?> deadlineUtc = const Value.absent(),
    Value<String?> deadlineZone = const Value.absent(),
    Value<DateTime?> deadlineBoundaryUtc = const Value.absent(),
    Value<DateTime?> targetUtc = const Value.absent(),
    Value<int?> remainingMinutes = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    title: title ?? this.title,
    description: description ?? this.description,
    nextAction: nextAction.present ? nextAction.value : this.nextAction,
    courseId: courseId.present ? courseId.value : this.courseId,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    deadlineKind: deadlineKind ?? this.deadlineKind,
    deadlineDate: deadlineDate.present ? deadlineDate.value : this.deadlineDate,
    deadlineUtc: deadlineUtc.present ? deadlineUtc.value : this.deadlineUtc,
    deadlineZone: deadlineZone.present ? deadlineZone.value : this.deadlineZone,
    deadlineBoundaryUtc: deadlineBoundaryUtc.present
        ? deadlineBoundaryUtc.value
        : this.deadlineBoundaryUtc,
    targetUtc: targetUtc.present ? targetUtc.value : this.targetUtc,
    remainingMinutes: remainingMinutes.present
        ? remainingMinutes.value
        : this.remainingMinutes,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      nextAction: data.nextAction.present
          ? data.nextAction.value
          : this.nextAction,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      deadlineKind: data.deadlineKind.present
          ? data.deadlineKind.value
          : this.deadlineKind,
      deadlineDate: data.deadlineDate.present
          ? data.deadlineDate.value
          : this.deadlineDate,
      deadlineUtc: data.deadlineUtc.present
          ? data.deadlineUtc.value
          : this.deadlineUtc,
      deadlineZone: data.deadlineZone.present
          ? data.deadlineZone.value
          : this.deadlineZone,
      deadlineBoundaryUtc: data.deadlineBoundaryUtc.present
          ? data.deadlineBoundaryUtc.value
          : this.deadlineBoundaryUtc,
      targetUtc: data.targetUtc.present ? data.targetUtc.value : this.targetUtc,
      remainingMinutes: data.remainingMinutes.present
          ? data.remainingMinutes.value
          : this.remainingMinutes,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('nextAction: $nextAction, ')
          ..write('courseId: $courseId, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('deadlineKind: $deadlineKind, ')
          ..write('deadlineDate: $deadlineDate, ')
          ..write('deadlineUtc: $deadlineUtc, ')
          ..write('deadlineZone: $deadlineZone, ')
          ..write('deadlineBoundaryUtc: $deadlineBoundaryUtc, ')
          ..write('targetUtc: $targetUtc, ')
          ..write('remainingMinutes: $remainingMinutes, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    title,
    description,
    nextAction,
    courseId,
    status,
    priority,
    deadlineKind,
    deadlineDate,
    deadlineUtc,
    deadlineZone,
    deadlineBoundaryUtc,
    targetUtc,
    remainingMinutes,
    completedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.title == this.title &&
          other.description == this.description &&
          other.nextAction == this.nextAction &&
          other.courseId == this.courseId &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.deadlineKind == this.deadlineKind &&
          other.deadlineDate == this.deadlineDate &&
          other.deadlineUtc == this.deadlineUtc &&
          other.deadlineZone == this.deadlineZone &&
          other.deadlineBoundaryUtc == this.deadlineBoundaryUtc &&
          other.targetUtc == this.targetUtc &&
          other.remainingMinutes == this.remainingMinutes &&
          other.completedAt == this.completedAt &&
          other.archivedAt == this.archivedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> title;
  final Value<String> description;
  final Value<String?> nextAction;
  final Value<String?> courseId;
  final Value<TaskStatus> status;
  final Value<TaskPriority> priority;
  final Value<DeadlineKind> deadlineKind;
  final Value<CalendarDate?> deadlineDate;
  final Value<DateTime?> deadlineUtc;
  final Value<String?> deadlineZone;
  final Value<DateTime?> deadlineBoundaryUtc;
  final Value<DateTime?> targetUtc;
  final Value<int?> remainingMinutes;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.courseId = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.deadlineKind = const Value.absent(),
    this.deadlineDate = const Value.absent(),
    this.deadlineUtc = const Value.absent(),
    this.deadlineZone = const Value.absent(),
    this.deadlineBoundaryUtc = const Value.absent(),
    this.targetUtc = const Value.absent(),
    this.remainingMinutes = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.courseId = const Value.absent(),
    required TaskStatus status,
    required TaskPriority priority,
    required DeadlineKind deadlineKind,
    this.deadlineDate = const Value.absent(),
    this.deadlineUtc = const Value.absent(),
    this.deadlineZone = const Value.absent(),
    this.deadlineBoundaryUtc = const Value.absent(),
    this.targetUtc = const Value.absent(),
    this.remainingMinutes = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title),
       status = Value(status),
       priority = Value(priority),
       deadlineKind = Value(deadlineKind);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? nextAction,
    Expression<String>? courseId,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<String>? deadlineKind,
    Expression<String>? deadlineDate,
    Expression<int>? deadlineUtc,
    Expression<String>? deadlineZone,
    Expression<int>? deadlineBoundaryUtc,
    Expression<int>? targetUtc,
    Expression<int>? remainingMinutes,
    Expression<int>? completedAt,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (nextAction != null) 'next_action': nextAction,
      if (courseId != null) 'course_id': courseId,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (deadlineKind != null) 'deadline_kind': deadlineKind,
      if (deadlineDate != null) 'deadline_date': deadlineDate,
      if (deadlineUtc != null) 'deadline_utc': deadlineUtc,
      if (deadlineZone != null) 'deadline_zone': deadlineZone,
      if (deadlineBoundaryUtc != null)
        'deadline_boundary_utc': deadlineBoundaryUtc,
      if (targetUtc != null) 'target_utc': targetUtc,
      if (remainingMinutes != null) 'remaining_minutes': remainingMinutes,
      if (completedAt != null) 'completed_at': completedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? title,
    Value<String>? description,
    Value<String?>? nextAction,
    Value<String?>? courseId,
    Value<TaskStatus>? status,
    Value<TaskPriority>? priority,
    Value<DeadlineKind>? deadlineKind,
    Value<CalendarDate?>? deadlineDate,
    Value<DateTime?>? deadlineUtc,
    Value<String?>? deadlineZone,
    Value<DateTime?>? deadlineBoundaryUtc,
    Value<DateTime?>? targetUtc,
    Value<int?>? remainingMinutes,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      nextAction: nextAction ?? this.nextAction,
      courseId: courseId ?? this.courseId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      deadlineKind: deadlineKind ?? this.deadlineKind,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      deadlineUtc: deadlineUtc ?? this.deadlineUtc,
      deadlineZone: deadlineZone ?? this.deadlineZone,
      deadlineBoundaryUtc: deadlineBoundaryUtc ?? this.deadlineBoundaryUtc,
      targetUtc: targetUtc ?? this.targetUtc,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
      completedAt: completedAt ?? this.completedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $TasksTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $TasksTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $TasksTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (nextAction.present) {
      map['next_action'] = Variable<String>(nextAction.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TasksTable.$converterstatus.toSql(status.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<String>(
        $TasksTable.$converterpriority.toSql(priority.value),
      );
    }
    if (deadlineKind.present) {
      map['deadline_kind'] = Variable<String>(
        $TasksTable.$converterdeadlineKind.toSql(deadlineKind.value),
      );
    }
    if (deadlineDate.present) {
      map['deadline_date'] = Variable<String>(
        $TasksTable.$converterdeadlineDaten.toSql(deadlineDate.value),
      );
    }
    if (deadlineUtc.present) {
      map['deadline_utc'] = Variable<int>(
        $TasksTable.$converterdeadlineUtcn.toSql(deadlineUtc.value),
      );
    }
    if (deadlineZone.present) {
      map['deadline_zone'] = Variable<String>(deadlineZone.value);
    }
    if (deadlineBoundaryUtc.present) {
      map['deadline_boundary_utc'] = Variable<int>(
        $TasksTable.$converterdeadlineBoundaryUtcn.toSql(
          deadlineBoundaryUtc.value,
        ),
      );
    }
    if (targetUtc.present) {
      map['target_utc'] = Variable<int>(
        $TasksTable.$convertertargetUtcn.toSql(targetUtc.value),
      );
    }
    if (remainingMinutes.present) {
      map['remaining_minutes'] = Variable<int>(remainingMinutes.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(
        $TasksTable.$convertercompletedAtn.toSql(completedAt.value),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(
        $TasksTable.$converterarchivedAtn.toSql(archivedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('nextAction: $nextAction, ')
          ..write('courseId: $courseId, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('deadlineKind: $deadlineKind, ')
          ..write('deadlineDate: $deadlineDate, ')
          ..write('deadlineUtc: $deadlineUtc, ')
          ..write('deadlineZone: $deadlineZone, ')
          ..write('deadlineBoundaryUtc: $deadlineBoundaryUtc, ')
          ..write('targetUtc: $targetUtc, ')
          ..write('remainingMinutes: $remainingMinutes, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubtasksTable extends Subtasks with TableInfo<$SubtasksTable, Subtask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SubtasksTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SubtasksTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SubtasksTable.$converterdeletedAtn);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    check: () =>
        const CustomExpression("length(trim(title)) BETWEEN 1 AND 200"),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    check: () => const CustomExpression('position >= 0'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> completedAt =
      GeneratedColumn<int>(
        'completed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SubtasksTable.$convertercompletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    taskId,
    title,
    position,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subtask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subtask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subtask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: $SubtasksTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $SubtasksTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $SubtasksTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      completedAt: $SubtasksTable.$convertercompletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}completed_at'],
        ),
      ),
    );
  }

  @override
  $SubtasksTable createAlias(String alias) {
    return $SubtasksTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<DateTime, int> $convertercompletedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $convertercompletedAtn =
      NullAwareTypeConverter.wrap($convertercompletedAt);
}

class Subtask extends DataClass implements Insertable<Subtask> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String taskId;
  final String title;
  final int position;
  final DateTime? completedAt;
  const Subtask({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.taskId,
    required this.title,
    required this.position,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['created_at'] = Variable<int>(
        $SubtasksTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $SubtasksTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $SubtasksTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(
        $SubtasksTable.$convertercompletedAtn.toSql(completedAt),
      );
    }
    return map;
  }

  SubtasksCompanion toCompanion(bool nullToAbsent) {
    return SubtasksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      taskId: Value(taskId),
      title: Value(title),
      position: Value(position),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Subtask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subtask(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      position: serializer.fromJson<int>(json['position']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'position': serializer.toJson<int>(position),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  Subtask copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? taskId,
    String? title,
    int? position,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => Subtask(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    position: position ?? this.position,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  Subtask copyWithCompanion(SubtasksCompanion data) {
    return Subtask(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      position: data.position.present ? data.position.value : this.position,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subtask(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('position: $position, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    taskId,
    title,
    position,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subtask &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.position == this.position &&
          other.completedAt == this.completedAt);
}

class SubtasksCompanion extends UpdateCompanion<Subtask> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> taskId;
  final Value<String> title;
  final Value<int> position;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const SubtasksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.position = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubtasksCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String taskId,
    required String title,
    required int position,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       taskId = Value(taskId),
       title = Value(title),
       position = Value(position);
  static Insertable<Subtask> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<int>? position,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (position != null) 'position': position,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubtasksCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? taskId,
    Value<String>? title,
    Value<int>? position,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return SubtasksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      position: position ?? this.position,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $SubtasksTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $SubtasksTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $SubtasksTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(
        $SubtasksTable.$convertercompletedAtn.toSql(completedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubtasksCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('position: $position, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($NotesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($NotesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($NotesTable.$converterdeletedAtn);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    check: () => const CustomExpression('length(title) <= 200'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    check: () => const CustomExpression('length(body) <= 100000'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES courses (id)',
    ),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    title,
    body,
    courseId,
    pinned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: $NotesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $NotesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $NotesTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      ),
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String title;
  final String body;
  final String? courseId;
  final bool pinned;
  const Note({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.title,
    required this.body,
    this.courseId,
    required this.pinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['created_at'] = Variable<int>(
        $NotesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $NotesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $NotesTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || courseId != null) {
      map['course_id'] = Variable<String>(courseId);
    }
    map['pinned'] = Variable<bool>(pinned);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      title: Value(title),
      body: Value(body),
      courseId: courseId == null && nullToAbsent
          ? const Value.absent()
          : Value(courseId),
      pinned: Value(pinned),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      courseId: serializer.fromJson<String?>(json['courseId']),
      pinned: serializer.fromJson<bool>(json['pinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'courseId': serializer.toJson<String?>(courseId),
      'pinned': serializer.toJson<bool>(pinned),
    };
  }

  Note copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? title,
    String? body,
    Value<String?> courseId = const Value.absent(),
    bool? pinned,
  }) => Note(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    title: title ?? this.title,
    body: body ?? this.body,
    courseId: courseId.present ? courseId.value : this.courseId,
    pinned: pinned ?? this.pinned,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('courseId: $courseId, ')
          ..write('pinned: $pinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    title,
    body,
    courseId,
    pinned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.title == this.title &&
          other.body == this.body &&
          other.courseId == this.courseId &&
          other.pinned == this.pinned);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> courseId;
  final Value<bool> pinned;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.courseId = const Value.absent(),
    this.pinned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String title,
    required String body,
    this.courseId = const Value.absent(),
    this.pinned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title),
       body = Value(body);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? courseId,
    Expression<bool>? pinned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (courseId != null) 'course_id': courseId,
      if (pinned != null) 'pinned': pinned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? courseId,
    Value<bool>? pinned,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      title: title ?? this.title,
      body: body ?? this.body,
      courseId: courseId ?? this.courseId,
      pinned: pinned ?? this.pinned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $NotesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $NotesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $NotesTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('courseId: $courseId, ')
          ..write('pinned: $pinned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteTaskLinksTable extends NoteTaskLinks
    with TableInfo<$NoteTaskLinksTable, NoteTaskLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteTaskLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id)',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($NoteTaskLinksTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [id, noteId, taskId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_task_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteTaskLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {noteId, taskId},
  ];
  @override
  NoteTaskLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteTaskLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      createdAt: $NoteTaskLinksTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $NoteTaskLinksTable createAlias(String alias) {
    return $NoteTaskLinksTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
}

class NoteTaskLink extends DataClass implements Insertable<NoteTaskLink> {
  final String id;
  final String noteId;
  final String taskId;
  final DateTime createdAt;
  const NoteTaskLink({
    required this.id,
    required this.noteId,
    required this.taskId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note_id'] = Variable<String>(noteId);
    map['task_id'] = Variable<String>(taskId);
    {
      map['created_at'] = Variable<int>(
        $NoteTaskLinksTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  NoteTaskLinksCompanion toCompanion(bool nullToAbsent) {
    return NoteTaskLinksCompanion(
      id: Value(id),
      noteId: Value(noteId),
      taskId: Value(taskId),
      createdAt: Value(createdAt),
    );
  }

  factory NoteTaskLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteTaskLink(
      id: serializer.fromJson<String>(json['id']),
      noteId: serializer.fromJson<String>(json['noteId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'noteId': serializer.toJson<String>(noteId),
      'taskId': serializer.toJson<String>(taskId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NoteTaskLink copyWith({
    String? id,
    String? noteId,
    String? taskId,
    DateTime? createdAt,
  }) => NoteTaskLink(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    taskId: taskId ?? this.taskId,
    createdAt: createdAt ?? this.createdAt,
  );
  NoteTaskLink copyWithCompanion(NoteTaskLinksCompanion data) {
    return NoteTaskLink(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteTaskLink(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('taskId: $taskId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, noteId, taskId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteTaskLink &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.taskId == this.taskId &&
          other.createdAt == this.createdAt);
}

class NoteTaskLinksCompanion extends UpdateCompanion<NoteTaskLink> {
  final Value<String> id;
  final Value<String> noteId;
  final Value<String> taskId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NoteTaskLinksCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteTaskLinksCompanion.insert({
    required String id,
    required String noteId,
    required String taskId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       noteId = Value(noteId),
       taskId = Value(taskId),
       createdAt = Value(createdAt);
  static Insertable<NoteTaskLink> custom({
    Expression<String>? id,
    Expression<String>? noteId,
    Expression<String>? taskId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (taskId != null) 'task_id': taskId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteTaskLinksCompanion copyWith({
    Value<String>? id,
    Value<String>? noteId,
    Value<String>? taskId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return NoteTaskLinksCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      taskId: taskId ?? this.taskId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $NoteTaskLinksTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteTaskLinksCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('taskId: $taskId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyPrioritiesTable extends DailyPriorities
    with TableInfo<$DailyPrioritiesTable, DailyPriority> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyPrioritiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> day =
      GeneratedColumn<String>(
        'day',
        aliasedName,
        false,
        check: () => CustomExpression(validDateSql('day')),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>($DailyPrioritiesTable.$converterday);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    check: () => const CustomExpression('slot IN (1, 2, 3)'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($DailyPrioritiesTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [id, day, taskId, slot, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_priorities';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyPriority> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {day, slot},
    {day, taskId},
  ];
  @override
  DailyPriority map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyPriority(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: $DailyPrioritiesTable.$converterday.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}day'],
        )!,
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      createdAt: $DailyPrioritiesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $DailyPrioritiesTable createAlias(String alias) {
    return $DailyPrioritiesTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converterday =
      const CalendarDateConverter();
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
}

class DailyPriority extends DataClass implements Insertable<DailyPriority> {
  final String id;
  final CalendarDate day;
  final String taskId;
  final int slot;
  final DateTime createdAt;
  const DailyPriority({
    required this.id,
    required this.day,
    required this.taskId,
    required this.slot,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['day'] = Variable<String>(
        $DailyPrioritiesTable.$converterday.toSql(day),
      );
    }
    map['task_id'] = Variable<String>(taskId);
    map['slot'] = Variable<int>(slot);
    {
      map['created_at'] = Variable<int>(
        $DailyPrioritiesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  DailyPrioritiesCompanion toCompanion(bool nullToAbsent) {
    return DailyPrioritiesCompanion(
      id: Value(id),
      day: Value(day),
      taskId: Value(taskId),
      slot: Value(slot),
      createdAt: Value(createdAt),
    );
  }

  factory DailyPriority.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyPriority(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<CalendarDate>(json['day']),
      taskId: serializer.fromJson<String>(json['taskId']),
      slot: serializer.fromJson<int>(json['slot']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<CalendarDate>(day),
      'taskId': serializer.toJson<String>(taskId),
      'slot': serializer.toJson<int>(slot),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyPriority copyWith({
    String? id,
    CalendarDate? day,
    String? taskId,
    int? slot,
    DateTime? createdAt,
  }) => DailyPriority(
    id: id ?? this.id,
    day: day ?? this.day,
    taskId: taskId ?? this.taskId,
    slot: slot ?? this.slot,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyPriority copyWithCompanion(DailyPrioritiesCompanion data) {
    return DailyPriority(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      slot: data.slot.present ? data.slot.value : this.slot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyPriority(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('taskId: $taskId, ')
          ..write('slot: $slot, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, taskId, slot, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyPriority &&
          other.id == this.id &&
          other.day == this.day &&
          other.taskId == this.taskId &&
          other.slot == this.slot &&
          other.createdAt == this.createdAt);
}

class DailyPrioritiesCompanion extends UpdateCompanion<DailyPriority> {
  final Value<String> id;
  final Value<CalendarDate> day;
  final Value<String> taskId;
  final Value<int> slot;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DailyPrioritiesCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.taskId = const Value.absent(),
    this.slot = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyPrioritiesCompanion.insert({
    required String id,
    required CalendarDate day,
    required String taskId,
    required int slot,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       taskId = Value(taskId),
       slot = Value(slot),
       createdAt = Value(createdAt);
  static Insertable<DailyPriority> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? taskId,
    Expression<int>? slot,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (taskId != null) 'task_id': taskId,
      if (slot != null) 'slot': slot,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyPrioritiesCompanion copyWith({
    Value<String>? id,
    Value<CalendarDate>? day,
    Value<String>? taskId,
    Value<int>? slot,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DailyPrioritiesCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      taskId: taskId ?? this.taskId,
      slot: slot ?? this.slot,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(
        $DailyPrioritiesTable.$converterday.toSql(day.value),
      );
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $DailyPrioritiesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyPrioritiesCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('taskId: $taskId, ')
          ..write('slot: $slot, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, Settings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _singletonMeta = const VerificationMeta(
    'singleton',
  );
  @override
  late final GeneratedColumn<int> singleton = GeneratedColumn<int>(
    'singleton',
    aliasedName,
    false,
    check: () => const CustomExpression('singleton = 1'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ThemePreference, String> theme =
      GeneratedColumn<String>(
        'theme',
        aliasedName,
        false,
        check: () =>
            const CustomExpression("theme IN ('system','light','dark')"),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ThemePreference>($AppSettingsTable.$convertertheme);
  static const VerificationMeta _planningZoneMeta = const VerificationMeta(
    'planningZone',
  );
  @override
  late final GeneratedColumn<String> planningZone = GeneratedColumn<String>(
    'planning_zone',
    aliasedName,
    false,
    check: () =>
        const CustomExpression('length(planning_zone) BETWEEN 1 AND 100'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _focusMinutesMeta = const VerificationMeta(
    'focusMinutes',
  );
  @override
  late final GeneratedColumn<int> focusMinutes = GeneratedColumn<int>(
    'focus_minutes',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(focus_minutes) = 'integer' AND focus_minutes BETWEEN 1 AND 180",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(25),
  );
  static const VerificationMeta _breakMinutesMeta = const VerificationMeta(
    'breakMinutes',
  );
  @override
  late final GeneratedColumn<int> breakMinutes = GeneratedColumn<int>(
    'break_minutes',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(break_minutes) = 'integer' AND break_minutes BETWEEN 1 AND 60",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _reducedMotionMeta = const VerificationMeta(
    'reducedMotion',
  );
  @override
  late final GeneratedColumn<bool> reducedMotion = GeneratedColumn<bool>(
    'reduced_motion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reduced_motion" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AppSettingsTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    singleton,
    theme,
    planningZone,
    focusMinutes,
    breakMinutes,
    reducedMotion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Settings> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('singleton')) {
      context.handle(
        _singletonMeta,
        singleton.isAcceptableOrUnknown(data['singleton']!, _singletonMeta),
      );
    } else if (isInserting) {
      context.missing(_singletonMeta);
    }
    if (data.containsKey('planning_zone')) {
      context.handle(
        _planningZoneMeta,
        planningZone.isAcceptableOrUnknown(
          data['planning_zone']!,
          _planningZoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_planningZoneMeta);
    }
    if (data.containsKey('focus_minutes')) {
      context.handle(
        _focusMinutesMeta,
        focusMinutes.isAcceptableOrUnknown(
          data['focus_minutes']!,
          _focusMinutesMeta,
        ),
      );
    }
    if (data.containsKey('break_minutes')) {
      context.handle(
        _breakMinutesMeta,
        breakMinutes.isAcceptableOrUnknown(
          data['break_minutes']!,
          _breakMinutesMeta,
        ),
      );
    }
    if (data.containsKey('reduced_motion')) {
      context.handle(
        _reducedMotionMeta,
        reducedMotion.isAcceptableOrUnknown(
          data['reduced_motion']!,
          _reducedMotionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Settings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Settings(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      singleton: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton'],
      )!,
      theme: $AppSettingsTable.$convertertheme.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme'],
        )!,
      ),
      planningZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planning_zone'],
      )!,
      focusMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_minutes'],
      )!,
      breakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_minutes'],
      )!,
      reducedMotion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reduced_motion'],
      )!,
      updatedAt: $AppSettingsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ThemePreference, String, String> $convertertheme =
      const EnumNameConverter<ThemePreference>(ThemePreference.values);
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcInstantConverter();
}

class Settings extends DataClass implements Insertable<Settings> {
  final String id;
  final int singleton;
  final ThemePreference theme;
  final String planningZone;
  final int focusMinutes;
  final int breakMinutes;
  final bool reducedMotion;
  final DateTime updatedAt;
  const Settings({
    required this.id,
    required this.singleton,
    required this.theme,
    required this.planningZone,
    required this.focusMinutes,
    required this.breakMinutes,
    required this.reducedMotion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['singleton'] = Variable<int>(singleton);
    {
      map['theme'] = Variable<String>(
        $AppSettingsTable.$convertertheme.toSql(theme),
      );
    }
    map['planning_zone'] = Variable<String>(planningZone);
    map['focus_minutes'] = Variable<int>(focusMinutes);
    map['break_minutes'] = Variable<int>(breakMinutes);
    map['reduced_motion'] = Variable<bool>(reducedMotion);
    {
      map['updated_at'] = Variable<int>(
        $AppSettingsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      singleton: Value(singleton),
      theme: Value(theme),
      planningZone: Value(planningZone),
      focusMinutes: Value(focusMinutes),
      breakMinutes: Value(breakMinutes),
      reducedMotion: Value(reducedMotion),
      updatedAt: Value(updatedAt),
    );
  }

  factory Settings.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Settings(
      id: serializer.fromJson<String>(json['id']),
      singleton: serializer.fromJson<int>(json['singleton']),
      theme: $AppSettingsTable.$convertertheme.fromJson(
        serializer.fromJson<String>(json['theme']),
      ),
      planningZone: serializer.fromJson<String>(json['planningZone']),
      focusMinutes: serializer.fromJson<int>(json['focusMinutes']),
      breakMinutes: serializer.fromJson<int>(json['breakMinutes']),
      reducedMotion: serializer.fromJson<bool>(json['reducedMotion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'singleton': serializer.toJson<int>(singleton),
      'theme': serializer.toJson<String>(
        $AppSettingsTable.$convertertheme.toJson(theme),
      ),
      'planningZone': serializer.toJson<String>(planningZone),
      'focusMinutes': serializer.toJson<int>(focusMinutes),
      'breakMinutes': serializer.toJson<int>(breakMinutes),
      'reducedMotion': serializer.toJson<bool>(reducedMotion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Settings copyWith({
    String? id,
    int? singleton,
    ThemePreference? theme,
    String? planningZone,
    int? focusMinutes,
    int? breakMinutes,
    bool? reducedMotion,
    DateTime? updatedAt,
  }) => Settings(
    id: id ?? this.id,
    singleton: singleton ?? this.singleton,
    theme: theme ?? this.theme,
    planningZone: planningZone ?? this.planningZone,
    focusMinutes: focusMinutes ?? this.focusMinutes,
    breakMinutes: breakMinutes ?? this.breakMinutes,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Settings copyWithCompanion(AppSettingsCompanion data) {
    return Settings(
      id: data.id.present ? data.id.value : this.id,
      singleton: data.singleton.present ? data.singleton.value : this.singleton,
      theme: data.theme.present ? data.theme.value : this.theme,
      planningZone: data.planningZone.present
          ? data.planningZone.value
          : this.planningZone,
      focusMinutes: data.focusMinutes.present
          ? data.focusMinutes.value
          : this.focusMinutes,
      breakMinutes: data.breakMinutes.present
          ? data.breakMinutes.value
          : this.breakMinutes,
      reducedMotion: data.reducedMotion.present
          ? data.reducedMotion.value
          : this.reducedMotion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Settings(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('theme: $theme, ')
          ..write('planningZone: $planningZone, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('reducedMotion: $reducedMotion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    singleton,
    theme,
    planningZone,
    focusMinutes,
    breakMinutes,
    reducedMotion,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Settings &&
          other.id == this.id &&
          other.singleton == this.singleton &&
          other.theme == this.theme &&
          other.planningZone == this.planningZone &&
          other.focusMinutes == this.focusMinutes &&
          other.breakMinutes == this.breakMinutes &&
          other.reducedMotion == this.reducedMotion &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<Settings> {
  final Value<String> id;
  final Value<int> singleton;
  final Value<ThemePreference> theme;
  final Value<String> planningZone;
  final Value<int> focusMinutes;
  final Value<int> breakMinutes;
  final Value<bool> reducedMotion;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.singleton = const Value.absent(),
    this.theme = const Value.absent(),
    this.planningZone = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.reducedMotion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String id,
    required int singleton,
    required ThemePreference theme,
    required String planningZone,
    this.focusMinutes = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.reducedMotion = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       singleton = Value(singleton),
       theme = Value(theme),
       planningZone = Value(planningZone),
       updatedAt = Value(updatedAt);
  static Insertable<Settings> custom({
    Expression<String>? id,
    Expression<int>? singleton,
    Expression<String>? theme,
    Expression<String>? planningZone,
    Expression<int>? focusMinutes,
    Expression<int>? breakMinutes,
    Expression<bool>? reducedMotion,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (singleton != null) 'singleton': singleton,
      if (theme != null) 'theme': theme,
      if (planningZone != null) 'planning_zone': planningZone,
      if (focusMinutes != null) 'focus_minutes': focusMinutes,
      if (breakMinutes != null) 'break_minutes': breakMinutes,
      if (reducedMotion != null) 'reduced_motion': reducedMotion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? id,
    Value<int>? singleton,
    Value<ThemePreference>? theme,
    Value<String>? planningZone,
    Value<int>? focusMinutes,
    Value<int>? breakMinutes,
    Value<bool>? reducedMotion,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      singleton: singleton ?? this.singleton,
      theme: theme ?? this.theme,
      planningZone: planningZone ?? this.planningZone,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (singleton.present) {
      map['singleton'] = Variable<int>(singleton.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(
        $AppSettingsTable.$convertertheme.toSql(theme.value),
      );
    }
    if (planningZone.present) {
      map['planning_zone'] = Variable<String>(planningZone.value);
    }
    if (focusMinutes.present) {
      map['focus_minutes'] = Variable<int>(focusMinutes.value);
    }
    if (breakMinutes.present) {
      map['break_minutes'] = Variable<int>(breakMinutes.value);
    }
    if (reducedMotion.present) {
      map['reduced_motion'] = Variable<bool>(reducedMotion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $AppSettingsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('theme: $theme, ')
          ..write('planningZone: $planningZone, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('reducedMotion: $reducedMotion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstallationsTable extends Installations
    with TableInfo<$InstallationsTable, InstallationMetadata> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _singletonMeta = const VerificationMeta(
    'singleton',
  );
  @override
  late final GeneratedColumn<int> singleton = GeneratedColumn<int>(
    'singleton',
    aliasedName,
    false,
    check: () => const CustomExpression('singleton = 1'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($InstallationsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [id, singleton, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installations';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstallationMetadata> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('singleton')) {
      context.handle(
        _singletonMeta,
        singleton.isAcceptableOrUnknown(data['singleton']!, _singletonMeta),
      );
    } else if (isInserting) {
      context.missing(_singletonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstallationMetadata map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallationMetadata(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      singleton: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton'],
      )!,
      createdAt: $InstallationsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $InstallationsTable createAlias(String alias) {
    return $InstallationsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
}

class InstallationMetadata extends DataClass
    implements Insertable<InstallationMetadata> {
  final String id;
  final int singleton;
  final DateTime createdAt;
  const InstallationMetadata({
    required this.id,
    required this.singleton,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['singleton'] = Variable<int>(singleton);
    {
      map['created_at'] = Variable<int>(
        $InstallationsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  InstallationsCompanion toCompanion(bool nullToAbsent) {
    return InstallationsCompanion(
      id: Value(id),
      singleton: Value(singleton),
      createdAt: Value(createdAt),
    );
  }

  factory InstallationMetadata.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallationMetadata(
      id: serializer.fromJson<String>(json['id']),
      singleton: serializer.fromJson<int>(json['singleton']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'singleton': serializer.toJson<int>(singleton),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InstallationMetadata copyWith({
    String? id,
    int? singleton,
    DateTime? createdAt,
  }) => InstallationMetadata(
    id: id ?? this.id,
    singleton: singleton ?? this.singleton,
    createdAt: createdAt ?? this.createdAt,
  );
  InstallationMetadata copyWithCompanion(InstallationsCompanion data) {
    return InstallationMetadata(
      id: data.id.present ? data.id.value : this.id,
      singleton: data.singleton.present ? data.singleton.value : this.singleton,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallationMetadata(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, singleton, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallationMetadata &&
          other.id == this.id &&
          other.singleton == this.singleton &&
          other.createdAt == this.createdAt);
}

class InstallationsCompanion extends UpdateCompanion<InstallationMetadata> {
  final Value<String> id;
  final Value<int> singleton;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InstallationsCompanion({
    this.id = const Value.absent(),
    this.singleton = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallationsCompanion.insert({
    required String id,
    required int singleton,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       singleton = Value(singleton),
       createdAt = Value(createdAt);
  static Insertable<InstallationMetadata> custom({
    Expression<String>? id,
    Expression<int>? singleton,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (singleton != null) 'singleton': singleton,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallationsCompanion copyWith({
    Value<String>? id,
    Value<int>? singleton,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InstallationsCompanion(
      id: id ?? this.id,
      singleton: singleton ?? this.singleton,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (singleton.present) {
      map['singleton'] = Variable<int>(singleton.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $InstallationsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallationsCompanion(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitySeriesRowsTable extends ActivitySeriesRows
    with TableInfo<$ActivitySeriesRowsTable, ActivitySeries> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitySeriesRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ActivitySeriesRowsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ActivitySeriesRowsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ActivitySeriesRowsTable.$converterdeletedAtn);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    check: () =>
        const CustomExpression("length(trim(title)) BETWEEN 1 AND 200"),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES courses (id)',
    ),
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    check: () => const CustomExpression("recurrence IN ('once','weekly')"),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  @override
  late final GeneratedColumn<int> weekdays = GeneratedColumn<int>(
    'weekdays',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(weekdays) = 'integer' AND weekdays BETWEEN 0 AND 127",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> startDate =
      GeneratedColumn<String>(
        'start_date',
        aliasedName,
        false,
        check: () => CustomExpression(validDateSql('start_date')),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>(
        $ActivitySeriesRowsTable.$converterstartDate,
      );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> endDate =
      GeneratedColumn<String>(
        'end_date',
        aliasedName,
        false,
        check: () => CustomExpression(validDateSql('end_date')),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>($ActivitySeriesRowsTable.$converterendDate);
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(start_minute) = 'integer' AND start_minute BETWEEN 0 AND 1439",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(end_minute) = 'integer' AND end_minute BETWEEN 0 AND 1439",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDayOffsetMeta = const VerificationMeta(
    'endDayOffset',
  );
  @override
  late final GeneratedColumn<int> endDayOffset = GeneratedColumn<int>(
    'end_day_offset',
    aliasedName,
    false,
    check: () => const CustomExpression('end_day_offset IN (0,1)'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<String> zone = GeneratedColumn<String>(
    'zone',
    aliasedName,
    false,
    check: () => const CustomExpression('length(zone) BETWEEN 1 AND 100'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _busyMeta = const VerificationMeta('busy');
  @override
  late final GeneratedColumn<bool> busy = GeneratedColumn<bool>(
    'busy',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("busy" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String>
  supersededFrom =
      GeneratedColumn<String>(
        'superseded_from',
        aliasedName,
        true,
        check: () => CustomExpression(validDateSql('superseded_from')),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>(
        $ActivitySeriesRowsTable.$convertersupersededFromn,
      );
  static const VerificationMeta _replacedByMeta = const VerificationMeta(
    'replacedBy',
  );
  @override
  late final GeneratedColumn<String> replacedBy = GeneratedColumn<String>(
    'replaced_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activity_series (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    title,
    courseId,
    recurrence,
    weekdays,
    startDate,
    endDate,
    startMinute,
    endMinute,
    endDayOffset,
    zone,
    location,
    busy,
    supersededFrom,
    replacedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_series';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivitySeries> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    } else if (isInserting) {
      context.missing(_recurrenceMeta);
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdaysMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('end_day_offset')) {
      context.handle(
        _endDayOffsetMeta,
        endDayOffset.isAcceptableOrUnknown(
          data['end_day_offset']!,
          _endDayOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endDayOffsetMeta);
    }
    if (data.containsKey('zone')) {
      context.handle(
        _zoneMeta,
        zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('busy')) {
      context.handle(
        _busyMeta,
        busy.isAcceptableOrUnknown(data['busy']!, _busyMeta),
      );
    }
    if (data.containsKey('replaced_by')) {
      context.handle(
        _replacedByMeta,
        replacedBy.isAcceptableOrUnknown(data['replaced_by']!, _replacedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivitySeries map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivitySeries(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: $ActivitySeriesRowsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ActivitySeriesRowsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $ActivitySeriesRowsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      ),
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      )!,
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays'],
      )!,
      startDate: $ActivitySeriesRowsTable.$converterstartDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}start_date'],
        )!,
      ),
      endDate: $ActivitySeriesRowsTable.$converterendDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}end_date'],
        )!,
      ),
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      )!,
      endDayOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_day_offset'],
      )!,
      zone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      busy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}busy'],
      )!,
      supersededFrom: $ActivitySeriesRowsTable.$convertersupersededFromn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}superseded_from'],
            ),
          ),
      replacedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replaced_by'],
      ),
    );
  }

  @override
  $ActivitySeriesRowsTable createAlias(String alias) {
    return $ActivitySeriesRowsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<CalendarDate, String> $converterstartDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate, String> $converterendDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate, String> $convertersupersededFrom =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate?, String?> $convertersupersededFromn =
      NullAwareTypeConverter.wrap($convertersupersededFrom);
}

class ActivitySeries extends DataClass implements Insertable<ActivitySeries> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String title;
  final String? courseId;
  final String recurrence;
  final int weekdays;
  final CalendarDate startDate;
  final CalendarDate endDate;
  final int startMinute;
  final int endMinute;
  final int endDayOffset;
  final String zone;
  final String location;
  final bool busy;
  final CalendarDate? supersededFrom;
  final String? replacedBy;
  const ActivitySeries({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.title,
    this.courseId,
    required this.recurrence,
    required this.weekdays,
    required this.startDate,
    required this.endDate,
    required this.startMinute,
    required this.endMinute,
    required this.endDayOffset,
    required this.zone,
    required this.location,
    required this.busy,
    this.supersededFrom,
    this.replacedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['created_at'] = Variable<int>(
        $ActivitySeriesRowsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $ActivitySeriesRowsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $ActivitySeriesRowsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || courseId != null) {
      map['course_id'] = Variable<String>(courseId);
    }
    map['recurrence'] = Variable<String>(recurrence);
    map['weekdays'] = Variable<int>(weekdays);
    {
      map['start_date'] = Variable<String>(
        $ActivitySeriesRowsTable.$converterstartDate.toSql(startDate),
      );
    }
    {
      map['end_date'] = Variable<String>(
        $ActivitySeriesRowsTable.$converterendDate.toSql(endDate),
      );
    }
    map['start_minute'] = Variable<int>(startMinute);
    map['end_minute'] = Variable<int>(endMinute);
    map['end_day_offset'] = Variable<int>(endDayOffset);
    map['zone'] = Variable<String>(zone);
    map['location'] = Variable<String>(location);
    map['busy'] = Variable<bool>(busy);
    if (!nullToAbsent || supersededFrom != null) {
      map['superseded_from'] = Variable<String>(
        $ActivitySeriesRowsTable.$convertersupersededFromn.toSql(
          supersededFrom,
        ),
      );
    }
    if (!nullToAbsent || replacedBy != null) {
      map['replaced_by'] = Variable<String>(replacedBy);
    }
    return map;
  }

  ActivitySeriesRowsCompanion toCompanion(bool nullToAbsent) {
    return ActivitySeriesRowsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      title: Value(title),
      courseId: courseId == null && nullToAbsent
          ? const Value.absent()
          : Value(courseId),
      recurrence: Value(recurrence),
      weekdays: Value(weekdays),
      startDate: Value(startDate),
      endDate: Value(endDate),
      startMinute: Value(startMinute),
      endMinute: Value(endMinute),
      endDayOffset: Value(endDayOffset),
      zone: Value(zone),
      location: Value(location),
      busy: Value(busy),
      supersededFrom: supersededFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(supersededFrom),
      replacedBy: replacedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(replacedBy),
    );
  }

  factory ActivitySeries.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivitySeries(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      title: serializer.fromJson<String>(json['title']),
      courseId: serializer.fromJson<String?>(json['courseId']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      weekdays: serializer.fromJson<int>(json['weekdays']),
      startDate: serializer.fromJson<CalendarDate>(json['startDate']),
      endDate: serializer.fromJson<CalendarDate>(json['endDate']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      endDayOffset: serializer.fromJson<int>(json['endDayOffset']),
      zone: serializer.fromJson<String>(json['zone']),
      location: serializer.fromJson<String>(json['location']),
      busy: serializer.fromJson<bool>(json['busy']),
      supersededFrom: serializer.fromJson<CalendarDate?>(
        json['supersededFrom'],
      ),
      replacedBy: serializer.fromJson<String?>(json['replacedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'title': serializer.toJson<String>(title),
      'courseId': serializer.toJson<String?>(courseId),
      'recurrence': serializer.toJson<String>(recurrence),
      'weekdays': serializer.toJson<int>(weekdays),
      'startDate': serializer.toJson<CalendarDate>(startDate),
      'endDate': serializer.toJson<CalendarDate>(endDate),
      'startMinute': serializer.toJson<int>(startMinute),
      'endMinute': serializer.toJson<int>(endMinute),
      'endDayOffset': serializer.toJson<int>(endDayOffset),
      'zone': serializer.toJson<String>(zone),
      'location': serializer.toJson<String>(location),
      'busy': serializer.toJson<bool>(busy),
      'supersededFrom': serializer.toJson<CalendarDate?>(supersededFrom),
      'replacedBy': serializer.toJson<String?>(replacedBy),
    };
  }

  ActivitySeries copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? title,
    Value<String?> courseId = const Value.absent(),
    String? recurrence,
    int? weekdays,
    CalendarDate? startDate,
    CalendarDate? endDate,
    int? startMinute,
    int? endMinute,
    int? endDayOffset,
    String? zone,
    String? location,
    bool? busy,
    Value<CalendarDate?> supersededFrom = const Value.absent(),
    Value<String?> replacedBy = const Value.absent(),
  }) => ActivitySeries(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    title: title ?? this.title,
    courseId: courseId.present ? courseId.value : this.courseId,
    recurrence: recurrence ?? this.recurrence,
    weekdays: weekdays ?? this.weekdays,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    endDayOffset: endDayOffset ?? this.endDayOffset,
    zone: zone ?? this.zone,
    location: location ?? this.location,
    busy: busy ?? this.busy,
    supersededFrom: supersededFrom.present
        ? supersededFrom.value
        : this.supersededFrom,
    replacedBy: replacedBy.present ? replacedBy.value : this.replacedBy,
  );
  ActivitySeries copyWithCompanion(ActivitySeriesRowsCompanion data) {
    return ActivitySeries(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      title: data.title.present ? data.title.value : this.title,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      endDayOffset: data.endDayOffset.present
          ? data.endDayOffset.value
          : this.endDayOffset,
      zone: data.zone.present ? data.zone.value : this.zone,
      location: data.location.present ? data.location.value : this.location,
      busy: data.busy.present ? data.busy.value : this.busy,
      supersededFrom: data.supersededFrom.present
          ? data.supersededFrom.value
          : this.supersededFrom,
      replacedBy: data.replacedBy.present
          ? data.replacedBy.value
          : this.replacedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivitySeries(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('title: $title, ')
          ..write('courseId: $courseId, ')
          ..write('recurrence: $recurrence, ')
          ..write('weekdays: $weekdays, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('endDayOffset: $endDayOffset, ')
          ..write('zone: $zone, ')
          ..write('location: $location, ')
          ..write('busy: $busy, ')
          ..write('supersededFrom: $supersededFrom, ')
          ..write('replacedBy: $replacedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    title,
    courseId,
    recurrence,
    weekdays,
    startDate,
    endDate,
    startMinute,
    endMinute,
    endDayOffset,
    zone,
    location,
    busy,
    supersededFrom,
    replacedBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivitySeries &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.title == this.title &&
          other.courseId == this.courseId &&
          other.recurrence == this.recurrence &&
          other.weekdays == this.weekdays &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.endDayOffset == this.endDayOffset &&
          other.zone == this.zone &&
          other.location == this.location &&
          other.busy == this.busy &&
          other.supersededFrom == this.supersededFrom &&
          other.replacedBy == this.replacedBy);
}

class ActivitySeriesRowsCompanion extends UpdateCompanion<ActivitySeries> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> title;
  final Value<String?> courseId;
  final Value<String> recurrence;
  final Value<int> weekdays;
  final Value<CalendarDate> startDate;
  final Value<CalendarDate> endDate;
  final Value<int> startMinute;
  final Value<int> endMinute;
  final Value<int> endDayOffset;
  final Value<String> zone;
  final Value<String> location;
  final Value<bool> busy;
  final Value<CalendarDate?> supersededFrom;
  final Value<String?> replacedBy;
  final Value<int> rowid;
  const ActivitySeriesRowsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.courseId = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.endDayOffset = const Value.absent(),
    this.zone = const Value.absent(),
    this.location = const Value.absent(),
    this.busy = const Value.absent(),
    this.supersededFrom = const Value.absent(),
    this.replacedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitySeriesRowsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String title,
    this.courseId = const Value.absent(),
    required String recurrence,
    required int weekdays,
    required CalendarDate startDate,
    required CalendarDate endDate,
    required int startMinute,
    required int endMinute,
    required int endDayOffset,
    required String zone,
    this.location = const Value.absent(),
    this.busy = const Value.absent(),
    this.supersededFrom = const Value.absent(),
    this.replacedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title),
       recurrence = Value(recurrence),
       weekdays = Value(weekdays),
       startDate = Value(startDate),
       endDate = Value(endDate),
       startMinute = Value(startMinute),
       endMinute = Value(endMinute),
       endDayOffset = Value(endDayOffset),
       zone = Value(zone);
  static Insertable<ActivitySeries> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? title,
    Expression<String>? courseId,
    Expression<String>? recurrence,
    Expression<int>? weekdays,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<int>? endDayOffset,
    Expression<String>? zone,
    Expression<String>? location,
    Expression<bool>? busy,
    Expression<String>? supersededFrom,
    Expression<String>? replacedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (title != null) 'title': title,
      if (courseId != null) 'course_id': courseId,
      if (recurrence != null) 'recurrence': recurrence,
      if (weekdays != null) 'weekdays': weekdays,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (endDayOffset != null) 'end_day_offset': endDayOffset,
      if (zone != null) 'zone': zone,
      if (location != null) 'location': location,
      if (busy != null) 'busy': busy,
      if (supersededFrom != null) 'superseded_from': supersededFrom,
      if (replacedBy != null) 'replaced_by': replacedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitySeriesRowsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? title,
    Value<String?>? courseId,
    Value<String>? recurrence,
    Value<int>? weekdays,
    Value<CalendarDate>? startDate,
    Value<CalendarDate>? endDate,
    Value<int>? startMinute,
    Value<int>? endMinute,
    Value<int>? endDayOffset,
    Value<String>? zone,
    Value<String>? location,
    Value<bool>? busy,
    Value<CalendarDate?>? supersededFrom,
    Value<String?>? replacedBy,
    Value<int>? rowid,
  }) {
    return ActivitySeriesRowsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      recurrence: recurrence ?? this.recurrence,
      weekdays: weekdays ?? this.weekdays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      endDayOffset: endDayOffset ?? this.endDayOffset,
      zone: zone ?? this.zone,
      location: location ?? this.location,
      busy: busy ?? this.busy,
      supersededFrom: supersededFrom ?? this.supersededFrom,
      replacedBy: replacedBy ?? this.replacedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $ActivitySeriesRowsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $ActivitySeriesRowsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $ActivitySeriesRowsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<int>(weekdays.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(
        $ActivitySeriesRowsTable.$converterstartDate.toSql(startDate.value),
      );
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(
        $ActivitySeriesRowsTable.$converterendDate.toSql(endDate.value),
      );
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (endDayOffset.present) {
      map['end_day_offset'] = Variable<int>(endDayOffset.value);
    }
    if (zone.present) {
      map['zone'] = Variable<String>(zone.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (busy.present) {
      map['busy'] = Variable<bool>(busy.value);
    }
    if (supersededFrom.present) {
      map['superseded_from'] = Variable<String>(
        $ActivitySeriesRowsTable.$convertersupersededFromn.toSql(
          supersededFrom.value,
        ),
      );
    }
    if (replacedBy.present) {
      map['replaced_by'] = Variable<String>(replacedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitySeriesRowsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('title: $title, ')
          ..write('courseId: $courseId, ')
          ..write('recurrence: $recurrence, ')
          ..write('weekdays: $weekdays, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('endDayOffset: $endDayOffset, ')
          ..write('zone: $zone, ')
          ..write('location: $location, ')
          ..write('busy: $busy, ')
          ..write('supersededFrom: $supersededFrom, ')
          ..write('replacedBy: $replacedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityExceptionsTable extends ActivityExceptions
    with TableInfo<$ActivityExceptionsTable, ActivityException> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityExceptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activity_series (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String>
  originalDate =
      GeneratedColumn<String>(
        'original_date',
        aliasedName,
        false,
        check: () => CustomExpression(validDateSql('original_date')),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>(
        $ActivityExceptionsTable.$converteroriginalDate,
      );
  static const VerificationMeta _cancelledMeta = const VerificationMeta(
    'cancelled',
  );
  @override
  late final GeneratedColumn<bool> cancelled = GeneratedColumn<bool>(
    'cancelled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cancelled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String> movedDate =
      GeneratedColumn<String>(
        'moved_date',
        aliasedName,
        true,
        check: () => CustomExpression(validDateSql('moved_date')),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>(
        $ActivityExceptionsTable.$convertermovedDaten,
      );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    true,
    check: () => const CustomExpression(
      "start_minute IS NULL OR (typeof(start_minute) = 'integer' AND start_minute BETWEEN 0 AND 1439)",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    true,
    check: () => const CustomExpression(
      "end_minute IS NULL OR (typeof(end_minute) = 'integer' AND end_minute BETWEEN 0 AND 1439)",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDayOffsetMeta = const VerificationMeta(
    'endDayOffset',
  );
  @override
  late final GeneratedColumn<int> endDayOffset = GeneratedColumn<int>(
    'end_day_offset',
    aliasedName,
    true,
    check: () => const CustomExpression('end_day_offset IN (0,1)'),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<String> zone = GeneratedColumn<String>(
    'zone',
    aliasedName,
    true,
    check: () => const CustomExpression('length(zone) BETWEEN 1 AND 100'),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ActivityExceptionsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ActivityExceptionsTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seriesId,
    originalDate,
    cancelled,
    movedDate,
    startMinute,
    endMinute,
    endDayOffset,
    zone,
    location,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_exceptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityException> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('cancelled')) {
      context.handle(
        _cancelledMeta,
        cancelled.isAcceptableOrUnknown(data['cancelled']!, _cancelledMeta),
      );
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    }
    if (data.containsKey('end_day_offset')) {
      context.handle(
        _endDayOffsetMeta,
        endDayOffset.isAcceptableOrUnknown(
          data['end_day_offset']!,
          _endDayOffsetMeta,
        ),
      );
    }
    if (data.containsKey('zone')) {
      context.handle(
        _zoneMeta,
        zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {seriesId, originalDate},
  ];
  @override
  ActivityException map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityException(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      originalDate: $ActivityExceptionsTable.$converteroriginalDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}original_date'],
        )!,
      ),
      cancelled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cancelled'],
      )!,
      movedDate: $ActivityExceptionsTable.$convertermovedDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}moved_date'],
        ),
      ),
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      ),
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      ),
      endDayOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_day_offset'],
      ),
      zone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      createdAt: $ActivityExceptionsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ActivityExceptionsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $ActivityExceptionsTable createAlias(String alias) {
    return $ActivityExceptionsTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converteroriginalDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate, String> $convertermovedDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate?, String?> $convertermovedDaten =
      NullAwareTypeConverter.wrap($convertermovedDate);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcInstantConverter();
}

class ActivityException extends DataClass
    implements Insertable<ActivityException> {
  final String id;
  final String seriesId;
  final CalendarDate originalDate;
  final bool cancelled;
  final CalendarDate? movedDate;
  final int? startMinute;
  final int? endMinute;
  final int? endDayOffset;
  final String? zone;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ActivityException({
    required this.id,
    required this.seriesId,
    required this.originalDate,
    required this.cancelled,
    this.movedDate,
    this.startMinute,
    this.endMinute,
    this.endDayOffset,
    this.zone,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['series_id'] = Variable<String>(seriesId);
    {
      map['original_date'] = Variable<String>(
        $ActivityExceptionsTable.$converteroriginalDate.toSql(originalDate),
      );
    }
    map['cancelled'] = Variable<bool>(cancelled);
    if (!nullToAbsent || movedDate != null) {
      map['moved_date'] = Variable<String>(
        $ActivityExceptionsTable.$convertermovedDaten.toSql(movedDate),
      );
    }
    if (!nullToAbsent || startMinute != null) {
      map['start_minute'] = Variable<int>(startMinute);
    }
    if (!nullToAbsent || endMinute != null) {
      map['end_minute'] = Variable<int>(endMinute);
    }
    if (!nullToAbsent || endDayOffset != null) {
      map['end_day_offset'] = Variable<int>(endDayOffset);
    }
    if (!nullToAbsent || zone != null) {
      map['zone'] = Variable<String>(zone);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    {
      map['created_at'] = Variable<int>(
        $ActivityExceptionsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $ActivityExceptionsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  ActivityExceptionsCompanion toCompanion(bool nullToAbsent) {
    return ActivityExceptionsCompanion(
      id: Value(id),
      seriesId: Value(seriesId),
      originalDate: Value(originalDate),
      cancelled: Value(cancelled),
      movedDate: movedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(movedDate),
      startMinute: startMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(startMinute),
      endMinute: endMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(endMinute),
      endDayOffset: endDayOffset == null && nullToAbsent
          ? const Value.absent()
          : Value(endDayOffset),
      zone: zone == null && nullToAbsent ? const Value.absent() : Value(zone),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ActivityException.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityException(
      id: serializer.fromJson<String>(json['id']),
      seriesId: serializer.fromJson<String>(json['seriesId']),
      originalDate: serializer.fromJson<CalendarDate>(json['originalDate']),
      cancelled: serializer.fromJson<bool>(json['cancelled']),
      movedDate: serializer.fromJson<CalendarDate?>(json['movedDate']),
      startMinute: serializer.fromJson<int?>(json['startMinute']),
      endMinute: serializer.fromJson<int?>(json['endMinute']),
      endDayOffset: serializer.fromJson<int?>(json['endDayOffset']),
      zone: serializer.fromJson<String?>(json['zone']),
      location: serializer.fromJson<String?>(json['location']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seriesId': serializer.toJson<String>(seriesId),
      'originalDate': serializer.toJson<CalendarDate>(originalDate),
      'cancelled': serializer.toJson<bool>(cancelled),
      'movedDate': serializer.toJson<CalendarDate?>(movedDate),
      'startMinute': serializer.toJson<int?>(startMinute),
      'endMinute': serializer.toJson<int?>(endMinute),
      'endDayOffset': serializer.toJson<int?>(endDayOffset),
      'zone': serializer.toJson<String?>(zone),
      'location': serializer.toJson<String?>(location),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ActivityException copyWith({
    String? id,
    String? seriesId,
    CalendarDate? originalDate,
    bool? cancelled,
    Value<CalendarDate?> movedDate = const Value.absent(),
    Value<int?> startMinute = const Value.absent(),
    Value<int?> endMinute = const Value.absent(),
    Value<int?> endDayOffset = const Value.absent(),
    Value<String?> zone = const Value.absent(),
    Value<String?> location = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ActivityException(
    id: id ?? this.id,
    seriesId: seriesId ?? this.seriesId,
    originalDate: originalDate ?? this.originalDate,
    cancelled: cancelled ?? this.cancelled,
    movedDate: movedDate.present ? movedDate.value : this.movedDate,
    startMinute: startMinute.present ? startMinute.value : this.startMinute,
    endMinute: endMinute.present ? endMinute.value : this.endMinute,
    endDayOffset: endDayOffset.present ? endDayOffset.value : this.endDayOffset,
    zone: zone.present ? zone.value : this.zone,
    location: location.present ? location.value : this.location,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ActivityException copyWithCompanion(ActivityExceptionsCompanion data) {
    return ActivityException(
      id: data.id.present ? data.id.value : this.id,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      originalDate: data.originalDate.present
          ? data.originalDate.value
          : this.originalDate,
      cancelled: data.cancelled.present ? data.cancelled.value : this.cancelled,
      movedDate: data.movedDate.present ? data.movedDate.value : this.movedDate,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      endDayOffset: data.endDayOffset.present
          ? data.endDayOffset.value
          : this.endDayOffset,
      zone: data.zone.present ? data.zone.value : this.zone,
      location: data.location.present ? data.location.value : this.location,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityException(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('originalDate: $originalDate, ')
          ..write('cancelled: $cancelled, ')
          ..write('movedDate: $movedDate, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('endDayOffset: $endDayOffset, ')
          ..write('zone: $zone, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seriesId,
    originalDate,
    cancelled,
    movedDate,
    startMinute,
    endMinute,
    endDayOffset,
    zone,
    location,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityException &&
          other.id == this.id &&
          other.seriesId == this.seriesId &&
          other.originalDate == this.originalDate &&
          other.cancelled == this.cancelled &&
          other.movedDate == this.movedDate &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.endDayOffset == this.endDayOffset &&
          other.zone == this.zone &&
          other.location == this.location &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ActivityExceptionsCompanion extends UpdateCompanion<ActivityException> {
  final Value<String> id;
  final Value<String> seriesId;
  final Value<CalendarDate> originalDate;
  final Value<bool> cancelled;
  final Value<CalendarDate?> movedDate;
  final Value<int?> startMinute;
  final Value<int?> endMinute;
  final Value<int?> endDayOffset;
  final Value<String?> zone;
  final Value<String?> location;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ActivityExceptionsCompanion({
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.originalDate = const Value.absent(),
    this.cancelled = const Value.absent(),
    this.movedDate = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.endDayOffset = const Value.absent(),
    this.zone = const Value.absent(),
    this.location = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityExceptionsCompanion.insert({
    required String id,
    required String seriesId,
    required CalendarDate originalDate,
    this.cancelled = const Value.absent(),
    this.movedDate = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.endDayOffset = const Value.absent(),
    this.zone = const Value.absent(),
    this.location = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seriesId = Value(seriesId),
       originalDate = Value(originalDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ActivityException> custom({
    Expression<String>? id,
    Expression<String>? seriesId,
    Expression<String>? originalDate,
    Expression<bool>? cancelled,
    Expression<String>? movedDate,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<int>? endDayOffset,
    Expression<String>? zone,
    Expression<String>? location,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seriesId != null) 'series_id': seriesId,
      if (originalDate != null) 'original_date': originalDate,
      if (cancelled != null) 'cancelled': cancelled,
      if (movedDate != null) 'moved_date': movedDate,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (endDayOffset != null) 'end_day_offset': endDayOffset,
      if (zone != null) 'zone': zone,
      if (location != null) 'location': location,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityExceptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? seriesId,
    Value<CalendarDate>? originalDate,
    Value<bool>? cancelled,
    Value<CalendarDate?>? movedDate,
    Value<int?>? startMinute,
    Value<int?>? endMinute,
    Value<int?>? endDayOffset,
    Value<String?>? zone,
    Value<String?>? location,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ActivityExceptionsCompanion(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      originalDate: originalDate ?? this.originalDate,
      cancelled: cancelled ?? this.cancelled,
      movedDate: movedDate ?? this.movedDate,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      endDayOffset: endDayOffset ?? this.endDayOffset,
      zone: zone ?? this.zone,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (originalDate.present) {
      map['original_date'] = Variable<String>(
        $ActivityExceptionsTable.$converteroriginalDate.toSql(
          originalDate.value,
        ),
      );
    }
    if (cancelled.present) {
      map['cancelled'] = Variable<bool>(cancelled.value);
    }
    if (movedDate.present) {
      map['moved_date'] = Variable<String>(
        $ActivityExceptionsTable.$convertermovedDaten.toSql(movedDate.value),
      );
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (endDayOffset.present) {
      map['end_day_offset'] = Variable<int>(endDayOffset.value);
    }
    if (zone.present) {
      map['zone'] = Variable<String>(zone.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $ActivityExceptionsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $ActivityExceptionsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityExceptionsCompanion(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('originalDate: $originalDate, ')
          ..write('cancelled: $cancelled, ')
          ..write('movedDate: $movedDate, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('endDayOffset: $endDayOffset, ')
          ..write('zone: $zone, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteActivityLinksTable extends NoteActivityLinks
    with TableInfo<$NoteActivityLinksTable, NoteActivityLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteActivityLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id)',
    ),
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activity_series (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String>
  originalDate =
      GeneratedColumn<String>(
        'original_date',
        aliasedName,
        true,
        check: () => CustomExpression(validDateSql('original_date')),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>(
        $NoteActivityLinksTable.$converteroriginalDaten,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($NoteActivityLinksTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    seriesId,
    originalDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_activity_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteActivityLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteActivityLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteActivityLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      originalDate: $NoteActivityLinksTable.$converteroriginalDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}original_date'],
        ),
      ),
      createdAt: $NoteActivityLinksTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $NoteActivityLinksTable createAlias(String alias) {
    return $NoteActivityLinksTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converteroriginalDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate?, String?> $converteroriginalDaten =
      NullAwareTypeConverter.wrap($converteroriginalDate);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
}

class NoteActivityLink extends DataClass
    implements Insertable<NoteActivityLink> {
  final String id;
  final String noteId;
  final String seriesId;
  final CalendarDate? originalDate;
  final DateTime createdAt;
  const NoteActivityLink({
    required this.id,
    required this.noteId,
    required this.seriesId,
    this.originalDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note_id'] = Variable<String>(noteId);
    map['series_id'] = Variable<String>(seriesId);
    if (!nullToAbsent || originalDate != null) {
      map['original_date'] = Variable<String>(
        $NoteActivityLinksTable.$converteroriginalDaten.toSql(originalDate),
      );
    }
    {
      map['created_at'] = Variable<int>(
        $NoteActivityLinksTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  NoteActivityLinksCompanion toCompanion(bool nullToAbsent) {
    return NoteActivityLinksCompanion(
      id: Value(id),
      noteId: Value(noteId),
      seriesId: Value(seriesId),
      originalDate: originalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(originalDate),
      createdAt: Value(createdAt),
    );
  }

  factory NoteActivityLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteActivityLink(
      id: serializer.fromJson<String>(json['id']),
      noteId: serializer.fromJson<String>(json['noteId']),
      seriesId: serializer.fromJson<String>(json['seriesId']),
      originalDate: serializer.fromJson<CalendarDate?>(json['originalDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'noteId': serializer.toJson<String>(noteId),
      'seriesId': serializer.toJson<String>(seriesId),
      'originalDate': serializer.toJson<CalendarDate?>(originalDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NoteActivityLink copyWith({
    String? id,
    String? noteId,
    String? seriesId,
    Value<CalendarDate?> originalDate = const Value.absent(),
    DateTime? createdAt,
  }) => NoteActivityLink(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    seriesId: seriesId ?? this.seriesId,
    originalDate: originalDate.present ? originalDate.value : this.originalDate,
    createdAt: createdAt ?? this.createdAt,
  );
  NoteActivityLink copyWithCompanion(NoteActivityLinksCompanion data) {
    return NoteActivityLink(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      originalDate: data.originalDate.present
          ? data.originalDate.value
          : this.originalDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteActivityLink(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('seriesId: $seriesId, ')
          ..write('originalDate: $originalDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, noteId, seriesId, originalDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteActivityLink &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.seriesId == this.seriesId &&
          other.originalDate == this.originalDate &&
          other.createdAt == this.createdAt);
}

class NoteActivityLinksCompanion extends UpdateCompanion<NoteActivityLink> {
  final Value<String> id;
  final Value<String> noteId;
  final Value<String> seriesId;
  final Value<CalendarDate?> originalDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NoteActivityLinksCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.originalDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteActivityLinksCompanion.insert({
    required String id,
    required String noteId,
    required String seriesId,
    this.originalDate = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       noteId = Value(noteId),
       seriesId = Value(seriesId),
       createdAt = Value(createdAt);
  static Insertable<NoteActivityLink> custom({
    Expression<String>? id,
    Expression<String>? noteId,
    Expression<String>? seriesId,
    Expression<String>? originalDate,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (seriesId != null) 'series_id': seriesId,
      if (originalDate != null) 'original_date': originalDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteActivityLinksCompanion copyWith({
    Value<String>? id,
    Value<String>? noteId,
    Value<String>? seriesId,
    Value<CalendarDate?>? originalDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return NoteActivityLinksCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      seriesId: seriesId ?? this.seriesId,
      originalDate: originalDate ?? this.originalDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (originalDate.present) {
      map['original_date'] = Variable<String>(
        $NoteActivityLinksTable.$converteroriginalDaten.toSql(
          originalDate.value,
        ),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $NoteActivityLinksTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteActivityLinksCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('seriesId: $seriesId, ')
          ..write('originalDate: $originalDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlannedWorkBlocksTable extends PlannedWorkBlocks
    with TableInfo<$PlannedWorkBlocksTable, PlannedWorkBlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedWorkBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PlannedWorkBlocksTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PlannedWorkBlocksTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($PlannedWorkBlocksTable.$converterdeletedAtn);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> startUtc =
      GeneratedColumn<int>(
        'start_utc',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PlannedWorkBlocksTable.$converterstartUtc);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> endUtc =
      GeneratedColumn<int>(
        'end_utc',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PlannedWorkBlocksTable.$converterendUtc);
  static const VerificationMeta _planningZoneMeta = const VerificationMeta(
    'planningZone',
  );
  @override
  late final GeneratedColumn<String> planningZone = GeneratedColumn<String>(
    'planning_zone',
    aliasedName,
    false,
    check: () =>
        const CustomExpression('length(planning_zone) BETWEEN 1 AND 100'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WorkBlockStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () =>
        const CustomExpression("status IN ('planned','completed','cancelled')"),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<WorkBlockStatus>($PlannedWorkBlocksTable.$converterstatus);
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    taskId,
    startUtc,
    endUtc,
    planningZone,
    status,
    locked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_work_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlannedWorkBlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('planning_zone')) {
      context.handle(
        _planningZoneMeta,
        planningZone.isAcceptableOrUnknown(
          data['planning_zone']!,
          _planningZoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_planningZoneMeta);
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedWorkBlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedWorkBlock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: $PlannedWorkBlocksTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $PlannedWorkBlocksTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $PlannedWorkBlocksTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      startUtc: $PlannedWorkBlocksTable.$converterstartUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}start_utc'],
        )!,
      ),
      endUtc: $PlannedWorkBlocksTable.$converterendUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}end_utc'],
        )!,
      ),
      planningZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planning_zone'],
      )!,
      status: $PlannedWorkBlocksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
    );
  }

  @override
  $PlannedWorkBlocksTable createAlias(String alias) {
    return $PlannedWorkBlocksTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<DateTime, int> $converterstartUtc =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterendUtc =
      const UtcInstantConverter();
  static JsonTypeConverter2<WorkBlockStatus, String, String> $converterstatus =
      const EnumNameConverter<WorkBlockStatus>(WorkBlockStatus.values);
}

class PlannedWorkBlock extends DataClass
    implements Insertable<PlannedWorkBlock> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String taskId;
  final DateTime startUtc;
  final DateTime endUtc;
  final String planningZone;
  final WorkBlockStatus status;
  final bool locked;
  const PlannedWorkBlock({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.taskId,
    required this.startUtc,
    required this.endUtc,
    required this.planningZone,
    required this.status,
    required this.locked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['created_at'] = Variable<int>(
        $PlannedWorkBlocksTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $PlannedWorkBlocksTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $PlannedWorkBlocksTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['task_id'] = Variable<String>(taskId);
    {
      map['start_utc'] = Variable<int>(
        $PlannedWorkBlocksTable.$converterstartUtc.toSql(startUtc),
      );
    }
    {
      map['end_utc'] = Variable<int>(
        $PlannedWorkBlocksTable.$converterendUtc.toSql(endUtc),
      );
    }
    map['planning_zone'] = Variable<String>(planningZone);
    {
      map['status'] = Variable<String>(
        $PlannedWorkBlocksTable.$converterstatus.toSql(status),
      );
    }
    map['locked'] = Variable<bool>(locked);
    return map;
  }

  PlannedWorkBlocksCompanion toCompanion(bool nullToAbsent) {
    return PlannedWorkBlocksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      taskId: Value(taskId),
      startUtc: Value(startUtc),
      endUtc: Value(endUtc),
      planningZone: Value(planningZone),
      status: Value(status),
      locked: Value(locked),
    );
  }

  factory PlannedWorkBlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedWorkBlock(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      taskId: serializer.fromJson<String>(json['taskId']),
      startUtc: serializer.fromJson<DateTime>(json['startUtc']),
      endUtc: serializer.fromJson<DateTime>(json['endUtc']),
      planningZone: serializer.fromJson<String>(json['planningZone']),
      status: $PlannedWorkBlocksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      locked: serializer.fromJson<bool>(json['locked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'taskId': serializer.toJson<String>(taskId),
      'startUtc': serializer.toJson<DateTime>(startUtc),
      'endUtc': serializer.toJson<DateTime>(endUtc),
      'planningZone': serializer.toJson<String>(planningZone),
      'status': serializer.toJson<String>(
        $PlannedWorkBlocksTable.$converterstatus.toJson(status),
      ),
      'locked': serializer.toJson<bool>(locked),
    };
  }

  PlannedWorkBlock copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? taskId,
    DateTime? startUtc,
    DateTime? endUtc,
    String? planningZone,
    WorkBlockStatus? status,
    bool? locked,
  }) => PlannedWorkBlock(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    taskId: taskId ?? this.taskId,
    startUtc: startUtc ?? this.startUtc,
    endUtc: endUtc ?? this.endUtc,
    planningZone: planningZone ?? this.planningZone,
    status: status ?? this.status,
    locked: locked ?? this.locked,
  );
  PlannedWorkBlock copyWithCompanion(PlannedWorkBlocksCompanion data) {
    return PlannedWorkBlock(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      endUtc: data.endUtc.present ? data.endUtc.value : this.endUtc,
      planningZone: data.planningZone.present
          ? data.planningZone.value
          : this.planningZone,
      status: data.status.present ? data.status.value : this.status,
      locked: data.locked.present ? data.locked.value : this.locked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedWorkBlock(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('taskId: $taskId, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('planningZone: $planningZone, ')
          ..write('status: $status, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    taskId,
    startUtc,
    endUtc,
    planningZone,
    status,
    locked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedWorkBlock &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.taskId == this.taskId &&
          other.startUtc == this.startUtc &&
          other.endUtc == this.endUtc &&
          other.planningZone == this.planningZone &&
          other.status == this.status &&
          other.locked == this.locked);
}

class PlannedWorkBlocksCompanion extends UpdateCompanion<PlannedWorkBlock> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> taskId;
  final Value<DateTime> startUtc;
  final Value<DateTime> endUtc;
  final Value<String> planningZone;
  final Value<WorkBlockStatus> status;
  final Value<bool> locked;
  final Value<int> rowid;
  const PlannedWorkBlocksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.taskId = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
    this.planningZone = const Value.absent(),
    this.status = const Value.absent(),
    this.locked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlannedWorkBlocksCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String taskId,
    required DateTime startUtc,
    required DateTime endUtc,
    required String planningZone,
    required WorkBlockStatus status,
    this.locked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       taskId = Value(taskId),
       startUtc = Value(startUtc),
       endUtc = Value(endUtc),
       planningZone = Value(planningZone),
       status = Value(status);
  static Insertable<PlannedWorkBlock> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? taskId,
    Expression<int>? startUtc,
    Expression<int>? endUtc,
    Expression<String>? planningZone,
    Expression<String>? status,
    Expression<bool>? locked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (taskId != null) 'task_id': taskId,
      if (startUtc != null) 'start_utc': startUtc,
      if (endUtc != null) 'end_utc': endUtc,
      if (planningZone != null) 'planning_zone': planningZone,
      if (status != null) 'status': status,
      if (locked != null) 'locked': locked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlannedWorkBlocksCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? taskId,
    Value<DateTime>? startUtc,
    Value<DateTime>? endUtc,
    Value<String>? planningZone,
    Value<WorkBlockStatus>? status,
    Value<bool>? locked,
    Value<int>? rowid,
  }) {
    return PlannedWorkBlocksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      taskId: taskId ?? this.taskId,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      planningZone: planningZone ?? this.planningZone,
      status: status ?? this.status,
      locked: locked ?? this.locked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $PlannedWorkBlocksTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $PlannedWorkBlocksTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $PlannedWorkBlocksTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<int>(
        $PlannedWorkBlocksTable.$converterstartUtc.toSql(startUtc.value),
      );
    }
    if (endUtc.present) {
      map['end_utc'] = Variable<int>(
        $PlannedWorkBlocksTable.$converterendUtc.toSql(endUtc.value),
      );
    }
    if (planningZone.present) {
      map['planning_zone'] = Variable<String>(planningZone.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PlannedWorkBlocksTable.$converterstatus.toSql(status.value),
      );
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedWorkBlocksCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('taskId: $taskId, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('planningZone: $planningZone, ')
          ..write('status: $status, ')
          ..write('locked: $locked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES installations (id)',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _subtaskIdMeta = const VerificationMeta(
    'subtaskId',
  );
  @override
  late final GeneratedColumn<String> subtaskId = GeneratedColumn<String>(
    'subtask_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subtasks (id)',
    ),
  );
  static const VerificationMeta _titleSnapshotMeta = const VerificationMeta(
    'titleSnapshot',
  );
  @override
  late final GeneratedColumn<String> titleSnapshot = GeneratedColumn<String>(
    'title_snapshot',
    aliasedName,
    false,
    check: () =>
        const CustomExpression('length(title_snapshot) BETWEEN 1 AND 200'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<String> zone = GeneratedColumn<String>(
    'zone',
    aliasedName,
    false,
    check: () => const CustomExpression('length(zone) BETWEEN 1 AND 100'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String>
  localStartDate = GeneratedColumn<String>(
    'local_start_date',
    aliasedName,
    false,
    check: () => CustomExpression(validDateSql('local_start_date')),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<CalendarDate>($FocusSessionsTable.$converterlocalStartDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> startedUtc =
      GeneratedColumn<int>(
        'started_utc',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($FocusSessionsTable.$converterstartedUtc);
  @override
  late final GeneratedColumnWithTypeConverter<SessionKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        check: () =>
            const CustomExpression("kind IN ('starter','focus','rest')"),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionKind>($FocusSessionsTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<SessionState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        check: () => const CustomExpression(
          "state IN ('running','paused','awaitingReview','finalized')",
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionState>($FocusSessionsTable.$converterstate);
  @override
  late final GeneratedColumnWithTypeConverter<SessionOutcome?, String> outcome =
      GeneratedColumn<String>(
        'outcome',
        aliasedName,
        true,
        check: () => const CustomExpression(
          "outcome IN ('completed','stoppedEarly','interrupted')",
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<SessionOutcome?>($FocusSessionsTable.$converteroutcomen);
  static const VerificationMeta _plannedMsMeta = const VerificationMeta(
    'plannedMs',
  );
  @override
  late final GeneratedColumn<int> plannedMs = GeneratedColumn<int>(
    'planned_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eligibleMsMeta = const VerificationMeta(
    'eligibleMs',
  );
  @override
  late final GeneratedColumn<int> eligibleMs = GeneratedColumn<int>(
    'eligible_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uncertainMsMeta = const VerificationMeta(
    'uncertainMs',
  );
  @override
  late final GeneratedColumn<int> uncertainMs = GeneratedColumn<int>(
    'uncertain_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasUncertaintyMeta = const VerificationMeta(
    'hasUncertainty',
  );
  @override
  late final GeneratedColumn<bool> hasUncertainty = GeneratedColumn<bool>(
    'has_uncertainty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_uncertainty" IN (0, 1))',
    ),
  );
  static const VerificationMeta _backgroundMeta = const VerificationMeta(
    'background',
  );
  @override
  late final GeneratedColumn<bool> background = GeneratedColumn<bool>(
    'background',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("background" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> checkpointUtc =
      GeneratedColumn<int>(
        'checkpoint_utc',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($FocusSessionsTable.$convertercheckpointUtc);
  static const VerificationMeta _elapsedMarkMsMeta = const VerificationMeta(
    'elapsedMarkMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMarkMs = GeneratedColumn<int>(
    'elapsed_mark_ms',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(elapsed_mark_ms) = 'integer' AND elapsed_mark_ms >= 0",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clockEpochMeta = const VerificationMeta(
    'clockEpoch',
  );
  @override
  late final GeneratedColumn<String> clockEpoch = GeneratedColumn<String>(
    'clock_epoch',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(revision) = 'integer' AND revision >= 0",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportedMsMeta = const VerificationMeta(
    'reportedMs',
  );
  @override
  late final GeneratedColumn<int> reportedMs = GeneratedColumn<int>(
    'reported_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> finalizedUtc =
      GeneratedColumn<int>(
        'finalized_utc',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($FocusSessionsTable.$converterfinalizedUtcn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    installationId,
    taskId,
    subtaskId,
    titleSnapshot,
    zone,
    localStartDate,
    startedUtc,
    kind,
    state,
    outcome,
    plannedMs,
    elapsedMs,
    eligibleMs,
    uncertainMs,
    hasUncertainty,
    background,
    checkpointUtc,
    elapsedMarkMs,
    clockEpoch,
    revision,
    reportedMs,
    finalizedUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installationIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('subtask_id')) {
      context.handle(
        _subtaskIdMeta,
        subtaskId.isAcceptableOrUnknown(data['subtask_id']!, _subtaskIdMeta),
      );
    }
    if (data.containsKey('title_snapshot')) {
      context.handle(
        _titleSnapshotMeta,
        titleSnapshot.isAcceptableOrUnknown(
          data['title_snapshot']!,
          _titleSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_titleSnapshotMeta);
    }
    if (data.containsKey('zone')) {
      context.handle(
        _zoneMeta,
        zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneMeta);
    }
    if (data.containsKey('planned_ms')) {
      context.handle(
        _plannedMsMeta,
        plannedMs.isAcceptableOrUnknown(data['planned_ms']!, _plannedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_plannedMsMeta);
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_elapsedMsMeta);
    }
    if (data.containsKey('eligible_ms')) {
      context.handle(
        _eligibleMsMeta,
        eligibleMs.isAcceptableOrUnknown(data['eligible_ms']!, _eligibleMsMeta),
      );
    } else if (isInserting) {
      context.missing(_eligibleMsMeta);
    }
    if (data.containsKey('uncertain_ms')) {
      context.handle(
        _uncertainMsMeta,
        uncertainMs.isAcceptableOrUnknown(
          data['uncertain_ms']!,
          _uncertainMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uncertainMsMeta);
    }
    if (data.containsKey('has_uncertainty')) {
      context.handle(
        _hasUncertaintyMeta,
        hasUncertainty.isAcceptableOrUnknown(
          data['has_uncertainty']!,
          _hasUncertaintyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hasUncertaintyMeta);
    }
    if (data.containsKey('background')) {
      context.handle(
        _backgroundMeta,
        background.isAcceptableOrUnknown(data['background']!, _backgroundMeta),
      );
    } else if (isInserting) {
      context.missing(_backgroundMeta);
    }
    if (data.containsKey('elapsed_mark_ms')) {
      context.handle(
        _elapsedMarkMsMeta,
        elapsedMarkMs.isAcceptableOrUnknown(
          data['elapsed_mark_ms']!,
          _elapsedMarkMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedMarkMsMeta);
    }
    if (data.containsKey('clock_epoch')) {
      context.handle(
        _clockEpochMeta,
        clockEpoch.isAcceptableOrUnknown(data['clock_epoch']!, _clockEpochMeta),
      );
    } else if (isInserting) {
      context.missing(_clockEpochMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('reported_ms')) {
      context.handle(
        _reportedMsMeta,
        reportedMs.isAcceptableOrUnknown(data['reported_ms']!, _reportedMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      subtaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtask_id'],
      ),
      titleSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_snapshot'],
      )!,
      zone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone'],
      )!,
      localStartDate: $FocusSessionsTable.$converterlocalStartDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}local_start_date'],
        )!,
      ),
      startedUtc: $FocusSessionsTable.$converterstartedUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}started_utc'],
        )!,
      ),
      kind: $FocusSessionsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      state: $FocusSessionsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      outcome: $FocusSessionsTable.$converteroutcomen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        ),
      ),
      plannedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_ms'],
      )!,
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
      eligibleMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eligible_ms'],
      )!,
      uncertainMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uncertain_ms'],
      )!,
      hasUncertainty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_uncertainty'],
      )!,
      background: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}background'],
      )!,
      checkpointUtc: $FocusSessionsTable.$convertercheckpointUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}checkpoint_utc'],
        )!,
      ),
      elapsedMarkMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_mark_ms'],
      )!,
      clockEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clock_epoch'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      reportedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reported_ms'],
      ),
      finalizedUtc: $FocusSessionsTable.$converterfinalizedUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}finalized_utc'],
        ),
      ),
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converterlocalStartDate =
      const CalendarDateConverter();
  static TypeConverter<DateTime, int> $converterstartedUtc =
      const UtcInstantConverter();
  static JsonTypeConverter2<SessionKind, String, String> $converterkind =
      const EnumNameConverter<SessionKind>(SessionKind.values);
  static JsonTypeConverter2<SessionState, String, String> $converterstate =
      const EnumNameConverter<SessionState>(SessionState.values);
  static JsonTypeConverter2<SessionOutcome, String, String> $converteroutcome =
      const EnumNameConverter<SessionOutcome>(SessionOutcome.values);
  static JsonTypeConverter2<SessionOutcome?, String?, String?>
  $converteroutcomen = JsonTypeConverter2.asNullable($converteroutcome);
  static TypeConverter<DateTime, int> $convertercheckpointUtc =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterfinalizedUtc =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterfinalizedUtcn =
      NullAwareTypeConverter.wrap($converterfinalizedUtc);
}

class FocusSession extends DataClass implements Insertable<FocusSession> {
  final String id;
  final String installationId;
  final String? taskId;
  final String? subtaskId;
  final String titleSnapshot;
  final String zone;
  final CalendarDate localStartDate;
  final DateTime startedUtc;
  final SessionKind kind;
  final SessionState state;
  final SessionOutcome? outcome;
  final int plannedMs;
  final int elapsedMs;
  final int eligibleMs;
  final int uncertainMs;
  final bool hasUncertainty;
  final bool background;
  final DateTime checkpointUtc;
  final int elapsedMarkMs;
  final String clockEpoch;
  final int revision;
  final int? reportedMs;
  final DateTime? finalizedUtc;
  const FocusSession({
    required this.id,
    required this.installationId,
    this.taskId,
    this.subtaskId,
    required this.titleSnapshot,
    required this.zone,
    required this.localStartDate,
    required this.startedUtc,
    required this.kind,
    required this.state,
    this.outcome,
    required this.plannedMs,
    required this.elapsedMs,
    required this.eligibleMs,
    required this.uncertainMs,
    required this.hasUncertainty,
    required this.background,
    required this.checkpointUtc,
    required this.elapsedMarkMs,
    required this.clockEpoch,
    required this.revision,
    this.reportedMs,
    this.finalizedUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['installation_id'] = Variable<String>(installationId);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    if (!nullToAbsent || subtaskId != null) {
      map['subtask_id'] = Variable<String>(subtaskId);
    }
    map['title_snapshot'] = Variable<String>(titleSnapshot);
    map['zone'] = Variable<String>(zone);
    {
      map['local_start_date'] = Variable<String>(
        $FocusSessionsTable.$converterlocalStartDate.toSql(localStartDate),
      );
    }
    {
      map['started_utc'] = Variable<int>(
        $FocusSessionsTable.$converterstartedUtc.toSql(startedUtc),
      );
    }
    {
      map['kind'] = Variable<String>(
        $FocusSessionsTable.$converterkind.toSql(kind),
      );
    }
    {
      map['state'] = Variable<String>(
        $FocusSessionsTable.$converterstate.toSql(state),
      );
    }
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(
        $FocusSessionsTable.$converteroutcomen.toSql(outcome),
      );
    }
    map['planned_ms'] = Variable<int>(plannedMs);
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    map['eligible_ms'] = Variable<int>(eligibleMs);
    map['uncertain_ms'] = Variable<int>(uncertainMs);
    map['has_uncertainty'] = Variable<bool>(hasUncertainty);
    map['background'] = Variable<bool>(background);
    {
      map['checkpoint_utc'] = Variable<int>(
        $FocusSessionsTable.$convertercheckpointUtc.toSql(checkpointUtc),
      );
    }
    map['elapsed_mark_ms'] = Variable<int>(elapsedMarkMs);
    map['clock_epoch'] = Variable<String>(clockEpoch);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || reportedMs != null) {
      map['reported_ms'] = Variable<int>(reportedMs);
    }
    if (!nullToAbsent || finalizedUtc != null) {
      map['finalized_utc'] = Variable<int>(
        $FocusSessionsTable.$converterfinalizedUtcn.toSql(finalizedUtc),
      );
    }
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      installationId: Value(installationId),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      subtaskId: subtaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(subtaskId),
      titleSnapshot: Value(titleSnapshot),
      zone: Value(zone),
      localStartDate: Value(localStartDate),
      startedUtc: Value(startedUtc),
      kind: Value(kind),
      state: Value(state),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      plannedMs: Value(plannedMs),
      elapsedMs: Value(elapsedMs),
      eligibleMs: Value(eligibleMs),
      uncertainMs: Value(uncertainMs),
      hasUncertainty: Value(hasUncertainty),
      background: Value(background),
      checkpointUtc: Value(checkpointUtc),
      elapsedMarkMs: Value(elapsedMarkMs),
      clockEpoch: Value(clockEpoch),
      revision: Value(revision),
      reportedMs: reportedMs == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedMs),
      finalizedUtc: finalizedUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(finalizedUtc),
    );
  }

  factory FocusSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSession(
      id: serializer.fromJson<String>(json['id']),
      installationId: serializer.fromJson<String>(json['installationId']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      subtaskId: serializer.fromJson<String?>(json['subtaskId']),
      titleSnapshot: serializer.fromJson<String>(json['titleSnapshot']),
      zone: serializer.fromJson<String>(json['zone']),
      localStartDate: serializer.fromJson<CalendarDate>(json['localStartDate']),
      startedUtc: serializer.fromJson<DateTime>(json['startedUtc']),
      kind: $FocusSessionsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      state: $FocusSessionsTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      outcome: $FocusSessionsTable.$converteroutcomen.fromJson(
        serializer.fromJson<String?>(json['outcome']),
      ),
      plannedMs: serializer.fromJson<int>(json['plannedMs']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      eligibleMs: serializer.fromJson<int>(json['eligibleMs']),
      uncertainMs: serializer.fromJson<int>(json['uncertainMs']),
      hasUncertainty: serializer.fromJson<bool>(json['hasUncertainty']),
      background: serializer.fromJson<bool>(json['background']),
      checkpointUtc: serializer.fromJson<DateTime>(json['checkpointUtc']),
      elapsedMarkMs: serializer.fromJson<int>(json['elapsedMarkMs']),
      clockEpoch: serializer.fromJson<String>(json['clockEpoch']),
      revision: serializer.fromJson<int>(json['revision']),
      reportedMs: serializer.fromJson<int?>(json['reportedMs']),
      finalizedUtc: serializer.fromJson<DateTime?>(json['finalizedUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'installationId': serializer.toJson<String>(installationId),
      'taskId': serializer.toJson<String?>(taskId),
      'subtaskId': serializer.toJson<String?>(subtaskId),
      'titleSnapshot': serializer.toJson<String>(titleSnapshot),
      'zone': serializer.toJson<String>(zone),
      'localStartDate': serializer.toJson<CalendarDate>(localStartDate),
      'startedUtc': serializer.toJson<DateTime>(startedUtc),
      'kind': serializer.toJson<String>(
        $FocusSessionsTable.$converterkind.toJson(kind),
      ),
      'state': serializer.toJson<String>(
        $FocusSessionsTable.$converterstate.toJson(state),
      ),
      'outcome': serializer.toJson<String?>(
        $FocusSessionsTable.$converteroutcomen.toJson(outcome),
      ),
      'plannedMs': serializer.toJson<int>(plannedMs),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'eligibleMs': serializer.toJson<int>(eligibleMs),
      'uncertainMs': serializer.toJson<int>(uncertainMs),
      'hasUncertainty': serializer.toJson<bool>(hasUncertainty),
      'background': serializer.toJson<bool>(background),
      'checkpointUtc': serializer.toJson<DateTime>(checkpointUtc),
      'elapsedMarkMs': serializer.toJson<int>(elapsedMarkMs),
      'clockEpoch': serializer.toJson<String>(clockEpoch),
      'revision': serializer.toJson<int>(revision),
      'reportedMs': serializer.toJson<int?>(reportedMs),
      'finalizedUtc': serializer.toJson<DateTime?>(finalizedUtc),
    };
  }

  FocusSession copyWith({
    String? id,
    String? installationId,
    Value<String?> taskId = const Value.absent(),
    Value<String?> subtaskId = const Value.absent(),
    String? titleSnapshot,
    String? zone,
    CalendarDate? localStartDate,
    DateTime? startedUtc,
    SessionKind? kind,
    SessionState? state,
    Value<SessionOutcome?> outcome = const Value.absent(),
    int? plannedMs,
    int? elapsedMs,
    int? eligibleMs,
    int? uncertainMs,
    bool? hasUncertainty,
    bool? background,
    DateTime? checkpointUtc,
    int? elapsedMarkMs,
    String? clockEpoch,
    int? revision,
    Value<int?> reportedMs = const Value.absent(),
    Value<DateTime?> finalizedUtc = const Value.absent(),
  }) => FocusSession(
    id: id ?? this.id,
    installationId: installationId ?? this.installationId,
    taskId: taskId.present ? taskId.value : this.taskId,
    subtaskId: subtaskId.present ? subtaskId.value : this.subtaskId,
    titleSnapshot: titleSnapshot ?? this.titleSnapshot,
    zone: zone ?? this.zone,
    localStartDate: localStartDate ?? this.localStartDate,
    startedUtc: startedUtc ?? this.startedUtc,
    kind: kind ?? this.kind,
    state: state ?? this.state,
    outcome: outcome.present ? outcome.value : this.outcome,
    plannedMs: plannedMs ?? this.plannedMs,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    eligibleMs: eligibleMs ?? this.eligibleMs,
    uncertainMs: uncertainMs ?? this.uncertainMs,
    hasUncertainty: hasUncertainty ?? this.hasUncertainty,
    background: background ?? this.background,
    checkpointUtc: checkpointUtc ?? this.checkpointUtc,
    elapsedMarkMs: elapsedMarkMs ?? this.elapsedMarkMs,
    clockEpoch: clockEpoch ?? this.clockEpoch,
    revision: revision ?? this.revision,
    reportedMs: reportedMs.present ? reportedMs.value : this.reportedMs,
    finalizedUtc: finalizedUtc.present ? finalizedUtc.value : this.finalizedUtc,
  );
  FocusSession copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSession(
      id: data.id.present ? data.id.value : this.id,
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      subtaskId: data.subtaskId.present ? data.subtaskId.value : this.subtaskId,
      titleSnapshot: data.titleSnapshot.present
          ? data.titleSnapshot.value
          : this.titleSnapshot,
      zone: data.zone.present ? data.zone.value : this.zone,
      localStartDate: data.localStartDate.present
          ? data.localStartDate.value
          : this.localStartDate,
      startedUtc: data.startedUtc.present
          ? data.startedUtc.value
          : this.startedUtc,
      kind: data.kind.present ? data.kind.value : this.kind,
      state: data.state.present ? data.state.value : this.state,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      plannedMs: data.plannedMs.present ? data.plannedMs.value : this.plannedMs,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      eligibleMs: data.eligibleMs.present
          ? data.eligibleMs.value
          : this.eligibleMs,
      uncertainMs: data.uncertainMs.present
          ? data.uncertainMs.value
          : this.uncertainMs,
      hasUncertainty: data.hasUncertainty.present
          ? data.hasUncertainty.value
          : this.hasUncertainty,
      background: data.background.present
          ? data.background.value
          : this.background,
      checkpointUtc: data.checkpointUtc.present
          ? data.checkpointUtc.value
          : this.checkpointUtc,
      elapsedMarkMs: data.elapsedMarkMs.present
          ? data.elapsedMarkMs.value
          : this.elapsedMarkMs,
      clockEpoch: data.clockEpoch.present
          ? data.clockEpoch.value
          : this.clockEpoch,
      revision: data.revision.present ? data.revision.value : this.revision,
      reportedMs: data.reportedMs.present
          ? data.reportedMs.value
          : this.reportedMs,
      finalizedUtc: data.finalizedUtc.present
          ? data.finalizedUtc.value
          : this.finalizedUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSession(')
          ..write('id: $id, ')
          ..write('installationId: $installationId, ')
          ..write('taskId: $taskId, ')
          ..write('subtaskId: $subtaskId, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('zone: $zone, ')
          ..write('localStartDate: $localStartDate, ')
          ..write('startedUtc: $startedUtc, ')
          ..write('kind: $kind, ')
          ..write('state: $state, ')
          ..write('outcome: $outcome, ')
          ..write('plannedMs: $plannedMs, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('eligibleMs: $eligibleMs, ')
          ..write('uncertainMs: $uncertainMs, ')
          ..write('hasUncertainty: $hasUncertainty, ')
          ..write('background: $background, ')
          ..write('checkpointUtc: $checkpointUtc, ')
          ..write('elapsedMarkMs: $elapsedMarkMs, ')
          ..write('clockEpoch: $clockEpoch, ')
          ..write('revision: $revision, ')
          ..write('reportedMs: $reportedMs, ')
          ..write('finalizedUtc: $finalizedUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    installationId,
    taskId,
    subtaskId,
    titleSnapshot,
    zone,
    localStartDate,
    startedUtc,
    kind,
    state,
    outcome,
    plannedMs,
    elapsedMs,
    eligibleMs,
    uncertainMs,
    hasUncertainty,
    background,
    checkpointUtc,
    elapsedMarkMs,
    clockEpoch,
    revision,
    reportedMs,
    finalizedUtc,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSession &&
          other.id == this.id &&
          other.installationId == this.installationId &&
          other.taskId == this.taskId &&
          other.subtaskId == this.subtaskId &&
          other.titleSnapshot == this.titleSnapshot &&
          other.zone == this.zone &&
          other.localStartDate == this.localStartDate &&
          other.startedUtc == this.startedUtc &&
          other.kind == this.kind &&
          other.state == this.state &&
          other.outcome == this.outcome &&
          other.plannedMs == this.plannedMs &&
          other.elapsedMs == this.elapsedMs &&
          other.eligibleMs == this.eligibleMs &&
          other.uncertainMs == this.uncertainMs &&
          other.hasUncertainty == this.hasUncertainty &&
          other.background == this.background &&
          other.checkpointUtc == this.checkpointUtc &&
          other.elapsedMarkMs == this.elapsedMarkMs &&
          other.clockEpoch == this.clockEpoch &&
          other.revision == this.revision &&
          other.reportedMs == this.reportedMs &&
          other.finalizedUtc == this.finalizedUtc);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSession> {
  final Value<String> id;
  final Value<String> installationId;
  final Value<String?> taskId;
  final Value<String?> subtaskId;
  final Value<String> titleSnapshot;
  final Value<String> zone;
  final Value<CalendarDate> localStartDate;
  final Value<DateTime> startedUtc;
  final Value<SessionKind> kind;
  final Value<SessionState> state;
  final Value<SessionOutcome?> outcome;
  final Value<int> plannedMs;
  final Value<int> elapsedMs;
  final Value<int> eligibleMs;
  final Value<int> uncertainMs;
  final Value<bool> hasUncertainty;
  final Value<bool> background;
  final Value<DateTime> checkpointUtc;
  final Value<int> elapsedMarkMs;
  final Value<String> clockEpoch;
  final Value<int> revision;
  final Value<int?> reportedMs;
  final Value<DateTime?> finalizedUtc;
  final Value<int> rowid;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.installationId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.subtaskId = const Value.absent(),
    this.titleSnapshot = const Value.absent(),
    this.zone = const Value.absent(),
    this.localStartDate = const Value.absent(),
    this.startedUtc = const Value.absent(),
    this.kind = const Value.absent(),
    this.state = const Value.absent(),
    this.outcome = const Value.absent(),
    this.plannedMs = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.eligibleMs = const Value.absent(),
    this.uncertainMs = const Value.absent(),
    this.hasUncertainty = const Value.absent(),
    this.background = const Value.absent(),
    this.checkpointUtc = const Value.absent(),
    this.elapsedMarkMs = const Value.absent(),
    this.clockEpoch = const Value.absent(),
    this.revision = const Value.absent(),
    this.reportedMs = const Value.absent(),
    this.finalizedUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    required String id,
    required String installationId,
    this.taskId = const Value.absent(),
    this.subtaskId = const Value.absent(),
    required String titleSnapshot,
    required String zone,
    required CalendarDate localStartDate,
    required DateTime startedUtc,
    required SessionKind kind,
    required SessionState state,
    this.outcome = const Value.absent(),
    required int plannedMs,
    required int elapsedMs,
    required int eligibleMs,
    required int uncertainMs,
    required bool hasUncertainty,
    required bool background,
    required DateTime checkpointUtc,
    required int elapsedMarkMs,
    required String clockEpoch,
    required int revision,
    this.reportedMs = const Value.absent(),
    this.finalizedUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       installationId = Value(installationId),
       titleSnapshot = Value(titleSnapshot),
       zone = Value(zone),
       localStartDate = Value(localStartDate),
       startedUtc = Value(startedUtc),
       kind = Value(kind),
       state = Value(state),
       plannedMs = Value(plannedMs),
       elapsedMs = Value(elapsedMs),
       eligibleMs = Value(eligibleMs),
       uncertainMs = Value(uncertainMs),
       hasUncertainty = Value(hasUncertainty),
       background = Value(background),
       checkpointUtc = Value(checkpointUtc),
       elapsedMarkMs = Value(elapsedMarkMs),
       clockEpoch = Value(clockEpoch),
       revision = Value(revision);
  static Insertable<FocusSession> custom({
    Expression<String>? id,
    Expression<String>? installationId,
    Expression<String>? taskId,
    Expression<String>? subtaskId,
    Expression<String>? titleSnapshot,
    Expression<String>? zone,
    Expression<String>? localStartDate,
    Expression<int>? startedUtc,
    Expression<String>? kind,
    Expression<String>? state,
    Expression<String>? outcome,
    Expression<int>? plannedMs,
    Expression<int>? elapsedMs,
    Expression<int>? eligibleMs,
    Expression<int>? uncertainMs,
    Expression<bool>? hasUncertainty,
    Expression<bool>? background,
    Expression<int>? checkpointUtc,
    Expression<int>? elapsedMarkMs,
    Expression<String>? clockEpoch,
    Expression<int>? revision,
    Expression<int>? reportedMs,
    Expression<int>? finalizedUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (installationId != null) 'installation_id': installationId,
      if (taskId != null) 'task_id': taskId,
      if (subtaskId != null) 'subtask_id': subtaskId,
      if (titleSnapshot != null) 'title_snapshot': titleSnapshot,
      if (zone != null) 'zone': zone,
      if (localStartDate != null) 'local_start_date': localStartDate,
      if (startedUtc != null) 'started_utc': startedUtc,
      if (kind != null) 'kind': kind,
      if (state != null) 'state': state,
      if (outcome != null) 'outcome': outcome,
      if (plannedMs != null) 'planned_ms': plannedMs,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (eligibleMs != null) 'eligible_ms': eligibleMs,
      if (uncertainMs != null) 'uncertain_ms': uncertainMs,
      if (hasUncertainty != null) 'has_uncertainty': hasUncertainty,
      if (background != null) 'background': background,
      if (checkpointUtc != null) 'checkpoint_utc': checkpointUtc,
      if (elapsedMarkMs != null) 'elapsed_mark_ms': elapsedMarkMs,
      if (clockEpoch != null) 'clock_epoch': clockEpoch,
      if (revision != null) 'revision': revision,
      if (reportedMs != null) 'reported_ms': reportedMs,
      if (finalizedUtc != null) 'finalized_utc': finalizedUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? installationId,
    Value<String?>? taskId,
    Value<String?>? subtaskId,
    Value<String>? titleSnapshot,
    Value<String>? zone,
    Value<CalendarDate>? localStartDate,
    Value<DateTime>? startedUtc,
    Value<SessionKind>? kind,
    Value<SessionState>? state,
    Value<SessionOutcome?>? outcome,
    Value<int>? plannedMs,
    Value<int>? elapsedMs,
    Value<int>? eligibleMs,
    Value<int>? uncertainMs,
    Value<bool>? hasUncertainty,
    Value<bool>? background,
    Value<DateTime>? checkpointUtc,
    Value<int>? elapsedMarkMs,
    Value<String>? clockEpoch,
    Value<int>? revision,
    Value<int?>? reportedMs,
    Value<DateTime?>? finalizedUtc,
    Value<int>? rowid,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      installationId: installationId ?? this.installationId,
      taskId: taskId ?? this.taskId,
      subtaskId: subtaskId ?? this.subtaskId,
      titleSnapshot: titleSnapshot ?? this.titleSnapshot,
      zone: zone ?? this.zone,
      localStartDate: localStartDate ?? this.localStartDate,
      startedUtc: startedUtc ?? this.startedUtc,
      kind: kind ?? this.kind,
      state: state ?? this.state,
      outcome: outcome ?? this.outcome,
      plannedMs: plannedMs ?? this.plannedMs,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      eligibleMs: eligibleMs ?? this.eligibleMs,
      uncertainMs: uncertainMs ?? this.uncertainMs,
      hasUncertainty: hasUncertainty ?? this.hasUncertainty,
      background: background ?? this.background,
      checkpointUtc: checkpointUtc ?? this.checkpointUtc,
      elapsedMarkMs: elapsedMarkMs ?? this.elapsedMarkMs,
      clockEpoch: clockEpoch ?? this.clockEpoch,
      revision: revision ?? this.revision,
      reportedMs: reportedMs ?? this.reportedMs,
      finalizedUtc: finalizedUtc ?? this.finalizedUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (subtaskId.present) {
      map['subtask_id'] = Variable<String>(subtaskId.value);
    }
    if (titleSnapshot.present) {
      map['title_snapshot'] = Variable<String>(titleSnapshot.value);
    }
    if (zone.present) {
      map['zone'] = Variable<String>(zone.value);
    }
    if (localStartDate.present) {
      map['local_start_date'] = Variable<String>(
        $FocusSessionsTable.$converterlocalStartDate.toSql(
          localStartDate.value,
        ),
      );
    }
    if (startedUtc.present) {
      map['started_utc'] = Variable<int>(
        $FocusSessionsTable.$converterstartedUtc.toSql(startedUtc.value),
      );
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $FocusSessionsTable.$converterkind.toSql(kind.value),
      );
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $FocusSessionsTable.$converterstate.toSql(state.value),
      );
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $FocusSessionsTable.$converteroutcomen.toSql(outcome.value),
      );
    }
    if (plannedMs.present) {
      map['planned_ms'] = Variable<int>(plannedMs.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (eligibleMs.present) {
      map['eligible_ms'] = Variable<int>(eligibleMs.value);
    }
    if (uncertainMs.present) {
      map['uncertain_ms'] = Variable<int>(uncertainMs.value);
    }
    if (hasUncertainty.present) {
      map['has_uncertainty'] = Variable<bool>(hasUncertainty.value);
    }
    if (background.present) {
      map['background'] = Variable<bool>(background.value);
    }
    if (checkpointUtc.present) {
      map['checkpoint_utc'] = Variable<int>(
        $FocusSessionsTable.$convertercheckpointUtc.toSql(checkpointUtc.value),
      );
    }
    if (elapsedMarkMs.present) {
      map['elapsed_mark_ms'] = Variable<int>(elapsedMarkMs.value);
    }
    if (clockEpoch.present) {
      map['clock_epoch'] = Variable<String>(clockEpoch.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (reportedMs.present) {
      map['reported_ms'] = Variable<int>(reportedMs.value);
    }
    if (finalizedUtc.present) {
      map['finalized_utc'] = Variable<int>(
        $FocusSessionsTable.$converterfinalizedUtcn.toSql(finalizedUtc.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('installationId: $installationId, ')
          ..write('taskId: $taskId, ')
          ..write('subtaskId: $subtaskId, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('zone: $zone, ')
          ..write('localStartDate: $localStartDate, ')
          ..write('startedUtc: $startedUtc, ')
          ..write('kind: $kind, ')
          ..write('state: $state, ')
          ..write('outcome: $outcome, ')
          ..write('plannedMs: $plannedMs, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('eligibleMs: $eligibleMs, ')
          ..write('uncertainMs: $uncertainMs, ')
          ..write('hasUncertainty: $hasUncertainty, ')
          ..write('background: $background, ')
          ..write('checkpointUtc: $checkpointUtc, ')
          ..write('elapsedMarkMs: $elapsedMarkMs, ')
          ..write('clockEpoch: $clockEpoch, ')
          ..write('revision: $revision, ')
          ..write('reportedMs: $reportedMs, ')
          ..write('finalizedUtc: $finalizedUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FocusSegmentsTable extends FocusSegments
    with TableInfo<$FocusSegmentsTable, FocusSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES focus_sessions (id)',
    ),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    check: () => const CustomExpression('sequence >= 1'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SegmentKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        check: () => const CustomExpression("kind IN ('active','pause','gap')"),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SegmentKind>($FocusSegmentsTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> fromUtc =
      GeneratedColumn<int>(
        'from_utc',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($FocusSegmentsTable.$converterfromUtc);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> toUtc =
      GeneratedColumn<int>(
        'to_utc',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($FocusSegmentsTable.$convertertoUtc);
  static const VerificationMeta _spanMsMeta = const VerificationMeta('spanMs');
  @override
  late final GeneratedColumn<int> spanMs = GeneratedColumn<int>(
    'span_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eligibleMsMeta = const VerificationMeta(
    'eligibleMs',
  );
  @override
  late final GeneratedColumn<int> eligibleMs = GeneratedColumn<int>(
    'eligible_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    sequence,
    kind,
    fromUtc,
    toUtc,
    spanMs,
    elapsedMs,
    eligibleMs,
    reason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('span_ms')) {
      context.handle(
        _spanMsMeta,
        spanMs.isAcceptableOrUnknown(data['span_ms']!, _spanMsMeta),
      );
    } else if (isInserting) {
      context.missing(_spanMsMeta);
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_elapsedMsMeta);
    }
    if (data.containsKey('eligible_ms')) {
      context.handle(
        _eligibleMsMeta,
        eligibleMs.isAcceptableOrUnknown(data['eligible_ms']!, _eligibleMsMeta),
      );
    } else if (isInserting) {
      context.missing(_eligibleMsMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, sequence},
  ];
  @override
  FocusSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      kind: $FocusSegmentsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      fromUtc: $FocusSegmentsTable.$converterfromUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}from_utc'],
        )!,
      ),
      toUtc: $FocusSegmentsTable.$convertertoUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}to_utc'],
        )!,
      ),
      spanMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}span_ms'],
      )!,
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
      eligibleMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eligible_ms'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
    );
  }

  @override
  $FocusSegmentsTable createAlias(String alias) {
    return $FocusSegmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SegmentKind, String, String> $converterkind =
      const EnumNameConverter<SegmentKind>(SegmentKind.values);
  static TypeConverter<DateTime, int> $converterfromUtc =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $convertertoUtc =
      const UtcInstantConverter();
}

class FocusSegment extends DataClass implements Insertable<FocusSegment> {
  final String id;
  final String sessionId;
  final int sequence;
  final SegmentKind kind;
  final DateTime fromUtc;
  final DateTime toUtc;
  final int spanMs;
  final int elapsedMs;
  final int eligibleMs;
  final String? reason;
  const FocusSegment({
    required this.id,
    required this.sessionId,
    required this.sequence,
    required this.kind,
    required this.fromUtc,
    required this.toUtc,
    required this.spanMs,
    required this.elapsedMs,
    required this.eligibleMs,
    this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['sequence'] = Variable<int>(sequence);
    {
      map['kind'] = Variable<String>(
        $FocusSegmentsTable.$converterkind.toSql(kind),
      );
    }
    {
      map['from_utc'] = Variable<int>(
        $FocusSegmentsTable.$converterfromUtc.toSql(fromUtc),
      );
    }
    {
      map['to_utc'] = Variable<int>(
        $FocusSegmentsTable.$convertertoUtc.toSql(toUtc),
      );
    }
    map['span_ms'] = Variable<int>(spanMs);
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    map['eligible_ms'] = Variable<int>(eligibleMs);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    return map;
  }

  FocusSegmentsCompanion toCompanion(bool nullToAbsent) {
    return FocusSegmentsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      sequence: Value(sequence),
      kind: Value(kind),
      fromUtc: Value(fromUtc),
      toUtc: Value(toUtc),
      spanMs: Value(spanMs),
      elapsedMs: Value(elapsedMs),
      eligibleMs: Value(eligibleMs),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
    );
  }

  factory FocusSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSegment(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      kind: $FocusSegmentsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      fromUtc: serializer.fromJson<DateTime>(json['fromUtc']),
      toUtc: serializer.fromJson<DateTime>(json['toUtc']),
      spanMs: serializer.fromJson<int>(json['spanMs']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      eligibleMs: serializer.fromJson<int>(json['eligibleMs']),
      reason: serializer.fromJson<String?>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'sequence': serializer.toJson<int>(sequence),
      'kind': serializer.toJson<String>(
        $FocusSegmentsTable.$converterkind.toJson(kind),
      ),
      'fromUtc': serializer.toJson<DateTime>(fromUtc),
      'toUtc': serializer.toJson<DateTime>(toUtc),
      'spanMs': serializer.toJson<int>(spanMs),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'eligibleMs': serializer.toJson<int>(eligibleMs),
      'reason': serializer.toJson<String?>(reason),
    };
  }

  FocusSegment copyWith({
    String? id,
    String? sessionId,
    int? sequence,
    SegmentKind? kind,
    DateTime? fromUtc,
    DateTime? toUtc,
    int? spanMs,
    int? elapsedMs,
    int? eligibleMs,
    Value<String?> reason = const Value.absent(),
  }) => FocusSegment(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    sequence: sequence ?? this.sequence,
    kind: kind ?? this.kind,
    fromUtc: fromUtc ?? this.fromUtc,
    toUtc: toUtc ?? this.toUtc,
    spanMs: spanMs ?? this.spanMs,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    eligibleMs: eligibleMs ?? this.eligibleMs,
    reason: reason.present ? reason.value : this.reason,
  );
  FocusSegment copyWithCompanion(FocusSegmentsCompanion data) {
    return FocusSegment(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      kind: data.kind.present ? data.kind.value : this.kind,
      fromUtc: data.fromUtc.present ? data.fromUtc.value : this.fromUtc,
      toUtc: data.toUtc.present ? data.toUtc.value : this.toUtc,
      spanMs: data.spanMs.present ? data.spanMs.value : this.spanMs,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      eligibleMs: data.eligibleMs.present
          ? data.eligibleMs.value
          : this.eligibleMs,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSegment(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('sequence: $sequence, ')
          ..write('kind: $kind, ')
          ..write('fromUtc: $fromUtc, ')
          ..write('toUtc: $toUtc, ')
          ..write('spanMs: $spanMs, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('eligibleMs: $eligibleMs, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    sequence,
    kind,
    fromUtc,
    toUtc,
    spanMs,
    elapsedMs,
    eligibleMs,
    reason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSegment &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.sequence == this.sequence &&
          other.kind == this.kind &&
          other.fromUtc == this.fromUtc &&
          other.toUtc == this.toUtc &&
          other.spanMs == this.spanMs &&
          other.elapsedMs == this.elapsedMs &&
          other.eligibleMs == this.eligibleMs &&
          other.reason == this.reason);
}

class FocusSegmentsCompanion extends UpdateCompanion<FocusSegment> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> sequence;
  final Value<SegmentKind> kind;
  final Value<DateTime> fromUtc;
  final Value<DateTime> toUtc;
  final Value<int> spanMs;
  final Value<int> elapsedMs;
  final Value<int> eligibleMs;
  final Value<String?> reason;
  final Value<int> rowid;
  const FocusSegmentsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.kind = const Value.absent(),
    this.fromUtc = const Value.absent(),
    this.toUtc = const Value.absent(),
    this.spanMs = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.eligibleMs = const Value.absent(),
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FocusSegmentsCompanion.insert({
    required String id,
    required String sessionId,
    required int sequence,
    required SegmentKind kind,
    required DateTime fromUtc,
    required DateTime toUtc,
    required int spanMs,
    required int elapsedMs,
    required int eligibleMs,
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       sequence = Value(sequence),
       kind = Value(kind),
       fromUtc = Value(fromUtc),
       toUtc = Value(toUtc),
       spanMs = Value(spanMs),
       elapsedMs = Value(elapsedMs),
       eligibleMs = Value(eligibleMs);
  static Insertable<FocusSegment> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? sequence,
    Expression<String>? kind,
    Expression<int>? fromUtc,
    Expression<int>? toUtc,
    Expression<int>? spanMs,
    Expression<int>? elapsedMs,
    Expression<int>? eligibleMs,
    Expression<String>? reason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (sequence != null) 'sequence': sequence,
      if (kind != null) 'kind': kind,
      if (fromUtc != null) 'from_utc': fromUtc,
      if (toUtc != null) 'to_utc': toUtc,
      if (spanMs != null) 'span_ms': spanMs,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (eligibleMs != null) 'eligible_ms': eligibleMs,
      if (reason != null) 'reason': reason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FocusSegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? sequence,
    Value<SegmentKind>? kind,
    Value<DateTime>? fromUtc,
    Value<DateTime>? toUtc,
    Value<int>? spanMs,
    Value<int>? elapsedMs,
    Value<int>? eligibleMs,
    Value<String?>? reason,
    Value<int>? rowid,
  }) {
    return FocusSegmentsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      sequence: sequence ?? this.sequence,
      kind: kind ?? this.kind,
      fromUtc: fromUtc ?? this.fromUtc,
      toUtc: toUtc ?? this.toUtc,
      spanMs: spanMs ?? this.spanMs,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      eligibleMs: eligibleMs ?? this.eligibleMs,
      reason: reason ?? this.reason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $FocusSegmentsTable.$converterkind.toSql(kind.value),
      );
    }
    if (fromUtc.present) {
      map['from_utc'] = Variable<int>(
        $FocusSegmentsTable.$converterfromUtc.toSql(fromUtc.value),
      );
    }
    if (toUtc.present) {
      map['to_utc'] = Variable<int>(
        $FocusSegmentsTable.$convertertoUtc.toSql(toUtc.value),
      );
    }
    if (spanMs.present) {
      map['span_ms'] = Variable<int>(spanMs.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (eligibleMs.present) {
      map['eligible_ms'] = Variable<int>(eligibleMs.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('sequence: $sequence, ')
          ..write('kind: $kind, ')
          ..write('fromUtc: $fromUtc, ')
          ..write('toUtc: $toUtc, ')
          ..write('spanMs: $spanMs, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('eligibleMs: $eligibleMs, ')
          ..write('reason: $reason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimerCommandReceiptsTable extends TimerCommandReceipts
    with TableInfo<$TimerCommandReceiptsTable, TimerCommandReceipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerCommandReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES focus_sessions (id)',
    ),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "action IN ('start','pause','resume','extend','end','recover','finalize','background','foreground')",
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> committedUtc =
      GeneratedColumn<int>(
        'committed_utc',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $TimerCommandReceiptsTable.$convertercommittedUtc,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    action,
    payload,
    committedUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_command_receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerCommandReceipt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerCommandReceipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerCommandReceipt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      committedUtc: $TimerCommandReceiptsTable.$convertercommittedUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}committed_utc'],
        )!,
      ),
    );
  }

  @override
  $TimerCommandReceiptsTable createAlias(String alias) {
    return $TimerCommandReceiptsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercommittedUtc =
      const UtcInstantConverter();
}

class TimerCommandReceipt extends DataClass
    implements Insertable<TimerCommandReceipt> {
  final String id;
  final String sessionId;
  final String action;
  final String payload;
  final DateTime committedUtc;
  const TimerCommandReceipt({
    required this.id,
    required this.sessionId,
    required this.action,
    required this.payload,
    required this.committedUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    {
      map['committed_utc'] = Variable<int>(
        $TimerCommandReceiptsTable.$convertercommittedUtc.toSql(committedUtc),
      );
    }
    return map;
  }

  TimerCommandReceiptsCompanion toCompanion(bool nullToAbsent) {
    return TimerCommandReceiptsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      action: Value(action),
      payload: Value(payload),
      committedUtc: Value(committedUtc),
    );
  }

  factory TimerCommandReceipt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerCommandReceipt(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      committedUtc: serializer.fromJson<DateTime>(json['committedUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'committedUtc': serializer.toJson<DateTime>(committedUtc),
    };
  }

  TimerCommandReceipt copyWith({
    String? id,
    String? sessionId,
    String? action,
    String? payload,
    DateTime? committedUtc,
  }) => TimerCommandReceipt(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    action: action ?? this.action,
    payload: payload ?? this.payload,
    committedUtc: committedUtc ?? this.committedUtc,
  );
  TimerCommandReceipt copyWithCompanion(TimerCommandReceiptsCompanion data) {
    return TimerCommandReceipt(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      committedUtc: data.committedUtc.present
          ? data.committedUtc.value
          : this.committedUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerCommandReceipt(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('committedUtc: $committedUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, action, payload, committedUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerCommandReceipt &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.committedUtc == this.committedUtc);
}

class TimerCommandReceiptsCompanion
    extends UpdateCompanion<TimerCommandReceipt> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> committedUtc;
  final Value<int> rowid;
  const TimerCommandReceiptsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.committedUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimerCommandReceiptsCompanion.insert({
    required String id,
    required String sessionId,
    required String action,
    required String payload,
    required DateTime committedUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       action = Value(action),
       payload = Value(payload),
       committedUtc = Value(committedUtc);
  static Insertable<TimerCommandReceipt> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<int>? committedUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (committedUtc != null) 'committed_utc': committedUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimerCommandReceiptsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? action,
    Value<String>? payload,
    Value<DateTime>? committedUtc,
    Value<int>? rowid,
  }) {
    return TimerCommandReceiptsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      committedUtc: committedUtc ?? this.committedUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (committedUtc.present) {
      map['committed_utc'] = Variable<int>(
        $TimerCommandReceiptsTable.$convertercommittedUtc.toSql(
          committedUtc.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerCommandReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('committedUtc: $committedUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderPreferencesRowsTable extends ReminderPreferencesRows
    with TableInfo<$ReminderPreferencesRowsTable, ReminderPreferences> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderPreferencesRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _singletonMeta = const VerificationMeta(
    'singleton',
  );
  @override
  late final GeneratedColumn<int> singleton = GeneratedColumn<int>(
    'singleton',
    aliasedName,
    false,
    check: () => const CustomExpression('singleton = 1'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _quietEnabledMeta = const VerificationMeta(
    'quietEnabled',
  );
  @override
  late final GeneratedColumn<bool> quietEnabled = GeneratedColumn<bool>(
    'quiet_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("quiet_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _quietStartMeta = const VerificationMeta(
    'quietStart',
  );
  @override
  late final GeneratedColumn<int> quietStart = GeneratedColumn<int>(
    'quiet_start',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(quiet_start)='integer' AND quiet_start BETWEEN 0 AND 1439",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1320),
  );
  static const VerificationMeta _quietEndMeta = const VerificationMeta(
    'quietEnd',
  );
  @override
  late final GeneratedColumn<int> quietEnd = GeneratedColumn<int>(
    'quiet_end',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(quiet_end)='integer' AND quiet_end BETWEEN 0 AND 1439",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(420),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    singleton,
    enabled,
    quietEnabled,
    quietStart,
    quietEnd,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_preferences_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderPreferences> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('singleton')) {
      context.handle(
        _singletonMeta,
        singleton.isAcceptableOrUnknown(data['singleton']!, _singletonMeta),
      );
    } else if (isInserting) {
      context.missing(_singletonMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('quiet_enabled')) {
      context.handle(
        _quietEnabledMeta,
        quietEnabled.isAcceptableOrUnknown(
          data['quiet_enabled']!,
          _quietEnabledMeta,
        ),
      );
    }
    if (data.containsKey('quiet_start')) {
      context.handle(
        _quietStartMeta,
        quietStart.isAcceptableOrUnknown(data['quiet_start']!, _quietStartMeta),
      );
    }
    if (data.containsKey('quiet_end')) {
      context.handle(
        _quietEndMeta,
        quietEnd.isAcceptableOrUnknown(data['quiet_end']!, _quietEndMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderPreferences map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderPreferences(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      singleton: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      quietEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}quiet_enabled'],
      )!,
      quietStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_start'],
      )!,
      quietEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_end'],
      )!,
    );
  }

  @override
  $ReminderPreferencesRowsTable createAlias(String alias) {
    return $ReminderPreferencesRowsTable(attachedDatabase, alias);
  }
}

class ReminderPreferences extends DataClass
    implements Insertable<ReminderPreferences> {
  final String id;
  final int singleton;
  final bool enabled;
  final bool quietEnabled;
  final int quietStart;
  final int quietEnd;
  const ReminderPreferences({
    required this.id,
    required this.singleton,
    required this.enabled,
    required this.quietEnabled,
    required this.quietStart,
    required this.quietEnd,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['singleton'] = Variable<int>(singleton);
    map['enabled'] = Variable<bool>(enabled);
    map['quiet_enabled'] = Variable<bool>(quietEnabled);
    map['quiet_start'] = Variable<int>(quietStart);
    map['quiet_end'] = Variable<int>(quietEnd);
    return map;
  }

  ReminderPreferencesRowsCompanion toCompanion(bool nullToAbsent) {
    return ReminderPreferencesRowsCompanion(
      id: Value(id),
      singleton: Value(singleton),
      enabled: Value(enabled),
      quietEnabled: Value(quietEnabled),
      quietStart: Value(quietStart),
      quietEnd: Value(quietEnd),
    );
  }

  factory ReminderPreferences.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderPreferences(
      id: serializer.fromJson<String>(json['id']),
      singleton: serializer.fromJson<int>(json['singleton']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      quietEnabled: serializer.fromJson<bool>(json['quietEnabled']),
      quietStart: serializer.fromJson<int>(json['quietStart']),
      quietEnd: serializer.fromJson<int>(json['quietEnd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'singleton': serializer.toJson<int>(singleton),
      'enabled': serializer.toJson<bool>(enabled),
      'quietEnabled': serializer.toJson<bool>(quietEnabled),
      'quietStart': serializer.toJson<int>(quietStart),
      'quietEnd': serializer.toJson<int>(quietEnd),
    };
  }

  ReminderPreferences copyWith({
    String? id,
    int? singleton,
    bool? enabled,
    bool? quietEnabled,
    int? quietStart,
    int? quietEnd,
  }) => ReminderPreferences(
    id: id ?? this.id,
    singleton: singleton ?? this.singleton,
    enabled: enabled ?? this.enabled,
    quietEnabled: quietEnabled ?? this.quietEnabled,
    quietStart: quietStart ?? this.quietStart,
    quietEnd: quietEnd ?? this.quietEnd,
  );
  ReminderPreferences copyWithCompanion(ReminderPreferencesRowsCompanion data) {
    return ReminderPreferences(
      id: data.id.present ? data.id.value : this.id,
      singleton: data.singleton.present ? data.singleton.value : this.singleton,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      quietEnabled: data.quietEnabled.present
          ? data.quietEnabled.value
          : this.quietEnabled,
      quietStart: data.quietStart.present
          ? data.quietStart.value
          : this.quietStart,
      quietEnd: data.quietEnd.present ? data.quietEnd.value : this.quietEnd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderPreferences(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('enabled: $enabled, ')
          ..write('quietEnabled: $quietEnabled, ')
          ..write('quietStart: $quietStart, ')
          ..write('quietEnd: $quietEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, singleton, enabled, quietEnabled, quietStart, quietEnd);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderPreferences &&
          other.id == this.id &&
          other.singleton == this.singleton &&
          other.enabled == this.enabled &&
          other.quietEnabled == this.quietEnabled &&
          other.quietStart == this.quietStart &&
          other.quietEnd == this.quietEnd);
}

class ReminderPreferencesRowsCompanion
    extends UpdateCompanion<ReminderPreferences> {
  final Value<String> id;
  final Value<int> singleton;
  final Value<bool> enabled;
  final Value<bool> quietEnabled;
  final Value<int> quietStart;
  final Value<int> quietEnd;
  final Value<int> rowid;
  const ReminderPreferencesRowsCompanion({
    this.id = const Value.absent(),
    this.singleton = const Value.absent(),
    this.enabled = const Value.absent(),
    this.quietEnabled = const Value.absent(),
    this.quietStart = const Value.absent(),
    this.quietEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderPreferencesRowsCompanion.insert({
    required String id,
    required int singleton,
    this.enabled = const Value.absent(),
    this.quietEnabled = const Value.absent(),
    this.quietStart = const Value.absent(),
    this.quietEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       singleton = Value(singleton);
  static Insertable<ReminderPreferences> custom({
    Expression<String>? id,
    Expression<int>? singleton,
    Expression<bool>? enabled,
    Expression<bool>? quietEnabled,
    Expression<int>? quietStart,
    Expression<int>? quietEnd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (singleton != null) 'singleton': singleton,
      if (enabled != null) 'enabled': enabled,
      if (quietEnabled != null) 'quiet_enabled': quietEnabled,
      if (quietStart != null) 'quiet_start': quietStart,
      if (quietEnd != null) 'quiet_end': quietEnd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderPreferencesRowsCompanion copyWith({
    Value<String>? id,
    Value<int>? singleton,
    Value<bool>? enabled,
    Value<bool>? quietEnabled,
    Value<int>? quietStart,
    Value<int>? quietEnd,
    Value<int>? rowid,
  }) {
    return ReminderPreferencesRowsCompanion(
      id: id ?? this.id,
      singleton: singleton ?? this.singleton,
      enabled: enabled ?? this.enabled,
      quietEnabled: quietEnabled ?? this.quietEnabled,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (singleton.present) {
      map['singleton'] = Variable<int>(singleton.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (quietEnabled.present) {
      map['quiet_enabled'] = Variable<bool>(quietEnabled.value);
    }
    if (quietStart.present) {
      map['quiet_start'] = Variable<int>(quietStart.value);
    }
    if (quietEnd.present) {
      map['quiet_end'] = Variable<int>(quietEnd.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderPreferencesRowsCompanion(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('enabled: $enabled, ')
          ..write('quietEnabled: $quietEnabled, ')
          ..write('quietStart: $quietStart, ')
          ..write('quietEnd: $quietEnd, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderRulesTable extends ReminderRules
    with TableInfo<$ReminderRulesTable, ReminderRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        check: () => const CustomExpression(
          "kind IN ('deadline','activity','work','timer')",
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderKind>($ReminderRulesTable.$converterkind);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES activity_series (id)',
    ),
  );
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<String> workId = GeneratedColumn<String>(
    'work_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES planned_work_blocks (id)',
    ),
  );
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES installations (id)',
    ),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _leadMinutesMeta = const VerificationMeta(
    'leadMinutes',
  );
  @override
  late final GeneratedColumn<int> leadMinutes = GeneratedColumn<int>(
    'lead_minutes',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(lead_minutes)='integer' AND lead_minutes BETWEEN 0 AND 10080",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    taskId,
    seriesId,
    workId,
    installationId,
    enabled,
    leadMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    }
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('lead_minutes')) {
      context.handle(
        _leadMinutesMeta,
        leadMinutes.isAcceptableOrUnknown(
          data['lead_minutes']!,
          _leadMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: $ReminderRulesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_id'],
      ),
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      leadMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lead_minutes'],
      )!,
    );
  }

  @override
  $ReminderRulesTable createAlias(String alias) {
    return $ReminderRulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderKind, String, String> $converterkind =
      const EnumNameConverter<ReminderKind>(ReminderKind.values);
}

class ReminderRule extends DataClass implements Insertable<ReminderRule> {
  final String id;
  final ReminderKind kind;
  final String? taskId;
  final String? seriesId;
  final String? workId;
  final String? installationId;
  final bool enabled;
  final int leadMinutes;
  const ReminderRule({
    required this.id,
    required this.kind,
    this.taskId,
    this.seriesId,
    this.workId,
    this.installationId,
    required this.enabled,
    required this.leadMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['kind'] = Variable<String>(
        $ReminderRulesTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    if (!nullToAbsent || workId != null) {
      map['work_id'] = Variable<String>(workId);
    }
    if (!nullToAbsent || installationId != null) {
      map['installation_id'] = Variable<String>(installationId);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['lead_minutes'] = Variable<int>(leadMinutes);
    return map;
  }

  ReminderRulesCompanion toCompanion(bool nullToAbsent) {
    return ReminderRulesCompanion(
      id: Value(id),
      kind: Value(kind),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      workId: workId == null && nullToAbsent
          ? const Value.absent()
          : Value(workId),
      installationId: installationId == null && nullToAbsent
          ? const Value.absent()
          : Value(installationId),
      enabled: Value(enabled),
      leadMinutes: Value(leadMinutes),
    );
  }

  factory ReminderRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRule(
      id: serializer.fromJson<String>(json['id']),
      kind: $ReminderRulesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      taskId: serializer.fromJson<String?>(json['taskId']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      workId: serializer.fromJson<String?>(json['workId']),
      installationId: serializer.fromJson<String?>(json['installationId']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      leadMinutes: serializer.fromJson<int>(json['leadMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(
        $ReminderRulesTable.$converterkind.toJson(kind),
      ),
      'taskId': serializer.toJson<String?>(taskId),
      'seriesId': serializer.toJson<String?>(seriesId),
      'workId': serializer.toJson<String?>(workId),
      'installationId': serializer.toJson<String?>(installationId),
      'enabled': serializer.toJson<bool>(enabled),
      'leadMinutes': serializer.toJson<int>(leadMinutes),
    };
  }

  ReminderRule copyWith({
    String? id,
    ReminderKind? kind,
    Value<String?> taskId = const Value.absent(),
    Value<String?> seriesId = const Value.absent(),
    Value<String?> workId = const Value.absent(),
    Value<String?> installationId = const Value.absent(),
    bool? enabled,
    int? leadMinutes,
  }) => ReminderRule(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    taskId: taskId.present ? taskId.value : this.taskId,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    workId: workId.present ? workId.value : this.workId,
    installationId: installationId.present
        ? installationId.value
        : this.installationId,
    enabled: enabled ?? this.enabled,
    leadMinutes: leadMinutes ?? this.leadMinutes,
  );
  ReminderRule copyWithCompanion(ReminderRulesCompanion data) {
    return ReminderRule(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      workId: data.workId.present ? data.workId.value : this.workId,
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      leadMinutes: data.leadMinutes.present
          ? data.leadMinutes.value
          : this.leadMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRule(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('taskId: $taskId, ')
          ..write('seriesId: $seriesId, ')
          ..write('workId: $workId, ')
          ..write('installationId: $installationId, ')
          ..write('enabled: $enabled, ')
          ..write('leadMinutes: $leadMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    taskId,
    seriesId,
    workId,
    installationId,
    enabled,
    leadMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRule &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.taskId == this.taskId &&
          other.seriesId == this.seriesId &&
          other.workId == this.workId &&
          other.installationId == this.installationId &&
          other.enabled == this.enabled &&
          other.leadMinutes == this.leadMinutes);
}

class ReminderRulesCompanion extends UpdateCompanion<ReminderRule> {
  final Value<String> id;
  final Value<ReminderKind> kind;
  final Value<String?> taskId;
  final Value<String?> seriesId;
  final Value<String?> workId;
  final Value<String?> installationId;
  final Value<bool> enabled;
  final Value<int> leadMinutes;
  final Value<int> rowid;
  const ReminderRulesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.taskId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.workId = const Value.absent(),
    this.installationId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.leadMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderRulesCompanion.insert({
    required String id,
    required ReminderKind kind,
    this.taskId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.workId = const Value.absent(),
    this.installationId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.leadMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind);
  static Insertable<ReminderRule> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? taskId,
    Expression<String>? seriesId,
    Expression<String>? workId,
    Expression<String>? installationId,
    Expression<bool>? enabled,
    Expression<int>? leadMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (taskId != null) 'task_id': taskId,
      if (seriesId != null) 'series_id': seriesId,
      if (workId != null) 'work_id': workId,
      if (installationId != null) 'installation_id': installationId,
      if (enabled != null) 'enabled': enabled,
      if (leadMinutes != null) 'lead_minutes': leadMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderRulesCompanion copyWith({
    Value<String>? id,
    Value<ReminderKind>? kind,
    Value<String?>? taskId,
    Value<String?>? seriesId,
    Value<String?>? workId,
    Value<String?>? installationId,
    Value<bool>? enabled,
    Value<int>? leadMinutes,
    Value<int>? rowid,
  }) {
    return ReminderRulesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      taskId: taskId ?? this.taskId,
      seriesId: seriesId ?? this.seriesId,
      workId: workId ?? this.workId,
      installationId: installationId ?? this.installationId,
      enabled: enabled ?? this.enabled,
      leadMinutes: leadMinutes ?? this.leadMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ReminderRulesTable.$converterkind.toSql(kind.value),
      );
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (workId.present) {
      map['work_id'] = Variable<String>(workId.value);
    }
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (leadMinutes.present) {
      map['lead_minutes'] = Variable<int>(leadMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRulesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('taskId: $taskId, ')
          ..write('seriesId: $seriesId, ')
          ..write('workId: $workId, ')
          ..write('installationId: $installationId, ')
          ..write('enabled: $enabled, ')
          ..write('leadMinutes: $leadMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderRegistrationsTable extends ReminderRegistrations
    with TableInfo<$ReminderRegistrationsTable, ReminderRegistration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderRegistrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminder_rules (id)',
    ),
  );
  static const VerificationMeta _identityKeyMeta = const VerificationMeta(
    'identityKey',
  );
  @override
  late final GeneratedColumn<String> identityKey = GeneratedColumn<String>(
    'identity_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(notification_id)='integer' AND notification_id BETWEEN 1000000 AND 2147483000",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _originalDateMeta = const VerificationMeta(
    'originalDate',
  );
  @override
  late final GeneratedColumn<String> originalDate = GeneratedColumn<String>(
    'original_date',
    aliasedName,
    true,
    check: () => CustomExpression(validDateSql('original_date')),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES focus_sessions (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> sourceUtc =
      GeneratedColumn<int>(
        'source_utc',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $ReminderRegistrationsTable.$convertersourceUtc,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> dueUtc =
      GeneratedColumn<int>(
        'due_utc',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReminderRegistrationsTable.$converterdueUtc);
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RegistrationState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        check: () => const CustomExpression(
          "state IN ('pending','scheduled','cancelled','elapsed','scheduleFailed','cancelFailed')",
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RegistrationState>(
        $ReminderRegistrationsTable.$converterstate,
      );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> registeredAtUtc =
      GeneratedColumn<int>(
        'registered_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $ReminderRegistrationsTable.$converterregisteredAtUtcn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> openedAtUtc =
      GeneratedColumn<int>(
        'opened_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $ReminderRegistrationsTable.$converteropenedAtUtcn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ruleId,
    identityKey,
    notificationId,
    originalDate,
    sessionId,
    sourceUtc,
    dueUtc,
    fingerprint,
    state,
    error,
    registeredAtUtc,
    openedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_registrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRegistration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('identity_key')) {
      context.handle(
        _identityKeyMeta,
        identityKey.isAcceptableOrUnknown(
          data['identity_key']!,
          _identityKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_identityKeyMeta);
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('original_date')) {
      context.handle(
        _originalDateMeta,
        originalDate.isAcceptableOrUnknown(
          data['original_date']!,
          _originalDateMeta,
        ),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRegistration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRegistration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      identityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity_key'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
      originalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_date'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      sourceUtc: $ReminderRegistrationsTable.$convertersourceUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}source_utc'],
        )!,
      ),
      dueUtc: $ReminderRegistrationsTable.$converterdueUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}due_utc'],
        )!,
      ),
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      state: $ReminderRegistrationsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      registeredAtUtc: $ReminderRegistrationsTable.$converterregisteredAtUtcn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}registered_at_utc'],
            ),
          ),
      openedAtUtc: $ReminderRegistrationsTable.$converteropenedAtUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}opened_at_utc'],
        ),
      ),
    );
  }

  @override
  $ReminderRegistrationsTable createAlias(String alias) {
    return $ReminderRegistrationsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertersourceUtc =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterdueUtc =
      const UtcInstantConverter();
  static JsonTypeConverter2<RegistrationState, String, String> $converterstate =
      const EnumNameConverter<RegistrationState>(RegistrationState.values);
  static TypeConverter<DateTime, int> $converterregisteredAtUtc =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converterregisteredAtUtcn =
      NullAwareTypeConverter.wrap($converterregisteredAtUtc);
  static TypeConverter<DateTime, int> $converteropenedAtUtc =
      const UtcInstantConverter();
  static TypeConverter<DateTime?, int?> $converteropenedAtUtcn =
      NullAwareTypeConverter.wrap($converteropenedAtUtc);
}

class ReminderRegistration extends DataClass
    implements Insertable<ReminderRegistration> {
  final String id;
  final String ruleId;
  final String identityKey;
  final int notificationId;
  final String? originalDate;
  final String? sessionId;
  final DateTime sourceUtc;
  final DateTime dueUtc;
  final String fingerprint;
  final RegistrationState state;
  final String? error;
  final DateTime? registeredAtUtc;
  final DateTime? openedAtUtc;
  const ReminderRegistration({
    required this.id,
    required this.ruleId,
    required this.identityKey,
    required this.notificationId,
    this.originalDate,
    this.sessionId,
    required this.sourceUtc,
    required this.dueUtc,
    required this.fingerprint,
    required this.state,
    this.error,
    this.registeredAtUtc,
    this.openedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rule_id'] = Variable<String>(ruleId);
    map['identity_key'] = Variable<String>(identityKey);
    map['notification_id'] = Variable<int>(notificationId);
    if (!nullToAbsent || originalDate != null) {
      map['original_date'] = Variable<String>(originalDate);
    }
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    {
      map['source_utc'] = Variable<int>(
        $ReminderRegistrationsTable.$convertersourceUtc.toSql(sourceUtc),
      );
    }
    {
      map['due_utc'] = Variable<int>(
        $ReminderRegistrationsTable.$converterdueUtc.toSql(dueUtc),
      );
    }
    map['fingerprint'] = Variable<String>(fingerprint);
    {
      map['state'] = Variable<String>(
        $ReminderRegistrationsTable.$converterstate.toSql(state),
      );
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || registeredAtUtc != null) {
      map['registered_at_utc'] = Variable<int>(
        $ReminderRegistrationsTable.$converterregisteredAtUtcn.toSql(
          registeredAtUtc,
        ),
      );
    }
    if (!nullToAbsent || openedAtUtc != null) {
      map['opened_at_utc'] = Variable<int>(
        $ReminderRegistrationsTable.$converteropenedAtUtcn.toSql(openedAtUtc),
      );
    }
    return map;
  }

  ReminderRegistrationsCompanion toCompanion(bool nullToAbsent) {
    return ReminderRegistrationsCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      identityKey: Value(identityKey),
      notificationId: Value(notificationId),
      originalDate: originalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(originalDate),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      sourceUtc: Value(sourceUtc),
      dueUtc: Value(dueUtc),
      fingerprint: Value(fingerprint),
      state: Value(state),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      registeredAtUtc: registeredAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(registeredAtUtc),
      openedAtUtc: openedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(openedAtUtc),
    );
  }

  factory ReminderRegistration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRegistration(
      id: serializer.fromJson<String>(json['id']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      identityKey: serializer.fromJson<String>(json['identityKey']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
      originalDate: serializer.fromJson<String?>(json['originalDate']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      sourceUtc: serializer.fromJson<DateTime>(json['sourceUtc']),
      dueUtc: serializer.fromJson<DateTime>(json['dueUtc']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      state: $ReminderRegistrationsTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      error: serializer.fromJson<String?>(json['error']),
      registeredAtUtc: serializer.fromJson<DateTime?>(json['registeredAtUtc']),
      openedAtUtc: serializer.fromJson<DateTime?>(json['openedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ruleId': serializer.toJson<String>(ruleId),
      'identityKey': serializer.toJson<String>(identityKey),
      'notificationId': serializer.toJson<int>(notificationId),
      'originalDate': serializer.toJson<String?>(originalDate),
      'sessionId': serializer.toJson<String?>(sessionId),
      'sourceUtc': serializer.toJson<DateTime>(sourceUtc),
      'dueUtc': serializer.toJson<DateTime>(dueUtc),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'state': serializer.toJson<String>(
        $ReminderRegistrationsTable.$converterstate.toJson(state),
      ),
      'error': serializer.toJson<String?>(error),
      'registeredAtUtc': serializer.toJson<DateTime?>(registeredAtUtc),
      'openedAtUtc': serializer.toJson<DateTime?>(openedAtUtc),
    };
  }

  ReminderRegistration copyWith({
    String? id,
    String? ruleId,
    String? identityKey,
    int? notificationId,
    Value<String?> originalDate = const Value.absent(),
    Value<String?> sessionId = const Value.absent(),
    DateTime? sourceUtc,
    DateTime? dueUtc,
    String? fingerprint,
    RegistrationState? state,
    Value<String?> error = const Value.absent(),
    Value<DateTime?> registeredAtUtc = const Value.absent(),
    Value<DateTime?> openedAtUtc = const Value.absent(),
  }) => ReminderRegistration(
    id: id ?? this.id,
    ruleId: ruleId ?? this.ruleId,
    identityKey: identityKey ?? this.identityKey,
    notificationId: notificationId ?? this.notificationId,
    originalDate: originalDate.present ? originalDate.value : this.originalDate,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    sourceUtc: sourceUtc ?? this.sourceUtc,
    dueUtc: dueUtc ?? this.dueUtc,
    fingerprint: fingerprint ?? this.fingerprint,
    state: state ?? this.state,
    error: error.present ? error.value : this.error,
    registeredAtUtc: registeredAtUtc.present
        ? registeredAtUtc.value
        : this.registeredAtUtc,
    openedAtUtc: openedAtUtc.present ? openedAtUtc.value : this.openedAtUtc,
  );
  ReminderRegistration copyWithCompanion(ReminderRegistrationsCompanion data) {
    return ReminderRegistration(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      identityKey: data.identityKey.present
          ? data.identityKey.value
          : this.identityKey,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      originalDate: data.originalDate.present
          ? data.originalDate.value
          : this.originalDate,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      sourceUtc: data.sourceUtc.present ? data.sourceUtc.value : this.sourceUtc,
      dueUtc: data.dueUtc.present ? data.dueUtc.value : this.dueUtc,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      state: data.state.present ? data.state.value : this.state,
      error: data.error.present ? data.error.value : this.error,
      registeredAtUtc: data.registeredAtUtc.present
          ? data.registeredAtUtc.value
          : this.registeredAtUtc,
      openedAtUtc: data.openedAtUtc.present
          ? data.openedAtUtc.value
          : this.openedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRegistration(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('identityKey: $identityKey, ')
          ..write('notificationId: $notificationId, ')
          ..write('originalDate: $originalDate, ')
          ..write('sessionId: $sessionId, ')
          ..write('sourceUtc: $sourceUtc, ')
          ..write('dueUtc: $dueUtc, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('registeredAtUtc: $registeredAtUtc, ')
          ..write('openedAtUtc: $openedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ruleId,
    identityKey,
    notificationId,
    originalDate,
    sessionId,
    sourceUtc,
    dueUtc,
    fingerprint,
    state,
    error,
    registeredAtUtc,
    openedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRegistration &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.identityKey == this.identityKey &&
          other.notificationId == this.notificationId &&
          other.originalDate == this.originalDate &&
          other.sessionId == this.sessionId &&
          other.sourceUtc == this.sourceUtc &&
          other.dueUtc == this.dueUtc &&
          other.fingerprint == this.fingerprint &&
          other.state == this.state &&
          other.error == this.error &&
          other.registeredAtUtc == this.registeredAtUtc &&
          other.openedAtUtc == this.openedAtUtc);
}

class ReminderRegistrationsCompanion
    extends UpdateCompanion<ReminderRegistration> {
  final Value<String> id;
  final Value<String> ruleId;
  final Value<String> identityKey;
  final Value<int> notificationId;
  final Value<String?> originalDate;
  final Value<String?> sessionId;
  final Value<DateTime> sourceUtc;
  final Value<DateTime> dueUtc;
  final Value<String> fingerprint;
  final Value<RegistrationState> state;
  final Value<String?> error;
  final Value<DateTime?> registeredAtUtc;
  final Value<DateTime?> openedAtUtc;
  final Value<int> rowid;
  const ReminderRegistrationsCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.identityKey = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.originalDate = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.sourceUtc = const Value.absent(),
    this.dueUtc = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.state = const Value.absent(),
    this.error = const Value.absent(),
    this.registeredAtUtc = const Value.absent(),
    this.openedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderRegistrationsCompanion.insert({
    required String id,
    required String ruleId,
    required String identityKey,
    required int notificationId,
    this.originalDate = const Value.absent(),
    this.sessionId = const Value.absent(),
    required DateTime sourceUtc,
    required DateTime dueUtc,
    required String fingerprint,
    required RegistrationState state,
    this.error = const Value.absent(),
    this.registeredAtUtc = const Value.absent(),
    this.openedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ruleId = Value(ruleId),
       identityKey = Value(identityKey),
       notificationId = Value(notificationId),
       sourceUtc = Value(sourceUtc),
       dueUtc = Value(dueUtc),
       fingerprint = Value(fingerprint),
       state = Value(state);
  static Insertable<ReminderRegistration> custom({
    Expression<String>? id,
    Expression<String>? ruleId,
    Expression<String>? identityKey,
    Expression<int>? notificationId,
    Expression<String>? originalDate,
    Expression<String>? sessionId,
    Expression<int>? sourceUtc,
    Expression<int>? dueUtc,
    Expression<String>? fingerprint,
    Expression<String>? state,
    Expression<String>? error,
    Expression<int>? registeredAtUtc,
    Expression<int>? openedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (identityKey != null) 'identity_key': identityKey,
      if (notificationId != null) 'notification_id': notificationId,
      if (originalDate != null) 'original_date': originalDate,
      if (sessionId != null) 'session_id': sessionId,
      if (sourceUtc != null) 'source_utc': sourceUtc,
      if (dueUtc != null) 'due_utc': dueUtc,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (state != null) 'state': state,
      if (error != null) 'error': error,
      if (registeredAtUtc != null) 'registered_at_utc': registeredAtUtc,
      if (openedAtUtc != null) 'opened_at_utc': openedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderRegistrationsCompanion copyWith({
    Value<String>? id,
    Value<String>? ruleId,
    Value<String>? identityKey,
    Value<int>? notificationId,
    Value<String?>? originalDate,
    Value<String?>? sessionId,
    Value<DateTime>? sourceUtc,
    Value<DateTime>? dueUtc,
    Value<String>? fingerprint,
    Value<RegistrationState>? state,
    Value<String?>? error,
    Value<DateTime?>? registeredAtUtc,
    Value<DateTime?>? openedAtUtc,
    Value<int>? rowid,
  }) {
    return ReminderRegistrationsCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      identityKey: identityKey ?? this.identityKey,
      notificationId: notificationId ?? this.notificationId,
      originalDate: originalDate ?? this.originalDate,
      sessionId: sessionId ?? this.sessionId,
      sourceUtc: sourceUtc ?? this.sourceUtc,
      dueUtc: dueUtc ?? this.dueUtc,
      fingerprint: fingerprint ?? this.fingerprint,
      state: state ?? this.state,
      error: error ?? this.error,
      registeredAtUtc: registeredAtUtc ?? this.registeredAtUtc,
      openedAtUtc: openedAtUtc ?? this.openedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (identityKey.present) {
      map['identity_key'] = Variable<String>(identityKey.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (originalDate.present) {
      map['original_date'] = Variable<String>(originalDate.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (sourceUtc.present) {
      map['source_utc'] = Variable<int>(
        $ReminderRegistrationsTable.$convertersourceUtc.toSql(sourceUtc.value),
      );
    }
    if (dueUtc.present) {
      map['due_utc'] = Variable<int>(
        $ReminderRegistrationsTable.$converterdueUtc.toSql(dueUtc.value),
      );
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $ReminderRegistrationsTable.$converterstate.toSql(state.value),
      );
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (registeredAtUtc.present) {
      map['registered_at_utc'] = Variable<int>(
        $ReminderRegistrationsTable.$converterregisteredAtUtcn.toSql(
          registeredAtUtc.value,
        ),
      );
    }
    if (openedAtUtc.present) {
      map['opened_at_utc'] = Variable<int>(
        $ReminderRegistrationsTable.$converteropenedAtUtcn.toSql(
          openedAtUtc.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRegistrationsCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('identityKey: $identityKey, ')
          ..write('notificationId: $notificationId, ')
          ..write('originalDate: $originalDate, ')
          ..write('sessionId: $sessionId, ')
          ..write('sourceUtc: $sourceUtc, ')
          ..write('dueUtc: $dueUtc, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('registeredAtUtc: $registeredAtUtc, ')
          ..write('openedAtUtc: $openedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeeklyReflectionsTable extends WeeklyReflections
    with TableInfo<$WeeklyReflectionsTable, WeeklyReflection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyReflectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression(uuidCheckSql),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> weekStart =
      GeneratedColumn<String>(
        'week_start',
        aliasedName,
        false,
        check: () => CustomExpression(
          "(${validDateSql('week_start')}) AND strftime('%w',week_start) = '1'",
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      ).withConverter<CalendarDate>(
        $WeeklyReflectionsTable.$converterweekStart,
      );
  static const VerificationMeta _helpedMeta = const VerificationMeta('helped');
  @override
  late final GeneratedColumn<String> helped = GeneratedColumn<String>(
    'helped',
    aliasedName,
    false,
    check: () => const CustomExpression('length(helped) <= 5000'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _obstaclesMeta = const VerificationMeta(
    'obstacles',
  );
  @override
  late final GeneratedColumn<String> obstacles = GeneratedColumn<String>(
    'obstacles',
    aliasedName,
    false,
    check: () => const CustomExpression('length(obstacles) <= 5000'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adjustmentMeta = const VerificationMeta(
    'adjustment',
  );
  @override
  late final GeneratedColumn<String> adjustment = GeneratedColumn<String>(
    'adjustment',
    aliasedName,
    false,
    check: () => const CustomExpression('length(adjustment) <= 5000'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($WeeklyReflectionsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($WeeklyReflectionsTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weekStart,
    helped,
    obstacles,
    adjustment,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_reflections';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyReflection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('helped')) {
      context.handle(
        _helpedMeta,
        helped.isAcceptableOrUnknown(data['helped']!, _helpedMeta),
      );
    } else if (isInserting) {
      context.missing(_helpedMeta);
    }
    if (data.containsKey('obstacles')) {
      context.handle(
        _obstaclesMeta,
        obstacles.isAcceptableOrUnknown(data['obstacles']!, _obstaclesMeta),
      );
    } else if (isInserting) {
      context.missing(_obstaclesMeta);
    }
    if (data.containsKey('adjustment')) {
      context.handle(
        _adjustmentMeta,
        adjustment.isAcceptableOrUnknown(data['adjustment']!, _adjustmentMeta),
      );
    } else if (isInserting) {
      context.missing(_adjustmentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeeklyReflection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyReflection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      weekStart: $WeeklyReflectionsTable.$converterweekStart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}week_start'],
        )!,
      ),
      helped: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}helped'],
      )!,
      obstacles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}obstacles'],
      )!,
      adjustment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adjustment'],
      )!,
      createdAt: $WeeklyReflectionsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $WeeklyReflectionsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $WeeklyReflectionsTable createAlias(String alias) {
    return $WeeklyReflectionsTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converterweekStart =
      const CalendarDateConverter();
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcInstantConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcInstantConverter();
}

class WeeklyReflection extends DataClass
    implements Insertable<WeeklyReflection> {
  final String id;
  final CalendarDate weekStart;
  final String helped;
  final String obstacles;
  final String adjustment;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WeeklyReflection({
    required this.id,
    required this.weekStart,
    required this.helped,
    required this.obstacles,
    required this.adjustment,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['week_start'] = Variable<String>(
        $WeeklyReflectionsTable.$converterweekStart.toSql(weekStart),
      );
    }
    map['helped'] = Variable<String>(helped);
    map['obstacles'] = Variable<String>(obstacles);
    map['adjustment'] = Variable<String>(adjustment);
    {
      map['created_at'] = Variable<int>(
        $WeeklyReflectionsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $WeeklyReflectionsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  WeeklyReflectionsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyReflectionsCompanion(
      id: Value(id),
      weekStart: Value(weekStart),
      helped: Value(helped),
      obstacles: Value(obstacles),
      adjustment: Value(adjustment),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WeeklyReflection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyReflection(
      id: serializer.fromJson<String>(json['id']),
      weekStart: serializer.fromJson<CalendarDate>(json['weekStart']),
      helped: serializer.fromJson<String>(json['helped']),
      obstacles: serializer.fromJson<String>(json['obstacles']),
      adjustment: serializer.fromJson<String>(json['adjustment']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'weekStart': serializer.toJson<CalendarDate>(weekStart),
      'helped': serializer.toJson<String>(helped),
      'obstacles': serializer.toJson<String>(obstacles),
      'adjustment': serializer.toJson<String>(adjustment),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WeeklyReflection copyWith({
    String? id,
    CalendarDate? weekStart,
    String? helped,
    String? obstacles,
    String? adjustment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WeeklyReflection(
    id: id ?? this.id,
    weekStart: weekStart ?? this.weekStart,
    helped: helped ?? this.helped,
    obstacles: obstacles ?? this.obstacles,
    adjustment: adjustment ?? this.adjustment,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WeeklyReflection copyWithCompanion(WeeklyReflectionsCompanion data) {
    return WeeklyReflection(
      id: data.id.present ? data.id.value : this.id,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      helped: data.helped.present ? data.helped.value : this.helped,
      obstacles: data.obstacles.present ? data.obstacles.value : this.obstacles,
      adjustment: data.adjustment.present
          ? data.adjustment.value
          : this.adjustment,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyReflection(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('helped: $helped, ')
          ..write('obstacles: $obstacles, ')
          ..write('adjustment: $adjustment, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weekStart,
    helped,
    obstacles,
    adjustment,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyReflection &&
          other.id == this.id &&
          other.weekStart == this.weekStart &&
          other.helped == this.helped &&
          other.obstacles == this.obstacles &&
          other.adjustment == this.adjustment &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeeklyReflectionsCompanion extends UpdateCompanion<WeeklyReflection> {
  final Value<String> id;
  final Value<CalendarDate> weekStart;
  final Value<String> helped;
  final Value<String> obstacles;
  final Value<String> adjustment;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WeeklyReflectionsCompanion({
    this.id = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.helped = const Value.absent(),
    this.obstacles = const Value.absent(),
    this.adjustment = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeeklyReflectionsCompanion.insert({
    required String id,
    required CalendarDate weekStart,
    required String helped,
    required String obstacles,
    required String adjustment,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       weekStart = Value(weekStart),
       helped = Value(helped),
       obstacles = Value(obstacles),
       adjustment = Value(adjustment),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WeeklyReflection> custom({
    Expression<String>? id,
    Expression<String>? weekStart,
    Expression<String>? helped,
    Expression<String>? obstacles,
    Expression<String>? adjustment,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekStart != null) 'week_start': weekStart,
      if (helped != null) 'helped': helped,
      if (obstacles != null) 'obstacles': obstacles,
      if (adjustment != null) 'adjustment': adjustment,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeeklyReflectionsCompanion copyWith({
    Value<String>? id,
    Value<CalendarDate>? weekStart,
    Value<String>? helped,
    Value<String>? obstacles,
    Value<String>? adjustment,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WeeklyReflectionsCompanion(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      helped: helped ?? this.helped,
      obstacles: obstacles ?? this.obstacles,
      adjustment: adjustment ?? this.adjustment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<String>(
        $WeeklyReflectionsTable.$converterweekStart.toSql(weekStart.value),
      );
    }
    if (helped.present) {
      map['helped'] = Variable<String>(helped.value);
    }
    if (obstacles.present) {
      map['obstacles'] = Variable<String>(obstacles.value);
    }
    if (adjustment.present) {
      map['adjustment'] = Variable<String>(adjustment.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $WeeklyReflectionsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $WeeklyReflectionsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyReflectionsCompanion(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('helped: $helped, ')
          ..write('obstacles: $obstacles, ')
          ..write('adjustment: $adjustment, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationCleanupRowsTable extends NotificationCleanupRows
    with TableInfo<$NotificationCleanupRowsTable, NotificationCleanupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationCleanupRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "typeof(notification_id)='integer' AND notification_id BETWEEN 1000000 AND 2147483000",
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [notificationId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_cleanup_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationCleanupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {notificationId};
  @override
  NotificationCleanupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationCleanupRow(
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
    );
  }

  @override
  $NotificationCleanupRowsTable createAlias(String alias) {
    return $NotificationCleanupRowsTable(attachedDatabase, alias);
  }
}

class NotificationCleanupRow extends DataClass
    implements Insertable<NotificationCleanupRow> {
  final int notificationId;
  const NotificationCleanupRow({required this.notificationId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['notification_id'] = Variable<int>(notificationId);
    return map;
  }

  NotificationCleanupRowsCompanion toCompanion(bool nullToAbsent) {
    return NotificationCleanupRowsCompanion(
      notificationId: Value(notificationId),
    );
  }

  factory NotificationCleanupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationCleanupRow(
      notificationId: serializer.fromJson<int>(json['notificationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'notificationId': serializer.toJson<int>(notificationId),
    };
  }

  NotificationCleanupRow copyWith({int? notificationId}) =>
      NotificationCleanupRow(
        notificationId: notificationId ?? this.notificationId,
      );
  NotificationCleanupRow copyWithCompanion(
    NotificationCleanupRowsCompanion data,
  ) {
    return NotificationCleanupRow(
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationCleanupRow(')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => notificationId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationCleanupRow &&
          other.notificationId == this.notificationId);
}

class NotificationCleanupRowsCompanion
    extends UpdateCompanion<NotificationCleanupRow> {
  final Value<int> notificationId;
  const NotificationCleanupRowsCompanion({
    this.notificationId = const Value.absent(),
  });
  NotificationCleanupRowsCompanion.insert({
    this.notificationId = const Value.absent(),
  });
  static Insertable<NotificationCleanupRow> custom({
    Expression<int>? notificationId,
  }) {
    return RawValuesInsertable({
      if (notificationId != null) 'notification_id': notificationId,
    });
  }

  NotificationCleanupRowsCompanion copyWith({Value<int>? notificationId}) {
    return NotificationCleanupRowsCompanion(
      notificationId: notificationId ?? this.notificationId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationCleanupRowsCompanion(')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $SubtasksTable subtasks = $SubtasksTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $NoteTaskLinksTable noteTaskLinks = $NoteTaskLinksTable(this);
  late final $DailyPrioritiesTable dailyPriorities = $DailyPrioritiesTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $InstallationsTable installations = $InstallationsTable(this);
  late final $ActivitySeriesRowsTable activitySeriesRows =
      $ActivitySeriesRowsTable(this);
  late final $ActivityExceptionsTable activityExceptions =
      $ActivityExceptionsTable(this);
  late final $NoteActivityLinksTable noteActivityLinks =
      $NoteActivityLinksTable(this);
  late final $PlannedWorkBlocksTable plannedWorkBlocks =
      $PlannedWorkBlocksTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $FocusSegmentsTable focusSegments = $FocusSegmentsTable(this);
  late final $TimerCommandReceiptsTable timerCommandReceipts =
      $TimerCommandReceiptsTable(this);
  late final $ReminderPreferencesRowsTable reminderPreferencesRows =
      $ReminderPreferencesRowsTable(this);
  late final $ReminderRulesTable reminderRules = $ReminderRulesTable(this);
  late final $ReminderRegistrationsTable reminderRegistrations =
      $ReminderRegistrationsTable(this);
  late final $WeeklyReflectionsTable weeklyReflections =
      $WeeklyReflectionsTable(this);
  late final $NotificationCleanupRowsTable notificationCleanupRows =
      $NotificationCleanupRowsTable(this);
  late final Index coursesVisibility = Index(
    'courses_visibility',
    'CREATE INDEX courses_visibility ON courses (deleted_at, archived_at)',
  );
  late final Index tasksCourse = Index(
    'tasks_course',
    'CREATE INDEX tasks_course ON tasks (course_id)',
  );
  late final Index tasksStatusUpdated = Index(
    'tasks_status_updated',
    'CREATE INDEX tasks_status_updated ON tasks (deleted_at, status, updated_at)',
  );
  late final Index tasksDeadline = Index(
    'tasks_deadline',
    'CREATE INDEX tasks_deadline ON tasks (deleted_at, deadline_boundary_utc)',
  );
  late final Index tasksVisibility = Index(
    'tasks_visibility',
    'CREATE INDEX tasks_visibility ON tasks (deleted_at, archived_at)',
  );
  late final Index subtasksTaskOrder = Index(
    'subtasks_task_order',
    'CREATE INDEX subtasks_task_order ON subtasks (task_id, deleted_at, position)',
  );
  late final Index notesCourse = Index(
    'notes_course',
    'CREATE INDEX notes_course ON notes (course_id)',
  );
  late final Index notesVisibilityUpdated = Index(
    'notes_visibility_updated',
    'CREATE INDEX notes_visibility_updated ON notes (deleted_at, pinned, updated_at)',
  );
  late final Index noteLinksTask = Index(
    'note_links_task',
    'CREATE INDEX note_links_task ON note_task_links (task_id)',
  );
  late final Index dailyPrioritiesTask = Index(
    'daily_priorities_task',
    'CREATE INDEX daily_priorities_task ON daily_priorities (task_id)',
  );
  late final Index activitiesCourse = Index(
    'activities_course',
    'CREATE INDEX activities_course ON activity_series (course_id)',
  );
  late final Index activitiesDates = Index(
    'activities_dates',
    'CREATE INDEX activities_dates ON activity_series (start_date, end_date)',
  );
  late final Index activityExceptionsMoved = Index(
    'activity_exceptions_moved',
    'CREATE INDEX activity_exceptions_moved ON activity_exceptions (moved_date)',
  );
  late final Index noteActivityPair = Index(
    'note_activity_pair',
    'CREATE UNIQUE INDEX note_activity_pair ON note_activity_links (note_id, series_id, COALESCE(original_date, \'\'))',
  );
  late final Index noteActivityTarget = Index(
    'note_activity_target',
    'CREATE INDEX note_activity_target ON note_activity_links (series_id, original_date)',
  );
  late final Index workBlocksRange = Index(
    'work_blocks_range',
    'CREATE INDEX work_blocks_range ON planned_work_blocks (deleted_at, start_utc, end_utc)',
  );
  late final Index workBlocksTask = Index(
    'work_blocks_task',
    'CREATE INDEX work_blocks_task ON planned_work_blocks (task_id, deleted_at)',
  );
  late final Index oneUnfinishedSession = Index(
    'one_unfinished_session',
    'CREATE UNIQUE INDEX one_unfinished_session ON focus_sessions (installation_id) WHERE state != \'finalized\'',
  );
  late final Index sessionsStarted = Index(
    'sessions_started',
    'CREATE INDEX sessions_started ON focus_sessions (local_start_date, started_utc)',
  );
  late final Index segmentsSessionOrder = Index(
    'segments_session_order',
    'CREATE INDEX segments_session_order ON focus_segments (session_id, sequence)',
  );
  late final Index timerCommandsSession = Index(
    'timer_commands_session',
    'CREATE INDEX timer_commands_session ON timer_command_receipts (session_id)',
  );
  late final Index remindersDue = Index(
    'reminders_due',
    'CREATE INDEX reminders_due ON reminder_registrations (due_utc, state)',
  );
  late final Index remindersRule = Index(
    'reminders_rule',
    'CREATE INDEX reminders_rule ON reminder_registrations (rule_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    courses,
    tasks,
    subtasks,
    notes,
    noteTaskLinks,
    dailyPriorities,
    appSettings,
    installations,
    activitySeriesRows,
    activityExceptions,
    noteActivityLinks,
    plannedWorkBlocks,
    focusSessions,
    focusSegments,
    timerCommandReceipts,
    reminderPreferencesRows,
    reminderRules,
    reminderRegistrations,
    weeklyReflections,
    notificationCleanupRows,
    coursesVisibility,
    tasksCourse,
    tasksStatusUpdated,
    tasksDeadline,
    tasksVisibility,
    subtasksTaskOrder,
    notesCourse,
    notesVisibilityUpdated,
    noteLinksTask,
    dailyPrioritiesTask,
    activitiesCourse,
    activitiesDates,
    activityExceptionsMoved,
    noteActivityPair,
    noteActivityTarget,
    workBlocksRange,
    workBlocksTask,
    oneUnfinishedSession,
    sessionsStarted,
    segmentsSessionOrder,
    timerCommandsSession,
    remindersDue,
    remindersRule,
  ];
}

typedef $$CoursesTableCreateCompanionBuilder = CoursesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String name,
  Value<String?> color,
  Value<CalendarDate?> termStart,
  Value<CalendarDate?> termEnd,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$CoursesTableUpdateCompanionBuilder = CoursesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> name,
  Value<String?> color,
  Value<CalendarDate?> termStart,
  Value<CalendarDate?> termEnd,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$CoursesTableReferences
    extends BaseReferences<_$AppDatabase, $CoursesTable, Course> {
  $$CoursesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'courses__id__tasks__course_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.courseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: 'courses__id__notes__course_id',
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.courseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivitySeriesRowsTable, List<ActivitySeries>>
  _activitySeriesRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activitySeriesRows,
        aliasName: 'courses__id__activity_series__course_id',
      );

  $$ActivitySeriesRowsTableProcessedTableManager get activitySeriesRowsRefs {
    final manager = $$ActivitySeriesRowsTableTableManager(
      $_db,
      $_db.activitySeriesRows,
    ).filter((f) => f.courseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activitySeriesRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get termStart => $composableBuilder(
    column: $table.termStart,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get termEnd => $composableBuilder(
    column: $table.termEnd,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activitySeriesRowsRefs(
    Expression<bool> Function($$ActivitySeriesRowsTableFilterComposer f) f,
  ) {
    final $$ActivitySeriesRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activitySeriesRows,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySeriesRowsTableFilterComposer(
            $db: $db,
            $table: $db.activitySeriesRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get termStart => $composableBuilder(
    column: $table.termStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get termEnd => $composableBuilder(
    column: $table.termEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get termStart =>
      $composableBuilder(column: $table.termStart, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get termEnd =>
      $composableBuilder(column: $table.termEnd, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => column,
      );

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activitySeriesRowsRefs<T extends Object>(
    Expression<T> Function($$ActivitySeriesRowsTableAnnotationComposer a) f,
  ) {
    final $$ActivitySeriesRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activitySeriesRows,
          getReferencedColumn: (t) => t.courseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivitySeriesRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.activitySeriesRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoursesTable,
          Course,
          $$CoursesTableFilterComposer,
          $$CoursesTableOrderingComposer,
          $$CoursesTableAnnotationComposer,
          $$CoursesTableCreateCompanionBuilder,
          $$CoursesTableUpdateCompanionBuilder,
          (Course, $$CoursesTableReferences),
          Course,
          PrefetchHooks Function({
            bool tasksRefs,
            bool notesRefs,
            bool activitySeriesRowsRefs,
          })
        > {
  $$CoursesTableTableManager(_$AppDatabase db, $CoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<CalendarDate?> termStart = const Value.absent(),
                Value<CalendarDate?> termEnd = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                color: color,
                termStart: termStart,
                termEnd: termEnd,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> color = const Value.absent(),
                Value<CalendarDate?> termStart = const Value.absent(),
                Value<CalendarDate?> termEnd = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                color: color,
                termStart: termStart,
                termEnd: termEnd,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoursesTable, Course>(table),
                  $$CoursesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tasksRefs = false,
                notesRefs = false,
                activitySeriesRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tasksRefs) db.tasks,
                    if (notesRefs) db.notes,
                    if (activitySeriesRowsRefs) db.activitySeriesRows,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tasksRefs)
                        await $_getPrefetchedData<Course, $CoursesTable, Task>(
                          currentTable: table,
                          referencedTable: $$CoursesTableReferences
                              ._tasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoursesTableReferences(db, table, p0).tasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.courseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notesRefs)
                        await $_getPrefetchedData<Course, $CoursesTable, Note>(
                          currentTable: table,
                          referencedTable: $$CoursesTableReferences
                              ._notesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoursesTableReferences(db, table, p0).notesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.courseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activitySeriesRowsRefs)
                        await $_getPrefetchedData<
                          Course,
                          $CoursesTable,
                          ActivitySeries
                        >(
                          currentTable: table,
                          referencedTable: $$CoursesTableReferences
                              ._activitySeriesRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoursesTableReferences(
                                db,
                                table,
                                p0,
                              ).activitySeriesRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.courseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoursesTable,
      Course,
      $$CoursesTableFilterComposer,
      $$CoursesTableOrderingComposer,
      $$CoursesTableAnnotationComposer,
      $$CoursesTableCreateCompanionBuilder,
      $$CoursesTableUpdateCompanionBuilder,
      (Course, $$CoursesTableReferences),
      Course,
      PrefetchHooks Function({
        bool tasksRefs,
        bool notesRefs,
        bool activitySeriesRowsRefs,
      })
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String title,
  Value<String> description,
  Value<String?> nextAction,
  Value<String?> courseId,
  required TaskStatus status,
  required TaskPriority priority,
  required DeadlineKind deadlineKind,
  Value<CalendarDate?> deadlineDate,
  Value<DateTime?> deadlineUtc,
  Value<String?> deadlineZone,
  Value<DateTime?> deadlineBoundaryUtc,
  Value<DateTime?> targetUtc,
  Value<int?> remainingMinutes,
  Value<DateTime?> completedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> title,
  Value<String> description,
  Value<String?> nextAction,
  Value<String?> courseId,
  Value<TaskStatus> status,
  Value<TaskPriority> priority,
  Value<DeadlineKind> deadlineKind,
  Value<CalendarDate?> deadlineDate,
  Value<DateTime?> deadlineUtc,
  Value<String?> deadlineZone,
  Value<DateTime?> deadlineBoundaryUtc,
  Value<DateTime?> targetUtc,
  Value<int?> remainingMinutes,
  Value<DateTime?> completedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CoursesTable _courseIdTable(_$AppDatabase db) =>
      db.courses.createAlias('tasks__course_id__courses__id');

  $$CoursesTableProcessedTableManager? get courseId {
    final $_column = $_itemColumn<String>('course_id');
    if ($_column == null) return null;
    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_courseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SubtasksTable, List<Subtask>> _subtasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.subtasks,
    aliasName: 'tasks__id__subtasks__task_id',
  );

  $$SubtasksTableProcessedTableManager get subtasksRefs {
    final manager = $$SubtasksTableTableManager(
      $_db,
      $_db.subtasks,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_subtasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NoteTaskLinksTable, List<NoteTaskLink>>
  _noteTaskLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteTaskLinks,
    aliasName: 'tasks__id__note_task_links__task_id',
  );

  $$NoteTaskLinksTableProcessedTableManager get noteTaskLinksRefs {
    final manager = $$NoteTaskLinksTableTableManager(
      $_db,
      $_db.noteTaskLinks,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteTaskLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DailyPrioritiesTable, List<DailyPriority>>
  _dailyPrioritiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyPriorities,
    aliasName: 'tasks__id__daily_priorities__task_id',
  );

  $$DailyPrioritiesTableProcessedTableManager get dailyPrioritiesRefs {
    final manager = $$DailyPrioritiesTableTableManager(
      $_db,
      $_db.dailyPriorities,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dailyPrioritiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlannedWorkBlocksTable, List<PlannedWorkBlock>>
  _plannedWorkBlocksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.plannedWorkBlocks,
        aliasName: 'tasks__id__planned_work_blocks__task_id',
      );

  $$PlannedWorkBlocksTableProcessedTableManager get plannedWorkBlocksRefs {
    final manager = $$PlannedWorkBlocksTableTableManager(
      $_db,
      $_db.plannedWorkBlocks,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plannedWorkBlocksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>>
  _focusSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: 'tasks__id__focus_sessions__task_id',
  );

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReminderRulesTable, List<ReminderRule>>
  _reminderRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderRules,
    aliasName: 'tasks__id__reminder_rules__task_id',
  );

  $$ReminderRulesTableProcessedTableManager get reminderRulesRefs {
    final manager = $$ReminderRulesTableTableManager(
      $_db,
      $_db.reminderRules,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TaskPriority, TaskPriority, String>
  get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DeadlineKind, DeadlineKind, String>
  get deadlineKind => $composableBuilder(
    column: $table.deadlineKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get deadlineDate => $composableBuilder(
    column: $table.deadlineDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deadlineUtc =>
      $composableBuilder(
        column: $table.deadlineUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get deadlineZone => $composableBuilder(
    column: $table.deadlineZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int>
  get deadlineBoundaryUtc => $composableBuilder(
    column: $table.deadlineBoundaryUtc,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get targetUtc =>
      $composableBuilder(
        column: $table.targetUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get remainingMinutes => $composableBuilder(
    column: $table.remainingMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get completedAt =>
      $composableBuilder(
        column: $table.completedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CoursesTableFilterComposer get courseId {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> subtasksRefs(
    Expression<bool> Function($$SubtasksTableFilterComposer f) f,
  ) {
    final $$SubtasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableFilterComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> noteTaskLinksRefs(
    Expression<bool> Function($$NoteTaskLinksTableFilterComposer f) f,
  ) {
    final $$NoteTaskLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTaskLinks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTaskLinksTableFilterComposer(
            $db: $db,
            $table: $db.noteTaskLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailyPrioritiesRefs(
    Expression<bool> Function($$DailyPrioritiesTableFilterComposer f) f,
  ) {
    final $$DailyPrioritiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyPriorities,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyPrioritiesTableFilterComposer(
            $db: $db,
            $table: $db.dailyPriorities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> plannedWorkBlocksRefs(
    Expression<bool> Function($$PlannedWorkBlocksTableFilterComposer f) f,
  ) {
    final $$PlannedWorkBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plannedWorkBlocks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedWorkBlocksTableFilterComposer(
            $db: $db,
            $table: $db.plannedWorkBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($$FocusSessionsTableFilterComposer f) f,
  ) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderRulesRefs(
    Expression<bool> Function($$ReminderRulesTableFilterComposer f) f,
  ) {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableFilterComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadlineKind => $composableBuilder(
    column: $table.deadlineKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadlineDate => $composableBuilder(
    column: $table.deadlineDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deadlineUtc => $composableBuilder(
    column: $table.deadlineUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadlineZone => $composableBuilder(
    column: $table.deadlineZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deadlineBoundaryUtc => $composableBuilder(
    column: $table.deadlineBoundaryUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetUtc => $composableBuilder(
    column: $table.targetUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingMinutes => $composableBuilder(
    column: $table.remainingMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoursesTableOrderingComposer get courseId {
    final $$CoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableOrderingComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TaskStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskPriority, String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DeadlineKind, String> get deadlineKind =>
      $composableBuilder(
        column: $table.deadlineKind,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get deadlineDate =>
      $composableBuilder(
        column: $table.deadlineDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get deadlineUtc =>
      $composableBuilder(
        column: $table.deadlineUtc,
        builder: (column) => column,
      );

  GeneratedColumn<String> get deadlineZone => $composableBuilder(
    column: $table.deadlineZone,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get deadlineBoundaryUtc =>
      $composableBuilder(
        column: $table.deadlineBoundaryUtc,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get targetUtc =>
      $composableBuilder(column: $table.targetUtc, builder: (column) => column);

  GeneratedColumn<int> get remainingMinutes => $composableBuilder(
    column: $table.remainingMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get completedAt =>
      $composableBuilder(
        column: $table.completedAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => column,
      );

  $$CoursesTableAnnotationComposer get courseId {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> subtasksRefs<T extends Object>(
    Expression<T> Function($$SubtasksTableAnnotationComposer a) f,
  ) {
    final $$SubtasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableAnnotationComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> noteTaskLinksRefs<T extends Object>(
    Expression<T> Function($$NoteTaskLinksTableAnnotationComposer a) f,
  ) {
    final $$NoteTaskLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTaskLinks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTaskLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTaskLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dailyPrioritiesRefs<T extends Object>(
    Expression<T> Function($$DailyPrioritiesTableAnnotationComposer a) f,
  ) {
    final $$DailyPrioritiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyPriorities,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyPrioritiesTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyPriorities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> plannedWorkBlocksRefs<T extends Object>(
    Expression<T> Function($$PlannedWorkBlocksTableAnnotationComposer a) f,
  ) {
    final $$PlannedWorkBlocksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.plannedWorkBlocks,
          getReferencedColumn: (t) => t.taskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlannedWorkBlocksTableAnnotationComposer(
                $db: $db,
                $table: $db.plannedWorkBlocks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reminderRulesRefs<T extends Object>(
    Expression<T> Function($$ReminderRulesTableAnnotationComposer a) f,
  ) {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({
            bool courseId,
            bool subtasksRefs,
            bool noteTaskLinksRefs,
            bool dailyPrioritiesRefs,
            bool plannedWorkBlocksRefs,
            bool focusSessionsRefs,
            bool reminderRulesRefs,
          })
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<String?> courseId = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<TaskPriority> priority = const Value.absent(),
                Value<DeadlineKind> deadlineKind = const Value.absent(),
                Value<CalendarDate?> deadlineDate = const Value.absent(),
                Value<DateTime?> deadlineUtc = const Value.absent(),
                Value<String?> deadlineZone = const Value.absent(),
                Value<DateTime?> deadlineBoundaryUtc = const Value.absent(),
                Value<DateTime?> targetUtc = const Value.absent(),
                Value<int?> remainingMinutes = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                title: title,
                description: description,
                nextAction: nextAction,
                courseId: courseId,
                status: status,
                priority: priority,
                deadlineKind: deadlineKind,
                deadlineDate: deadlineDate,
                deadlineUtc: deadlineUtc,
                deadlineZone: deadlineZone,
                deadlineBoundaryUtc: deadlineBoundaryUtc,
                targetUtc: targetUtc,
                remainingMinutes: remainingMinutes,
                completedAt: completedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<String?> courseId = const Value.absent(),
                required TaskStatus status,
                required TaskPriority priority,
                required DeadlineKind deadlineKind,
                Value<CalendarDate?> deadlineDate = const Value.absent(),
                Value<DateTime?> deadlineUtc = const Value.absent(),
                Value<String?> deadlineZone = const Value.absent(),
                Value<DateTime?> deadlineBoundaryUtc = const Value.absent(),
                Value<DateTime?> targetUtc = const Value.absent(),
                Value<int?> remainingMinutes = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                title: title,
                description: description,
                nextAction: nextAction,
                courseId: courseId,
                status: status,
                priority: priority,
                deadlineKind: deadlineKind,
                deadlineDate: deadlineDate,
                deadlineUtc: deadlineUtc,
                deadlineZone: deadlineZone,
                deadlineBoundaryUtc: deadlineBoundaryUtc,
                targetUtc: targetUtc,
                remainingMinutes: remainingMinutes,
                completedAt: completedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  $$TasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                courseId = false,
                subtasksRefs = false,
                noteTaskLinksRefs = false,
                dailyPrioritiesRefs = false,
                plannedWorkBlocksRefs = false,
                focusSessionsRefs = false,
                reminderRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (subtasksRefs) db.subtasks,
                    if (noteTaskLinksRefs) db.noteTaskLinks,
                    if (dailyPrioritiesRefs) db.dailyPriorities,
                    if (plannedWorkBlocksRefs) db.plannedWorkBlocks,
                    if (focusSessionsRefs) db.focusSessions,
                    if (reminderRulesRefs) db.reminderRules,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (courseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.courseId,
                            referencedTable: $$TasksTableReferences
                                ._courseIdTable(db),
                            referencedColumn: $$TasksTableReferences
                                ._courseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (subtasksRefs)
                        await $_getPrefetchedData<Task, $TasksTable, Subtask>(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._subtasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).subtasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (noteTaskLinksRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          NoteTaskLink
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._noteTaskLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).noteTaskLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dailyPrioritiesRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          DailyPriority
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._dailyPrioritiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyPrioritiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (plannedWorkBlocksRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          PlannedWorkBlock
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._plannedWorkBlocksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).plannedWorkBlocksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (focusSessionsRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          FocusSession
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._focusSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).focusSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reminderRulesRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          ReminderRule
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._reminderRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({
        bool courseId,
        bool subtasksRefs,
        bool noteTaskLinksRefs,
        bool dailyPrioritiesRefs,
        bool plannedWorkBlocksRefs,
        bool focusSessionsRefs,
        bool reminderRulesRefs,
      })
    >;
typedef $$SubtasksTableCreateCompanionBuilder = SubtasksCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String taskId,
  required String title,
  required int position,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$SubtasksTableUpdateCompanionBuilder = SubtasksCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> taskId,
  Value<String> title,
  Value<int> position,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

final class $$SubtasksTableReferences
    extends BaseReferences<_$AppDatabase, $SubtasksTable, Subtask> {
  $$SubtasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('subtasks__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>>
  _focusSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: 'subtasks__id__focus_sessions__subtask_id',
  );

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.subtaskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get completedAt =>
      $composableBuilder(
        column: $table.completedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($$FocusSessionsTableFilterComposer f) f,
  ) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.subtaskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get completedAt =>
      $composableBuilder(
        column: $table.completedAt,
        builder: (column) => column,
      );

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.subtaskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubtasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubtasksTable,
          Subtask,
          $$SubtasksTableFilterComposer,
          $$SubtasksTableOrderingComposer,
          $$SubtasksTableAnnotationComposer,
          $$SubtasksTableCreateCompanionBuilder,
          $$SubtasksTableUpdateCompanionBuilder,
          (Subtask, $$SubtasksTableReferences),
          Subtask,
          PrefetchHooks Function({bool taskId, bool focusSessionsRefs})
        > {
  $$SubtasksTableTableManager(_$AppDatabase db, $SubtasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubtasksCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                taskId: taskId,
                title: title,
                position: position,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String taskId,
                required String title,
                required int position,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubtasksCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                taskId: taskId,
                title: title,
                position: position,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubtasksTable, Subtask>(table),
                  $$SubtasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false, focusSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (focusSessionsRefs) db.focusSessions,
              ],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$SubtasksTableReferences._taskIdTable(
                          db,
                        ),
                        referencedColumn: $$SubtasksTableReferences
                            ._taskIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (focusSessionsRefs)
                    await $_getPrefetchedData<
                      Subtask,
                      $SubtasksTable,
                      FocusSession
                    >(
                      currentTable: table,
                      referencedTable: $$SubtasksTableReferences
                          ._focusSessionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$SubtasksTableReferences(
                        db,
                        table,
                        p0,
                      ).focusSessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.subtaskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SubtasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubtasksTable,
      Subtask,
      $$SubtasksTableFilterComposer,
      $$SubtasksTableOrderingComposer,
      $$SubtasksTableAnnotationComposer,
      $$SubtasksTableCreateCompanionBuilder,
      $$SubtasksTableUpdateCompanionBuilder,
      (Subtask, $$SubtasksTableReferences),
      Subtask,
      PrefetchHooks Function({bool taskId, bool focusSessionsRefs})
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String title,
  required String body,
  Value<String?> courseId,
  Value<bool> pinned,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> title,
  Value<String> body,
  Value<String?> courseId,
  Value<bool> pinned,
  Value<int> rowid,
});

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CoursesTable _courseIdTable(_$AppDatabase db) =>
      db.courses.createAlias('notes__course_id__courses__id');

  $$CoursesTableProcessedTableManager? get courseId {
    final $_column = $_itemColumn<String>('course_id');
    if ($_column == null) return null;
    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_courseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$NoteTaskLinksTable, List<NoteTaskLink>>
  _noteTaskLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteTaskLinks,
    aliasName: 'notes__id__note_task_links__note_id',
  );

  $$NoteTaskLinksTableProcessedTableManager get noteTaskLinksRefs {
    final manager = $$NoteTaskLinksTableTableManager(
      $_db,
      $_db.noteTaskLinks,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteTaskLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NoteActivityLinksTable, List<NoteActivityLink>>
  _noteActivityLinksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.noteActivityLinks,
        aliasName: 'notes__id__note_activity_links__note_id',
      );

  $$NoteActivityLinksTableProcessedTableManager get noteActivityLinksRefs {
    final manager = $$NoteActivityLinksTableTableManager(
      $_db,
      $_db.noteActivityLinks,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _noteActivityLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  $$CoursesTableFilterComposer get courseId {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> noteTaskLinksRefs(
    Expression<bool> Function($$NoteTaskLinksTableFilterComposer f) f,
  ) {
    final $$NoteTaskLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTaskLinks,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTaskLinksTableFilterComposer(
            $db: $db,
            $table: $db.noteTaskLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> noteActivityLinksRefs(
    Expression<bool> Function($$NoteActivityLinksTableFilterComposer f) f,
  ) {
    final $$NoteActivityLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteActivityLinks,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteActivityLinksTableFilterComposer(
            $db: $db,
            $table: $db.noteActivityLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoursesTableOrderingComposer get courseId {
    final $$CoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableOrderingComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  $$CoursesTableAnnotationComposer get courseId {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> noteTaskLinksRefs<T extends Object>(
    Expression<T> Function($$NoteTaskLinksTableAnnotationComposer a) f,
  ) {
    final $$NoteTaskLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTaskLinks,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTaskLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTaskLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> noteActivityLinksRefs<T extends Object>(
    Expression<T> Function($$NoteActivityLinksTableAnnotationComposer a) f,
  ) {
    final $$NoteActivityLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.noteActivityLinks,
          getReferencedColumn: (t) => t.noteId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NoteActivityLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.noteActivityLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({
            bool courseId,
            bool noteTaskLinksRefs,
            bool noteActivityLinksRefs,
          })
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> courseId = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                title: title,
                body: body,
                courseId: courseId,
                pinned: pinned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String title,
                required String body,
                Value<String?> courseId = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                title: title,
                body: body,
                courseId: courseId,
                pinned: pinned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, Note>(table),
                  $$NotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                courseId = false,
                noteTaskLinksRefs = false,
                noteActivityLinksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (noteTaskLinksRefs) db.noteTaskLinks,
                    if (noteActivityLinksRefs) db.noteActivityLinks,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (courseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.courseId,
                            referencedTable: $$NotesTableReferences
                                ._courseIdTable(db),
                            referencedColumn: $$NotesTableReferences
                                ._courseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (noteTaskLinksRefs)
                        await $_getPrefetchedData<
                          Note,
                          $NotesTable,
                          NoteTaskLink
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteTaskLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteTaskLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.noteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (noteActivityLinksRefs)
                        await $_getPrefetchedData<
                          Note,
                          $NotesTable,
                          NoteActivityLink
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteActivityLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteActivityLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.noteId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({
        bool courseId,
        bool noteTaskLinksRefs,
        bool noteActivityLinksRefs,
      })
    >;
typedef $$NoteTaskLinksTableCreateCompanionBuilder =
    NoteTaskLinksCompanion Function({
      required String id,
      required String noteId,
      required String taskId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$NoteTaskLinksTableUpdateCompanionBuilder =
    NoteTaskLinksCompanion Function({
      Value<String> id,
      Value<String> noteId,
      Value<String> taskId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$NoteTaskLinksTableReferences
    extends BaseReferences<_$AppDatabase, $NoteTaskLinksTable, NoteTaskLink> {
  $$NoteTaskLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NotesTable _noteIdTable(_$AppDatabase db) =>
      db.notes.createAlias('note_task_links__note_id__notes__id');

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<String>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('note_task_links__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteTaskLinksTableFilterComposer
    extends Composer<_$AppDatabase, $NoteTaskLinksTable> {
  $$NoteTaskLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTaskLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteTaskLinksTable> {
  $$NoteTaskLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTaskLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteTaskLinksTable> {
  $$NoteTaskLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTaskLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteTaskLinksTable,
          NoteTaskLink,
          $$NoteTaskLinksTableFilterComposer,
          $$NoteTaskLinksTableOrderingComposer,
          $$NoteTaskLinksTableAnnotationComposer,
          $$NoteTaskLinksTableCreateCompanionBuilder,
          $$NoteTaskLinksTableUpdateCompanionBuilder,
          (NoteTaskLink, $$NoteTaskLinksTableReferences),
          NoteTaskLink,
          PrefetchHooks Function({bool noteId, bool taskId})
        > {
  $$NoteTaskLinksTableTableManager(_$AppDatabase db, $NoteTaskLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteTaskLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteTaskLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteTaskLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteTaskLinksCompanion(
                id: id,
                noteId: noteId,
                taskId: taskId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String noteId,
                required String taskId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => NoteTaskLinksCompanion.insert(
                id: id,
                noteId: noteId,
                taskId: taskId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteTaskLinksTable, NoteTaskLink>(table),
                  $$NoteTaskLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false, taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.noteId,
                        referencedTable: $$NoteTaskLinksTableReferences
                            ._noteIdTable(db),
                        referencedColumn: $$NoteTaskLinksTableReferences
                            ._noteIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$NoteTaskLinksTableReferences
                            ._taskIdTable(db),
                        referencedColumn: $$NoteTaskLinksTableReferences
                            ._taskIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteTaskLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteTaskLinksTable,
      NoteTaskLink,
      $$NoteTaskLinksTableFilterComposer,
      $$NoteTaskLinksTableOrderingComposer,
      $$NoteTaskLinksTableAnnotationComposer,
      $$NoteTaskLinksTableCreateCompanionBuilder,
      $$NoteTaskLinksTableUpdateCompanionBuilder,
      (NoteTaskLink, $$NoteTaskLinksTableReferences),
      NoteTaskLink,
      PrefetchHooks Function({bool noteId, bool taskId})
    >;
typedef $$DailyPrioritiesTableCreateCompanionBuilder =
    DailyPrioritiesCompanion Function({
      required String id,
      required CalendarDate day,
      required String taskId,
      required int slot,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DailyPrioritiesTableUpdateCompanionBuilder =
    DailyPrioritiesCompanion Function({
      Value<String> id,
      Value<CalendarDate> day,
      Value<String> taskId,
      Value<int> slot,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$DailyPrioritiesTableReferences
    extends
        BaseReferences<_$AppDatabase, $DailyPrioritiesTable, DailyPriority> {
  $$DailyPrioritiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('daily_priorities__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailyPrioritiesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyPrioritiesTable> {
  $$DailyPrioritiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String> get day =>
      $composableBuilder(
        column: $table.day,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyPrioritiesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyPrioritiesTable> {
  $$DailyPrioritiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyPrioritiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyPrioritiesTable> {
  $$DailyPrioritiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyPrioritiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyPrioritiesTable,
          DailyPriority,
          $$DailyPrioritiesTableFilterComposer,
          $$DailyPrioritiesTableOrderingComposer,
          $$DailyPrioritiesTableAnnotationComposer,
          $$DailyPrioritiesTableCreateCompanionBuilder,
          $$DailyPrioritiesTableUpdateCompanionBuilder,
          (DailyPriority, $$DailyPrioritiesTableReferences),
          DailyPriority,
          PrefetchHooks Function({bool taskId})
        > {
  $$DailyPrioritiesTableTableManager(
    _$AppDatabase db,
    $DailyPrioritiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyPrioritiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyPrioritiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyPrioritiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<CalendarDate> day = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyPrioritiesCompanion(
                id: id,
                day: day,
                taskId: taskId,
                slot: slot,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required CalendarDate day,
                required String taskId,
                required int slot,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyPrioritiesCompanion.insert(
                id: id,
                day: day,
                taskId: taskId,
                slot: slot,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyPrioritiesTable, DailyPriority>(table),
                  $$DailyPrioritiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$DailyPrioritiesTableReferences
                            ._taskIdTable(db),
                        referencedColumn: $$DailyPrioritiesTableReferences
                            ._taskIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DailyPrioritiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyPrioritiesTable,
      DailyPriority,
      $$DailyPrioritiesTableFilterComposer,
      $$DailyPrioritiesTableOrderingComposer,
      $$DailyPrioritiesTableAnnotationComposer,
      $$DailyPrioritiesTableCreateCompanionBuilder,
      $$DailyPrioritiesTableUpdateCompanionBuilder,
      (DailyPriority, $$DailyPrioritiesTableReferences),
      DailyPriority,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String id,
      required int singleton,
      required ThemePreference theme,
      required String planningZone,
      Value<int> focusMinutes,
      Value<int> breakMinutes,
      Value<bool> reducedMotion,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> id,
      Value<int> singleton,
      Value<ThemePreference> theme,
      Value<String> planningZone,
      Value<int> focusMinutes,
      Value<int> breakMinutes,
      Value<bool> reducedMotion,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ThemePreference, ThemePreference, String>
  get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get planningZone => $composableBuilder(
    column: $table.planningZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focusMinutes => $composableBuilder(
    column: $table.focusMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reducedMotion => $composableBuilder(
    column: $table.reducedMotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planningZone => $composableBuilder(
    column: $table.planningZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focusMinutes => $composableBuilder(
    column: $table.focusMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reducedMotion => $composableBuilder(
    column: $table.reducedMotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get singleton =>
      $composableBuilder(column: $table.singleton, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ThemePreference, String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get planningZone => $composableBuilder(
    column: $table.planningZone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get focusMinutes => $composableBuilder(
    column: $table.focusMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reducedMotion => $composableBuilder(
    column: $table.reducedMotion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          Settings,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            Settings,
            BaseReferences<_$AppDatabase, $AppSettingsTable, Settings>,
          ),
          Settings,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> singleton = const Value.absent(),
                Value<ThemePreference> theme = const Value.absent(),
                Value<String> planningZone = const Value.absent(),
                Value<int> focusMinutes = const Value.absent(),
                Value<int> breakMinutes = const Value.absent(),
                Value<bool> reducedMotion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                singleton: singleton,
                theme: theme,
                planningZone: planningZone,
                focusMinutes: focusMinutes,
                breakMinutes: breakMinutes,
                reducedMotion: reducedMotion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int singleton,
                required ThemePreference theme,
                required String planningZone,
                Value<int> focusMinutes = const Value.absent(),
                Value<int> breakMinutes = const Value.absent(),
                Value<bool> reducedMotion = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                singleton: singleton,
                theme: theme,
                planningZone: planningZone,
                focusMinutes: focusMinutes,
                breakMinutes: breakMinutes,
                reducedMotion: reducedMotion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, Settings>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, Settings>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      Settings,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (Settings, BaseReferences<_$AppDatabase, $AppSettingsTable, Settings>),
      Settings,
      PrefetchHooks Function()
    >;
typedef $$InstallationsTableCreateCompanionBuilder =
    InstallationsCompanion Function({
      required String id,
      required int singleton,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$InstallationsTableUpdateCompanionBuilder =
    InstallationsCompanion Function({
      Value<String> id,
      Value<int> singleton,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$InstallationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InstallationsTable,
          InstallationMetadata
        > {
  $$InstallationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>>
  _focusSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: 'installations__id__focus_sessions__installation_id',
  );

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.installationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReminderRulesTable, List<ReminderRule>>
  _reminderRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderRules,
    aliasName: 'installations__id__reminder_rules__installation_id',
  );

  $$ReminderRulesTableProcessedTableManager get reminderRulesRefs {
    final manager = $$ReminderRulesTableTableManager(
      $_db,
      $_db.reminderRules,
    ).filter((f) => f.installationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InstallationsTableFilterComposer
    extends Composer<_$AppDatabase, $InstallationsTable> {
  $$InstallationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($$FocusSessionsTableFilterComposer f) f,
  ) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.installationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderRulesRefs(
    Expression<bool> Function($$ReminderRulesTableFilterComposer f) f,
  ) {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.installationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableFilterComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstallationsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallationsTable> {
  $$InstallationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstallationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallationsTable> {
  $$InstallationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get singleton =>
      $composableBuilder(column: $table.singleton, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.installationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reminderRulesRefs<T extends Object>(
    Expression<T> Function($$ReminderRulesTableAnnotationComposer a) f,
  ) {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.installationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstallationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstallationsTable,
          InstallationMetadata,
          $$InstallationsTableFilterComposer,
          $$InstallationsTableOrderingComposer,
          $$InstallationsTableAnnotationComposer,
          $$InstallationsTableCreateCompanionBuilder,
          $$InstallationsTableUpdateCompanionBuilder,
          (InstallationMetadata, $$InstallationsTableReferences),
          InstallationMetadata,
          PrefetchHooks Function({
            bool focusSessionsRefs,
            bool reminderRulesRefs,
          })
        > {
  $$InstallationsTableTableManager(_$AppDatabase db, $InstallationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstallationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstallationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> singleton = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallationsCompanion(
                id: id,
                singleton: singleton,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int singleton,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InstallationsCompanion.insert(
                id: id,
                singleton: singleton,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InstallationsTable, InstallationMetadata>(table),
                  $$InstallationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({focusSessionsRefs = false, reminderRulesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (focusSessionsRefs) db.focusSessions,
                    if (reminderRulesRefs) db.reminderRules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (focusSessionsRefs)
                        await $_getPrefetchedData<
                          InstallationMetadata,
                          $InstallationsTable,
                          FocusSession
                        >(
                          currentTable: table,
                          referencedTable: $$InstallationsTableReferences
                              ._focusSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstallationsTableReferences(
                                db,
                                table,
                                p0,
                              ).focusSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.installationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reminderRulesRefs)
                        await $_getPrefetchedData<
                          InstallationMetadata,
                          $InstallationsTable,
                          ReminderRule
                        >(
                          currentTable: table,
                          referencedTable: $$InstallationsTableReferences
                              ._reminderRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstallationsTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.installationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InstallationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstallationsTable,
      InstallationMetadata,
      $$InstallationsTableFilterComposer,
      $$InstallationsTableOrderingComposer,
      $$InstallationsTableAnnotationComposer,
      $$InstallationsTableCreateCompanionBuilder,
      $$InstallationsTableUpdateCompanionBuilder,
      (InstallationMetadata, $$InstallationsTableReferences),
      InstallationMetadata,
      PrefetchHooks Function({bool focusSessionsRefs, bool reminderRulesRefs})
    >;
typedef $$ActivitySeriesRowsTableCreateCompanionBuilder =
    ActivitySeriesRowsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String title,
      Value<String?> courseId,
      required String recurrence,
      required int weekdays,
      required CalendarDate startDate,
      required CalendarDate endDate,
      required int startMinute,
      required int endMinute,
      required int endDayOffset,
      required String zone,
      Value<String> location,
      Value<bool> busy,
      Value<CalendarDate?> supersededFrom,
      Value<String?> replacedBy,
      Value<int> rowid,
    });
typedef $$ActivitySeriesRowsTableUpdateCompanionBuilder =
    ActivitySeriesRowsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> title,
      Value<String?> courseId,
      Value<String> recurrence,
      Value<int> weekdays,
      Value<CalendarDate> startDate,
      Value<CalendarDate> endDate,
      Value<int> startMinute,
      Value<int> endMinute,
      Value<int> endDayOffset,
      Value<String> zone,
      Value<String> location,
      Value<bool> busy,
      Value<CalendarDate?> supersededFrom,
      Value<String?> replacedBy,
      Value<int> rowid,
    });

final class $$ActivitySeriesRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ActivitySeriesRowsTable,
          ActivitySeries
        > {
  $$ActivitySeriesRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CoursesTable _courseIdTable(_$AppDatabase db) =>
      db.courses.createAlias('activity_series__course_id__courses__id');

  $$CoursesTableProcessedTableManager? get courseId {
    final $_column = $_itemColumn<String>('course_id');
    if ($_column == null) return null;
    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_courseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ActivitySeriesRowsTable _replacedByTable(_$AppDatabase db) => db
      .activitySeriesRows
      .createAlias('activity_series__replaced_by__activity_series__id');

  $$ActivitySeriesRowsTableProcessedTableManager? get replacedBy {
    final $_column = $_itemColumn<String>('replaced_by');
    if ($_column == null) return null;
    final manager = $$ActivitySeriesRowsTableTableManager(
      $_db,
      $_db.activitySeriesRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_replacedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ActivityExceptionsTable, List<ActivityException>>
  _activityExceptionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activityExceptions,
        aliasName: 'activity_series__id__activity_exceptions__series_id',
      );

  $$ActivityExceptionsTableProcessedTableManager get activityExceptionsRefs {
    final manager = $$ActivityExceptionsTableTableManager(
      $_db,
      $_db.activityExceptions,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activityExceptionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NoteActivityLinksTable, List<NoteActivityLink>>
  _noteActivityLinksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.noteActivityLinks,
        aliasName: 'activity_series__id__note_activity_links__series_id',
      );

  $$NoteActivityLinksTableProcessedTableManager get noteActivityLinksRefs {
    final manager = $$NoteActivityLinksTableTableManager(
      $_db,
      $_db.noteActivityLinks,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _noteActivityLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReminderRulesTable, List<ReminderRule>>
  _reminderRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderRules,
    aliasName: 'activity_series__id__reminder_rules__series_id',
  );

  $$ReminderRulesTableProcessedTableManager get reminderRulesRefs {
    final manager = $$ReminderRulesTableTableManager(
      $_db,
      $_db.reminderRules,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActivitySeriesRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitySeriesRowsTable> {
  $$ActivitySeriesRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDayOffset => $composableBuilder(
    column: $table.endDayOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get busy => $composableBuilder(
    column: $table.busy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get supersededFrom => $composableBuilder(
    column: $table.supersededFrom,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$CoursesTableFilterComposer get courseId {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitySeriesRowsTableFilterComposer get replacedBy {
    final $$ActivitySeriesRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.replacedBy,
      referencedTable: $db.activitySeriesRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySeriesRowsTableFilterComposer(
            $db: $db,
            $table: $db.activitySeriesRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> activityExceptionsRefs(
    Expression<bool> Function($$ActivityExceptionsTableFilterComposer f) f,
  ) {
    final $$ActivityExceptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityExceptions,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityExceptionsTableFilterComposer(
            $db: $db,
            $table: $db.activityExceptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> noteActivityLinksRefs(
    Expression<bool> Function($$NoteActivityLinksTableFilterComposer f) f,
  ) {
    final $$NoteActivityLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteActivityLinks,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteActivityLinksTableFilterComposer(
            $db: $db,
            $table: $db.noteActivityLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderRulesRefs(
    Expression<bool> Function($$ReminderRulesTableFilterComposer f) f,
  ) {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableFilterComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitySeriesRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitySeriesRowsTable> {
  $$ActivitySeriesRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDayOffset => $composableBuilder(
    column: $table.endDayOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get busy => $composableBuilder(
    column: $table.busy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supersededFrom => $composableBuilder(
    column: $table.supersededFrom,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoursesTableOrderingComposer get courseId {
    final $$CoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableOrderingComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitySeriesRowsTableOrderingComposer get replacedBy {
    final $$ActivitySeriesRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.replacedBy,
      referencedTable: $db.activitySeriesRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySeriesRowsTableOrderingComposer(
            $db: $db,
            $table: $db.activitySeriesRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitySeriesRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitySeriesRowsTable> {
  $$ActivitySeriesRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<int> get endDayOffset => $composableBuilder(
    column: $table.endDayOffset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<bool> get busy =>
      $composableBuilder(column: $table.busy, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get supersededFrom =>
      $composableBuilder(
        column: $table.supersededFrom,
        builder: (column) => column,
      );

  $$CoursesTableAnnotationComposer get courseId {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitySeriesRowsTableAnnotationComposer get replacedBy {
    final $$ActivitySeriesRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.replacedBy,
          referencedTable: $db.activitySeriesRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivitySeriesRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.activitySeriesRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> activityExceptionsRefs<T extends Object>(
    Expression<T> Function($$ActivityExceptionsTableAnnotationComposer a) f,
  ) {
    final $$ActivityExceptionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activityExceptions,
          getReferencedColumn: (t) => t.seriesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivityExceptionsTableAnnotationComposer(
                $db: $db,
                $table: $db.activityExceptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> noteActivityLinksRefs<T extends Object>(
    Expression<T> Function($$NoteActivityLinksTableAnnotationComposer a) f,
  ) {
    final $$NoteActivityLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.noteActivityLinks,
          getReferencedColumn: (t) => t.seriesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NoteActivityLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.noteActivityLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> reminderRulesRefs<T extends Object>(
    Expression<T> Function($$ReminderRulesTableAnnotationComposer a) f,
  ) {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitySeriesRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitySeriesRowsTable,
          ActivitySeries,
          $$ActivitySeriesRowsTableFilterComposer,
          $$ActivitySeriesRowsTableOrderingComposer,
          $$ActivitySeriesRowsTableAnnotationComposer,
          $$ActivitySeriesRowsTableCreateCompanionBuilder,
          $$ActivitySeriesRowsTableUpdateCompanionBuilder,
          (ActivitySeries, $$ActivitySeriesRowsTableReferences),
          ActivitySeries,
          PrefetchHooks Function({
            bool courseId,
            bool replacedBy,
            bool activityExceptionsRefs,
            bool noteActivityLinksRefs,
            bool reminderRulesRefs,
          })
        > {
  $$ActivitySeriesRowsTableTableManager(
    _$AppDatabase db,
    $ActivitySeriesRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitySeriesRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitySeriesRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitySeriesRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> courseId = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<int> weekdays = const Value.absent(),
                Value<CalendarDate> startDate = const Value.absent(),
                Value<CalendarDate> endDate = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> endMinute = const Value.absent(),
                Value<int> endDayOffset = const Value.absent(),
                Value<String> zone = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<bool> busy = const Value.absent(),
                Value<CalendarDate?> supersededFrom = const Value.absent(),
                Value<String?> replacedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitySeriesRowsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                title: title,
                courseId: courseId,
                recurrence: recurrence,
                weekdays: weekdays,
                startDate: startDate,
                endDate: endDate,
                startMinute: startMinute,
                endMinute: endMinute,
                endDayOffset: endDayOffset,
                zone: zone,
                location: location,
                busy: busy,
                supersededFrom: supersededFrom,
                replacedBy: replacedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String title,
                Value<String?> courseId = const Value.absent(),
                required String recurrence,
                required int weekdays,
                required CalendarDate startDate,
                required CalendarDate endDate,
                required int startMinute,
                required int endMinute,
                required int endDayOffset,
                required String zone,
                Value<String> location = const Value.absent(),
                Value<bool> busy = const Value.absent(),
                Value<CalendarDate?> supersededFrom = const Value.absent(),
                Value<String?> replacedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitySeriesRowsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                title: title,
                courseId: courseId,
                recurrence: recurrence,
                weekdays: weekdays,
                startDate: startDate,
                endDate: endDate,
                startMinute: startMinute,
                endMinute: endMinute,
                endDayOffset: endDayOffset,
                zone: zone,
                location: location,
                busy: busy,
                supersededFrom: supersededFrom,
                replacedBy: replacedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivitySeriesRowsTable, ActivitySeries>(table),
                  $$ActivitySeriesRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                courseId = false,
                replacedBy = false,
                activityExceptionsRefs = false,
                noteActivityLinksRefs = false,
                reminderRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activityExceptionsRefs) db.activityExceptions,
                    if (noteActivityLinksRefs) db.noteActivityLinks,
                    if (reminderRulesRefs) db.reminderRules,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (courseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.courseId,
                            referencedTable: $$ActivitySeriesRowsTableReferences
                                ._courseIdTable(db),
                            referencedColumn:
                                $$ActivitySeriesRowsTableReferences
                                    ._courseIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (replacedBy) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.replacedBy,
                            referencedTable: $$ActivitySeriesRowsTableReferences
                                ._replacedByTable(db),
                            referencedColumn:
                                $$ActivitySeriesRowsTableReferences
                                    ._replacedByTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activityExceptionsRefs)
                        await $_getPrefetchedData<
                          ActivitySeries,
                          $ActivitySeriesRowsTable,
                          ActivityException
                        >(
                          currentTable: table,
                          referencedTable: $$ActivitySeriesRowsTableReferences
                              ._activityExceptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitySeriesRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).activityExceptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.seriesId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (noteActivityLinksRefs)
                        await $_getPrefetchedData<
                          ActivitySeries,
                          $ActivitySeriesRowsTable,
                          NoteActivityLink
                        >(
                          currentTable: table,
                          referencedTable: $$ActivitySeriesRowsTableReferences
                              ._noteActivityLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitySeriesRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).noteActivityLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.seriesId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reminderRulesRefs)
                        await $_getPrefetchedData<
                          ActivitySeries,
                          $ActivitySeriesRowsTable,
                          ReminderRule
                        >(
                          currentTable: table,
                          referencedTable: $$ActivitySeriesRowsTableReferences
                              ._reminderRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitySeriesRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.seriesId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ActivitySeriesRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitySeriesRowsTable,
      ActivitySeries,
      $$ActivitySeriesRowsTableFilterComposer,
      $$ActivitySeriesRowsTableOrderingComposer,
      $$ActivitySeriesRowsTableAnnotationComposer,
      $$ActivitySeriesRowsTableCreateCompanionBuilder,
      $$ActivitySeriesRowsTableUpdateCompanionBuilder,
      (ActivitySeries, $$ActivitySeriesRowsTableReferences),
      ActivitySeries,
      PrefetchHooks Function({
        bool courseId,
        bool replacedBy,
        bool activityExceptionsRefs,
        bool noteActivityLinksRefs,
        bool reminderRulesRefs,
      })
    >;
typedef $$ActivityExceptionsTableCreateCompanionBuilder =
    ActivityExceptionsCompanion Function({
      required String id,
      required String seriesId,
      required CalendarDate originalDate,
      Value<bool> cancelled,
      Value<CalendarDate?> movedDate,
      Value<int?> startMinute,
      Value<int?> endMinute,
      Value<int?> endDayOffset,
      Value<String?> zone,
      Value<String?> location,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ActivityExceptionsTableUpdateCompanionBuilder =
    ActivityExceptionsCompanion Function({
      Value<String> id,
      Value<String> seriesId,
      Value<CalendarDate> originalDate,
      Value<bool> cancelled,
      Value<CalendarDate?> movedDate,
      Value<int?> startMinute,
      Value<int?> endMinute,
      Value<int?> endDayOffset,
      Value<String?> zone,
      Value<String?> location,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ActivityExceptionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ActivityExceptionsTable,
          ActivityException
        > {
  $$ActivityExceptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ActivitySeriesRowsTable _seriesIdTable(_$AppDatabase db) => db
      .activitySeriesRows
      .createAlias('activity_exceptions__series_id__activity_series__id');

  $$ActivitySeriesRowsTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<String>('series_id')!;

    final manager = $$ActivitySeriesRowsTableTableManager(
      $_db,
      $_db.activitySeriesRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivityExceptionsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityExceptionsTable> {
  $$ActivityExceptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get cancelled => $composableBuilder(
    column: $table.cancelled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get movedDate => $composableBuilder(
    column: $table.movedDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDayOffset => $composableBuilder(
    column: $table.endDayOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$ActivitySeriesRowsTableFilterComposer get seriesId {
    final $$ActivitySeriesRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.activitySeriesRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySeriesRowsTableFilterComposer(
            $db: $db,
            $table: $db.activitySeriesRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityExceptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityExceptionsTable> {
  $$ActivityExceptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cancelled => $composableBuilder(
    column: $table.cancelled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movedDate => $composableBuilder(
    column: $table.movedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDayOffset => $composableBuilder(
    column: $table.endDayOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivitySeriesRowsTableOrderingComposer get seriesId {
    final $$ActivitySeriesRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.activitySeriesRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySeriesRowsTableOrderingComposer(
            $db: $db,
            $table: $db.activitySeriesRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityExceptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityExceptionsTable> {
  $$ActivityExceptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get originalDate =>
      $composableBuilder(
        column: $table.originalDate,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get cancelled =>
      $composableBuilder(column: $table.cancelled, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get movedDate =>
      $composableBuilder(column: $table.movedDate, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<int> get endDayOffset => $composableBuilder(
    column: $table.endDayOffset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ActivitySeriesRowsTableAnnotationComposer get seriesId {
    final $$ActivitySeriesRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.seriesId,
          referencedTable: $db.activitySeriesRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivitySeriesRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.activitySeriesRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ActivityExceptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityExceptionsTable,
          ActivityException,
          $$ActivityExceptionsTableFilterComposer,
          $$ActivityExceptionsTableOrderingComposer,
          $$ActivityExceptionsTableAnnotationComposer,
          $$ActivityExceptionsTableCreateCompanionBuilder,
          $$ActivityExceptionsTableUpdateCompanionBuilder,
          (ActivityException, $$ActivityExceptionsTableReferences),
          ActivityException,
          PrefetchHooks Function({bool seriesId})
        > {
  $$ActivityExceptionsTableTableManager(
    _$AppDatabase db,
    $ActivityExceptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityExceptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityExceptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityExceptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> seriesId = const Value.absent(),
                Value<CalendarDate> originalDate = const Value.absent(),
                Value<bool> cancelled = const Value.absent(),
                Value<CalendarDate?> movedDate = const Value.absent(),
                Value<int?> startMinute = const Value.absent(),
                Value<int?> endMinute = const Value.absent(),
                Value<int?> endDayOffset = const Value.absent(),
                Value<String?> zone = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityExceptionsCompanion(
                id: id,
                seriesId: seriesId,
                originalDate: originalDate,
                cancelled: cancelled,
                movedDate: movedDate,
                startMinute: startMinute,
                endMinute: endMinute,
                endDayOffset: endDayOffset,
                zone: zone,
                location: location,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String seriesId,
                required CalendarDate originalDate,
                Value<bool> cancelled = const Value.absent(),
                Value<CalendarDate?> movedDate = const Value.absent(),
                Value<int?> startMinute = const Value.absent(),
                Value<int?> endMinute = const Value.absent(),
                Value<int?> endDayOffset = const Value.absent(),
                Value<String?> zone = const Value.absent(),
                Value<String?> location = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ActivityExceptionsCompanion.insert(
                id: id,
                seriesId: seriesId,
                originalDate: originalDate,
                cancelled: cancelled,
                movedDate: movedDate,
                startMinute: startMinute,
                endMinute: endMinute,
                endDayOffset: endDayOffset,
                zone: zone,
                location: location,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivityExceptionsTable, ActivityException>(
                    table,
                  ),
                  $$ActivityExceptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seriesId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (seriesId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.seriesId,
                        referencedTable: $$ActivityExceptionsTableReferences
                            ._seriesIdTable(db),
                        referencedColumn: $$ActivityExceptionsTableReferences
                            ._seriesIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActivityExceptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityExceptionsTable,
      ActivityException,
      $$ActivityExceptionsTableFilterComposer,
      $$ActivityExceptionsTableOrderingComposer,
      $$ActivityExceptionsTableAnnotationComposer,
      $$ActivityExceptionsTableCreateCompanionBuilder,
      $$ActivityExceptionsTableUpdateCompanionBuilder,
      (ActivityException, $$ActivityExceptionsTableReferences),
      ActivityException,
      PrefetchHooks Function({bool seriesId})
    >;
typedef $$NoteActivityLinksTableCreateCompanionBuilder =
    NoteActivityLinksCompanion Function({
      required String id,
      required String noteId,
      required String seriesId,
      Value<CalendarDate?> originalDate,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$NoteActivityLinksTableUpdateCompanionBuilder =
    NoteActivityLinksCompanion Function({
      Value<String> id,
      Value<String> noteId,
      Value<String> seriesId,
      Value<CalendarDate?> originalDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$NoteActivityLinksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NoteActivityLinksTable,
          NoteActivityLink
        > {
  $$NoteActivityLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NotesTable _noteIdTable(_$AppDatabase db) =>
      db.notes.createAlias('note_activity_links__note_id__notes__id');

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<String>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ActivitySeriesRowsTable _seriesIdTable(_$AppDatabase db) => db
      .activitySeriesRows
      .createAlias('note_activity_links__series_id__activity_series__id');

  $$ActivitySeriesRowsTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<String>('series_id')!;

    final manager = $$ActivitySeriesRowsTableTableManager(
      $_db,
      $_db.activitySeriesRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteActivityLinksTableFilterComposer
    extends Composer<_$AppDatabase, $NoteActivityLinksTable> {
  $$NoteActivityLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitySeriesRowsTableFilterComposer get seriesId {
    final $$ActivitySeriesRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.activitySeriesRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySeriesRowsTableFilterComposer(
            $db: $db,
            $table: $db.activitySeriesRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteActivityLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteActivityLinksTable> {
  $$NoteActivityLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitySeriesRowsTableOrderingComposer get seriesId {
    final $$ActivitySeriesRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.activitySeriesRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySeriesRowsTableOrderingComposer(
            $db: $db,
            $table: $db.activitySeriesRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteActivityLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteActivityLinksTable> {
  $$NoteActivityLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get originalDate =>
      $composableBuilder(
        column: $table.originalDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitySeriesRowsTableAnnotationComposer get seriesId {
    final $$ActivitySeriesRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.seriesId,
          referencedTable: $db.activitySeriesRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivitySeriesRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.activitySeriesRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$NoteActivityLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteActivityLinksTable,
          NoteActivityLink,
          $$NoteActivityLinksTableFilterComposer,
          $$NoteActivityLinksTableOrderingComposer,
          $$NoteActivityLinksTableAnnotationComposer,
          $$NoteActivityLinksTableCreateCompanionBuilder,
          $$NoteActivityLinksTableUpdateCompanionBuilder,
          (NoteActivityLink, $$NoteActivityLinksTableReferences),
          NoteActivityLink,
          PrefetchHooks Function({bool noteId, bool seriesId})
        > {
  $$NoteActivityLinksTableTableManager(
    _$AppDatabase db,
    $NoteActivityLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteActivityLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteActivityLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteActivityLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<String> seriesId = const Value.absent(),
                Value<CalendarDate?> originalDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteActivityLinksCompanion(
                id: id,
                noteId: noteId,
                seriesId: seriesId,
                originalDate: originalDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String noteId,
                required String seriesId,
                Value<CalendarDate?> originalDate = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => NoteActivityLinksCompanion.insert(
                id: id,
                noteId: noteId,
                seriesId: seriesId,
                originalDate: originalDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteActivityLinksTable, NoteActivityLink>(table),
                  $$NoteActivityLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false, seriesId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.noteId,
                        referencedTable: $$NoteActivityLinksTableReferences
                            ._noteIdTable(db),
                        referencedColumn: $$NoteActivityLinksTableReferences
                            ._noteIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (seriesId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.seriesId,
                        referencedTable: $$NoteActivityLinksTableReferences
                            ._seriesIdTable(db),
                        referencedColumn: $$NoteActivityLinksTableReferences
                            ._seriesIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteActivityLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteActivityLinksTable,
      NoteActivityLink,
      $$NoteActivityLinksTableFilterComposer,
      $$NoteActivityLinksTableOrderingComposer,
      $$NoteActivityLinksTableAnnotationComposer,
      $$NoteActivityLinksTableCreateCompanionBuilder,
      $$NoteActivityLinksTableUpdateCompanionBuilder,
      (NoteActivityLink, $$NoteActivityLinksTableReferences),
      NoteActivityLink,
      PrefetchHooks Function({bool noteId, bool seriesId})
    >;
typedef $$PlannedWorkBlocksTableCreateCompanionBuilder =
    PlannedWorkBlocksCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String taskId,
      required DateTime startUtc,
      required DateTime endUtc,
      required String planningZone,
      required WorkBlockStatus status,
      Value<bool> locked,
      Value<int> rowid,
    });
typedef $$PlannedWorkBlocksTableUpdateCompanionBuilder =
    PlannedWorkBlocksCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> taskId,
      Value<DateTime> startUtc,
      Value<DateTime> endUtc,
      Value<String> planningZone,
      Value<WorkBlockStatus> status,
      Value<bool> locked,
      Value<int> rowid,
    });

final class $$PlannedWorkBlocksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlannedWorkBlocksTable,
          PlannedWorkBlock
        > {
  $$PlannedWorkBlocksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('planned_work_blocks__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReminderRulesTable, List<ReminderRule>>
  _reminderRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderRules,
    aliasName: 'planned_work_blocks__id__reminder_rules__work_id',
  );

  $$ReminderRulesTableProcessedTableManager get reminderRulesRefs {
    final manager = $$ReminderRulesTableTableManager(
      $_db,
      $_db.reminderRules,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlannedWorkBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $PlannedWorkBlocksTable> {
  $$PlannedWorkBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get startUtc =>
      $composableBuilder(
        column: $table.startUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get endUtc =>
      $composableBuilder(
        column: $table.endUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get planningZone => $composableBuilder(
    column: $table.planningZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WorkBlockStatus, WorkBlockStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reminderRulesRefs(
    Expression<bool> Function($$ReminderRulesTableFilterComposer f) f,
  ) {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableFilterComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlannedWorkBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $PlannedWorkBlocksTable> {
  $$PlannedWorkBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startUtc => $composableBuilder(
    column: $table.startUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endUtc => $composableBuilder(
    column: $table.endUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planningZone => $composableBuilder(
    column: $table.planningZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlannedWorkBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlannedWorkBlocksTable> {
  $$PlannedWorkBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => column);

  GeneratedColumn<String> get planningZone => $composableBuilder(
    column: $table.planningZone,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WorkBlockStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reminderRulesRefs<T extends Object>(
    Expression<T> Function($$ReminderRulesTableAnnotationComposer a) f,
  ) {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlannedWorkBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlannedWorkBlocksTable,
          PlannedWorkBlock,
          $$PlannedWorkBlocksTableFilterComposer,
          $$PlannedWorkBlocksTableOrderingComposer,
          $$PlannedWorkBlocksTableAnnotationComposer,
          $$PlannedWorkBlocksTableCreateCompanionBuilder,
          $$PlannedWorkBlocksTableUpdateCompanionBuilder,
          (PlannedWorkBlock, $$PlannedWorkBlocksTableReferences),
          PlannedWorkBlock,
          PrefetchHooks Function({bool taskId, bool reminderRulesRefs})
        > {
  $$PlannedWorkBlocksTableTableManager(
    _$AppDatabase db,
    $PlannedWorkBlocksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedWorkBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedWorkBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlannedWorkBlocksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<DateTime> startUtc = const Value.absent(),
                Value<DateTime> endUtc = const Value.absent(),
                Value<String> planningZone = const Value.absent(),
                Value<WorkBlockStatus> status = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlannedWorkBlocksCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                taskId: taskId,
                startUtc: startUtc,
                endUtc: endUtc,
                planningZone: planningZone,
                status: status,
                locked: locked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String taskId,
                required DateTime startUtc,
                required DateTime endUtc,
                required String planningZone,
                required WorkBlockStatus status,
                Value<bool> locked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlannedWorkBlocksCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                taskId: taskId,
                startUtc: startUtc,
                endUtc: endUtc,
                planningZone: planningZone,
                status: status,
                locked: locked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlannedWorkBlocksTable, PlannedWorkBlock>(table),
                  $$PlannedWorkBlocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false, reminderRulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (reminderRulesRefs) db.reminderRules,
              ],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$PlannedWorkBlocksTableReferences
                            ._taskIdTable(db),
                        referencedColumn: $$PlannedWorkBlocksTableReferences
                            ._taskIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reminderRulesRefs)
                    await $_getPrefetchedData<
                      PlannedWorkBlock,
                      $PlannedWorkBlocksTable,
                      ReminderRule
                    >(
                      currentTable: table,
                      referencedTable: $$PlannedWorkBlocksTableReferences
                          ._reminderRulesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlannedWorkBlocksTableReferences(
                            db,
                            table,
                            p0,
                          ).reminderRulesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.workId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlannedWorkBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlannedWorkBlocksTable,
      PlannedWorkBlock,
      $$PlannedWorkBlocksTableFilterComposer,
      $$PlannedWorkBlocksTableOrderingComposer,
      $$PlannedWorkBlocksTableAnnotationComposer,
      $$PlannedWorkBlocksTableCreateCompanionBuilder,
      $$PlannedWorkBlocksTableUpdateCompanionBuilder,
      (PlannedWorkBlock, $$PlannedWorkBlocksTableReferences),
      PlannedWorkBlock,
      PrefetchHooks Function({bool taskId, bool reminderRulesRefs})
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      required String id,
      required String installationId,
      Value<String?> taskId,
      Value<String?> subtaskId,
      required String titleSnapshot,
      required String zone,
      required CalendarDate localStartDate,
      required DateTime startedUtc,
      required SessionKind kind,
      required SessionState state,
      Value<SessionOutcome?> outcome,
      required int plannedMs,
      required int elapsedMs,
      required int eligibleMs,
      required int uncertainMs,
      required bool hasUncertainty,
      required bool background,
      required DateTime checkpointUtc,
      required int elapsedMarkMs,
      required String clockEpoch,
      required int revision,
      Value<int?> reportedMs,
      Value<DateTime?> finalizedUtc,
      Value<int> rowid,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<String> id,
      Value<String> installationId,
      Value<String?> taskId,
      Value<String?> subtaskId,
      Value<String> titleSnapshot,
      Value<String> zone,
      Value<CalendarDate> localStartDate,
      Value<DateTime> startedUtc,
      Value<SessionKind> kind,
      Value<SessionState> state,
      Value<SessionOutcome?> outcome,
      Value<int> plannedMs,
      Value<int> elapsedMs,
      Value<int> eligibleMs,
      Value<int> uncertainMs,
      Value<bool> hasUncertainty,
      Value<bool> background,
      Value<DateTime> checkpointUtc,
      Value<int> elapsedMarkMs,
      Value<String> clockEpoch,
      Value<int> revision,
      Value<int?> reportedMs,
      Value<DateTime?> finalizedUtc,
      Value<int> rowid,
    });

final class $$FocusSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSession> {
  $$FocusSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InstallationsTable _installationIdTable(_$AppDatabase db) => db
      .installations
      .createAlias('focus_sessions__installation_id__installations__id');

  $$InstallationsTableProcessedTableManager get installationId {
    final $_column = $_itemColumn<String>('installation_id')!;

    final manager = $$InstallationsTableTableManager(
      $_db,
      $_db.installations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_installationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('focus_sessions__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<String>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubtasksTable _subtaskIdTable(_$AppDatabase db) =>
      db.subtasks.createAlias('focus_sessions__subtask_id__subtasks__id');

  $$SubtasksTableProcessedTableManager? get subtaskId {
    final $_column = $_itemColumn<String>('subtask_id');
    if ($_column == null) return null;
    final manager = $$SubtasksTableTableManager(
      $_db,
      $_db.subtasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subtaskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FocusSegmentsTable, List<FocusSegment>>
  _focusSegmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSegments,
    aliasName: 'focus_sessions__id__focus_segments__session_id',
  );

  $$FocusSegmentsTableProcessedTableManager get focusSegmentsRefs {
    final manager = $$FocusSegmentsTableTableManager(
      $_db,
      $_db.focusSegments,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSegmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TimerCommandReceiptsTable,
    List<TimerCommandReceipt>
  >
  _timerCommandReceiptsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.timerCommandReceipts,
        aliasName: 'focus_sessions__id__timer_command_receipts__session_id',
      );

  $$TimerCommandReceiptsTableProcessedTableManager
  get timerCommandReceiptsRefs {
    final manager = $$TimerCommandReceiptsTableTableManager(
      $_db,
      $_db.timerCommandReceipts,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _timerCommandReceiptsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ReminderRegistrationsTable,
    List<ReminderRegistration>
  >
  _reminderRegistrationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reminderRegistrations,
        aliasName: 'focus_sessions__id__reminder_registrations__session_id',
      );

  $$ReminderRegistrationsTableProcessedTableManager
  get reminderRegistrationsRefs {
    final manager = $$ReminderRegistrationsTableTableManager(
      $_db,
      $_db.reminderRegistrations,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reminderRegistrationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FocusSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get localStartDate => $composableBuilder(
    column: $table.localStartDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get startedUtc =>
      $composableBuilder(
        column: $table.startedUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<SessionKind, SessionKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<SessionState, SessionState, String>
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionOutcome?, SessionOutcome, String>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get plannedMs => $composableBuilder(
    column: $table.plannedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eligibleMs => $composableBuilder(
    column: $table.eligibleMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uncertainMs => $composableBuilder(
    column: $table.uncertainMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasUncertainty => $composableBuilder(
    column: $table.hasUncertainty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get checkpointUtc =>
      $composableBuilder(
        column: $table.checkpointUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get elapsedMarkMs => $composableBuilder(
    column: $table.elapsedMarkMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clockEpoch => $composableBuilder(
    column: $table.clockEpoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reportedMs => $composableBuilder(
    column: $table.reportedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get finalizedUtc =>
      $composableBuilder(
        column: $table.finalizedUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$InstallationsTableFilterComposer get installationId {
    final $$InstallationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.installationId,
      referencedTable: $db.installations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallationsTableFilterComposer(
            $db: $db,
            $table: $db.installations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubtasksTableFilterComposer get subtaskId {
    final $$SubtasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtaskId,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableFilterComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> focusSegmentsRefs(
    Expression<bool> Function($$FocusSegmentsTableFilterComposer f) f,
  ) {
    final $$FocusSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSegments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.focusSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> timerCommandReceiptsRefs(
    Expression<bool> Function($$TimerCommandReceiptsTableFilterComposer f) f,
  ) {
    final $$TimerCommandReceiptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timerCommandReceipts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerCommandReceiptsTableFilterComposer(
            $db: $db,
            $table: $db.timerCommandReceipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderRegistrationsRefs(
    Expression<bool> Function($$ReminderRegistrationsTableFilterComposer f) f,
  ) {
    final $$ReminderRegistrationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reminderRegistrations,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReminderRegistrationsTableFilterComposer(
                $db: $db,
                $table: $db.reminderRegistrations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localStartDate => $composableBuilder(
    column: $table.localStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedUtc => $composableBuilder(
    column: $table.startedUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedMs => $composableBuilder(
    column: $table.plannedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eligibleMs => $composableBuilder(
    column: $table.eligibleMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uncertainMs => $composableBuilder(
    column: $table.uncertainMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasUncertainty => $composableBuilder(
    column: $table.hasUncertainty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checkpointUtc => $composableBuilder(
    column: $table.checkpointUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMarkMs => $composableBuilder(
    column: $table.elapsedMarkMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clockEpoch => $composableBuilder(
    column: $table.clockEpoch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reportedMs => $composableBuilder(
    column: $table.reportedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finalizedUtc => $composableBuilder(
    column: $table.finalizedUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstallationsTableOrderingComposer get installationId {
    final $$InstallationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.installationId,
      referencedTable: $db.installations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallationsTableOrderingComposer(
            $db: $db,
            $table: $db.installations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubtasksTableOrderingComposer get subtaskId {
    final $$SubtasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtaskId,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableOrderingComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get localStartDate =>
      $composableBuilder(
        column: $table.localStartDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, int> get startedUtc =>
      $composableBuilder(
        column: $table.startedUtc,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<SessionKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionOutcome?, String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get plannedMs =>
      $composableBuilder(column: $table.plannedMs, builder: (column) => column);

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<int> get eligibleMs => $composableBuilder(
    column: $table.eligibleMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get uncertainMs => $composableBuilder(
    column: $table.uncertainMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasUncertainty => $composableBuilder(
    column: $table.hasUncertainty,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get checkpointUtc =>
      $composableBuilder(
        column: $table.checkpointUtc,
        builder: (column) => column,
      );

  GeneratedColumn<int> get elapsedMarkMs => $composableBuilder(
    column: $table.elapsedMarkMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clockEpoch => $composableBuilder(
    column: $table.clockEpoch,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get reportedMs => $composableBuilder(
    column: $table.reportedMs,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get finalizedUtc =>
      $composableBuilder(
        column: $table.finalizedUtc,
        builder: (column) => column,
      );

  $$InstallationsTableAnnotationComposer get installationId {
    final $$InstallationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.installationId,
      referencedTable: $db.installations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallationsTableAnnotationComposer(
            $db: $db,
            $table: $db.installations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubtasksTableAnnotationComposer get subtaskId {
    final $$SubtasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtaskId,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableAnnotationComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> focusSegmentsRefs<T extends Object>(
    Expression<T> Function($$FocusSegmentsTableAnnotationComposer a) f,
  ) {
    final $$FocusSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSegments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> timerCommandReceiptsRefs<T extends Object>(
    Expression<T> Function($$TimerCommandReceiptsTableAnnotationComposer a) f,
  ) {
    final $$TimerCommandReceiptsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.timerCommandReceipts,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TimerCommandReceiptsTableAnnotationComposer(
                $db: $db,
                $table: $db.timerCommandReceipts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> reminderRegistrationsRefs<T extends Object>(
    Expression<T> Function($$ReminderRegistrationsTableAnnotationComposer a) f,
  ) {
    final $$ReminderRegistrationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reminderRegistrations,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReminderRegistrationsTableAnnotationComposer(
                $db: $db,
                $table: $db.reminderRegistrations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSessionsTable,
          FocusSession,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (FocusSession, $$FocusSessionsTableReferences),
          FocusSession,
          PrefetchHooks Function({
            bool installationId,
            bool taskId,
            bool subtaskId,
            bool focusSegmentsRefs,
            bool timerCommandReceiptsRefs,
            bool reminderRegistrationsRefs,
          })
        > {
  $$FocusSessionsTableTableManager(_$AppDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> installationId = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<String?> subtaskId = const Value.absent(),
                Value<String> titleSnapshot = const Value.absent(),
                Value<String> zone = const Value.absent(),
                Value<CalendarDate> localStartDate = const Value.absent(),
                Value<DateTime> startedUtc = const Value.absent(),
                Value<SessionKind> kind = const Value.absent(),
                Value<SessionState> state = const Value.absent(),
                Value<SessionOutcome?> outcome = const Value.absent(),
                Value<int> plannedMs = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<int> eligibleMs = const Value.absent(),
                Value<int> uncertainMs = const Value.absent(),
                Value<bool> hasUncertainty = const Value.absent(),
                Value<bool> background = const Value.absent(),
                Value<DateTime> checkpointUtc = const Value.absent(),
                Value<int> elapsedMarkMs = const Value.absent(),
                Value<String> clockEpoch = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> reportedMs = const Value.absent(),
                Value<DateTime?> finalizedUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                installationId: installationId,
                taskId: taskId,
                subtaskId: subtaskId,
                titleSnapshot: titleSnapshot,
                zone: zone,
                localStartDate: localStartDate,
                startedUtc: startedUtc,
                kind: kind,
                state: state,
                outcome: outcome,
                plannedMs: plannedMs,
                elapsedMs: elapsedMs,
                eligibleMs: eligibleMs,
                uncertainMs: uncertainMs,
                hasUncertainty: hasUncertainty,
                background: background,
                checkpointUtc: checkpointUtc,
                elapsedMarkMs: elapsedMarkMs,
                clockEpoch: clockEpoch,
                revision: revision,
                reportedMs: reportedMs,
                finalizedUtc: finalizedUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String installationId,
                Value<String?> taskId = const Value.absent(),
                Value<String?> subtaskId = const Value.absent(),
                required String titleSnapshot,
                required String zone,
                required CalendarDate localStartDate,
                required DateTime startedUtc,
                required SessionKind kind,
                required SessionState state,
                Value<SessionOutcome?> outcome = const Value.absent(),
                required int plannedMs,
                required int elapsedMs,
                required int eligibleMs,
                required int uncertainMs,
                required bool hasUncertainty,
                required bool background,
                required DateTime checkpointUtc,
                required int elapsedMarkMs,
                required String clockEpoch,
                required int revision,
                Value<int?> reportedMs = const Value.absent(),
                Value<DateTime?> finalizedUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                installationId: installationId,
                taskId: taskId,
                subtaskId: subtaskId,
                titleSnapshot: titleSnapshot,
                zone: zone,
                localStartDate: localStartDate,
                startedUtc: startedUtc,
                kind: kind,
                state: state,
                outcome: outcome,
                plannedMs: plannedMs,
                elapsedMs: elapsedMs,
                eligibleMs: eligibleMs,
                uncertainMs: uncertainMs,
                hasUncertainty: hasUncertainty,
                background: background,
                checkpointUtc: checkpointUtc,
                elapsedMarkMs: elapsedMarkMs,
                clockEpoch: clockEpoch,
                revision: revision,
                reportedMs: reportedMs,
                finalizedUtc: finalizedUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FocusSessionsTable, FocusSession>(table),
                  $$FocusSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                installationId = false,
                taskId = false,
                subtaskId = false,
                focusSegmentsRefs = false,
                timerCommandReceiptsRefs = false,
                reminderRegistrationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (focusSegmentsRefs) db.focusSegments,
                    if (timerCommandReceiptsRefs) db.timerCommandReceipts,
                    if (reminderRegistrationsRefs) db.reminderRegistrations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (installationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.installationId,
                            referencedTable: $$FocusSessionsTableReferences
                                ._installationIdTable(db),
                            referencedColumn: $$FocusSessionsTableReferences
                                ._installationIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (taskId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.taskId,
                            referencedTable: $$FocusSessionsTableReferences
                                ._taskIdTable(db),
                            referencedColumn: $$FocusSessionsTableReferences
                                ._taskIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (subtaskId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.subtaskId,
                            referencedTable: $$FocusSessionsTableReferences
                                ._subtaskIdTable(db),
                            referencedColumn: $$FocusSessionsTableReferences
                                ._subtaskIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (focusSegmentsRefs)
                        await $_getPrefetchedData<
                          FocusSession,
                          $FocusSessionsTable,
                          FocusSegment
                        >(
                          currentTable: table,
                          referencedTable: $$FocusSessionsTableReferences
                              ._focusSegmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FocusSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).focusSegmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (timerCommandReceiptsRefs)
                        await $_getPrefetchedData<
                          FocusSession,
                          $FocusSessionsTable,
                          TimerCommandReceipt
                        >(
                          currentTable: table,
                          referencedTable: $$FocusSessionsTableReferences
                              ._timerCommandReceiptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FocusSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).timerCommandReceiptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reminderRegistrationsRefs)
                        await $_getPrefetchedData<
                          FocusSession,
                          $FocusSessionsTable,
                          ReminderRegistration
                        >(
                          currentTable: table,
                          referencedTable: $$FocusSessionsTableReferences
                              ._reminderRegistrationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FocusSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderRegistrationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSessionsTable,
      FocusSession,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (FocusSession, $$FocusSessionsTableReferences),
      FocusSession,
      PrefetchHooks Function({
        bool installationId,
        bool taskId,
        bool subtaskId,
        bool focusSegmentsRefs,
        bool timerCommandReceiptsRefs,
        bool reminderRegistrationsRefs,
      })
    >;
typedef $$FocusSegmentsTableCreateCompanionBuilder =
    FocusSegmentsCompanion Function({
      required String id,
      required String sessionId,
      required int sequence,
      required SegmentKind kind,
      required DateTime fromUtc,
      required DateTime toUtc,
      required int spanMs,
      required int elapsedMs,
      required int eligibleMs,
      Value<String?> reason,
      Value<int> rowid,
    });
typedef $$FocusSegmentsTableUpdateCompanionBuilder =
    FocusSegmentsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> sequence,
      Value<SegmentKind> kind,
      Value<DateTime> fromUtc,
      Value<DateTime> toUtc,
      Value<int> spanMs,
      Value<int> elapsedMs,
      Value<int> eligibleMs,
      Value<String?> reason,
      Value<int> rowid,
    });

final class $$FocusSegmentsTableReferences
    extends BaseReferences<_$AppDatabase, $FocusSegmentsTable, FocusSegment> {
  $$FocusSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FocusSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .focusSessions
      .createAlias('focus_segments__session_id__focus_sessions__id');

  $$FocusSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FocusSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $FocusSegmentsTable> {
  $$FocusSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SegmentKind, SegmentKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get fromUtc =>
      $composableBuilder(
        column: $table.fromUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get toUtc =>
      $composableBuilder(
        column: $table.toUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get spanMs => $composableBuilder(
    column: $table.spanMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eligibleMs => $composableBuilder(
    column: $table.eligibleMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  $$FocusSessionsTableFilterComposer get sessionId {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusSegmentsTable> {
  $$FocusSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromUtc => $composableBuilder(
    column: $table.fromUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toUtc => $composableBuilder(
    column: $table.toUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spanMs => $composableBuilder(
    column: $table.spanMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eligibleMs => $composableBuilder(
    column: $table.eligibleMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  $$FocusSessionsTableOrderingComposer get sessionId {
    final $$FocusSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusSegmentsTable> {
  $$FocusSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SegmentKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get fromUtc =>
      $composableBuilder(column: $table.fromUtc, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get toUtc =>
      $composableBuilder(column: $table.toUtc, builder: (column) => column);

  GeneratedColumn<int> get spanMs =>
      $composableBuilder(column: $table.spanMs, builder: (column) => column);

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<int> get eligibleMs => $composableBuilder(
    column: $table.eligibleMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  $$FocusSessionsTableAnnotationComposer get sessionId {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSegmentsTable,
          FocusSegment,
          $$FocusSegmentsTableFilterComposer,
          $$FocusSegmentsTableOrderingComposer,
          $$FocusSegmentsTableAnnotationComposer,
          $$FocusSegmentsTableCreateCompanionBuilder,
          $$FocusSegmentsTableUpdateCompanionBuilder,
          (FocusSegment, $$FocusSegmentsTableReferences),
          FocusSegment,
          PrefetchHooks Function({bool sessionId})
        > {
  $$FocusSegmentsTableTableManager(_$AppDatabase db, $FocusSegmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<SegmentKind> kind = const Value.absent(),
                Value<DateTime> fromUtc = const Value.absent(),
                Value<DateTime> toUtc = const Value.absent(),
                Value<int> spanMs = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<int> eligibleMs = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSegmentsCompanion(
                id: id,
                sessionId: sessionId,
                sequence: sequence,
                kind: kind,
                fromUtc: fromUtc,
                toUtc: toUtc,
                spanMs: spanMs,
                elapsedMs: elapsedMs,
                eligibleMs: eligibleMs,
                reason: reason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int sequence,
                required SegmentKind kind,
                required DateTime fromUtc,
                required DateTime toUtc,
                required int spanMs,
                required int elapsedMs,
                required int eligibleMs,
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSegmentsCompanion.insert(
                id: id,
                sessionId: sessionId,
                sequence: sequence,
                kind: kind,
                fromUtc: fromUtc,
                toUtc: toUtc,
                spanMs: spanMs,
                elapsedMs: elapsedMs,
                eligibleMs: eligibleMs,
                reason: reason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FocusSegmentsTable, FocusSegment>(table),
                  $$FocusSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$FocusSegmentsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$FocusSegmentsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FocusSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSegmentsTable,
      FocusSegment,
      $$FocusSegmentsTableFilterComposer,
      $$FocusSegmentsTableOrderingComposer,
      $$FocusSegmentsTableAnnotationComposer,
      $$FocusSegmentsTableCreateCompanionBuilder,
      $$FocusSegmentsTableUpdateCompanionBuilder,
      (FocusSegment, $$FocusSegmentsTableReferences),
      FocusSegment,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$TimerCommandReceiptsTableCreateCompanionBuilder =
    TimerCommandReceiptsCompanion Function({
      required String id,
      required String sessionId,
      required String action,
      required String payload,
      required DateTime committedUtc,
      Value<int> rowid,
    });
typedef $$TimerCommandReceiptsTableUpdateCompanionBuilder =
    TimerCommandReceiptsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> action,
      Value<String> payload,
      Value<DateTime> committedUtc,
      Value<int> rowid,
    });

final class $$TimerCommandReceiptsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TimerCommandReceiptsTable,
          TimerCommandReceipt
        > {
  $$TimerCommandReceiptsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FocusSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .focusSessions
      .createAlias('timer_command_receipts__session_id__focus_sessions__id');

  $$FocusSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimerCommandReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $TimerCommandReceiptsTable> {
  $$TimerCommandReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get committedUtc =>
      $composableBuilder(
        column: $table.committedUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$FocusSessionsTableFilterComposer get sessionId {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerCommandReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimerCommandReceiptsTable> {
  $$TimerCommandReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get committedUtc => $composableBuilder(
    column: $table.committedUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$FocusSessionsTableOrderingComposer get sessionId {
    final $$FocusSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerCommandReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimerCommandReceiptsTable> {
  $$TimerCommandReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get committedUtc =>
      $composableBuilder(
        column: $table.committedUtc,
        builder: (column) => column,
      );

  $$FocusSessionsTableAnnotationComposer get sessionId {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerCommandReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimerCommandReceiptsTable,
          TimerCommandReceipt,
          $$TimerCommandReceiptsTableFilterComposer,
          $$TimerCommandReceiptsTableOrderingComposer,
          $$TimerCommandReceiptsTableAnnotationComposer,
          $$TimerCommandReceiptsTableCreateCompanionBuilder,
          $$TimerCommandReceiptsTableUpdateCompanionBuilder,
          (TimerCommandReceipt, $$TimerCommandReceiptsTableReferences),
          TimerCommandReceipt,
          PrefetchHooks Function({bool sessionId})
        > {
  $$TimerCommandReceiptsTableTableManager(
    _$AppDatabase db,
    $TimerCommandReceiptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerCommandReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerCommandReceiptsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TimerCommandReceiptsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> committedUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimerCommandReceiptsCompanion(
                id: id,
                sessionId: sessionId,
                action: action,
                payload: payload,
                committedUtc: committedUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String action,
                required String payload,
                required DateTime committedUtc,
                Value<int> rowid = const Value.absent(),
              }) => TimerCommandReceiptsCompanion.insert(
                id: id,
                sessionId: sessionId,
                action: action,
                payload: payload,
                committedUtc: committedUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimerCommandReceiptsTable, TimerCommandReceipt>(
                    table,
                  ),
                  $$TimerCommandReceiptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$TimerCommandReceiptsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$TimerCommandReceiptsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TimerCommandReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimerCommandReceiptsTable,
      TimerCommandReceipt,
      $$TimerCommandReceiptsTableFilterComposer,
      $$TimerCommandReceiptsTableOrderingComposer,
      $$TimerCommandReceiptsTableAnnotationComposer,
      $$TimerCommandReceiptsTableCreateCompanionBuilder,
      $$TimerCommandReceiptsTableUpdateCompanionBuilder,
      (TimerCommandReceipt, $$TimerCommandReceiptsTableReferences),
      TimerCommandReceipt,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$ReminderPreferencesRowsTableCreateCompanionBuilder =
    ReminderPreferencesRowsCompanion Function({
      required String id,
      required int singleton,
      Value<bool> enabled,
      Value<bool> quietEnabled,
      Value<int> quietStart,
      Value<int> quietEnd,
      Value<int> rowid,
    });
typedef $$ReminderPreferencesRowsTableUpdateCompanionBuilder =
    ReminderPreferencesRowsCompanion Function({
      Value<String> id,
      Value<int> singleton,
      Value<bool> enabled,
      Value<bool> quietEnabled,
      Value<int> quietStart,
      Value<int> quietEnd,
      Value<int> rowid,
    });

class $$ReminderPreferencesRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesRowsTable> {
  $$ReminderPreferencesRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get quietEnabled => $composableBuilder(
    column: $table.quietEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietStart => $composableBuilder(
    column: $table.quietStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietEnd => $composableBuilder(
    column: $table.quietEnd,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderPreferencesRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesRowsTable> {
  $$ReminderPreferencesRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get quietEnabled => $composableBuilder(
    column: $table.quietEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietStart => $composableBuilder(
    column: $table.quietStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietEnd => $composableBuilder(
    column: $table.quietEnd,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderPreferencesRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesRowsTable> {
  $$ReminderPreferencesRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get singleton =>
      $composableBuilder(column: $table.singleton, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<bool> get quietEnabled => $composableBuilder(
    column: $table.quietEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietStart => $composableBuilder(
    column: $table.quietStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietEnd =>
      $composableBuilder(column: $table.quietEnd, builder: (column) => column);
}

class $$ReminderPreferencesRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderPreferencesRowsTable,
          ReminderPreferences,
          $$ReminderPreferencesRowsTableFilterComposer,
          $$ReminderPreferencesRowsTableOrderingComposer,
          $$ReminderPreferencesRowsTableAnnotationComposer,
          $$ReminderPreferencesRowsTableCreateCompanionBuilder,
          $$ReminderPreferencesRowsTableUpdateCompanionBuilder,
          (
            ReminderPreferences,
            BaseReferences<
              _$AppDatabase,
              $ReminderPreferencesRowsTable,
              ReminderPreferences
            >,
          ),
          ReminderPreferences,
          PrefetchHooks Function()
        > {
  $$ReminderPreferencesRowsTableTableManager(
    _$AppDatabase db,
    $ReminderPreferencesRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderPreferencesRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ReminderPreferencesRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReminderPreferencesRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> singleton = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> quietEnabled = const Value.absent(),
                Value<int> quietStart = const Value.absent(),
                Value<int> quietEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderPreferencesRowsCompanion(
                id: id,
                singleton: singleton,
                enabled: enabled,
                quietEnabled: quietEnabled,
                quietStart: quietStart,
                quietEnd: quietEnd,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int singleton,
                Value<bool> enabled = const Value.absent(),
                Value<bool> quietEnabled = const Value.absent(),
                Value<int> quietStart = const Value.absent(),
                Value<int> quietEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderPreferencesRowsCompanion.insert(
                id: id,
                singleton: singleton,
                enabled: enabled,
                quietEnabled: quietEnabled,
                quietStart: quietStart,
                quietEnd: quietEnd,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ReminderPreferencesRowsTable,
                    ReminderPreferences
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReminderPreferencesRowsTable,
                    ReminderPreferences
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderPreferencesRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderPreferencesRowsTable,
      ReminderPreferences,
      $$ReminderPreferencesRowsTableFilterComposer,
      $$ReminderPreferencesRowsTableOrderingComposer,
      $$ReminderPreferencesRowsTableAnnotationComposer,
      $$ReminderPreferencesRowsTableCreateCompanionBuilder,
      $$ReminderPreferencesRowsTableUpdateCompanionBuilder,
      (
        ReminderPreferences,
        BaseReferences<
          _$AppDatabase,
          $ReminderPreferencesRowsTable,
          ReminderPreferences
        >,
      ),
      ReminderPreferences,
      PrefetchHooks Function()
    >;
typedef $$ReminderRulesTableCreateCompanionBuilder =
    ReminderRulesCompanion Function({
      required String id,
      required ReminderKind kind,
      Value<String?> taskId,
      Value<String?> seriesId,
      Value<String?> workId,
      Value<String?> installationId,
      Value<bool> enabled,
      Value<int> leadMinutes,
      Value<int> rowid,
    });
typedef $$ReminderRulesTableUpdateCompanionBuilder =
    ReminderRulesCompanion Function({
      Value<String> id,
      Value<ReminderKind> kind,
      Value<String?> taskId,
      Value<String?> seriesId,
      Value<String?> workId,
      Value<String?> installationId,
      Value<bool> enabled,
      Value<int> leadMinutes,
      Value<int> rowid,
    });

final class $$ReminderRulesTableReferences
    extends BaseReferences<_$AppDatabase, $ReminderRulesTable, ReminderRule> {
  $$ReminderRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('reminder_rules__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<String>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ActivitySeriesRowsTable _seriesIdTable(_$AppDatabase db) => db
      .activitySeriesRows
      .createAlias('reminder_rules__series_id__activity_series__id');

  $$ActivitySeriesRowsTableProcessedTableManager? get seriesId {
    final $_column = $_itemColumn<String>('series_id');
    if ($_column == null) return null;
    final manager = $$ActivitySeriesRowsTableTableManager(
      $_db,
      $_db.activitySeriesRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlannedWorkBlocksTable _workIdTable(_$AppDatabase db) => db
      .plannedWorkBlocks
      .createAlias('reminder_rules__work_id__planned_work_blocks__id');

  $$PlannedWorkBlocksTableProcessedTableManager? get workId {
    final $_column = $_itemColumn<String>('work_id');
    if ($_column == null) return null;
    final manager = $$PlannedWorkBlocksTableTableManager(
      $_db,
      $_db.plannedWorkBlocks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InstallationsTable _installationIdTable(_$AppDatabase db) => db
      .installations
      .createAlias('reminder_rules__installation_id__installations__id');

  $$InstallationsTableProcessedTableManager? get installationId {
    final $_column = $_itemColumn<String>('installation_id');
    if ($_column == null) return null;
    final manager = $$InstallationsTableTableManager(
      $_db,
      $_db.installations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_installationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ReminderRegistrationsTable,
    List<ReminderRegistration>
  >
  _reminderRegistrationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reminderRegistrations,
        aliasName: 'reminder_rules__id__reminder_registrations__rule_id',
      );

  $$ReminderRegistrationsTableProcessedTableManager
  get reminderRegistrationsRefs {
    final manager = $$ReminderRegistrationsTableTableManager(
      $_db,
      $_db.reminderRegistrations,
    ).filter((f) => f.ruleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reminderRegistrationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReminderRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderKind, ReminderKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leadMinutes => $composableBuilder(
    column: $table.leadMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitySeriesRowsTableFilterComposer get seriesId {
    final $$ActivitySeriesRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.activitySeriesRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySeriesRowsTableFilterComposer(
            $db: $db,
            $table: $db.activitySeriesRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlannedWorkBlocksTableFilterComposer get workId {
    final $$PlannedWorkBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.plannedWorkBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedWorkBlocksTableFilterComposer(
            $db: $db,
            $table: $db.plannedWorkBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstallationsTableFilterComposer get installationId {
    final $$InstallationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.installationId,
      referencedTable: $db.installations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallationsTableFilterComposer(
            $db: $db,
            $table: $db.installations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reminderRegistrationsRefs(
    Expression<bool> Function($$ReminderRegistrationsTableFilterComposer f) f,
  ) {
    final $$ReminderRegistrationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reminderRegistrations,
          getReferencedColumn: (t) => t.ruleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReminderRegistrationsTableFilterComposer(
                $db: $db,
                $table: $db.reminderRegistrations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ReminderRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leadMinutes => $composableBuilder(
    column: $table.leadMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitySeriesRowsTableOrderingComposer get seriesId {
    final $$ActivitySeriesRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.activitySeriesRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySeriesRowsTableOrderingComposer(
            $db: $db,
            $table: $db.activitySeriesRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlannedWorkBlocksTableOrderingComposer get workId {
    final $$PlannedWorkBlocksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.plannedWorkBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedWorkBlocksTableOrderingComposer(
            $db: $db,
            $table: $db.plannedWorkBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstallationsTableOrderingComposer get installationId {
    final $$InstallationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.installationId,
      referencedTable: $db.installations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallationsTableOrderingComposer(
            $db: $db,
            $table: $db.installations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get leadMinutes => $composableBuilder(
    column: $table.leadMinutes,
    builder: (column) => column,
  );

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitySeriesRowsTableAnnotationComposer get seriesId {
    final $$ActivitySeriesRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.seriesId,
          referencedTable: $db.activitySeriesRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivitySeriesRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.activitySeriesRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$PlannedWorkBlocksTableAnnotationComposer get workId {
    final $$PlannedWorkBlocksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workId,
          referencedTable: $db.plannedWorkBlocks,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlannedWorkBlocksTableAnnotationComposer(
                $db: $db,
                $table: $db.plannedWorkBlocks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$InstallationsTableAnnotationComposer get installationId {
    final $$InstallationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.installationId,
      referencedTable: $db.installations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallationsTableAnnotationComposer(
            $db: $db,
            $table: $db.installations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reminderRegistrationsRefs<T extends Object>(
    Expression<T> Function($$ReminderRegistrationsTableAnnotationComposer a) f,
  ) {
    final $$ReminderRegistrationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reminderRegistrations,
          getReferencedColumn: (t) => t.ruleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReminderRegistrationsTableAnnotationComposer(
                $db: $db,
                $table: $db.reminderRegistrations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ReminderRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderRulesTable,
          ReminderRule,
          $$ReminderRulesTableFilterComposer,
          $$ReminderRulesTableOrderingComposer,
          $$ReminderRulesTableAnnotationComposer,
          $$ReminderRulesTableCreateCompanionBuilder,
          $$ReminderRulesTableUpdateCompanionBuilder,
          (ReminderRule, $$ReminderRulesTableReferences),
          ReminderRule,
          PrefetchHooks Function({
            bool taskId,
            bool seriesId,
            bool workId,
            bool installationId,
            bool reminderRegistrationsRefs,
          })
        > {
  $$ReminderRulesTableTableManager(_$AppDatabase db, $ReminderRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<ReminderKind> kind = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<String?> workId = const Value.absent(),
                Value<String?> installationId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> leadMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRulesCompanion(
                id: id,
                kind: kind,
                taskId: taskId,
                seriesId: seriesId,
                workId: workId,
                installationId: installationId,
                enabled: enabled,
                leadMinutes: leadMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required ReminderKind kind,
                Value<String?> taskId = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<String?> workId = const Value.absent(),
                Value<String?> installationId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> leadMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRulesCompanion.insert(
                id: id,
                kind: kind,
                taskId: taskId,
                seriesId: seriesId,
                workId: workId,
                installationId: installationId,
                enabled: enabled,
                leadMinutes: leadMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReminderRulesTable, ReminderRule>(table),
                  $$ReminderRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                taskId = false,
                seriesId = false,
                workId = false,
                installationId = false,
                reminderRegistrationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reminderRegistrationsRefs) db.reminderRegistrations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (taskId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.taskId,
                            referencedTable: $$ReminderRulesTableReferences
                                ._taskIdTable(db),
                            referencedColumn: $$ReminderRulesTableReferences
                                ._taskIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (seriesId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.seriesId,
                            referencedTable: $$ReminderRulesTableReferences
                                ._seriesIdTable(db),
                            referencedColumn: $$ReminderRulesTableReferences
                                ._seriesIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (workId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workId,
                            referencedTable: $$ReminderRulesTableReferences
                                ._workIdTable(db),
                            referencedColumn: $$ReminderRulesTableReferences
                                ._workIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (installationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.installationId,
                            referencedTable: $$ReminderRulesTableReferences
                                ._installationIdTable(db),
                            referencedColumn: $$ReminderRulesTableReferences
                                ._installationIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reminderRegistrationsRefs)
                        await $_getPrefetchedData<
                          ReminderRule,
                          $ReminderRulesTable,
                          ReminderRegistration
                        >(
                          currentTable: table,
                          referencedTable: $$ReminderRulesTableReferences
                              ._reminderRegistrationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReminderRulesTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderRegistrationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ruleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ReminderRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderRulesTable,
      ReminderRule,
      $$ReminderRulesTableFilterComposer,
      $$ReminderRulesTableOrderingComposer,
      $$ReminderRulesTableAnnotationComposer,
      $$ReminderRulesTableCreateCompanionBuilder,
      $$ReminderRulesTableUpdateCompanionBuilder,
      (ReminderRule, $$ReminderRulesTableReferences),
      ReminderRule,
      PrefetchHooks Function({
        bool taskId,
        bool seriesId,
        bool workId,
        bool installationId,
        bool reminderRegistrationsRefs,
      })
    >;
typedef $$ReminderRegistrationsTableCreateCompanionBuilder =
    ReminderRegistrationsCompanion Function({
      required String id,
      required String ruleId,
      required String identityKey,
      required int notificationId,
      Value<String?> originalDate,
      Value<String?> sessionId,
      required DateTime sourceUtc,
      required DateTime dueUtc,
      required String fingerprint,
      required RegistrationState state,
      Value<String?> error,
      Value<DateTime?> registeredAtUtc,
      Value<DateTime?> openedAtUtc,
      Value<int> rowid,
    });
typedef $$ReminderRegistrationsTableUpdateCompanionBuilder =
    ReminderRegistrationsCompanion Function({
      Value<String> id,
      Value<String> ruleId,
      Value<String> identityKey,
      Value<int> notificationId,
      Value<String?> originalDate,
      Value<String?> sessionId,
      Value<DateTime> sourceUtc,
      Value<DateTime> dueUtc,
      Value<String> fingerprint,
      Value<RegistrationState> state,
      Value<String?> error,
      Value<DateTime?> registeredAtUtc,
      Value<DateTime?> openedAtUtc,
      Value<int> rowid,
    });

final class $$ReminderRegistrationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReminderRegistrationsTable,
          ReminderRegistration
        > {
  $$ReminderRegistrationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReminderRulesTable _ruleIdTable(_$AppDatabase db) => db.reminderRules
      .createAlias('reminder_registrations__rule_id__reminder_rules__id');

  $$ReminderRulesTableProcessedTableManager get ruleId {
    final $_column = $_itemColumn<String>('rule_id')!;

    final manager = $$ReminderRulesTableTableManager(
      $_db,
      $_db.reminderRules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FocusSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .focusSessions
      .createAlias('reminder_registrations__session_id__focus_sessions__id');

  $$FocusSessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<String>('session_id');
    if ($_column == null) return null;
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReminderRegistrationsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderRegistrationsTable> {
  $$ReminderRegistrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identityKey => $composableBuilder(
    column: $table.identityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get sourceUtc =>
      $composableBuilder(
        column: $table.sourceUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get dueUtc =>
      $composableBuilder(
        column: $table.dueUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RegistrationState, RegistrationState, String>
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int>
  get registeredAtUtc => $composableBuilder(
    column: $table.registeredAtUtc,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get openedAtUtc =>
      $composableBuilder(
        column: $table.openedAtUtc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$ReminderRulesTableFilterComposer get ruleId {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableFilterComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FocusSessionsTableFilterComposer get sessionId {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRegistrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderRegistrationsTable> {
  $$ReminderRegistrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identityKey => $composableBuilder(
    column: $table.identityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceUtc => $composableBuilder(
    column: $table.sourceUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueUtc => $composableBuilder(
    column: $table.dueUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get registeredAtUtc => $composableBuilder(
    column: $table.registeredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openedAtUtc => $composableBuilder(
    column: $table.openedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReminderRulesTableOrderingComposer get ruleId {
    final $$ReminderRulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableOrderingComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FocusSessionsTableOrderingComposer get sessionId {
    final $$FocusSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRegistrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderRegistrationsTable> {
  $$ReminderRegistrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get identityKey => $composableBuilder(
    column: $table.identityKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get sourceUtc =>
      $composableBuilder(column: $table.sourceUtc, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get dueUtc =>
      $composableBuilder(column: $table.dueUtc, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RegistrationState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get registeredAtUtc =>
      $composableBuilder(
        column: $table.registeredAtUtc,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get openedAtUtc =>
      $composableBuilder(
        column: $table.openedAtUtc,
        builder: (column) => column,
      );

  $$ReminderRulesTableAnnotationComposer get ruleId {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FocusSessionsTableAnnotationComposer get sessionId {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRegistrationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderRegistrationsTable,
          ReminderRegistration,
          $$ReminderRegistrationsTableFilterComposer,
          $$ReminderRegistrationsTableOrderingComposer,
          $$ReminderRegistrationsTableAnnotationComposer,
          $$ReminderRegistrationsTableCreateCompanionBuilder,
          $$ReminderRegistrationsTableUpdateCompanionBuilder,
          (ReminderRegistration, $$ReminderRegistrationsTableReferences),
          ReminderRegistration,
          PrefetchHooks Function({bool ruleId, bool sessionId})
        > {
  $$ReminderRegistrationsTableTableManager(
    _$AppDatabase db,
    $ReminderRegistrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderRegistrationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ReminderRegistrationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReminderRegistrationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ruleId = const Value.absent(),
                Value<String> identityKey = const Value.absent(),
                Value<int> notificationId = const Value.absent(),
                Value<String?> originalDate = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<DateTime> sourceUtc = const Value.absent(),
                Value<DateTime> dueUtc = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<RegistrationState> state = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime?> registeredAtUtc = const Value.absent(),
                Value<DateTime?> openedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRegistrationsCompanion(
                id: id,
                ruleId: ruleId,
                identityKey: identityKey,
                notificationId: notificationId,
                originalDate: originalDate,
                sessionId: sessionId,
                sourceUtc: sourceUtc,
                dueUtc: dueUtc,
                fingerprint: fingerprint,
                state: state,
                error: error,
                registeredAtUtc: registeredAtUtc,
                openedAtUtc: openedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ruleId,
                required String identityKey,
                required int notificationId,
                Value<String?> originalDate = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                required DateTime sourceUtc,
                required DateTime dueUtc,
                required String fingerprint,
                required RegistrationState state,
                Value<String?> error = const Value.absent(),
                Value<DateTime?> registeredAtUtc = const Value.absent(),
                Value<DateTime?> openedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRegistrationsCompanion.insert(
                id: id,
                ruleId: ruleId,
                identityKey: identityKey,
                notificationId: notificationId,
                originalDate: originalDate,
                sessionId: sessionId,
                sourceUtc: sourceUtc,
                dueUtc: dueUtc,
                fingerprint: fingerprint,
                state: state,
                error: error,
                registeredAtUtc: registeredAtUtc,
                openedAtUtc: openedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ReminderRegistrationsTable,
                    ReminderRegistration
                  >(table),
                  $$ReminderRegistrationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ruleId = false, sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ruleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ruleId,
                        referencedTable: $$ReminderRegistrationsTableReferences
                            ._ruleIdTable(db),
                        referencedColumn: $$ReminderRegistrationsTableReferences
                            ._ruleIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$ReminderRegistrationsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$ReminderRegistrationsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReminderRegistrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderRegistrationsTable,
      ReminderRegistration,
      $$ReminderRegistrationsTableFilterComposer,
      $$ReminderRegistrationsTableOrderingComposer,
      $$ReminderRegistrationsTableAnnotationComposer,
      $$ReminderRegistrationsTableCreateCompanionBuilder,
      $$ReminderRegistrationsTableUpdateCompanionBuilder,
      (ReminderRegistration, $$ReminderRegistrationsTableReferences),
      ReminderRegistration,
      PrefetchHooks Function({bool ruleId, bool sessionId})
    >;
typedef $$WeeklyReflectionsTableCreateCompanionBuilder =
    WeeklyReflectionsCompanion Function({
      required String id,
      required CalendarDate weekStart,
      required String helped,
      required String obstacles,
      required String adjustment,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WeeklyReflectionsTableUpdateCompanionBuilder =
    WeeklyReflectionsCompanion Function({
      Value<String> id,
      Value<CalendarDate> weekStart,
      Value<String> helped,
      Value<String> obstacles,
      Value<String> adjustment,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WeeklyReflectionsTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyReflectionsTable> {
  $$WeeklyReflectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get helped => $composableBuilder(
    column: $table.helped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get obstacles => $composableBuilder(
    column: $table.obstacles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adjustment => $composableBuilder(
    column: $table.adjustment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$WeeklyReflectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyReflectionsTable> {
  $$WeeklyReflectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get helped => $composableBuilder(
    column: $table.helped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get obstacles => $composableBuilder(
    column: $table.obstacles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adjustment => $composableBuilder(
    column: $table.adjustment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklyReflectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyReflectionsTable> {
  $$WeeklyReflectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<String> get helped =>
      $composableBuilder(column: $table.helped, builder: (column) => column);

  GeneratedColumn<String> get obstacles =>
      $composableBuilder(column: $table.obstacles, builder: (column) => column);

  GeneratedColumn<String> get adjustment => $composableBuilder(
    column: $table.adjustment,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WeeklyReflectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyReflectionsTable,
          WeeklyReflection,
          $$WeeklyReflectionsTableFilterComposer,
          $$WeeklyReflectionsTableOrderingComposer,
          $$WeeklyReflectionsTableAnnotationComposer,
          $$WeeklyReflectionsTableCreateCompanionBuilder,
          $$WeeklyReflectionsTableUpdateCompanionBuilder,
          (
            WeeklyReflection,
            BaseReferences<
              _$AppDatabase,
              $WeeklyReflectionsTable,
              WeeklyReflection
            >,
          ),
          WeeklyReflection,
          PrefetchHooks Function()
        > {
  $$WeeklyReflectionsTableTableManager(
    _$AppDatabase db,
    $WeeklyReflectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyReflectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyReflectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyReflectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<CalendarDate> weekStart = const Value.absent(),
                Value<String> helped = const Value.absent(),
                Value<String> obstacles = const Value.absent(),
                Value<String> adjustment = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeeklyReflectionsCompanion(
                id: id,
                weekStart: weekStart,
                helped: helped,
                obstacles: obstacles,
                adjustment: adjustment,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required CalendarDate weekStart,
                required String helped,
                required String obstacles,
                required String adjustment,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WeeklyReflectionsCompanion.insert(
                id: id,
                weekStart: weekStart,
                helped: helped,
                obstacles: obstacles,
                adjustment: adjustment,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeeklyReflectionsTable, WeeklyReflection>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WeeklyReflectionsTable,
                    WeeklyReflection
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeeklyReflectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyReflectionsTable,
      WeeklyReflection,
      $$WeeklyReflectionsTableFilterComposer,
      $$WeeklyReflectionsTableOrderingComposer,
      $$WeeklyReflectionsTableAnnotationComposer,
      $$WeeklyReflectionsTableCreateCompanionBuilder,
      $$WeeklyReflectionsTableUpdateCompanionBuilder,
      (
        WeeklyReflection,
        BaseReferences<
          _$AppDatabase,
          $WeeklyReflectionsTable,
          WeeklyReflection
        >,
      ),
      WeeklyReflection,
      PrefetchHooks Function()
    >;
typedef $$NotificationCleanupRowsTableCreateCompanionBuilder =
    NotificationCleanupRowsCompanion Function({Value<int> notificationId});
typedef $$NotificationCleanupRowsTableUpdateCompanionBuilder =
    NotificationCleanupRowsCompanion Function({Value<int> notificationId});

class $$NotificationCleanupRowsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationCleanupRowsTable> {
  $$NotificationCleanupRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationCleanupRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationCleanupRowsTable> {
  $$NotificationCleanupRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationCleanupRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationCleanupRowsTable> {
  $$NotificationCleanupRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );
}

class $$NotificationCleanupRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationCleanupRowsTable,
          NotificationCleanupRow,
          $$NotificationCleanupRowsTableFilterComposer,
          $$NotificationCleanupRowsTableOrderingComposer,
          $$NotificationCleanupRowsTableAnnotationComposer,
          $$NotificationCleanupRowsTableCreateCompanionBuilder,
          $$NotificationCleanupRowsTableUpdateCompanionBuilder,
          (
            NotificationCleanupRow,
            BaseReferences<
              _$AppDatabase,
              $NotificationCleanupRowsTable,
              NotificationCleanupRow
            >,
          ),
          NotificationCleanupRow,
          PrefetchHooks Function()
        > {
  $$NotificationCleanupRowsTableTableManager(
    _$AppDatabase db,
    $NotificationCleanupRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationCleanupRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationCleanupRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationCleanupRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({Value<int> notificationId = const Value.absent()}) =>
                  NotificationCleanupRowsCompanion(
                    notificationId: notificationId,
                  ),
          createCompanionCallback:
              ({Value<int> notificationId = const Value.absent()}) =>
                  NotificationCleanupRowsCompanion.insert(
                    notificationId: notificationId,
                  ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $NotificationCleanupRowsTable,
                    NotificationCleanupRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $NotificationCleanupRowsTable,
                    NotificationCleanupRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationCleanupRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationCleanupRowsTable,
      NotificationCleanupRow,
      $$NotificationCleanupRowsTableFilterComposer,
      $$NotificationCleanupRowsTableOrderingComposer,
      $$NotificationCleanupRowsTableAnnotationComposer,
      $$NotificationCleanupRowsTableCreateCompanionBuilder,
      $$NotificationCleanupRowsTableUpdateCompanionBuilder,
      (
        NotificationCleanupRow,
        BaseReferences<
          _$AppDatabase,
          $NotificationCleanupRowsTable,
          NotificationCleanupRow
        >,
      ),
      NotificationCleanupRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db, _db.subtasks);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$NoteTaskLinksTableTableManager get noteTaskLinks =>
      $$NoteTaskLinksTableTableManager(_db, _db.noteTaskLinks);
  $$DailyPrioritiesTableTableManager get dailyPriorities =>
      $$DailyPrioritiesTableTableManager(_db, _db.dailyPriorities);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$InstallationsTableTableManager get installations =>
      $$InstallationsTableTableManager(_db, _db.installations);
  $$ActivitySeriesRowsTableTableManager get activitySeriesRows =>
      $$ActivitySeriesRowsTableTableManager(_db, _db.activitySeriesRows);
  $$ActivityExceptionsTableTableManager get activityExceptions =>
      $$ActivityExceptionsTableTableManager(_db, _db.activityExceptions);
  $$NoteActivityLinksTableTableManager get noteActivityLinks =>
      $$NoteActivityLinksTableTableManager(_db, _db.noteActivityLinks);
  $$PlannedWorkBlocksTableTableManager get plannedWorkBlocks =>
      $$PlannedWorkBlocksTableTableManager(_db, _db.plannedWorkBlocks);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$FocusSegmentsTableTableManager get focusSegments =>
      $$FocusSegmentsTableTableManager(_db, _db.focusSegments);
  $$TimerCommandReceiptsTableTableManager get timerCommandReceipts =>
      $$TimerCommandReceiptsTableTableManager(_db, _db.timerCommandReceipts);
  $$ReminderPreferencesRowsTableTableManager get reminderPreferencesRows =>
      $$ReminderPreferencesRowsTableTableManager(
        _db,
        _db.reminderPreferencesRows,
      );
  $$ReminderRulesTableTableManager get reminderRules =>
      $$ReminderRulesTableTableManager(_db, _db.reminderRules);
  $$ReminderRegistrationsTableTableManager get reminderRegistrations =>
      $$ReminderRegistrationsTableTableManager(_db, _db.reminderRegistrations);
  $$WeeklyReflectionsTableTableManager get weeklyReflections =>
      $$WeeklyReflectionsTableTableManager(_db, _db.weeklyReflections);
  $$NotificationCleanupRowsTableTableManager get notificationCleanupRows =>
      $$NotificationCleanupRowsTableTableManager(
        _db,
        _db.notificationCleanupRows,
      );
}
