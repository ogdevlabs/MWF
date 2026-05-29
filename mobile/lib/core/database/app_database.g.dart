// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalProgramsTable extends LocalPrograms
    with TableInfo<$LocalProgramsTable, LocalProgram> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProgramsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationWeeksMeta = const VerificationMeta(
    'durationWeeks',
  );
  @override
  late final GeneratedColumn<int> durationWeeks = GeneratedColumn<int>(
    'duration_weeks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedMeta = const VerificationMeta(
    'published',
  );
  @override
  late final GeneratedColumn<bool> published = GeneratedColumn<bool>(
    'published',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("published" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    difficulty,
    durationWeeks,
    thumbnailUrl,
    published,
    publishedAt,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_programs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProgram> instance, {
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
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('duration_weeks')) {
      context.handle(
        _durationWeeksMeta,
        durationWeeks.isAcceptableOrUnknown(
          data['duration_weeks']!,
          _durationWeeksMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationWeeksMeta);
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('published')) {
      context.handle(
        _publishedMeta,
        published.isAcceptableOrUnknown(data['published']!, _publishedMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  LocalProgram map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProgram(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
      durationWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_weeks'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      published: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}published'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalProgramsTable createAlias(String alias) {
    return $LocalProgramsTable(attachedDatabase, alias);
  }
}

class LocalProgram extends DataClass implements Insertable<LocalProgram> {
  final String id;
  final String title;
  final String? description;
  final String difficulty;
  final int durationWeeks;
  final String? thumbnailUrl;
  final bool published;
  final DateTime? publishedAt;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalProgram({
    required this.id,
    required this.title,
    this.description,
    required this.difficulty,
    required this.durationWeeks,
    this.thumbnailUrl,
    required this.published,
    this.publishedAt,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['difficulty'] = Variable<String>(difficulty);
    map['duration_weeks'] = Variable<int>(durationWeeks);
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    map['published'] = Variable<bool>(published);
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalProgramsCompanion toCompanion(bool nullToAbsent) {
    return LocalProgramsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      difficulty: Value(difficulty),
      durationWeeks: Value(durationWeeks),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      published: Value(published),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalProgram.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProgram(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      durationWeeks: serializer.fromJson<int>(json['durationWeeks']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      published: serializer.fromJson<bool>(json['published']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'difficulty': serializer.toJson<String>(difficulty),
      'durationWeeks': serializer.toJson<int>(durationWeeks),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'published': serializer.toJson<bool>(published),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalProgram copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    String? difficulty,
    int? durationWeeks,
    Value<String?> thumbnailUrl = const Value.absent(),
    bool? published,
    Value<DateTime?> publishedAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalProgram(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    difficulty: difficulty ?? this.difficulty,
    durationWeeks: durationWeeks ?? this.durationWeeks,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    published: published ?? this.published,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalProgram copyWithCompanion(LocalProgramsCompanion data) {
    return LocalProgram(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      durationWeeks: data.durationWeeks.present
          ? data.durationWeeks.value
          : this.durationWeeks,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      published: data.published.present ? data.published.value : this.published,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProgram(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('difficulty: $difficulty, ')
          ..write('durationWeeks: $durationWeeks, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('published: $published, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    difficulty,
    durationWeeks,
    thumbnailUrl,
    published,
    publishedAt,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProgram &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.difficulty == this.difficulty &&
          other.durationWeeks == this.durationWeeks &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.published == this.published &&
          other.publishedAt == this.publishedAt &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalProgramsCompanion extends UpdateCompanion<LocalProgram> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> difficulty;
  final Value<int> durationWeeks;
  final Value<String?> thumbnailUrl;
  final Value<bool> published;
  final Value<DateTime?> publishedAt;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalProgramsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.durationWeeks = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.published = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProgramsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required String difficulty,
    required int durationWeeks,
    this.thumbnailUrl = const Value.absent(),
    this.published = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       difficulty = Value(difficulty),
       durationWeeks = Value(durationWeeks),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalProgram> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? difficulty,
    Expression<int>? durationWeeks,
    Expression<String>? thumbnailUrl,
    Expression<bool>? published,
    Expression<DateTime>? publishedAt,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (difficulty != null) 'difficulty': difficulty,
      if (durationWeeks != null) 'duration_weeks': durationWeeks,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (published != null) 'published': published,
      if (publishedAt != null) 'published_at': publishedAt,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProgramsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? difficulty,
    Value<int>? durationWeeks,
    Value<String?>? thumbnailUrl,
    Value<bool>? published,
    Value<DateTime?>? publishedAt,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalProgramsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      published: published ?? this.published,
      publishedAt: publishedAt ?? this.publishedAt,
      createdBy: createdBy ?? this.createdBy,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (durationWeeks.present) {
      map['duration_weeks'] = Variable<int>(durationWeeks.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (published.present) {
      map['published'] = Variable<bool>(published.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProgramsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('difficulty: $difficulty, ')
          ..write('durationWeeks: $durationWeeks, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('published: $published, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSessionsTable extends LocalSessions
    with TableInfo<$LocalSessionsTable, LocalSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<String> programId = GeneratedColumn<String>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayNumberMeta = const VerificationMeta(
    'dayNumber',
  );
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
    'day_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  List<GeneratedColumn> get $columns => [
    id,
    programId,
    dayNumber,
    title,
    description,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('day_number')) {
      context.handle(
        _dayNumberMeta,
        dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_dayNumberMeta);
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  LocalSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program_id'],
      )!,
      dayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_number'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalSessionsTable createAlias(String alias) {
    return $LocalSessionsTable(attachedDatabase, alias);
  }
}

class LocalSession extends DataClass implements Insertable<LocalSession> {
  final String id;
  final String programId;
  final int dayNumber;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalSession({
    required this.id,
    required this.programId,
    required this.dayNumber,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['program_id'] = Variable<String>(programId);
    map['day_number'] = Variable<int>(dayNumber);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalSessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalSessionsCompanion(
      id: Value(id),
      programId: Value(programId),
      dayNumber: Value(dayNumber),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSession(
      id: serializer.fromJson<String>(json['id']),
      programId: serializer.fromJson<String>(json['programId']),
      dayNumber: serializer.fromJson<int>(json['dayNumber']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'programId': serializer.toJson<String>(programId),
      'dayNumber': serializer.toJson<int>(dayNumber),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalSession copyWith({
    String? id,
    String? programId,
    int? dayNumber,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalSession(
    id: id ?? this.id,
    programId: programId ?? this.programId,
    dayNumber: dayNumber ?? this.dayNumber,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalSession copyWithCompanion(LocalSessionsCompanion data) {
    return LocalSession(
      id: data.id.present ? data.id.value : this.id,
      programId: data.programId.present ? data.programId.value : this.programId,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSession(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    programId,
    dayNumber,
    title,
    description,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSession &&
          other.id == this.id &&
          other.programId == this.programId &&
          other.dayNumber == this.dayNumber &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalSessionsCompanion extends UpdateCompanion<LocalSession> {
  final Value<String> id;
  final Value<String> programId;
  final Value<int> dayNumber;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalSessionsCompanion({
    this.id = const Value.absent(),
    this.programId = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSessionsCompanion.insert({
    required String id,
    required String programId,
    required int dayNumber,
    required String title,
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       programId = Value(programId),
       dayNumber = Value(dayNumber),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalSession> custom({
    Expression<String>? id,
    Expression<String>? programId,
    Expression<int>? dayNumber,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (programId != null) 'program_id': programId,
      if (dayNumber != null) 'day_number': dayNumber,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? programId,
    Value<int>? dayNumber,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalSessionsCompanion(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      description: description ?? this.description,
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
    if (programId.present) {
      map['program_id'] = Variable<String>(programId.value);
    }
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSessionsCompanion(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalExercisesTable extends LocalExercises
    with TableInfo<$LocalExercisesTable, LocalExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
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
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cueTextMeta = const VerificationMeta(
    'cueText',
  );
  @override
  late final GeneratedColumn<String> cueText = GeneratedColumn<String>(
    'cue_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muxAssetIdMeta = const VerificationMeta(
    'muxAssetId',
  );
  @override
  late final GeneratedColumn<String> muxAssetId = GeneratedColumn<String>(
    'mux_asset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muxPlaybackIdMeta = const VerificationMeta(
    'muxPlaybackId',
  );
  @override
  late final GeneratedColumn<String> muxPlaybackId = GeneratedColumn<String>(
    'mux_playback_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muxDownloadUrlMeta = const VerificationMeta(
    'muxDownloadUrl',
  );
  @override
  late final GeneratedColumn<String> muxDownloadUrl = GeneratedColumn<String>(
    'mux_download_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelAssetUrlMeta = const VerificationMeta(
    'modelAssetUrl',
  );
  @override
  late final GeneratedColumn<String> modelAssetUrl = GeneratedColumn<String>(
    'model_asset_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repCountMeta = const VerificationMeta(
    'repCount',
  );
  @override
  late final GeneratedColumn<int> repCount = GeneratedColumn<int>(
    'rep_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _videoVersionMeta = const VerificationMeta(
    'videoVersion',
  );
  @override
  late final GeneratedColumn<int> videoVersion = GeneratedColumn<int>(
    'video_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _localVideoPathMeta = const VerificationMeta(
    'localVideoPath',
  );
  @override
  late final GeneratedColumn<String> localVideoPath = GeneratedColumn<String>(
    'local_video_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localModelPathMeta = const VerificationMeta(
    'localModelPath',
  );
  @override
  late final GeneratedColumn<String> localModelPath = GeneratedColumn<String>(
    'local_model_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    displayOrder,
    title,
    cueText,
    muxAssetId,
    muxPlaybackId,
    muxDownloadUrl,
    modelAssetUrl,
    repCount,
    durationSeconds,
    videoVersion,
    localVideoPath,
    localModelPath,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalExercise> instance, {
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
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayOrderMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cue_text')) {
      context.handle(
        _cueTextMeta,
        cueText.isAcceptableOrUnknown(data['cue_text']!, _cueTextMeta),
      );
    }
    if (data.containsKey('mux_asset_id')) {
      context.handle(
        _muxAssetIdMeta,
        muxAssetId.isAcceptableOrUnknown(
          data['mux_asset_id']!,
          _muxAssetIdMeta,
        ),
      );
    }
    if (data.containsKey('mux_playback_id')) {
      context.handle(
        _muxPlaybackIdMeta,
        muxPlaybackId.isAcceptableOrUnknown(
          data['mux_playback_id']!,
          _muxPlaybackIdMeta,
        ),
      );
    }
    if (data.containsKey('mux_download_url')) {
      context.handle(
        _muxDownloadUrlMeta,
        muxDownloadUrl.isAcceptableOrUnknown(
          data['mux_download_url']!,
          _muxDownloadUrlMeta,
        ),
      );
    }
    if (data.containsKey('model_asset_url')) {
      context.handle(
        _modelAssetUrlMeta,
        modelAssetUrl.isAcceptableOrUnknown(
          data['model_asset_url']!,
          _modelAssetUrlMeta,
        ),
      );
    }
    if (data.containsKey('rep_count')) {
      context.handle(
        _repCountMeta,
        repCount.isAcceptableOrUnknown(data['rep_count']!, _repCountMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('video_version')) {
      context.handle(
        _videoVersionMeta,
        videoVersion.isAcceptableOrUnknown(
          data['video_version']!,
          _videoVersionMeta,
        ),
      );
    }
    if (data.containsKey('local_video_path')) {
      context.handle(
        _localVideoPathMeta,
        localVideoPath.isAcceptableOrUnknown(
          data['local_video_path']!,
          _localVideoPathMeta,
        ),
      );
    }
    if (data.containsKey('local_model_path')) {
      context.handle(
        _localModelPathMeta,
        localModelPath.isAcceptableOrUnknown(
          data['local_model_path']!,
          _localModelPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  LocalExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      cueText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cue_text'],
      ),
      muxAssetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mux_asset_id'],
      ),
      muxPlaybackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mux_playback_id'],
      ),
      muxDownloadUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mux_download_url'],
      ),
      modelAssetUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_asset_url'],
      ),
      repCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_count'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      videoVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}video_version'],
      )!,
      localVideoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_video_path'],
      ),
      localModelPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_model_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalExercisesTable createAlias(String alias) {
    return $LocalExercisesTable(attachedDatabase, alias);
  }
}

class LocalExercise extends DataClass implements Insertable<LocalExercise> {
  final String id;
  final String sessionId;
  final int displayOrder;
  final String title;
  final String? cueText;
  final String? muxAssetId;
  final String? muxPlaybackId;
  final String? muxDownloadUrl;
  final String? modelAssetUrl;
  final int? repCount;
  final int? durationSeconds;
  final int videoVersion;
  final String? localVideoPath;
  final String? localModelPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalExercise({
    required this.id,
    required this.sessionId,
    required this.displayOrder,
    required this.title,
    this.cueText,
    this.muxAssetId,
    this.muxPlaybackId,
    this.muxDownloadUrl,
    this.modelAssetUrl,
    this.repCount,
    this.durationSeconds,
    required this.videoVersion,
    this.localVideoPath,
    this.localModelPath,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['display_order'] = Variable<int>(displayOrder);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || cueText != null) {
      map['cue_text'] = Variable<String>(cueText);
    }
    if (!nullToAbsent || muxAssetId != null) {
      map['mux_asset_id'] = Variable<String>(muxAssetId);
    }
    if (!nullToAbsent || muxPlaybackId != null) {
      map['mux_playback_id'] = Variable<String>(muxPlaybackId);
    }
    if (!nullToAbsent || muxDownloadUrl != null) {
      map['mux_download_url'] = Variable<String>(muxDownloadUrl);
    }
    if (!nullToAbsent || modelAssetUrl != null) {
      map['model_asset_url'] = Variable<String>(modelAssetUrl);
    }
    if (!nullToAbsent || repCount != null) {
      map['rep_count'] = Variable<int>(repCount);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['video_version'] = Variable<int>(videoVersion);
    if (!nullToAbsent || localVideoPath != null) {
      map['local_video_path'] = Variable<String>(localVideoPath);
    }
    if (!nullToAbsent || localModelPath != null) {
      map['local_model_path'] = Variable<String>(localModelPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalExercisesCompanion toCompanion(bool nullToAbsent) {
    return LocalExercisesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      displayOrder: Value(displayOrder),
      title: Value(title),
      cueText: cueText == null && nullToAbsent
          ? const Value.absent()
          : Value(cueText),
      muxAssetId: muxAssetId == null && nullToAbsent
          ? const Value.absent()
          : Value(muxAssetId),
      muxPlaybackId: muxPlaybackId == null && nullToAbsent
          ? const Value.absent()
          : Value(muxPlaybackId),
      muxDownloadUrl: muxDownloadUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(muxDownloadUrl),
      modelAssetUrl: modelAssetUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(modelAssetUrl),
      repCount: repCount == null && nullToAbsent
          ? const Value.absent()
          : Value(repCount),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      videoVersion: Value(videoVersion),
      localVideoPath: localVideoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localVideoPath),
      localModelPath: localModelPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localModelPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalExercise(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      title: serializer.fromJson<String>(json['title']),
      cueText: serializer.fromJson<String?>(json['cueText']),
      muxAssetId: serializer.fromJson<String?>(json['muxAssetId']),
      muxPlaybackId: serializer.fromJson<String?>(json['muxPlaybackId']),
      muxDownloadUrl: serializer.fromJson<String?>(json['muxDownloadUrl']),
      modelAssetUrl: serializer.fromJson<String?>(json['modelAssetUrl']),
      repCount: serializer.fromJson<int?>(json['repCount']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      videoVersion: serializer.fromJson<int>(json['videoVersion']),
      localVideoPath: serializer.fromJson<String?>(json['localVideoPath']),
      localModelPath: serializer.fromJson<String?>(json['localModelPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'title': serializer.toJson<String>(title),
      'cueText': serializer.toJson<String?>(cueText),
      'muxAssetId': serializer.toJson<String?>(muxAssetId),
      'muxPlaybackId': serializer.toJson<String?>(muxPlaybackId),
      'muxDownloadUrl': serializer.toJson<String?>(muxDownloadUrl),
      'modelAssetUrl': serializer.toJson<String?>(modelAssetUrl),
      'repCount': serializer.toJson<int?>(repCount),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'videoVersion': serializer.toJson<int>(videoVersion),
      'localVideoPath': serializer.toJson<String?>(localVideoPath),
      'localModelPath': serializer.toJson<String?>(localModelPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalExercise copyWith({
    String? id,
    String? sessionId,
    int? displayOrder,
    String? title,
    Value<String?> cueText = const Value.absent(),
    Value<String?> muxAssetId = const Value.absent(),
    Value<String?> muxPlaybackId = const Value.absent(),
    Value<String?> muxDownloadUrl = const Value.absent(),
    Value<String?> modelAssetUrl = const Value.absent(),
    Value<int?> repCount = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    int? videoVersion,
    Value<String?> localVideoPath = const Value.absent(),
    Value<String?> localModelPath = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalExercise(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    displayOrder: displayOrder ?? this.displayOrder,
    title: title ?? this.title,
    cueText: cueText.present ? cueText.value : this.cueText,
    muxAssetId: muxAssetId.present ? muxAssetId.value : this.muxAssetId,
    muxPlaybackId: muxPlaybackId.present
        ? muxPlaybackId.value
        : this.muxPlaybackId,
    muxDownloadUrl: muxDownloadUrl.present
        ? muxDownloadUrl.value
        : this.muxDownloadUrl,
    modelAssetUrl: modelAssetUrl.present
        ? modelAssetUrl.value
        : this.modelAssetUrl,
    repCount: repCount.present ? repCount.value : this.repCount,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    videoVersion: videoVersion ?? this.videoVersion,
    localVideoPath: localVideoPath.present
        ? localVideoPath.value
        : this.localVideoPath,
    localModelPath: localModelPath.present
        ? localModelPath.value
        : this.localModelPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalExercise copyWithCompanion(LocalExercisesCompanion data) {
    return LocalExercise(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      title: data.title.present ? data.title.value : this.title,
      cueText: data.cueText.present ? data.cueText.value : this.cueText,
      muxAssetId: data.muxAssetId.present
          ? data.muxAssetId.value
          : this.muxAssetId,
      muxPlaybackId: data.muxPlaybackId.present
          ? data.muxPlaybackId.value
          : this.muxPlaybackId,
      muxDownloadUrl: data.muxDownloadUrl.present
          ? data.muxDownloadUrl.value
          : this.muxDownloadUrl,
      modelAssetUrl: data.modelAssetUrl.present
          ? data.modelAssetUrl.value
          : this.modelAssetUrl,
      repCount: data.repCount.present ? data.repCount.value : this.repCount,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      videoVersion: data.videoVersion.present
          ? data.videoVersion.value
          : this.videoVersion,
      localVideoPath: data.localVideoPath.present
          ? data.localVideoPath.value
          : this.localVideoPath,
      localModelPath: data.localModelPath.present
          ? data.localModelPath.value
          : this.localModelPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalExercise(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('title: $title, ')
          ..write('cueText: $cueText, ')
          ..write('muxAssetId: $muxAssetId, ')
          ..write('muxPlaybackId: $muxPlaybackId, ')
          ..write('muxDownloadUrl: $muxDownloadUrl, ')
          ..write('modelAssetUrl: $modelAssetUrl, ')
          ..write('repCount: $repCount, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('videoVersion: $videoVersion, ')
          ..write('localVideoPath: $localVideoPath, ')
          ..write('localModelPath: $localModelPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    displayOrder,
    title,
    cueText,
    muxAssetId,
    muxPlaybackId,
    muxDownloadUrl,
    modelAssetUrl,
    repCount,
    durationSeconds,
    videoVersion,
    localVideoPath,
    localModelPath,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalExercise &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.displayOrder == this.displayOrder &&
          other.title == this.title &&
          other.cueText == this.cueText &&
          other.muxAssetId == this.muxAssetId &&
          other.muxPlaybackId == this.muxPlaybackId &&
          other.muxDownloadUrl == this.muxDownloadUrl &&
          other.modelAssetUrl == this.modelAssetUrl &&
          other.repCount == this.repCount &&
          other.durationSeconds == this.durationSeconds &&
          other.videoVersion == this.videoVersion &&
          other.localVideoPath == this.localVideoPath &&
          other.localModelPath == this.localModelPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalExercisesCompanion extends UpdateCompanion<LocalExercise> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> displayOrder;
  final Value<String> title;
  final Value<String?> cueText;
  final Value<String?> muxAssetId;
  final Value<String?> muxPlaybackId;
  final Value<String?> muxDownloadUrl;
  final Value<String?> modelAssetUrl;
  final Value<int?> repCount;
  final Value<int?> durationSeconds;
  final Value<int> videoVersion;
  final Value<String?> localVideoPath;
  final Value<String?> localModelPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalExercisesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.title = const Value.absent(),
    this.cueText = const Value.absent(),
    this.muxAssetId = const Value.absent(),
    this.muxPlaybackId = const Value.absent(),
    this.muxDownloadUrl = const Value.absent(),
    this.modelAssetUrl = const Value.absent(),
    this.repCount = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.videoVersion = const Value.absent(),
    this.localVideoPath = const Value.absent(),
    this.localModelPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalExercisesCompanion.insert({
    required String id,
    required String sessionId,
    required int displayOrder,
    required String title,
    this.cueText = const Value.absent(),
    this.muxAssetId = const Value.absent(),
    this.muxPlaybackId = const Value.absent(),
    this.muxDownloadUrl = const Value.absent(),
    this.modelAssetUrl = const Value.absent(),
    this.repCount = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.videoVersion = const Value.absent(),
    this.localVideoPath = const Value.absent(),
    this.localModelPath = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       displayOrder = Value(displayOrder),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalExercise> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? displayOrder,
    Expression<String>? title,
    Expression<String>? cueText,
    Expression<String>? muxAssetId,
    Expression<String>? muxPlaybackId,
    Expression<String>? muxDownloadUrl,
    Expression<String>? modelAssetUrl,
    Expression<int>? repCount,
    Expression<int>? durationSeconds,
    Expression<int>? videoVersion,
    Expression<String>? localVideoPath,
    Expression<String>? localModelPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (displayOrder != null) 'display_order': displayOrder,
      if (title != null) 'title': title,
      if (cueText != null) 'cue_text': cueText,
      if (muxAssetId != null) 'mux_asset_id': muxAssetId,
      if (muxPlaybackId != null) 'mux_playback_id': muxPlaybackId,
      if (muxDownloadUrl != null) 'mux_download_url': muxDownloadUrl,
      if (modelAssetUrl != null) 'model_asset_url': modelAssetUrl,
      if (repCount != null) 'rep_count': repCount,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (videoVersion != null) 'video_version': videoVersion,
      if (localVideoPath != null) 'local_video_path': localVideoPath,
      if (localModelPath != null) 'local_model_path': localModelPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? displayOrder,
    Value<String>? title,
    Value<String?>? cueText,
    Value<String?>? muxAssetId,
    Value<String?>? muxPlaybackId,
    Value<String?>? muxDownloadUrl,
    Value<String?>? modelAssetUrl,
    Value<int?>? repCount,
    Value<int?>? durationSeconds,
    Value<int>? videoVersion,
    Value<String?>? localVideoPath,
    Value<String?>? localModelPath,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalExercisesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      displayOrder: displayOrder ?? this.displayOrder,
      title: title ?? this.title,
      cueText: cueText ?? this.cueText,
      muxAssetId: muxAssetId ?? this.muxAssetId,
      muxPlaybackId: muxPlaybackId ?? this.muxPlaybackId,
      muxDownloadUrl: muxDownloadUrl ?? this.muxDownloadUrl,
      modelAssetUrl: modelAssetUrl ?? this.modelAssetUrl,
      repCount: repCount ?? this.repCount,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      videoVersion: videoVersion ?? this.videoVersion,
      localVideoPath: localVideoPath ?? this.localVideoPath,
      localModelPath: localModelPath ?? this.localModelPath,
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
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (cueText.present) {
      map['cue_text'] = Variable<String>(cueText.value);
    }
    if (muxAssetId.present) {
      map['mux_asset_id'] = Variable<String>(muxAssetId.value);
    }
    if (muxPlaybackId.present) {
      map['mux_playback_id'] = Variable<String>(muxPlaybackId.value);
    }
    if (muxDownloadUrl.present) {
      map['mux_download_url'] = Variable<String>(muxDownloadUrl.value);
    }
    if (modelAssetUrl.present) {
      map['model_asset_url'] = Variable<String>(modelAssetUrl.value);
    }
    if (repCount.present) {
      map['rep_count'] = Variable<int>(repCount.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (videoVersion.present) {
      map['video_version'] = Variable<int>(videoVersion.value);
    }
    if (localVideoPath.present) {
      map['local_video_path'] = Variable<String>(localVideoPath.value);
    }
    if (localModelPath.present) {
      map['local_model_path'] = Variable<String>(localModelPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalExercisesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('title: $title, ')
          ..write('cueText: $cueText, ')
          ..write('muxAssetId: $muxAssetId, ')
          ..write('muxPlaybackId: $muxPlaybackId, ')
          ..write('muxDownloadUrl: $muxDownloadUrl, ')
          ..write('modelAssetUrl: $modelAssetUrl, ')
          ..write('repCount: $repCount, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('videoVersion: $videoVersion, ')
          ..write('localVideoPath: $localVideoPath, ')
          ..write('localModelPath: $localModelPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalEnrollmentsTable extends LocalEnrollments
    with TableInfo<$LocalEnrollmentsTable, LocalEnrollment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalEnrollmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<String> programId = GeneratedColumn<String>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enrolledAtMeta = const VerificationMeta(
    'enrolledAt',
  );
  @override
  late final GeneratedColumn<DateTime> enrolledAt = GeneratedColumn<DateTime>(
    'enrolled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentDayMeta = const VerificationMeta(
    'currentDay',
  );
  @override
  late final GeneratedColumn<int> currentDay = GeneratedColumn<int>(
    'current_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    programId,
    enrolledAt,
    currentDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_enrollments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalEnrollment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('enrolled_at')) {
      context.handle(
        _enrolledAtMeta,
        enrolledAt.isAcceptableOrUnknown(data['enrolled_at']!, _enrolledAtMeta),
      );
    } else if (isInserting) {
      context.missing(_enrolledAtMeta);
    }
    if (data.containsKey('current_day')) {
      context.handle(
        _currentDayMeta,
        currentDay.isAcceptableOrUnknown(data['current_day']!, _currentDayMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalEnrollment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalEnrollment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program_id'],
      )!,
      enrolledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}enrolled_at'],
      )!,
      currentDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_day'],
      )!,
    );
  }

  @override
  $LocalEnrollmentsTable createAlias(String alias) {
    return $LocalEnrollmentsTable(attachedDatabase, alias);
  }
}

class LocalEnrollment extends DataClass implements Insertable<LocalEnrollment> {
  final String id;
  final String studentId;
  final String programId;
  final DateTime enrolledAt;
  final int currentDay;
  const LocalEnrollment({
    required this.id,
    required this.studentId,
    required this.programId,
    required this.enrolledAt,
    required this.currentDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['program_id'] = Variable<String>(programId);
    map['enrolled_at'] = Variable<DateTime>(enrolledAt);
    map['current_day'] = Variable<int>(currentDay);
    return map;
  }

  LocalEnrollmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalEnrollmentsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      programId: Value(programId),
      enrolledAt: Value(enrolledAt),
      currentDay: Value(currentDay),
    );
  }

  factory LocalEnrollment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalEnrollment(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      programId: serializer.fromJson<String>(json['programId']),
      enrolledAt: serializer.fromJson<DateTime>(json['enrolledAt']),
      currentDay: serializer.fromJson<int>(json['currentDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'programId': serializer.toJson<String>(programId),
      'enrolledAt': serializer.toJson<DateTime>(enrolledAt),
      'currentDay': serializer.toJson<int>(currentDay),
    };
  }

  LocalEnrollment copyWith({
    String? id,
    String? studentId,
    String? programId,
    DateTime? enrolledAt,
    int? currentDay,
  }) => LocalEnrollment(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    programId: programId ?? this.programId,
    enrolledAt: enrolledAt ?? this.enrolledAt,
    currentDay: currentDay ?? this.currentDay,
  );
  LocalEnrollment copyWithCompanion(LocalEnrollmentsCompanion data) {
    return LocalEnrollment(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      programId: data.programId.present ? data.programId.value : this.programId,
      enrolledAt: data.enrolledAt.present
          ? data.enrolledAt.value
          : this.enrolledAt,
      currentDay: data.currentDay.present
          ? data.currentDay.value
          : this.currentDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalEnrollment(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('programId: $programId, ')
          ..write('enrolledAt: $enrolledAt, ')
          ..write('currentDay: $currentDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, studentId, programId, enrolledAt, currentDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalEnrollment &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.programId == this.programId &&
          other.enrolledAt == this.enrolledAt &&
          other.currentDay == this.currentDay);
}

class LocalEnrollmentsCompanion extends UpdateCompanion<LocalEnrollment> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> programId;
  final Value<DateTime> enrolledAt;
  final Value<int> currentDay;
  final Value<int> rowid;
  const LocalEnrollmentsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.programId = const Value.absent(),
    this.enrolledAt = const Value.absent(),
    this.currentDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalEnrollmentsCompanion.insert({
    required String id,
    required String studentId,
    required String programId,
    required DateTime enrolledAt,
    this.currentDay = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       programId = Value(programId),
       enrolledAt = Value(enrolledAt);
  static Insertable<LocalEnrollment> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? programId,
    Expression<DateTime>? enrolledAt,
    Expression<int>? currentDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (programId != null) 'program_id': programId,
      if (enrolledAt != null) 'enrolled_at': enrolledAt,
      if (currentDay != null) 'current_day': currentDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalEnrollmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? programId,
    Value<DateTime>? enrolledAt,
    Value<int>? currentDay,
    Value<int>? rowid,
  }) {
    return LocalEnrollmentsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      programId: programId ?? this.programId,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      currentDay: currentDay ?? this.currentDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<String>(programId.value);
    }
    if (enrolledAt.present) {
      map['enrolled_at'] = Variable<DateTime>(enrolledAt.value);
    }
    if (currentDay.present) {
      map['current_day'] = Variable<int>(currentDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalEnrollmentsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('programId: $programId, ')
          ..write('enrolledAt: $enrolledAt, ')
          ..write('currentDay: $currentDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProgressRecordsTable extends LocalProgressRecords
    with TableInfo<$LocalProgressRecordsTable, LocalProgressRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProgressRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
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
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedFromOfflineMeta = const VerificationMeta(
    'syncedFromOffline',
  );
  @override
  late final GeneratedColumn<bool> syncedFromOffline = GeneratedColumn<bool>(
    'synced_from_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced_from_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    sessionId,
    completedAt,
    durationSeconds,
    syncedFromOffline,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_progress_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProgressRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('synced_from_offline')) {
      context.handle(
        _syncedFromOfflineMeta,
        syncedFromOffline.isAcceptableOrUnknown(
          data['synced_from_offline']!,
          _syncedFromOfflineMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProgressRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProgressRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      syncedFromOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced_from_offline'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalProgressRecordsTable createAlias(String alias) {
    return $LocalProgressRecordsTable(attachedDatabase, alias);
  }
}

class LocalProgressRecord extends DataClass
    implements Insertable<LocalProgressRecord> {
  final String id;
  final String studentId;
  final String sessionId;
  final DateTime completedAt;
  final int? durationSeconds;
  final bool syncedFromOffline;
  final DateTime createdAt;
  const LocalProgressRecord({
    required this.id,
    required this.studentId,
    required this.sessionId,
    required this.completedAt,
    this.durationSeconds,
    required this.syncedFromOffline,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['session_id'] = Variable<String>(sessionId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['synced_from_offline'] = Variable<bool>(syncedFromOffline);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalProgressRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocalProgressRecordsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      sessionId: Value(sessionId),
      completedAt: Value(completedAt),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      syncedFromOffline: Value(syncedFromOffline),
      createdAt: Value(createdAt),
    );
  }

  factory LocalProgressRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProgressRecord(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      syncedFromOffline: serializer.fromJson<bool>(json['syncedFromOffline']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'sessionId': serializer.toJson<String>(sessionId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'syncedFromOffline': serializer.toJson<bool>(syncedFromOffline),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalProgressRecord copyWith({
    String? id,
    String? studentId,
    String? sessionId,
    DateTime? completedAt,
    Value<int?> durationSeconds = const Value.absent(),
    bool? syncedFromOffline,
    DateTime? createdAt,
  }) => LocalProgressRecord(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    sessionId: sessionId ?? this.sessionId,
    completedAt: completedAt ?? this.completedAt,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    syncedFromOffline: syncedFromOffline ?? this.syncedFromOffline,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalProgressRecord copyWithCompanion(LocalProgressRecordsCompanion data) {
    return LocalProgressRecord(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      syncedFromOffline: data.syncedFromOffline.present
          ? data.syncedFromOffline.value
          : this.syncedFromOffline,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProgressRecord(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sessionId: $sessionId, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('syncedFromOffline: $syncedFromOffline, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    sessionId,
    completedAt,
    durationSeconds,
    syncedFromOffline,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProgressRecord &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.sessionId == this.sessionId &&
          other.completedAt == this.completedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.syncedFromOffline == this.syncedFromOffline &&
          other.createdAt == this.createdAt);
}

class LocalProgressRecordsCompanion
    extends UpdateCompanion<LocalProgressRecord> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> sessionId;
  final Value<DateTime> completedAt;
  final Value<int?> durationSeconds;
  final Value<bool> syncedFromOffline;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalProgressRecordsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.syncedFromOffline = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProgressRecordsCompanion.insert({
    required String id,
    required String studentId,
    required String sessionId,
    required DateTime completedAt,
    this.durationSeconds = const Value.absent(),
    this.syncedFromOffline = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       sessionId = Value(sessionId),
       completedAt = Value(completedAt),
       createdAt = Value(createdAt);
  static Insertable<LocalProgressRecord> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? sessionId,
    Expression<DateTime>? completedAt,
    Expression<int>? durationSeconds,
    Expression<bool>? syncedFromOffline,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (sessionId != null) 'session_id': sessionId,
      if (completedAt != null) 'completed_at': completedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (syncedFromOffline != null) 'synced_from_offline': syncedFromOffline,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProgressRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? sessionId,
    Value<DateTime>? completedAt,
    Value<int?>? durationSeconds,
    Value<bool>? syncedFromOffline,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalProgressRecordsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      sessionId: sessionId ?? this.sessionId,
      completedAt: completedAt ?? this.completedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      syncedFromOffline: syncedFromOffline ?? this.syncedFromOffline,
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
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (syncedFromOffline.present) {
      map['synced_from_offline'] = Variable<bool>(syncedFromOffline.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProgressRecordsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sessionId: $sessionId, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('syncedFromOffline: $syncedFromOffline, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMetricLogsTable extends LocalMetricLogs
    with TableInfo<$LocalMetricLogsTable, LocalMetricLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMetricLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricTypeMeta = const VerificationMeta(
    'metricType',
  );
  @override
  late final GeneratedColumn<String> metricType = GeneratedColumn<String>(
    'metric_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricSubtypeMeta = const VerificationMeta(
    'metricSubtype',
  );
  @override
  late final GeneratedColumn<String> metricSubtype = GeneratedColumn<String>(
    'metric_subtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    metricType,
    metricSubtype,
    value,
    unit,
    loggedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_metric_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMetricLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('metric_type')) {
      context.handle(
        _metricTypeMeta,
        metricType.isAcceptableOrUnknown(data['metric_type']!, _metricTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_metricTypeMeta);
    }
    if (data.containsKey('metric_subtype')) {
      context.handle(
        _metricSubtypeMeta,
        metricSubtype.isAcceptableOrUnknown(
          data['metric_subtype']!,
          _metricSubtypeMeta,
        ),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMetricLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMetricLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      metricType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_type'],
      )!,
      metricSubtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_subtype'],
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalMetricLogsTable createAlias(String alias) {
    return $LocalMetricLogsTable(attachedDatabase, alias);
  }
}

class LocalMetricLog extends DataClass implements Insertable<LocalMetricLog> {
  final String id;
  final String studentId;
  final String metricType;
  final String? metricSubtype;
  final double value;
  final String unit;
  final DateTime loggedAt;
  final DateTime createdAt;
  const LocalMetricLog({
    required this.id,
    required this.studentId,
    required this.metricType,
    this.metricSubtype,
    required this.value,
    required this.unit,
    required this.loggedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['metric_type'] = Variable<String>(metricType);
    if (!nullToAbsent || metricSubtype != null) {
      map['metric_subtype'] = Variable<String>(metricSubtype);
    }
    map['value'] = Variable<double>(value);
    map['unit'] = Variable<String>(unit);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalMetricLogsCompanion toCompanion(bool nullToAbsent) {
    return LocalMetricLogsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      metricType: Value(metricType),
      metricSubtype: metricSubtype == null && nullToAbsent
          ? const Value.absent()
          : Value(metricSubtype),
      value: Value(value),
      unit: Value(unit),
      loggedAt: Value(loggedAt),
      createdAt: Value(createdAt),
    );
  }

  factory LocalMetricLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMetricLog(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      metricType: serializer.fromJson<String>(json['metricType']),
      metricSubtype: serializer.fromJson<String?>(json['metricSubtype']),
      value: serializer.fromJson<double>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'metricType': serializer.toJson<String>(metricType),
      'metricSubtype': serializer.toJson<String?>(metricSubtype),
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String>(unit),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalMetricLog copyWith({
    String? id,
    String? studentId,
    String? metricType,
    Value<String?> metricSubtype = const Value.absent(),
    double? value,
    String? unit,
    DateTime? loggedAt,
    DateTime? createdAt,
  }) => LocalMetricLog(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    metricType: metricType ?? this.metricType,
    metricSubtype: metricSubtype.present
        ? metricSubtype.value
        : this.metricSubtype,
    value: value ?? this.value,
    unit: unit ?? this.unit,
    loggedAt: loggedAt ?? this.loggedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalMetricLog copyWithCompanion(LocalMetricLogsCompanion data) {
    return LocalMetricLog(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      metricType: data.metricType.present
          ? data.metricType.value
          : this.metricType,
      metricSubtype: data.metricSubtype.present
          ? data.metricSubtype.value
          : this.metricSubtype,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMetricLog(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('metricType: $metricType, ')
          ..write('metricSubtype: $metricSubtype, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    metricType,
    metricSubtype,
    value,
    unit,
    loggedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMetricLog &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.metricType == this.metricType &&
          other.metricSubtype == this.metricSubtype &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.loggedAt == this.loggedAt &&
          other.createdAt == this.createdAt);
}

class LocalMetricLogsCompanion extends UpdateCompanion<LocalMetricLog> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> metricType;
  final Value<String?> metricSubtype;
  final Value<double> value;
  final Value<String> unit;
  final Value<DateTime> loggedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalMetricLogsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.metricType = const Value.absent(),
    this.metricSubtype = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMetricLogsCompanion.insert({
    required String id,
    required String studentId,
    required String metricType,
    this.metricSubtype = const Value.absent(),
    required double value,
    required String unit,
    required DateTime loggedAt,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       metricType = Value(metricType),
       value = Value(value),
       unit = Value(unit),
       loggedAt = Value(loggedAt),
       createdAt = Value(createdAt);
  static Insertable<LocalMetricLog> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? metricType,
    Expression<String>? metricSubtype,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<DateTime>? loggedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (metricType != null) 'metric_type': metricType,
      if (metricSubtype != null) 'metric_subtype': metricSubtype,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMetricLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? metricType,
    Value<String?>? metricSubtype,
    Value<double>? value,
    Value<String>? unit,
    Value<DateTime>? loggedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalMetricLogsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      metricType: metricType ?? this.metricType,
      metricSubtype: metricSubtype ?? this.metricSubtype,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      loggedAt: loggedAt ?? this.loggedAt,
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
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (metricType.present) {
      map['metric_type'] = Variable<String>(metricType.value);
    }
    if (metricSubtype.present) {
      map['metric_subtype'] = Variable<String>(metricSubtype.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMetricLogsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('metricType: $metricType, ')
          ..write('metricSubtype: $metricSubtype, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFeedbackThreadsTable extends LocalFeedbackThreads
    with TableInfo<$LocalFeedbackThreadsTable, LocalFeedbackThread> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFeedbackThreadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
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
  );
  static const VerificationMeta _studentMessageMeta = const VerificationMeta(
    'studentMessage',
  );
  @override
  late final GeneratedColumn<String> studentMessage = GeneratedColumn<String>(
    'student_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coachReplyMeta = const VerificationMeta(
    'coachReply',
  );
  @override
  late final GeneratedColumn<String> coachReply = GeneratedColumn<String>(
    'coach_reply',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repliedAtMeta = const VerificationMeta(
    'repliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> repliedAt = GeneratedColumn<DateTime>(
    'replied_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationSentMeta = const VerificationMeta(
    'notificationSent',
  );
  @override
  late final GeneratedColumn<bool> notificationSent = GeneratedColumn<bool>(
    'notification_sent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notification_sent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sent'),
  );
  static const VerificationMeta _localPhotoPathMeta = const VerificationMeta(
    'localPhotoPath',
  );
  @override
  late final GeneratedColumn<String> localPhotoPath = GeneratedColumn<String>(
    'local_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    sessionId,
    studentMessage,
    photoUrl,
    coachReply,
    repliedAt,
    notificationSent,
    createdAt,
    updatedAt,
    status,
    localPhotoPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_feedback_threads';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalFeedbackThread> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('student_message')) {
      context.handle(
        _studentMessageMeta,
        studentMessage.isAcceptableOrUnknown(
          data['student_message']!,
          _studentMessageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentMessageMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('coach_reply')) {
      context.handle(
        _coachReplyMeta,
        coachReply.isAcceptableOrUnknown(data['coach_reply']!, _coachReplyMeta),
      );
    }
    if (data.containsKey('replied_at')) {
      context.handle(
        _repliedAtMeta,
        repliedAt.isAcceptableOrUnknown(data['replied_at']!, _repliedAtMeta),
      );
    }
    if (data.containsKey('notification_sent')) {
      context.handle(
        _notificationSentMeta,
        notificationSent.isAcceptableOrUnknown(
          data['notification_sent']!,
          _notificationSentMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('local_photo_path')) {
      context.handle(
        _localPhotoPathMeta,
        localPhotoPath.isAcceptableOrUnknown(
          data['local_photo_path']!,
          _localPhotoPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFeedbackThread map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFeedbackThread(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      studentMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_message'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      coachReply: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coach_reply'],
      ),
      repliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}replied_at'],
      ),
      notificationSent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notification_sent'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      localPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_photo_path'],
      ),
    );
  }

  @override
  $LocalFeedbackThreadsTable createAlias(String alias) {
    return $LocalFeedbackThreadsTable(attachedDatabase, alias);
  }
}

class LocalFeedbackThread extends DataClass
    implements Insertable<LocalFeedbackThread> {
  final String id;
  final String studentId;
  final String sessionId;
  final String studentMessage;
  final String? photoUrl;
  final String? coachReply;
  final DateTime? repliedAt;
  final bool notificationSent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String? localPhotoPath;
  const LocalFeedbackThread({
    required this.id,
    required this.studentId,
    required this.sessionId,
    required this.studentMessage,
    this.photoUrl,
    this.coachReply,
    this.repliedAt,
    required this.notificationSent,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.localPhotoPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['session_id'] = Variable<String>(sessionId);
    map['student_message'] = Variable<String>(studentMessage);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || coachReply != null) {
      map['coach_reply'] = Variable<String>(coachReply);
    }
    if (!nullToAbsent || repliedAt != null) {
      map['replied_at'] = Variable<DateTime>(repliedAt);
    }
    map['notification_sent'] = Variable<bool>(notificationSent);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || localPhotoPath != null) {
      map['local_photo_path'] = Variable<String>(localPhotoPath);
    }
    return map;
  }

  LocalFeedbackThreadsCompanion toCompanion(bool nullToAbsent) {
    return LocalFeedbackThreadsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      sessionId: Value(sessionId),
      studentMessage: Value(studentMessage),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      coachReply: coachReply == null && nullToAbsent
          ? const Value.absent()
          : Value(coachReply),
      repliedAt: repliedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(repliedAt),
      notificationSent: Value(notificationSent),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      status: Value(status),
      localPhotoPath: localPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPhotoPath),
    );
  }

  factory LocalFeedbackThread.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFeedbackThread(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      studentMessage: serializer.fromJson<String>(json['studentMessage']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      coachReply: serializer.fromJson<String?>(json['coachReply']),
      repliedAt: serializer.fromJson<DateTime?>(json['repliedAt']),
      notificationSent: serializer.fromJson<bool>(json['notificationSent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      status: serializer.fromJson<String>(json['status']),
      localPhotoPath: serializer.fromJson<String?>(json['localPhotoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'sessionId': serializer.toJson<String>(sessionId),
      'studentMessage': serializer.toJson<String>(studentMessage),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'coachReply': serializer.toJson<String?>(coachReply),
      'repliedAt': serializer.toJson<DateTime?>(repliedAt),
      'notificationSent': serializer.toJson<bool>(notificationSent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'status': serializer.toJson<String>(status),
      'localPhotoPath': serializer.toJson<String?>(localPhotoPath),
    };
  }

  LocalFeedbackThread copyWith({
    String? id,
    String? studentId,
    String? sessionId,
    String? studentMessage,
    Value<String?> photoUrl = const Value.absent(),
    Value<String?> coachReply = const Value.absent(),
    Value<DateTime?> repliedAt = const Value.absent(),
    bool? notificationSent,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    Value<String?> localPhotoPath = const Value.absent(),
  }) => LocalFeedbackThread(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    sessionId: sessionId ?? this.sessionId,
    studentMessage: studentMessage ?? this.studentMessage,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    coachReply: coachReply.present ? coachReply.value : this.coachReply,
    repliedAt: repliedAt.present ? repliedAt.value : this.repliedAt,
    notificationSent: notificationSent ?? this.notificationSent,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    status: status ?? this.status,
    localPhotoPath: localPhotoPath.present
        ? localPhotoPath.value
        : this.localPhotoPath,
  );
  LocalFeedbackThread copyWithCompanion(LocalFeedbackThreadsCompanion data) {
    return LocalFeedbackThread(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      studentMessage: data.studentMessage.present
          ? data.studentMessage.value
          : this.studentMessage,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      coachReply: data.coachReply.present
          ? data.coachReply.value
          : this.coachReply,
      repliedAt: data.repliedAt.present ? data.repliedAt.value : this.repliedAt,
      notificationSent: data.notificationSent.present
          ? data.notificationSent.value
          : this.notificationSent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      status: data.status.present ? data.status.value : this.status,
      localPhotoPath: data.localPhotoPath.present
          ? data.localPhotoPath.value
          : this.localPhotoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFeedbackThread(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sessionId: $sessionId, ')
          ..write('studentMessage: $studentMessage, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('coachReply: $coachReply, ')
          ..write('repliedAt: $repliedAt, ')
          ..write('notificationSent: $notificationSent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('status: $status, ')
          ..write('localPhotoPath: $localPhotoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    sessionId,
    studentMessage,
    photoUrl,
    coachReply,
    repliedAt,
    notificationSent,
    createdAt,
    updatedAt,
    status,
    localPhotoPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFeedbackThread &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.sessionId == this.sessionId &&
          other.studentMessage == this.studentMessage &&
          other.photoUrl == this.photoUrl &&
          other.coachReply == this.coachReply &&
          other.repliedAt == this.repliedAt &&
          other.notificationSent == this.notificationSent &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.status == this.status &&
          other.localPhotoPath == this.localPhotoPath);
}

class LocalFeedbackThreadsCompanion
    extends UpdateCompanion<LocalFeedbackThread> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> sessionId;
  final Value<String> studentMessage;
  final Value<String?> photoUrl;
  final Value<String?> coachReply;
  final Value<DateTime?> repliedAt;
  final Value<bool> notificationSent;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> status;
  final Value<String?> localPhotoPath;
  final Value<int> rowid;
  const LocalFeedbackThreadsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.studentMessage = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.coachReply = const Value.absent(),
    this.repliedAt = const Value.absent(),
    this.notificationSent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.localPhotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFeedbackThreadsCompanion.insert({
    required String id,
    required String studentId,
    required String sessionId,
    required String studentMessage,
    this.photoUrl = const Value.absent(),
    this.coachReply = const Value.absent(),
    this.repliedAt = const Value.absent(),
    this.notificationSent = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.status = const Value.absent(),
    this.localPhotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       sessionId = Value(sessionId),
       studentMessage = Value(studentMessage),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalFeedbackThread> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? sessionId,
    Expression<String>? studentMessage,
    Expression<String>? photoUrl,
    Expression<String>? coachReply,
    Expression<DateTime>? repliedAt,
    Expression<bool>? notificationSent,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? status,
    Expression<String>? localPhotoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (sessionId != null) 'session_id': sessionId,
      if (studentMessage != null) 'student_message': studentMessage,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (coachReply != null) 'coach_reply': coachReply,
      if (repliedAt != null) 'replied_at': repliedAt,
      if (notificationSent != null) 'notification_sent': notificationSent,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (status != null) 'status': status,
      if (localPhotoPath != null) 'local_photo_path': localPhotoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFeedbackThreadsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? sessionId,
    Value<String>? studentMessage,
    Value<String?>? photoUrl,
    Value<String?>? coachReply,
    Value<DateTime?>? repliedAt,
    Value<bool>? notificationSent,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? status,
    Value<String?>? localPhotoPath,
    Value<int>? rowid,
  }) {
    return LocalFeedbackThreadsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      sessionId: sessionId ?? this.sessionId,
      studentMessage: studentMessage ?? this.studentMessage,
      photoUrl: photoUrl ?? this.photoUrl,
      coachReply: coachReply ?? this.coachReply,
      repliedAt: repliedAt ?? this.repliedAt,
      notificationSent: notificationSent ?? this.notificationSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (studentMessage.present) {
      map['student_message'] = Variable<String>(studentMessage.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (coachReply.present) {
      map['coach_reply'] = Variable<String>(coachReply.value);
    }
    if (repliedAt.present) {
      map['replied_at'] = Variable<DateTime>(repliedAt.value);
    }
    if (notificationSent.present) {
      map['notification_sent'] = Variable<bool>(notificationSent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (localPhotoPath.present) {
      map['local_photo_path'] = Variable<String>(localPhotoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFeedbackThreadsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sessionId: $sessionId, ')
          ..write('studentMessage: $studentMessage, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('coachReply: $coachReply, ')
          ..write('repliedAt: $repliedAt, ')
          ..write('notificationSent: $notificationSent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('status: $status, ')
          ..write('localPhotoPath: $localPhotoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operation,
    targetTable,
    payload,
    createdAt,
    retryCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['table_name']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String operation;
  final String targetTable;
  final String payload;
  final int createdAt;
  final int retryCount;
  final String? lastError;
  const SyncQueueData({
    required this.id,
    required this.operation,
    required this.targetTable,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation'] = Variable<String>(operation);
    map['table_name'] = Variable<String>(targetTable);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<int>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      operation: Value(operation),
      targetTable: Value(targetTable),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operation': serializer.toJson<String>(operation),
      'targetTable': serializer.toJson<String>(targetTable),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<int>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? operation,
    String? targetTable,
    String? payload,
    int? createdAt,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    operation: operation ?? this.operation,
    targetTable: targetTable ?? this.targetTable,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('targetTable: $targetTable, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operation,
    targetTable,
    payload,
    createdAt,
    retryCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.targetTable == this.targetTable &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> operation;
  final Value<String> targetTable;
  final Value<String> payload;
  final Value<int> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String operation,
    required String targetTable,
    required String payload,
    required int createdAt,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : operation = Value(operation),
       targetTable = Value(targetTable),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? operation,
    Expression<String>? targetTable,
    Expression<String>? payload,
    Expression<int>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (targetTable != null) 'table_name': targetTable,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? operation,
    Value<String>? targetTable,
    Value<String>? payload,
    Value<int>? createdAt,
    Value<int>? retryCount,
    Value<String?>? lastError,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      targetTable: targetTable ?? this.targetTable,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (targetTable.present) {
      map['table_name'] = Variable<String>(targetTable.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('targetTable: $targetTable, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $DownloadManifestTable extends DownloadManifest
    with TableInfo<$DownloadManifestTable, DownloadManifestData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadManifestTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoVersionMeta = const VerificationMeta(
    'videoVersion',
  );
  @override
  late final GeneratedColumn<int> videoVersion = GeneratedColumn<int>(
    'video_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoLocalPathMeta = const VerificationMeta(
    'videoLocalPath',
  );
  @override
  late final GeneratedColumn<String> videoLocalPath = GeneratedColumn<String>(
    'video_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelLocalPathMeta = const VerificationMeta(
    'modelLocalPath',
  );
  @override
  late final GeneratedColumn<String> modelLocalPath = GeneratedColumn<String>(
    'model_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadStatusMeta = const VerificationMeta(
    'downloadStatus',
  );
  @override
  late final GeneratedColumn<String> downloadStatus = GeneratedColumn<String>(
    'download_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<int> downloadedAt = GeneratedColumn<int>(
    'downloaded_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    exerciseId,
    videoVersion,
    videoLocalPath,
    modelLocalPath,
    downloadStatus,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_manifest';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadManifestData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('video_version')) {
      context.handle(
        _videoVersionMeta,
        videoVersion.isAcceptableOrUnknown(
          data['video_version']!,
          _videoVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_videoVersionMeta);
    }
    if (data.containsKey('video_local_path')) {
      context.handle(
        _videoLocalPathMeta,
        videoLocalPath.isAcceptableOrUnknown(
          data['video_local_path']!,
          _videoLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('model_local_path')) {
      context.handle(
        _modelLocalPathMeta,
        modelLocalPath.isAcceptableOrUnknown(
          data['model_local_path']!,
          _modelLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('download_status')) {
      context.handle(
        _downloadStatusMeta,
        downloadStatus.isAcceptableOrUnknown(
          data['download_status']!,
          _downloadStatusMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  DownloadManifestData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadManifestData(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      videoVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}video_version'],
      )!,
      videoLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_local_path'],
      ),
      modelLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_local_path'],
      ),
      downloadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_status'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_at'],
      ),
    );
  }

  @override
  $DownloadManifestTable createAlias(String alias) {
    return $DownloadManifestTable(attachedDatabase, alias);
  }
}

class DownloadManifestData extends DataClass
    implements Insertable<DownloadManifestData> {
  final String exerciseId;
  final int videoVersion;
  final String? videoLocalPath;
  final String? modelLocalPath;
  final String downloadStatus;
  final int? downloadedAt;
  const DownloadManifestData({
    required this.exerciseId,
    required this.videoVersion,
    this.videoLocalPath,
    this.modelLocalPath,
    required this.downloadStatus,
    this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['video_version'] = Variable<int>(videoVersion);
    if (!nullToAbsent || videoLocalPath != null) {
      map['video_local_path'] = Variable<String>(videoLocalPath);
    }
    if (!nullToAbsent || modelLocalPath != null) {
      map['model_local_path'] = Variable<String>(modelLocalPath);
    }
    map['download_status'] = Variable<String>(downloadStatus);
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<int>(downloadedAt);
    }
    return map;
  }

  DownloadManifestCompanion toCompanion(bool nullToAbsent) {
    return DownloadManifestCompanion(
      exerciseId: Value(exerciseId),
      videoVersion: Value(videoVersion),
      videoLocalPath: videoLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(videoLocalPath),
      modelLocalPath: modelLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(modelLocalPath),
      downloadStatus: Value(downloadStatus),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
    );
  }

  factory DownloadManifestData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadManifestData(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      videoVersion: serializer.fromJson<int>(json['videoVersion']),
      videoLocalPath: serializer.fromJson<String?>(json['videoLocalPath']),
      modelLocalPath: serializer.fromJson<String?>(json['modelLocalPath']),
      downloadStatus: serializer.fromJson<String>(json['downloadStatus']),
      downloadedAt: serializer.fromJson<int?>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'videoVersion': serializer.toJson<int>(videoVersion),
      'videoLocalPath': serializer.toJson<String?>(videoLocalPath),
      'modelLocalPath': serializer.toJson<String?>(modelLocalPath),
      'downloadStatus': serializer.toJson<String>(downloadStatus),
      'downloadedAt': serializer.toJson<int?>(downloadedAt),
    };
  }

  DownloadManifestData copyWith({
    String? exerciseId,
    int? videoVersion,
    Value<String?> videoLocalPath = const Value.absent(),
    Value<String?> modelLocalPath = const Value.absent(),
    String? downloadStatus,
    Value<int?> downloadedAt = const Value.absent(),
  }) => DownloadManifestData(
    exerciseId: exerciseId ?? this.exerciseId,
    videoVersion: videoVersion ?? this.videoVersion,
    videoLocalPath: videoLocalPath.present
        ? videoLocalPath.value
        : this.videoLocalPath,
    modelLocalPath: modelLocalPath.present
        ? modelLocalPath.value
        : this.modelLocalPath,
    downloadStatus: downloadStatus ?? this.downloadStatus,
    downloadedAt: downloadedAt.present ? downloadedAt.value : this.downloadedAt,
  );
  DownloadManifestData copyWithCompanion(DownloadManifestCompanion data) {
    return DownloadManifestData(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      videoVersion: data.videoVersion.present
          ? data.videoVersion.value
          : this.videoVersion,
      videoLocalPath: data.videoLocalPath.present
          ? data.videoLocalPath.value
          : this.videoLocalPath,
      modelLocalPath: data.modelLocalPath.present
          ? data.modelLocalPath.value
          : this.modelLocalPath,
      downloadStatus: data.downloadStatus.present
          ? data.downloadStatus.value
          : this.downloadStatus,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadManifestData(')
          ..write('exerciseId: $exerciseId, ')
          ..write('videoVersion: $videoVersion, ')
          ..write('videoLocalPath: $videoLocalPath, ')
          ..write('modelLocalPath: $modelLocalPath, ')
          ..write('downloadStatus: $downloadStatus, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    exerciseId,
    videoVersion,
    videoLocalPath,
    modelLocalPath,
    downloadStatus,
    downloadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadManifestData &&
          other.exerciseId == this.exerciseId &&
          other.videoVersion == this.videoVersion &&
          other.videoLocalPath == this.videoLocalPath &&
          other.modelLocalPath == this.modelLocalPath &&
          other.downloadStatus == this.downloadStatus &&
          other.downloadedAt == this.downloadedAt);
}

class DownloadManifestCompanion extends UpdateCompanion<DownloadManifestData> {
  final Value<String> exerciseId;
  final Value<int> videoVersion;
  final Value<String?> videoLocalPath;
  final Value<String?> modelLocalPath;
  final Value<String> downloadStatus;
  final Value<int?> downloadedAt;
  final Value<int> rowid;
  const DownloadManifestCompanion({
    this.exerciseId = const Value.absent(),
    this.videoVersion = const Value.absent(),
    this.videoLocalPath = const Value.absent(),
    this.modelLocalPath = const Value.absent(),
    this.downloadStatus = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadManifestCompanion.insert({
    required String exerciseId,
    required int videoVersion,
    this.videoLocalPath = const Value.absent(),
    this.modelLocalPath = const Value.absent(),
    this.downloadStatus = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       videoVersion = Value(videoVersion);
  static Insertable<DownloadManifestData> custom({
    Expression<String>? exerciseId,
    Expression<int>? videoVersion,
    Expression<String>? videoLocalPath,
    Expression<String>? modelLocalPath,
    Expression<String>? downloadStatus,
    Expression<int>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (videoVersion != null) 'video_version': videoVersion,
      if (videoLocalPath != null) 'video_local_path': videoLocalPath,
      if (modelLocalPath != null) 'model_local_path': modelLocalPath,
      if (downloadStatus != null) 'download_status': downloadStatus,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadManifestCompanion copyWith({
    Value<String>? exerciseId,
    Value<int>? videoVersion,
    Value<String?>? videoLocalPath,
    Value<String?>? modelLocalPath,
    Value<String>? downloadStatus,
    Value<int?>? downloadedAt,
    Value<int>? rowid,
  }) {
    return DownloadManifestCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      videoVersion: videoVersion ?? this.videoVersion,
      videoLocalPath: videoLocalPath ?? this.videoLocalPath,
      modelLocalPath: modelLocalPath ?? this.modelLocalPath,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (videoVersion.present) {
      map['video_version'] = Variable<int>(videoVersion.value);
    }
    if (videoLocalPath.present) {
      map['video_local_path'] = Variable<String>(videoLocalPath.value);
    }
    if (modelLocalPath.present) {
      map['model_local_path'] = Variable<String>(modelLocalPath.value);
    }
    if (downloadStatus.present) {
      map['download_status'] = Variable<String>(downloadStatus.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<int>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadManifestCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('videoVersion: $videoVersion, ')
          ..write('videoLocalPath: $videoLocalPath, ')
          ..write('modelLocalPath: $modelLocalPath, ')
          ..write('downloadStatus: $downloadStatus, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionResumeStateTable extends SessionResumeState
    with TableInfo<$SessionResumeStateTable, SessionResumeStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionResumeStateTable(this.attachedDatabase, [this._alias]);
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
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIndexMeta = const VerificationMeta(
    'exerciseIndex',
  );
  @override
  late final GeneratedColumn<int> exerciseIndex = GeneratedColumn<int>(
    'exercise_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  List<GeneratedColumn> get $columns => [
    sessionId,
    studentId,
    exerciseIndex,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_resume_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionResumeStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('exercise_index')) {
      context.handle(
        _exerciseIndexMeta,
        exerciseIndex.isAcceptableOrUnknown(
          data['exercise_index']!,
          _exerciseIndexMeta,
        ),
      );
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
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  SessionResumeStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionResumeStateData(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      exerciseIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_index'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionResumeStateTable createAlias(String alias) {
    return $SessionResumeStateTable(attachedDatabase, alias);
  }
}

class SessionResumeStateData extends DataClass
    implements Insertable<SessionResumeStateData> {
  final String sessionId;
  final String studentId;
  final int exerciseIndex;
  final DateTime updatedAt;
  const SessionResumeStateData({
    required this.sessionId,
    required this.studentId,
    required this.exerciseIndex,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['student_id'] = Variable<String>(studentId);
    map['exercise_index'] = Variable<int>(exerciseIndex);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionResumeStateCompanion toCompanion(bool nullToAbsent) {
    return SessionResumeStateCompanion(
      sessionId: Value(sessionId),
      studentId: Value(studentId),
      exerciseIndex: Value(exerciseIndex),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionResumeStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionResumeStateData(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      exerciseIndex: serializer.fromJson<int>(json['exerciseIndex']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'studentId': serializer.toJson<String>(studentId),
      'exerciseIndex': serializer.toJson<int>(exerciseIndex),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionResumeStateData copyWith({
    String? sessionId,
    String? studentId,
    int? exerciseIndex,
    DateTime? updatedAt,
  }) => SessionResumeStateData(
    sessionId: sessionId ?? this.sessionId,
    studentId: studentId ?? this.studentId,
    exerciseIndex: exerciseIndex ?? this.exerciseIndex,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionResumeStateData copyWithCompanion(SessionResumeStateCompanion data) {
    return SessionResumeStateData(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      exerciseIndex: data.exerciseIndex.present
          ? data.exerciseIndex.value
          : this.exerciseIndex,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionResumeStateData(')
          ..write('sessionId: $sessionId, ')
          ..write('studentId: $studentId, ')
          ..write('exerciseIndex: $exerciseIndex, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sessionId, studentId, exerciseIndex, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionResumeStateData &&
          other.sessionId == this.sessionId &&
          other.studentId == this.studentId &&
          other.exerciseIndex == this.exerciseIndex &&
          other.updatedAt == this.updatedAt);
}

class SessionResumeStateCompanion
    extends UpdateCompanion<SessionResumeStateData> {
  final Value<String> sessionId;
  final Value<String> studentId;
  final Value<int> exerciseIndex;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionResumeStateCompanion({
    this.sessionId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.exerciseIndex = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionResumeStateCompanion.insert({
    required String sessionId,
    required String studentId,
    this.exerciseIndex = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       studentId = Value(studentId),
       updatedAt = Value(updatedAt);
  static Insertable<SessionResumeStateData> custom({
    Expression<String>? sessionId,
    Expression<String>? studentId,
    Expression<int>? exerciseIndex,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (studentId != null) 'student_id': studentId,
      if (exerciseIndex != null) 'exercise_index': exerciseIndex,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionResumeStateCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? studentId,
    Value<int>? exerciseIndex,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionResumeStateCompanion(
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (exerciseIndex.present) {
      map['exercise_index'] = Variable<int>(exerciseIndex.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionResumeStateCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('studentId: $studentId, ')
          ..write('exerciseIndex: $exerciseIndex, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalProgramsTable localPrograms = $LocalProgramsTable(this);
  late final $LocalSessionsTable localSessions = $LocalSessionsTable(this);
  late final $LocalExercisesTable localExercises = $LocalExercisesTable(this);
  late final $LocalEnrollmentsTable localEnrollments = $LocalEnrollmentsTable(
    this,
  );
  late final $LocalProgressRecordsTable localProgressRecords =
      $LocalProgressRecordsTable(this);
  late final $LocalMetricLogsTable localMetricLogs = $LocalMetricLogsTable(
    this,
  );
  late final $LocalFeedbackThreadsTable localFeedbackThreads =
      $LocalFeedbackThreadsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $DownloadManifestTable downloadManifest = $DownloadManifestTable(
    this,
  );
  late final $SessionResumeStateTable sessionResumeState =
      $SessionResumeStateTable(this);
  late final ProgramsDao programsDao = ProgramsDao(this as AppDatabase);
  late final SessionsDao sessionsDao = SessionsDao(this as AppDatabase);
  late final ExercisesDao exercisesDao = ExercisesDao(this as AppDatabase);
  late final ProgressDao progressDao = ProgressDao(this as AppDatabase);
  late final MetricLogsDao metricLogsDao = MetricLogsDao(this as AppDatabase);
  late final FeedbackDao feedbackDao = FeedbackDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  late final DownloadManifestDao downloadManifestDao = DownloadManifestDao(
    this as AppDatabase,
  );
  late final EnrollmentsDao enrollmentsDao = EnrollmentsDao(
    this as AppDatabase,
  );
  late final SessionResumeDao sessionResumeDao = SessionResumeDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localPrograms,
    localSessions,
    localExercises,
    localEnrollments,
    localProgressRecords,
    localMetricLogs,
    localFeedbackThreads,
    syncQueue,
    downloadManifest,
    sessionResumeState,
  ];
}

typedef $$LocalProgramsTableCreateCompanionBuilder =
    LocalProgramsCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      required String difficulty,
      required int durationWeeks,
      Value<String?> thumbnailUrl,
      Value<bool> published,
      Value<DateTime?> publishedAt,
      Value<String?> createdBy,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalProgramsTableUpdateCompanionBuilder =
    LocalProgramsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<String> difficulty,
      Value<int> durationWeeks,
      Value<String?> thumbnailUrl,
      Value<bool> published,
      Value<DateTime?> publishedAt,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalProgramsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProgramsTable> {
  $$LocalProgramsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get published => $composableBuilder(
    column: $table.published,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProgramsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProgramsTable> {
  $$LocalProgramsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get published => $composableBuilder(
    column: $table.published,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProgramsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProgramsTable> {
  $$LocalProgramsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get published =>
      $composableBuilder(column: $table.published, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalProgramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProgramsTable,
          LocalProgram,
          $$LocalProgramsTableFilterComposer,
          $$LocalProgramsTableOrderingComposer,
          $$LocalProgramsTableAnnotationComposer,
          $$LocalProgramsTableCreateCompanionBuilder,
          $$LocalProgramsTableUpdateCompanionBuilder,
          (
            LocalProgram,
            BaseReferences<_$AppDatabase, $LocalProgramsTable, LocalProgram>,
          ),
          LocalProgram,
          PrefetchHooks Function()
        > {
  $$LocalProgramsTableTableManager(_$AppDatabase db, $LocalProgramsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProgramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProgramsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProgramsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<int> durationWeeks = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<bool> published = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProgramsCompanion(
                id: id,
                title: title,
                description: description,
                difficulty: difficulty,
                durationWeeks: durationWeeks,
                thumbnailUrl: thumbnailUrl,
                published: published,
                publishedAt: publishedAt,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                required String difficulty,
                required int durationWeeks,
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<bool> published = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalProgramsCompanion.insert(
                id: id,
                title: title,
                description: description,
                difficulty: difficulty,
                durationWeeks: durationWeeks,
                thumbnailUrl: thumbnailUrl,
                published: published,
                publishedAt: publishedAt,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProgramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProgramsTable,
      LocalProgram,
      $$LocalProgramsTableFilterComposer,
      $$LocalProgramsTableOrderingComposer,
      $$LocalProgramsTableAnnotationComposer,
      $$LocalProgramsTableCreateCompanionBuilder,
      $$LocalProgramsTableUpdateCompanionBuilder,
      (
        LocalProgram,
        BaseReferences<_$AppDatabase, $LocalProgramsTable, LocalProgram>,
      ),
      LocalProgram,
      PrefetchHooks Function()
    >;
typedef $$LocalSessionsTableCreateCompanionBuilder =
    LocalSessionsCompanion Function({
      required String id,
      required String programId,
      required int dayNumber,
      required String title,
      Value<String?> description,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalSessionsTableUpdateCompanionBuilder =
    LocalSessionsCompanion Function({
      Value<String> id,
      Value<String> programId,
      Value<int> dayNumber,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableFilterComposer({
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

  ColumnFilters<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get programId =>
      $composableBuilder(column: $table.programId, builder: (column) => column);

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSessionsTable,
          LocalSession,
          $$LocalSessionsTableFilterComposer,
          $$LocalSessionsTableOrderingComposer,
          $$LocalSessionsTableAnnotationComposer,
          $$LocalSessionsTableCreateCompanionBuilder,
          $$LocalSessionsTableUpdateCompanionBuilder,
          (
            LocalSession,
            BaseReferences<_$AppDatabase, $LocalSessionsTable, LocalSession>,
          ),
          LocalSession,
          PrefetchHooks Function()
        > {
  $$LocalSessionsTableTableManager(_$AppDatabase db, $LocalSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> programId = const Value.absent(),
                Value<int> dayNumber = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSessionsCompanion(
                id: id,
                programId: programId,
                dayNumber: dayNumber,
                title: title,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String programId,
                required int dayNumber,
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalSessionsCompanion.insert(
                id: id,
                programId: programId,
                dayNumber: dayNumber,
                title: title,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSessionsTable,
      LocalSession,
      $$LocalSessionsTableFilterComposer,
      $$LocalSessionsTableOrderingComposer,
      $$LocalSessionsTableAnnotationComposer,
      $$LocalSessionsTableCreateCompanionBuilder,
      $$LocalSessionsTableUpdateCompanionBuilder,
      (
        LocalSession,
        BaseReferences<_$AppDatabase, $LocalSessionsTable, LocalSession>,
      ),
      LocalSession,
      PrefetchHooks Function()
    >;
typedef $$LocalExercisesTableCreateCompanionBuilder =
    LocalExercisesCompanion Function({
      required String id,
      required String sessionId,
      required int displayOrder,
      required String title,
      Value<String?> cueText,
      Value<String?> muxAssetId,
      Value<String?> muxPlaybackId,
      Value<String?> muxDownloadUrl,
      Value<String?> modelAssetUrl,
      Value<int?> repCount,
      Value<int?> durationSeconds,
      Value<int> videoVersion,
      Value<String?> localVideoPath,
      Value<String?> localModelPath,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalExercisesTableUpdateCompanionBuilder =
    LocalExercisesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> displayOrder,
      Value<String> title,
      Value<String?> cueText,
      Value<String?> muxAssetId,
      Value<String?> muxPlaybackId,
      Value<String?> muxDownloadUrl,
      Value<String?> modelAssetUrl,
      Value<int?> repCount,
      Value<int?> durationSeconds,
      Value<int> videoVersion,
      Value<String?> localVideoPath,
      Value<String?> localModelPath,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalExercisesTable> {
  $$LocalExercisesTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cueText => $composableBuilder(
    column: $table.cueText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muxAssetId => $composableBuilder(
    column: $table.muxAssetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muxPlaybackId => $composableBuilder(
    column: $table.muxPlaybackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muxDownloadUrl => $composableBuilder(
    column: $table.muxDownloadUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelAssetUrl => $composableBuilder(
    column: $table.modelAssetUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repCount => $composableBuilder(
    column: $table.repCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get videoVersion => $composableBuilder(
    column: $table.videoVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localVideoPath => $composableBuilder(
    column: $table.localVideoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localModelPath => $composableBuilder(
    column: $table.localModelPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalExercisesTable> {
  $$LocalExercisesTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cueText => $composableBuilder(
    column: $table.cueText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muxAssetId => $composableBuilder(
    column: $table.muxAssetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muxPlaybackId => $composableBuilder(
    column: $table.muxPlaybackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muxDownloadUrl => $composableBuilder(
    column: $table.muxDownloadUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelAssetUrl => $composableBuilder(
    column: $table.modelAssetUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repCount => $composableBuilder(
    column: $table.repCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get videoVersion => $composableBuilder(
    column: $table.videoVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localVideoPath => $composableBuilder(
    column: $table.localVideoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localModelPath => $composableBuilder(
    column: $table.localModelPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalExercisesTable> {
  $$LocalExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get cueText =>
      $composableBuilder(column: $table.cueText, builder: (column) => column);

  GeneratedColumn<String> get muxAssetId => $composableBuilder(
    column: $table.muxAssetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get muxPlaybackId => $composableBuilder(
    column: $table.muxPlaybackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get muxDownloadUrl => $composableBuilder(
    column: $table.muxDownloadUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelAssetUrl => $composableBuilder(
    column: $table.modelAssetUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repCount =>
      $composableBuilder(column: $table.repCount, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get videoVersion => $composableBuilder(
    column: $table.videoVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localVideoPath => $composableBuilder(
    column: $table.localVideoPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localModelPath => $composableBuilder(
    column: $table.localModelPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalExercisesTable,
          LocalExercise,
          $$LocalExercisesTableFilterComposer,
          $$LocalExercisesTableOrderingComposer,
          $$LocalExercisesTableAnnotationComposer,
          $$LocalExercisesTableCreateCompanionBuilder,
          $$LocalExercisesTableUpdateCompanionBuilder,
          (
            LocalExercise,
            BaseReferences<_$AppDatabase, $LocalExercisesTable, LocalExercise>,
          ),
          LocalExercise,
          PrefetchHooks Function()
        > {
  $$LocalExercisesTableTableManager(
    _$AppDatabase db,
    $LocalExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> cueText = const Value.absent(),
                Value<String?> muxAssetId = const Value.absent(),
                Value<String?> muxPlaybackId = const Value.absent(),
                Value<String?> muxDownloadUrl = const Value.absent(),
                Value<String?> modelAssetUrl = const Value.absent(),
                Value<int?> repCount = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int> videoVersion = const Value.absent(),
                Value<String?> localVideoPath = const Value.absent(),
                Value<String?> localModelPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExercisesCompanion(
                id: id,
                sessionId: sessionId,
                displayOrder: displayOrder,
                title: title,
                cueText: cueText,
                muxAssetId: muxAssetId,
                muxPlaybackId: muxPlaybackId,
                muxDownloadUrl: muxDownloadUrl,
                modelAssetUrl: modelAssetUrl,
                repCount: repCount,
                durationSeconds: durationSeconds,
                videoVersion: videoVersion,
                localVideoPath: localVideoPath,
                localModelPath: localModelPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int displayOrder,
                required String title,
                Value<String?> cueText = const Value.absent(),
                Value<String?> muxAssetId = const Value.absent(),
                Value<String?> muxPlaybackId = const Value.absent(),
                Value<String?> muxDownloadUrl = const Value.absent(),
                Value<String?> modelAssetUrl = const Value.absent(),
                Value<int?> repCount = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int> videoVersion = const Value.absent(),
                Value<String?> localVideoPath = const Value.absent(),
                Value<String?> localModelPath = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalExercisesCompanion.insert(
                id: id,
                sessionId: sessionId,
                displayOrder: displayOrder,
                title: title,
                cueText: cueText,
                muxAssetId: muxAssetId,
                muxPlaybackId: muxPlaybackId,
                muxDownloadUrl: muxDownloadUrl,
                modelAssetUrl: modelAssetUrl,
                repCount: repCount,
                durationSeconds: durationSeconds,
                videoVersion: videoVersion,
                localVideoPath: localVideoPath,
                localModelPath: localModelPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalExercisesTable,
      LocalExercise,
      $$LocalExercisesTableFilterComposer,
      $$LocalExercisesTableOrderingComposer,
      $$LocalExercisesTableAnnotationComposer,
      $$LocalExercisesTableCreateCompanionBuilder,
      $$LocalExercisesTableUpdateCompanionBuilder,
      (
        LocalExercise,
        BaseReferences<_$AppDatabase, $LocalExercisesTable, LocalExercise>,
      ),
      LocalExercise,
      PrefetchHooks Function()
    >;
typedef $$LocalEnrollmentsTableCreateCompanionBuilder =
    LocalEnrollmentsCompanion Function({
      required String id,
      required String studentId,
      required String programId,
      required DateTime enrolledAt,
      Value<int> currentDay,
      Value<int> rowid,
    });
typedef $$LocalEnrollmentsTableUpdateCompanionBuilder =
    LocalEnrollmentsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String> programId,
      Value<DateTime> enrolledAt,
      Value<int> currentDay,
      Value<int> rowid,
    });

class $$LocalEnrollmentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalEnrollmentsTable> {
  $$LocalEnrollmentsTableFilterComposer({
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

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get enrolledAt => $composableBuilder(
    column: $table.enrolledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentDay => $composableBuilder(
    column: $table.currentDay,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalEnrollmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalEnrollmentsTable> {
  $$LocalEnrollmentsTableOrderingComposer({
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

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get enrolledAt => $composableBuilder(
    column: $table.enrolledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentDay => $composableBuilder(
    column: $table.currentDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalEnrollmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalEnrollmentsTable> {
  $$LocalEnrollmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get programId =>
      $composableBuilder(column: $table.programId, builder: (column) => column);

  GeneratedColumn<DateTime> get enrolledAt => $composableBuilder(
    column: $table.enrolledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentDay => $composableBuilder(
    column: $table.currentDay,
    builder: (column) => column,
  );
}

class $$LocalEnrollmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalEnrollmentsTable,
          LocalEnrollment,
          $$LocalEnrollmentsTableFilterComposer,
          $$LocalEnrollmentsTableOrderingComposer,
          $$LocalEnrollmentsTableAnnotationComposer,
          $$LocalEnrollmentsTableCreateCompanionBuilder,
          $$LocalEnrollmentsTableUpdateCompanionBuilder,
          (
            LocalEnrollment,
            BaseReferences<
              _$AppDatabase,
              $LocalEnrollmentsTable,
              LocalEnrollment
            >,
          ),
          LocalEnrollment,
          PrefetchHooks Function()
        > {
  $$LocalEnrollmentsTableTableManager(
    _$AppDatabase db,
    $LocalEnrollmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalEnrollmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalEnrollmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalEnrollmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> programId = const Value.absent(),
                Value<DateTime> enrolledAt = const Value.absent(),
                Value<int> currentDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalEnrollmentsCompanion(
                id: id,
                studentId: studentId,
                programId: programId,
                enrolledAt: enrolledAt,
                currentDay: currentDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String programId,
                required DateTime enrolledAt,
                Value<int> currentDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalEnrollmentsCompanion.insert(
                id: id,
                studentId: studentId,
                programId: programId,
                enrolledAt: enrolledAt,
                currentDay: currentDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalEnrollmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalEnrollmentsTable,
      LocalEnrollment,
      $$LocalEnrollmentsTableFilterComposer,
      $$LocalEnrollmentsTableOrderingComposer,
      $$LocalEnrollmentsTableAnnotationComposer,
      $$LocalEnrollmentsTableCreateCompanionBuilder,
      $$LocalEnrollmentsTableUpdateCompanionBuilder,
      (
        LocalEnrollment,
        BaseReferences<_$AppDatabase, $LocalEnrollmentsTable, LocalEnrollment>,
      ),
      LocalEnrollment,
      PrefetchHooks Function()
    >;
typedef $$LocalProgressRecordsTableCreateCompanionBuilder =
    LocalProgressRecordsCompanion Function({
      required String id,
      required String studentId,
      required String sessionId,
      required DateTime completedAt,
      Value<int?> durationSeconds,
      Value<bool> syncedFromOffline,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalProgressRecordsTableUpdateCompanionBuilder =
    LocalProgressRecordsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String> sessionId,
      Value<DateTime> completedAt,
      Value<int?> durationSeconds,
      Value<bool> syncedFromOffline,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalProgressRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProgressRecordsTable> {
  $$LocalProgressRecordsTableFilterComposer({
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

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncedFromOffline => $composableBuilder(
    column: $table.syncedFromOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProgressRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProgressRecordsTable> {
  $$LocalProgressRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncedFromOffline => $composableBuilder(
    column: $table.syncedFromOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProgressRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProgressRecordsTable> {
  $$LocalProgressRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncedFromOffline => $composableBuilder(
    column: $table.syncedFromOffline,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalProgressRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProgressRecordsTable,
          LocalProgressRecord,
          $$LocalProgressRecordsTableFilterComposer,
          $$LocalProgressRecordsTableOrderingComposer,
          $$LocalProgressRecordsTableAnnotationComposer,
          $$LocalProgressRecordsTableCreateCompanionBuilder,
          $$LocalProgressRecordsTableUpdateCompanionBuilder,
          (
            LocalProgressRecord,
            BaseReferences<
              _$AppDatabase,
              $LocalProgressRecordsTable,
              LocalProgressRecord
            >,
          ),
          LocalProgressRecord,
          PrefetchHooks Function()
        > {
  $$LocalProgressRecordsTableTableManager(
    _$AppDatabase db,
    $LocalProgressRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProgressRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProgressRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalProgressRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> syncedFromOffline = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProgressRecordsCompanion(
                id: id,
                studentId: studentId,
                sessionId: sessionId,
                completedAt: completedAt,
                durationSeconds: durationSeconds,
                syncedFromOffline: syncedFromOffline,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String sessionId,
                required DateTime completedAt,
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> syncedFromOffline = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalProgressRecordsCompanion.insert(
                id: id,
                studentId: studentId,
                sessionId: sessionId,
                completedAt: completedAt,
                durationSeconds: durationSeconds,
                syncedFromOffline: syncedFromOffline,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProgressRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProgressRecordsTable,
      LocalProgressRecord,
      $$LocalProgressRecordsTableFilterComposer,
      $$LocalProgressRecordsTableOrderingComposer,
      $$LocalProgressRecordsTableAnnotationComposer,
      $$LocalProgressRecordsTableCreateCompanionBuilder,
      $$LocalProgressRecordsTableUpdateCompanionBuilder,
      (
        LocalProgressRecord,
        BaseReferences<
          _$AppDatabase,
          $LocalProgressRecordsTable,
          LocalProgressRecord
        >,
      ),
      LocalProgressRecord,
      PrefetchHooks Function()
    >;
typedef $$LocalMetricLogsTableCreateCompanionBuilder =
    LocalMetricLogsCompanion Function({
      required String id,
      required String studentId,
      required String metricType,
      Value<String?> metricSubtype,
      required double value,
      required String unit,
      required DateTime loggedAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalMetricLogsTableUpdateCompanionBuilder =
    LocalMetricLogsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String> metricType,
      Value<String?> metricSubtype,
      Value<double> value,
      Value<String> unit,
      Value<DateTime> loggedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalMetricLogsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMetricLogsTable> {
  $$LocalMetricLogsTableFilterComposer({
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

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricSubtype => $composableBuilder(
    column: $table.metricSubtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMetricLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMetricLogsTable> {
  $$LocalMetricLogsTableOrderingComposer({
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

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricSubtype => $composableBuilder(
    column: $table.metricSubtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMetricLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMetricLogsTable> {
  $$LocalMetricLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metricSubtype => $composableBuilder(
    column: $table.metricSubtype,
    builder: (column) => column,
  );

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalMetricLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMetricLogsTable,
          LocalMetricLog,
          $$LocalMetricLogsTableFilterComposer,
          $$LocalMetricLogsTableOrderingComposer,
          $$LocalMetricLogsTableAnnotationComposer,
          $$LocalMetricLogsTableCreateCompanionBuilder,
          $$LocalMetricLogsTableUpdateCompanionBuilder,
          (
            LocalMetricLog,
            BaseReferences<
              _$AppDatabase,
              $LocalMetricLogsTable,
              LocalMetricLog
            >,
          ),
          LocalMetricLog,
          PrefetchHooks Function()
        > {
  $$LocalMetricLogsTableTableManager(
    _$AppDatabase db,
    $LocalMetricLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMetricLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMetricLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMetricLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> metricType = const Value.absent(),
                Value<String?> metricSubtype = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMetricLogsCompanion(
                id: id,
                studentId: studentId,
                metricType: metricType,
                metricSubtype: metricSubtype,
                value: value,
                unit: unit,
                loggedAt: loggedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String metricType,
                Value<String?> metricSubtype = const Value.absent(),
                required double value,
                required String unit,
                required DateTime loggedAt,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalMetricLogsCompanion.insert(
                id: id,
                studentId: studentId,
                metricType: metricType,
                metricSubtype: metricSubtype,
                value: value,
                unit: unit,
                loggedAt: loggedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMetricLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMetricLogsTable,
      LocalMetricLog,
      $$LocalMetricLogsTableFilterComposer,
      $$LocalMetricLogsTableOrderingComposer,
      $$LocalMetricLogsTableAnnotationComposer,
      $$LocalMetricLogsTableCreateCompanionBuilder,
      $$LocalMetricLogsTableUpdateCompanionBuilder,
      (
        LocalMetricLog,
        BaseReferences<_$AppDatabase, $LocalMetricLogsTable, LocalMetricLog>,
      ),
      LocalMetricLog,
      PrefetchHooks Function()
    >;
typedef $$LocalFeedbackThreadsTableCreateCompanionBuilder =
    LocalFeedbackThreadsCompanion Function({
      required String id,
      required String studentId,
      required String sessionId,
      required String studentMessage,
      Value<String?> photoUrl,
      Value<String?> coachReply,
      Value<DateTime?> repliedAt,
      Value<bool> notificationSent,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> status,
      Value<String?> localPhotoPath,
      Value<int> rowid,
    });
typedef $$LocalFeedbackThreadsTableUpdateCompanionBuilder =
    LocalFeedbackThreadsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String> sessionId,
      Value<String> studentMessage,
      Value<String?> photoUrl,
      Value<String?> coachReply,
      Value<DateTime?> repliedAt,
      Value<bool> notificationSent,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> status,
      Value<String?> localPhotoPath,
      Value<int> rowid,
    });

class $$LocalFeedbackThreadsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFeedbackThreadsTable> {
  $$LocalFeedbackThreadsTableFilterComposer({
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

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentMessage => $composableBuilder(
    column: $table.studentMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coachReply => $composableBuilder(
    column: $table.coachReply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get repliedAt => $composableBuilder(
    column: $table.repliedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationSent => $composableBuilder(
    column: $table.notificationSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalFeedbackThreadsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFeedbackThreadsTable> {
  $$LocalFeedbackThreadsTableOrderingComposer({
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

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentMessage => $composableBuilder(
    column: $table.studentMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coachReply => $composableBuilder(
    column: $table.coachReply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get repliedAt => $composableBuilder(
    column: $table.repliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationSent => $composableBuilder(
    column: $table.notificationSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalFeedbackThreadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFeedbackThreadsTable> {
  $$LocalFeedbackThreadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get studentMessage => $composableBuilder(
    column: $table.studentMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get coachReply => $composableBuilder(
    column: $table.coachReply,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get repliedAt =>
      $composableBuilder(column: $table.repliedAt, builder: (column) => column);

  GeneratedColumn<bool> get notificationSent => $composableBuilder(
    column: $table.notificationSent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => column,
  );
}

class $$LocalFeedbackThreadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalFeedbackThreadsTable,
          LocalFeedbackThread,
          $$LocalFeedbackThreadsTableFilterComposer,
          $$LocalFeedbackThreadsTableOrderingComposer,
          $$LocalFeedbackThreadsTableAnnotationComposer,
          $$LocalFeedbackThreadsTableCreateCompanionBuilder,
          $$LocalFeedbackThreadsTableUpdateCompanionBuilder,
          (
            LocalFeedbackThread,
            BaseReferences<
              _$AppDatabase,
              $LocalFeedbackThreadsTable,
              LocalFeedbackThread
            >,
          ),
          LocalFeedbackThread,
          PrefetchHooks Function()
        > {
  $$LocalFeedbackThreadsTableTableManager(
    _$AppDatabase db,
    $LocalFeedbackThreadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFeedbackThreadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFeedbackThreadsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalFeedbackThreadsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> studentMessage = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> coachReply = const Value.absent(),
                Value<DateTime?> repliedAt = const Value.absent(),
                Value<bool> notificationSent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> localPhotoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalFeedbackThreadsCompanion(
                id: id,
                studentId: studentId,
                sessionId: sessionId,
                studentMessage: studentMessage,
                photoUrl: photoUrl,
                coachReply: coachReply,
                repliedAt: repliedAt,
                notificationSent: notificationSent,
                createdAt: createdAt,
                updatedAt: updatedAt,
                status: status,
                localPhotoPath: localPhotoPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String sessionId,
                required String studentMessage,
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> coachReply = const Value.absent(),
                Value<DateTime?> repliedAt = const Value.absent(),
                Value<bool> notificationSent = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> status = const Value.absent(),
                Value<String?> localPhotoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalFeedbackThreadsCompanion.insert(
                id: id,
                studentId: studentId,
                sessionId: sessionId,
                studentMessage: studentMessage,
                photoUrl: photoUrl,
                coachReply: coachReply,
                repliedAt: repliedAt,
                notificationSent: notificationSent,
                createdAt: createdAt,
                updatedAt: updatedAt,
                status: status,
                localPhotoPath: localPhotoPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalFeedbackThreadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalFeedbackThreadsTable,
      LocalFeedbackThread,
      $$LocalFeedbackThreadsTableFilterComposer,
      $$LocalFeedbackThreadsTableOrderingComposer,
      $$LocalFeedbackThreadsTableAnnotationComposer,
      $$LocalFeedbackThreadsTableCreateCompanionBuilder,
      $$LocalFeedbackThreadsTableUpdateCompanionBuilder,
      (
        LocalFeedbackThread,
        BaseReferences<
          _$AppDatabase,
          $LocalFeedbackThreadsTable,
          LocalFeedbackThread
        >,
      ),
      LocalFeedbackThread,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String operation,
      required String targetTable,
      required String payload,
      required int createdAt,
      Value<int> retryCount,
      Value<String?> lastError,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> operation,
      Value<String> targetTable,
      Value<String> payload,
      Value<int> createdAt,
      Value<int> retryCount,
      Value<String?> lastError,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
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

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
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

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                operation: operation,
                targetTable: targetTable,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operation,
                required String targetTable,
                required String payload,
                required int createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                operation: operation,
                targetTable: targetTable,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$DownloadManifestTableCreateCompanionBuilder =
    DownloadManifestCompanion Function({
      required String exerciseId,
      required int videoVersion,
      Value<String?> videoLocalPath,
      Value<String?> modelLocalPath,
      Value<String> downloadStatus,
      Value<int?> downloadedAt,
      Value<int> rowid,
    });
typedef $$DownloadManifestTableUpdateCompanionBuilder =
    DownloadManifestCompanion Function({
      Value<String> exerciseId,
      Value<int> videoVersion,
      Value<String?> videoLocalPath,
      Value<String?> modelLocalPath,
      Value<String> downloadStatus,
      Value<int?> downloadedAt,
      Value<int> rowid,
    });

class $$DownloadManifestTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadManifestTable> {
  $$DownloadManifestTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get videoVersion => $composableBuilder(
    column: $table.videoVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoLocalPath => $composableBuilder(
    column: $table.videoLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelLocalPath => $composableBuilder(
    column: $table.modelLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadManifestTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadManifestTable> {
  $$DownloadManifestTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get videoVersion => $composableBuilder(
    column: $table.videoVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoLocalPath => $composableBuilder(
    column: $table.videoLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelLocalPath => $composableBuilder(
    column: $table.modelLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadManifestTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadManifestTable> {
  $$DownloadManifestTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get videoVersion => $composableBuilder(
    column: $table.videoVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoLocalPath => $composableBuilder(
    column: $table.videoLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelLocalPath => $composableBuilder(
    column: $table.modelLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$DownloadManifestTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadManifestTable,
          DownloadManifestData,
          $$DownloadManifestTableFilterComposer,
          $$DownloadManifestTableOrderingComposer,
          $$DownloadManifestTableAnnotationComposer,
          $$DownloadManifestTableCreateCompanionBuilder,
          $$DownloadManifestTableUpdateCompanionBuilder,
          (
            DownloadManifestData,
            BaseReferences<
              _$AppDatabase,
              $DownloadManifestTable,
              DownloadManifestData
            >,
          ),
          DownloadManifestData,
          PrefetchHooks Function()
        > {
  $$DownloadManifestTableTableManager(
    _$AppDatabase db,
    $DownloadManifestTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadManifestTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadManifestTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadManifestTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<int> videoVersion = const Value.absent(),
                Value<String?> videoLocalPath = const Value.absent(),
                Value<String?> modelLocalPath = const Value.absent(),
                Value<String> downloadStatus = const Value.absent(),
                Value<int?> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadManifestCompanion(
                exerciseId: exerciseId,
                videoVersion: videoVersion,
                videoLocalPath: videoLocalPath,
                modelLocalPath: modelLocalPath,
                downloadStatus: downloadStatus,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required int videoVersion,
                Value<String?> videoLocalPath = const Value.absent(),
                Value<String?> modelLocalPath = const Value.absent(),
                Value<String> downloadStatus = const Value.absent(),
                Value<int?> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadManifestCompanion.insert(
                exerciseId: exerciseId,
                videoVersion: videoVersion,
                videoLocalPath: videoLocalPath,
                modelLocalPath: modelLocalPath,
                downloadStatus: downloadStatus,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadManifestTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadManifestTable,
      DownloadManifestData,
      $$DownloadManifestTableFilterComposer,
      $$DownloadManifestTableOrderingComposer,
      $$DownloadManifestTableAnnotationComposer,
      $$DownloadManifestTableCreateCompanionBuilder,
      $$DownloadManifestTableUpdateCompanionBuilder,
      (
        DownloadManifestData,
        BaseReferences<
          _$AppDatabase,
          $DownloadManifestTable,
          DownloadManifestData
        >,
      ),
      DownloadManifestData,
      PrefetchHooks Function()
    >;
typedef $$SessionResumeStateTableCreateCompanionBuilder =
    SessionResumeStateCompanion Function({
      required String sessionId,
      required String studentId,
      Value<int> exerciseIndex,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionResumeStateTableUpdateCompanionBuilder =
    SessionResumeStateCompanion Function({
      Value<String> sessionId,
      Value<String> studentId,
      Value<int> exerciseIndex,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionResumeStateTableFilterComposer
    extends Composer<_$AppDatabase, $SessionResumeStateTable> {
  $$SessionResumeStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exerciseIndex => $composableBuilder(
    column: $table.exerciseIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionResumeStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionResumeStateTable> {
  $$SessionResumeStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exerciseIndex => $composableBuilder(
    column: $table.exerciseIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionResumeStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionResumeStateTable> {
  $$SessionResumeStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get exerciseIndex => $composableBuilder(
    column: $table.exerciseIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionResumeStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionResumeStateTable,
          SessionResumeStateData,
          $$SessionResumeStateTableFilterComposer,
          $$SessionResumeStateTableOrderingComposer,
          $$SessionResumeStateTableAnnotationComposer,
          $$SessionResumeStateTableCreateCompanionBuilder,
          $$SessionResumeStateTableUpdateCompanionBuilder,
          (
            SessionResumeStateData,
            BaseReferences<
              _$AppDatabase,
              $SessionResumeStateTable,
              SessionResumeStateData
            >,
          ),
          SessionResumeStateData,
          PrefetchHooks Function()
        > {
  $$SessionResumeStateTableTableManager(
    _$AppDatabase db,
    $SessionResumeStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionResumeStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionResumeStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionResumeStateTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<int> exerciseIndex = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionResumeStateCompanion(
                sessionId: sessionId,
                studentId: studentId,
                exerciseIndex: exerciseIndex,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String studentId,
                Value<int> exerciseIndex = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionResumeStateCompanion.insert(
                sessionId: sessionId,
                studentId: studentId,
                exerciseIndex: exerciseIndex,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionResumeStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionResumeStateTable,
      SessionResumeStateData,
      $$SessionResumeStateTableFilterComposer,
      $$SessionResumeStateTableOrderingComposer,
      $$SessionResumeStateTableAnnotationComposer,
      $$SessionResumeStateTableCreateCompanionBuilder,
      $$SessionResumeStateTableUpdateCompanionBuilder,
      (
        SessionResumeStateData,
        BaseReferences<
          _$AppDatabase,
          $SessionResumeStateTable,
          SessionResumeStateData
        >,
      ),
      SessionResumeStateData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalProgramsTableTableManager get localPrograms =>
      $$LocalProgramsTableTableManager(_db, _db.localPrograms);
  $$LocalSessionsTableTableManager get localSessions =>
      $$LocalSessionsTableTableManager(_db, _db.localSessions);
  $$LocalExercisesTableTableManager get localExercises =>
      $$LocalExercisesTableTableManager(_db, _db.localExercises);
  $$LocalEnrollmentsTableTableManager get localEnrollments =>
      $$LocalEnrollmentsTableTableManager(_db, _db.localEnrollments);
  $$LocalProgressRecordsTableTableManager get localProgressRecords =>
      $$LocalProgressRecordsTableTableManager(_db, _db.localProgressRecords);
  $$LocalMetricLogsTableTableManager get localMetricLogs =>
      $$LocalMetricLogsTableTableManager(_db, _db.localMetricLogs);
  $$LocalFeedbackThreadsTableTableManager get localFeedbackThreads =>
      $$LocalFeedbackThreadsTableTableManager(_db, _db.localFeedbackThreads);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$DownloadManifestTableTableManager get downloadManifest =>
      $$DownloadManifestTableTableManager(_db, _db.downloadManifest);
  $$SessionResumeStateTableTableManager get sessionResumeState =>
      $$SessionResumeStateTableTableManager(_db, _db.sessionResumeState);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';
