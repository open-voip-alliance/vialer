// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class CallRecord extends DataClass implements Insertable<CallRecord> {
  final int id;
  final DateTime date;
  final Duration duration;
  final String callerNumber;
  final String sourceNumber;
  final String callerId;
  final String originalCallerId;
  final String destinationNumber;
  final Direction direction;
  CallRecord(
      {@required this.id,
      @required this.date,
      @required this.duration,
      @required this.callerNumber,
      @required this.sourceNumber,
      @required this.callerId,
      @required this.originalCallerId,
      @required this.destinationNumber,
      @required this.direction});
  factory CallRecord.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    return CallRecord(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      date:
          dateTimeType.mapFromDatabaseResponse(data['${effectivePrefix}date']),
      duration: $CallsTable.$converter0.mapToDart(
          intType.mapFromDatabaseResponse(data['${effectivePrefix}duration'])),
      callerNumber: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}caller_number']),
      sourceNumber: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}source_number']),
      callerId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}caller_id']),
      originalCallerId: stringType.mapFromDatabaseResponse(
          data['${effectivePrefix}original_caller_id']),
      destinationNumber: stringType.mapFromDatabaseResponse(
          data['${effectivePrefix}destination_number']),
      direction: $CallsTable.$converter1.mapToDart(
          intType.mapFromDatabaseResponse(data['${effectivePrefix}direction'])),
    );
  }
  factory CallRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return CallRecord(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      duration: serializer.fromJson<Duration>(json['duration']),
      callerNumber: serializer.fromJson<String>(json['callerNumber']),
      sourceNumber: serializer.fromJson<String>(json['sourceNumber']),
      callerId: serializer.fromJson<String>(json['callerId']),
      originalCallerId: serializer.fromJson<String>(json['originalCallerId']),
      destinationNumber: serializer.fromJson<String>(json['destinationNumber']),
      direction: serializer.fromJson<Direction>(json['direction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'duration': serializer.toJson<Duration>(duration),
      'callerNumber': serializer.toJson<String>(callerNumber),
      'sourceNumber': serializer.toJson<String>(sourceNumber),
      'callerId': serializer.toJson<String>(callerId),
      'originalCallerId': serializer.toJson<String>(originalCallerId),
      'destinationNumber': serializer.toJson<String>(destinationNumber),
      'direction': serializer.toJson<Direction>(direction),
    };
  }

  @override
  CallsCompanion createCompanion(bool nullToAbsent) {
    return CallsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      callerNumber: callerNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(callerNumber),
      sourceNumber: sourceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceNumber),
      callerId: callerId == null && nullToAbsent
          ? const Value.absent()
          : Value(callerId),
      originalCallerId: originalCallerId == null && nullToAbsent
          ? const Value.absent()
          : Value(originalCallerId),
      destinationNumber: destinationNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationNumber),
      direction: direction == null && nullToAbsent
          ? const Value.absent()
          : Value(direction),
    );
  }

  CallRecord copyWith(
          {int id,
          DateTime date,
          Duration duration,
          String callerNumber,
          String sourceNumber,
          String callerId,
          String originalCallerId,
          String destinationNumber,
          Direction direction}) =>
      CallRecord(
        id: id ?? this.id,
        date: date ?? this.date,
        duration: duration ?? this.duration,
        callerNumber: callerNumber ?? this.callerNumber,
        sourceNumber: sourceNumber ?? this.sourceNumber,
        callerId: callerId ?? this.callerId,
        originalCallerId: originalCallerId ?? this.originalCallerId,
        destinationNumber: destinationNumber ?? this.destinationNumber,
        direction: direction ?? this.direction,
      );
  @override
  String toString() {
    return (StringBuffer('CallRecord(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('duration: $duration, ')
          ..write('callerNumber: $callerNumber, ')
          ..write('sourceNumber: $sourceNumber, ')
          ..write('callerId: $callerId, ')
          ..write('originalCallerId: $originalCallerId, ')
          ..write('destinationNumber: $destinationNumber, ')
          ..write('direction: $direction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          date.hashCode,
          $mrjc(
              duration.hashCode,
              $mrjc(
                  callerNumber.hashCode,
                  $mrjc(
                      sourceNumber.hashCode,
                      $mrjc(
                          callerId.hashCode,
                          $mrjc(
                              originalCallerId.hashCode,
                              $mrjc(destinationNumber.hashCode,
                                  direction.hashCode)))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is CallRecord &&
          other.id == this.id &&
          other.date == this.date &&
          other.duration == this.duration &&
          other.callerNumber == this.callerNumber &&
          other.sourceNumber == this.sourceNumber &&
          other.callerId == this.callerId &&
          other.originalCallerId == this.originalCallerId &&
          other.destinationNumber == this.destinationNumber &&
          other.direction == this.direction);
}

class CallsCompanion extends UpdateCompanion<CallRecord> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<Duration> duration;
  final Value<String> callerNumber;
  final Value<String> sourceNumber;
  final Value<String> callerId;
  final Value<String> originalCallerId;
  final Value<String> destinationNumber;
  final Value<Direction> direction;
  const CallsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.duration = const Value.absent(),
    this.callerNumber = const Value.absent(),
    this.sourceNumber = const Value.absent(),
    this.callerId = const Value.absent(),
    this.originalCallerId = const Value.absent(),
    this.destinationNumber = const Value.absent(),
    this.direction = const Value.absent(),
  });
  CallsCompanion.insert({
    @required int id,
    @required DateTime date,
    @required Duration duration,
    @required String callerNumber,
    @required String sourceNumber,
    @required String callerId,
    @required String originalCallerId,
    @required String destinationNumber,
    @required Direction direction,
  })  : id = Value(id),
        date = Value(date),
        duration = Value(duration),
        callerNumber = Value(callerNumber),
        sourceNumber = Value(sourceNumber),
        callerId = Value(callerId),
        originalCallerId = Value(originalCallerId),
        destinationNumber = Value(destinationNumber),
        direction = Value(direction);
  CallsCompanion copyWith(
      {Value<int> id,
      Value<DateTime> date,
      Value<Duration> duration,
      Value<String> callerNumber,
      Value<String> sourceNumber,
      Value<String> callerId,
      Value<String> originalCallerId,
      Value<String> destinationNumber,
      Value<Direction> direction}) {
    return CallsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      callerNumber: callerNumber ?? this.callerNumber,
      sourceNumber: sourceNumber ?? this.sourceNumber,
      callerId: callerId ?? this.callerId,
      originalCallerId: originalCallerId ?? this.originalCallerId,
      destinationNumber: destinationNumber ?? this.destinationNumber,
      direction: direction ?? this.direction,
    );
  }
}

class $CallsTable extends Calls with TableInfo<$CallsTable, CallRecord> {
  final GeneratedDatabase _db;
  final String _alias;
  $CallsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn(
      'id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _dateMeta = const VerificationMeta('date');
  GeneratedDateTimeColumn _date;
  @override
  GeneratedDateTimeColumn get date => _date ??= _constructDate();
  GeneratedDateTimeColumn _constructDate() {
    return GeneratedDateTimeColumn(
      'date',
      $tableName,
      false,
    );
  }

  final VerificationMeta _durationMeta = const VerificationMeta('duration');
  GeneratedIntColumn _duration;
  @override
  GeneratedIntColumn get duration => _duration ??= _constructDuration();
  GeneratedIntColumn _constructDuration() {
    return GeneratedIntColumn(
      'duration',
      $tableName,
      false,
    );
  }

  final VerificationMeta _callerNumberMeta =
      const VerificationMeta('callerNumber');
  GeneratedTextColumn _callerNumber;
  @override
  GeneratedTextColumn get callerNumber =>
      _callerNumber ??= _constructCallerNumber();
  GeneratedTextColumn _constructCallerNumber() {
    return GeneratedTextColumn(
      'caller_number',
      $tableName,
      false,
    );
  }

  final VerificationMeta _sourceNumberMeta =
      const VerificationMeta('sourceNumber');
  GeneratedTextColumn _sourceNumber;
  @override
  GeneratedTextColumn get sourceNumber =>
      _sourceNumber ??= _constructSourceNumber();
  GeneratedTextColumn _constructSourceNumber() {
    return GeneratedTextColumn(
      'source_number',
      $tableName,
      false,
    );
  }

  final VerificationMeta _callerIdMeta = const VerificationMeta('callerId');
  GeneratedTextColumn _callerId;
  @override
  GeneratedTextColumn get callerId => _callerId ??= _constructCallerId();
  GeneratedTextColumn _constructCallerId() {
    return GeneratedTextColumn(
      'caller_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _originalCallerIdMeta =
      const VerificationMeta('originalCallerId');
  GeneratedTextColumn _originalCallerId;
  @override
  GeneratedTextColumn get originalCallerId =>
      _originalCallerId ??= _constructOriginalCallerId();
  GeneratedTextColumn _constructOriginalCallerId() {
    return GeneratedTextColumn(
      'original_caller_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _destinationNumberMeta =
      const VerificationMeta('destinationNumber');
  GeneratedTextColumn _destinationNumber;
  @override
  GeneratedTextColumn get destinationNumber =>
      _destinationNumber ??= _constructDestinationNumber();
  GeneratedTextColumn _constructDestinationNumber() {
    return GeneratedTextColumn(
      'destination_number',
      $tableName,
      false,
    );
  }

  final VerificationMeta _directionMeta = const VerificationMeta('direction');
  GeneratedIntColumn _direction;
  @override
  GeneratedIntColumn get direction => _direction ??= _constructDirection();
  GeneratedIntColumn _constructDirection() {
    return GeneratedIntColumn(
      'direction',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        duration,
        callerNumber,
        sourceNumber,
        callerId,
        originalCallerId,
        destinationNumber,
        direction
      ];
  @override
  $CallsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'calls';
  @override
  final String actualTableName = 'calls';
  @override
  VerificationContext validateIntegrity(CallsCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (d.date.present) {
      context.handle(
          _dateMeta, date.isAcceptableValue(d.date.value, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    context.handle(_durationMeta, const VerificationResult.success());
    if (d.callerNumber.present) {
      context.handle(
          _callerNumberMeta,
          callerNumber.isAcceptableValue(
              d.callerNumber.value, _callerNumberMeta));
    } else if (isInserting) {
      context.missing(_callerNumberMeta);
    }
    if (d.sourceNumber.present) {
      context.handle(
          _sourceNumberMeta,
          sourceNumber.isAcceptableValue(
              d.sourceNumber.value, _sourceNumberMeta));
    } else if (isInserting) {
      context.missing(_sourceNumberMeta);
    }
    if (d.callerId.present) {
      context.handle(_callerIdMeta,
          callerId.isAcceptableValue(d.callerId.value, _callerIdMeta));
    } else if (isInserting) {
      context.missing(_callerIdMeta);
    }
    if (d.originalCallerId.present) {
      context.handle(
          _originalCallerIdMeta,
          originalCallerId.isAcceptableValue(
              d.originalCallerId.value, _originalCallerIdMeta));
    } else if (isInserting) {
      context.missing(_originalCallerIdMeta);
    }
    if (d.destinationNumber.present) {
      context.handle(
          _destinationNumberMeta,
          destinationNumber.isAcceptableValue(
              d.destinationNumber.value, _destinationNumberMeta));
    } else if (isInserting) {
      context.missing(_destinationNumberMeta);
    }
    context.handle(_directionMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  CallRecord map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return CallRecord.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(CallsCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.date.present) {
      map['date'] = Variable<DateTime, DateTimeType>(d.date.value);
    }
    if (d.duration.present) {
      final converter = $CallsTable.$converter0;
      map['duration'] =
          Variable<int, IntType>(converter.mapToSql(d.duration.value));
    }
    if (d.callerNumber.present) {
      map['caller_number'] = Variable<String, StringType>(d.callerNumber.value);
    }
    if (d.sourceNumber.present) {
      map['source_number'] = Variable<String, StringType>(d.sourceNumber.value);
    }
    if (d.callerId.present) {
      map['caller_id'] = Variable<String, StringType>(d.callerId.value);
    }
    if (d.originalCallerId.present) {
      map['original_caller_id'] =
          Variable<String, StringType>(d.originalCallerId.value);
    }
    if (d.destinationNumber.present) {
      map['destination_number'] =
          Variable<String, StringType>(d.destinationNumber.value);
    }
    if (d.direction.present) {
      final converter = $CallsTable.$converter1;
      map['direction'] =
          Variable<int, IntType>(converter.mapToSql(d.direction.value));
    }
    return map;
  }

  @override
  $CallsTable createAlias(String alias) {
    return $CallsTable(_db, alias);
  }

  static TypeConverter<Duration, int> $converter0 = DurationConverter();
  static TypeConverter<Direction, int> $converter1 = DirectionConverter();
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $CallsTable _calls;
  $CallsTable get calls => _calls ??= $CallsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [calls];
}
