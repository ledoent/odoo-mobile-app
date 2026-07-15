// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PickingsTable extends Pickings with TableInfo<$PickingsTable, Picking> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PickingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pickingTypeCodeMeta = const VerificationMeta(
    'pickingTypeCode',
  );
  @override
  late final GeneratedColumn<String> pickingTypeCode = GeneratedColumn<String>(
    'picking_type_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerNameMeta = const VerificationMeta(
    'partnerName',
  );
  @override
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>(
    'partner_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    state,
    pickingTypeCode,
    partnerName,
    scheduledDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pickings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Picking> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('picking_type_code')) {
      context.handle(
        _pickingTypeCodeMeta,
        pickingTypeCode.isAcceptableOrUnknown(
          data['picking_type_code']!,
          _pickingTypeCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pickingTypeCodeMeta);
    }
    if (data.containsKey('partner_name')) {
      context.handle(
        _partnerNameMeta,
        partnerName.isAcceptableOrUnknown(
          data['partner_name']!,
          _partnerNameMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Picking map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Picking(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      pickingTypeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}picking_type_code'],
      )!,
      partnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_name'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      ),
    );
  }

  @override
  $PickingsTable createAlias(String alias) {
    return $PickingsTable(attachedDatabase, alias);
  }
}

class Picking extends DataClass implements Insertable<Picking> {
  final int id;
  final String name;
  final String state;
  final String pickingTypeCode;
  final String partnerName;
  final DateTime? scheduledDate;
  const Picking({
    required this.id,
    required this.name,
    required this.state,
    required this.pickingTypeCode,
    required this.partnerName,
    this.scheduledDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['state'] = Variable<String>(state);
    map['picking_type_code'] = Variable<String>(pickingTypeCode);
    map['partner_name'] = Variable<String>(partnerName);
    if (!nullToAbsent || scheduledDate != null) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    }
    return map;
  }

  PickingsCompanion toCompanion(bool nullToAbsent) {
    return PickingsCompanion(
      id: Value(id),
      name: Value(name),
      state: Value(state),
      pickingTypeCode: Value(pickingTypeCode),
      partnerName: Value(partnerName),
      scheduledDate: scheduledDate == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledDate),
    );
  }

  factory Picking.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Picking(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      state: serializer.fromJson<String>(json['state']),
      pickingTypeCode: serializer.fromJson<String>(json['pickingTypeCode']),
      partnerName: serializer.fromJson<String>(json['partnerName']),
      scheduledDate: serializer.fromJson<DateTime?>(json['scheduledDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'state': serializer.toJson<String>(state),
      'pickingTypeCode': serializer.toJson<String>(pickingTypeCode),
      'partnerName': serializer.toJson<String>(partnerName),
      'scheduledDate': serializer.toJson<DateTime?>(scheduledDate),
    };
  }

  Picking copyWith({
    int? id,
    String? name,
    String? state,
    String? pickingTypeCode,
    String? partnerName,
    Value<DateTime?> scheduledDate = const Value.absent(),
  }) => Picking(
    id: id ?? this.id,
    name: name ?? this.name,
    state: state ?? this.state,
    pickingTypeCode: pickingTypeCode ?? this.pickingTypeCode,
    partnerName: partnerName ?? this.partnerName,
    scheduledDate: scheduledDate.present
        ? scheduledDate.value
        : this.scheduledDate,
  );
  Picking copyWithCompanion(PickingsCompanion data) {
    return Picking(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      state: data.state.present ? data.state.value : this.state,
      pickingTypeCode: data.pickingTypeCode.present
          ? data.pickingTypeCode.value
          : this.pickingTypeCode,
      partnerName: data.partnerName.present
          ? data.partnerName.value
          : this.partnerName,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Picking(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('pickingTypeCode: $pickingTypeCode, ')
          ..write('partnerName: $partnerName, ')
          ..write('scheduledDate: $scheduledDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, state, pickingTypeCode, partnerName, scheduledDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Picking &&
          other.id == this.id &&
          other.name == this.name &&
          other.state == this.state &&
          other.pickingTypeCode == this.pickingTypeCode &&
          other.partnerName == this.partnerName &&
          other.scheduledDate == this.scheduledDate);
}

class PickingsCompanion extends UpdateCompanion<Picking> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> state;
  final Value<String> pickingTypeCode;
  final Value<String> partnerName;
  final Value<DateTime?> scheduledDate;
  const PickingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.state = const Value.absent(),
    this.pickingTypeCode = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.scheduledDate = const Value.absent(),
  });
  PickingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String state,
    required String pickingTypeCode,
    this.partnerName = const Value.absent(),
    this.scheduledDate = const Value.absent(),
  }) : name = Value(name),
       state = Value(state),
       pickingTypeCode = Value(pickingTypeCode);
  static Insertable<Picking> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? state,
    Expression<String>? pickingTypeCode,
    Expression<String>? partnerName,
    Expression<DateTime>? scheduledDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (state != null) 'state': state,
      if (pickingTypeCode != null) 'picking_type_code': pickingTypeCode,
      if (partnerName != null) 'partner_name': partnerName,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
    });
  }

  PickingsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? state,
    Value<String>? pickingTypeCode,
    Value<String>? partnerName,
    Value<DateTime?>? scheduledDate,
  }) {
    return PickingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      pickingTypeCode: pickingTypeCode ?? this.pickingTypeCode,
      partnerName: partnerName ?? this.partnerName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (pickingTypeCode.present) {
      map['picking_type_code'] = Variable<String>(pickingTypeCode.value);
    }
    if (partnerName.present) {
      map['partner_name'] = Variable<String>(partnerName.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PickingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('pickingTypeCode: $pickingTypeCode, ')
          ..write('partnerName: $partnerName, ')
          ..write('scheduledDate: $scheduledDate')
          ..write(')'))
        .toString();
  }
}

class $MoveLinesTable extends MoveLines
    with TableInfo<$MoveLinesTable, MoveLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoveLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pickingIdMeta = const VerificationMeta(
    'pickingId',
  );
  @override
  late final GeneratedColumn<int> pickingId = GeneratedColumn<int>(
    'picking_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pickedMeta = const VerificationMeta('picked');
  @override
  late final GeneratedColumn<bool> picked = GeneratedColumn<bool>(
    'picked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("picked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pickingId,
    productId,
    productName,
    quantity,
    picked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'move_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoveLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('picking_id')) {
      context.handle(
        _pickingIdMeta,
        pickingId.isAcceptableOrUnknown(data['picking_id']!, _pickingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pickingIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('picked')) {
      context.handle(
        _pickedMeta,
        picked.isAcceptableOrUnknown(data['picked']!, _pickedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoveLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoveLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pickingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}picking_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      picked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}picked'],
      )!,
    );
  }

  @override
  $MoveLinesTable createAlias(String alias) {
    return $MoveLinesTable(attachedDatabase, alias);
  }
}

class MoveLine extends DataClass implements Insertable<MoveLine> {
  final int id;
  final int pickingId;
  final int productId;
  final String productName;
  final double quantity;
  final bool picked;
  const MoveLine({
    required this.id,
    required this.pickingId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.picked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['picking_id'] = Variable<int>(pickingId);
    map['product_id'] = Variable<int>(productId);
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<double>(quantity);
    map['picked'] = Variable<bool>(picked);
    return map;
  }

  MoveLinesCompanion toCompanion(bool nullToAbsent) {
    return MoveLinesCompanion(
      id: Value(id),
      pickingId: Value(pickingId),
      productId: Value(productId),
      productName: Value(productName),
      quantity: Value(quantity),
      picked: Value(picked),
    );
  }

  factory MoveLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoveLine(
      id: serializer.fromJson<int>(json['id']),
      pickingId: serializer.fromJson<int>(json['pickingId']),
      productId: serializer.fromJson<int>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      picked: serializer.fromJson<bool>(json['picked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pickingId': serializer.toJson<int>(pickingId),
      'productId': serializer.toJson<int>(productId),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<double>(quantity),
      'picked': serializer.toJson<bool>(picked),
    };
  }

  MoveLine copyWith({
    int? id,
    int? pickingId,
    int? productId,
    String? productName,
    double? quantity,
    bool? picked,
  }) => MoveLine(
    id: id ?? this.id,
    pickingId: pickingId ?? this.pickingId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    picked: picked ?? this.picked,
  );
  MoveLine copyWithCompanion(MoveLinesCompanion data) {
    return MoveLine(
      id: data.id.present ? data.id.value : this.id,
      pickingId: data.pickingId.present ? data.pickingId.value : this.pickingId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      picked: data.picked.present ? data.picked.value : this.picked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoveLine(')
          ..write('id: $id, ')
          ..write('pickingId: $pickingId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('picked: $picked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pickingId, productId, productName, quantity, picked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoveLine &&
          other.id == this.id &&
          other.pickingId == this.pickingId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.picked == this.picked);
}

class MoveLinesCompanion extends UpdateCompanion<MoveLine> {
  final Value<int> id;
  final Value<int> pickingId;
  final Value<int> productId;
  final Value<String> productName;
  final Value<double> quantity;
  final Value<bool> picked;
  const MoveLinesCompanion({
    this.id = const Value.absent(),
    this.pickingId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.picked = const Value.absent(),
  });
  MoveLinesCompanion.insert({
    this.id = const Value.absent(),
    required int pickingId,
    required int productId,
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.picked = const Value.absent(),
  }) : pickingId = Value(pickingId),
       productId = Value(productId);
  static Insertable<MoveLine> custom({
    Expression<int>? id,
    Expression<int>? pickingId,
    Expression<int>? productId,
    Expression<String>? productName,
    Expression<double>? quantity,
    Expression<bool>? picked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pickingId != null) 'picking_id': pickingId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (picked != null) 'picked': picked,
    });
  }

  MoveLinesCompanion copyWith({
    Value<int>? id,
    Value<int>? pickingId,
    Value<int>? productId,
    Value<String>? productName,
    Value<double>? quantity,
    Value<bool>? picked,
  }) {
    return MoveLinesCompanion(
      id: id ?? this.id,
      pickingId: pickingId ?? this.pickingId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      picked: picked ?? this.picked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pickingId.present) {
      map['picking_id'] = Variable<int>(pickingId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (picked.present) {
      map['picked'] = Variable<bool>(picked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoveLinesCompanion(')
          ..write('id: $id, ')
          ..write('pickingId: $pickingId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('picked: $picked')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, barcode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String name;
  final String? barcode;
  const Product({required this.id, required this.name, this.barcode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      barcode: serializer.fromJson<String?>(json['barcode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'barcode': serializer.toJson<String?>(barcode),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    Value<String?> barcode = const Value.absent(),
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    barcode: barcode.present ? barcode.value : this.barcode,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, barcode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.barcode == this.barcode);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> barcode;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.barcode = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.barcode = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? barcode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (barcode != null) 'barcode': barcode,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? barcode,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode')
          ..write(')'))
        .toString();
  }
}

class $OpQueueTable extends OpQueue with TableInfo<$OpQueueTable, OpQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpQueueTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
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
  @override
  late final GeneratedColumnWithTypeConverter<OpStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(OpStatus.pending.name),
      ).withConverter<OpStatus>($OpQueueTable.$converterstatus);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    kind,
    payload,
    status,
    attempts,
    lastError,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'op_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OpQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: $OpQueueTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OpQueueTable createAlias(String alias) {
    return $OpQueueTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OpStatus, String, String> $converterstatus =
      const EnumNameConverter<OpStatus>(OpStatus.values);
}

class OpQueueData extends DataClass implements Insertable<OpQueueData> {
  final int id;
  final String uuid;
  final String kind;
  final String payload;
  final OpStatus status;
  final int attempts;
  final String? lastError;
  final DateTime createdAt;
  const OpQueueData({
    required this.id,
    required this.uuid,
    required this.kind,
    required this.payload,
    required this.status,
    required this.attempts,
    this.lastError,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['kind'] = Variable<String>(kind);
    map['payload'] = Variable<String>(payload);
    {
      map['status'] = Variable<String>(
        $OpQueueTable.$converterstatus.toSql(status),
      );
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OpQueueCompanion toCompanion(bool nullToAbsent) {
    return OpQueueCompanion(
      id: Value(id),
      uuid: Value(uuid),
      kind: Value(kind),
      payload: Value(payload),
      status: Value(status),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory OpQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpQueueData(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      kind: serializer.fromJson<String>(json['kind']),
      payload: serializer.fromJson<String>(json['payload']),
      status: $OpQueueTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'kind': serializer.toJson<String>(kind),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(
        $OpQueueTable.$converterstatus.toJson(status),
      ),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OpQueueData copyWith({
    int? id,
    String? uuid,
    String? kind,
    String? payload,
    OpStatus? status,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
  }) => OpQueueData(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    kind: kind ?? this.kind,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
  );
  OpQueueData copyWithCompanion(OpQueueCompanion data) {
    return OpQueueData(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      kind: data.kind.present ? data.kind.value : this.kind,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpQueueData(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    kind,
    payload,
    status,
    attempts,
    lastError,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpQueueData &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.kind == this.kind &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class OpQueueCompanion extends UpdateCompanion<OpQueueData> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> kind;
  final Value<String> payload;
  final Value<OpStatus> status;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  const OpQueueCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.kind = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OpQueueCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String kind,
    required String payload,
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : uuid = Value(uuid),
       kind = Value(kind),
       payload = Value(payload);
  static Insertable<OpQueueData> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? kind,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (kind != null) 'kind': kind,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OpQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? kind,
    Value<String>? payload,
    Value<OpStatus>? status,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
  }) {
    return OpQueueCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $OpQueueTable.$converterstatus.toSql(status.value),
      );
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpQueueCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LeadsTable extends Leads with TableInfo<$LeadsTable, Lead> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerNameMeta = const VerificationMeta(
    'partnerName',
  );
  @override
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>(
    'partner_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  @override
  late final GeneratedColumn<int> stageId = GeneratedColumn<int>(
    'stage_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stageNameMeta = const VerificationMeta(
    'stageName',
  );
  @override
  late final GeneratedColumn<String> stageName = GeneratedColumn<String>(
    'stage_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _expectedRevenueMeta = const VerificationMeta(
    'expectedRevenue',
  );
  @override
  late final GeneratedColumn<double> expectedRevenue = GeneratedColumn<double>(
    'expected_revenue',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    partnerName,
    stageId,
    stageName,
    expectedRevenue,
    phone,
    email,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leads';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lead> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('partner_name')) {
      context.handle(
        _partnerNameMeta,
        partnerName.isAcceptableOrUnknown(
          data['partner_name']!,
          _partnerNameMeta,
        ),
      );
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    }
    if (data.containsKey('stage_name')) {
      context.handle(
        _stageNameMeta,
        stageName.isAcceptableOrUnknown(data['stage_name']!, _stageNameMeta),
      );
    }
    if (data.containsKey('expected_revenue')) {
      context.handle(
        _expectedRevenueMeta,
        expectedRevenue.isAcceptableOrUnknown(
          data['expected_revenue']!,
          _expectedRevenueMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lead map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lead(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      partnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_name'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stage_id'],
      ),
      stageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_name'],
      )!,
      expectedRevenue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_revenue'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
    );
  }

  @override
  $LeadsTable createAlias(String alias) {
    return $LeadsTable(attachedDatabase, alias);
  }
}

class Lead extends DataClass implements Insertable<Lead> {
  final int id;
  final String name;
  final String partnerName;
  final int? stageId;
  final String stageName;
  final double expectedRevenue;
  final String phone;
  final String email;
  const Lead({
    required this.id,
    required this.name,
    required this.partnerName,
    this.stageId,
    required this.stageName,
    required this.expectedRevenue,
    required this.phone,
    required this.email,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['partner_name'] = Variable<String>(partnerName);
    if (!nullToAbsent || stageId != null) {
      map['stage_id'] = Variable<int>(stageId);
    }
    map['stage_name'] = Variable<String>(stageName);
    map['expected_revenue'] = Variable<double>(expectedRevenue);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    return map;
  }

  LeadsCompanion toCompanion(bool nullToAbsent) {
    return LeadsCompanion(
      id: Value(id),
      name: Value(name),
      partnerName: Value(partnerName),
      stageId: stageId == null && nullToAbsent
          ? const Value.absent()
          : Value(stageId),
      stageName: Value(stageName),
      expectedRevenue: Value(expectedRevenue),
      phone: Value(phone),
      email: Value(email),
    );
  }

  factory Lead.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lead(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      partnerName: serializer.fromJson<String>(json['partnerName']),
      stageId: serializer.fromJson<int?>(json['stageId']),
      stageName: serializer.fromJson<String>(json['stageName']),
      expectedRevenue: serializer.fromJson<double>(json['expectedRevenue']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'partnerName': serializer.toJson<String>(partnerName),
      'stageId': serializer.toJson<int?>(stageId),
      'stageName': serializer.toJson<String>(stageName),
      'expectedRevenue': serializer.toJson<double>(expectedRevenue),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
    };
  }

  Lead copyWith({
    int? id,
    String? name,
    String? partnerName,
    Value<int?> stageId = const Value.absent(),
    String? stageName,
    double? expectedRevenue,
    String? phone,
    String? email,
  }) => Lead(
    id: id ?? this.id,
    name: name ?? this.name,
    partnerName: partnerName ?? this.partnerName,
    stageId: stageId.present ? stageId.value : this.stageId,
    stageName: stageName ?? this.stageName,
    expectedRevenue: expectedRevenue ?? this.expectedRevenue,
    phone: phone ?? this.phone,
    email: email ?? this.email,
  );
  Lead copyWithCompanion(LeadsCompanion data) {
    return Lead(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      partnerName: data.partnerName.present
          ? data.partnerName.value
          : this.partnerName,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      stageName: data.stageName.present ? data.stageName.value : this.stageName,
      expectedRevenue: data.expectedRevenue.present
          ? data.expectedRevenue.value
          : this.expectedRevenue,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lead(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('partnerName: $partnerName, ')
          ..write('stageId: $stageId, ')
          ..write('stageName: $stageName, ')
          ..write('expectedRevenue: $expectedRevenue, ')
          ..write('phone: $phone, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    partnerName,
    stageId,
    stageName,
    expectedRevenue,
    phone,
    email,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lead &&
          other.id == this.id &&
          other.name == this.name &&
          other.partnerName == this.partnerName &&
          other.stageId == this.stageId &&
          other.stageName == this.stageName &&
          other.expectedRevenue == this.expectedRevenue &&
          other.phone == this.phone &&
          other.email == this.email);
}

class LeadsCompanion extends UpdateCompanion<Lead> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> partnerName;
  final Value<int?> stageId;
  final Value<String> stageName;
  final Value<double> expectedRevenue;
  final Value<String> phone;
  final Value<String> email;
  const LeadsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.stageId = const Value.absent(),
    this.stageName = const Value.absent(),
    this.expectedRevenue = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
  });
  LeadsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.partnerName = const Value.absent(),
    this.stageId = const Value.absent(),
    this.stageName = const Value.absent(),
    this.expectedRevenue = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Lead> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? partnerName,
    Expression<int>? stageId,
    Expression<String>? stageName,
    Expression<double>? expectedRevenue,
    Expression<String>? phone,
    Expression<String>? email,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (partnerName != null) 'partner_name': partnerName,
      if (stageId != null) 'stage_id': stageId,
      if (stageName != null) 'stage_name': stageName,
      if (expectedRevenue != null) 'expected_revenue': expectedRevenue,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
    });
  }

  LeadsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? partnerName,
    Value<int?>? stageId,
    Value<String>? stageName,
    Value<double>? expectedRevenue,
    Value<String>? phone,
    Value<String>? email,
  }) {
    return LeadsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      partnerName: partnerName ?? this.partnerName,
      stageId: stageId ?? this.stageId,
      stageName: stageName ?? this.stageName,
      expectedRevenue: expectedRevenue ?? this.expectedRevenue,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (partnerName.present) {
      map['partner_name'] = Variable<String>(partnerName.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<int>(stageId.value);
    }
    if (stageName.present) {
      map['stage_name'] = Variable<String>(stageName.value);
    }
    if (expectedRevenue.present) {
      map['expected_revenue'] = Variable<double>(expectedRevenue.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeadsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('partnerName: $partnerName, ')
          ..write('stageId: $stageId, ')
          ..write('stageName: $stageName, ')
          ..write('expectedRevenue: $expectedRevenue, ')
          ..write('phone: $phone, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }
}

class $CrmStagesTable extends CrmStages
    with TableInfo<$CrmStagesTable, CrmStage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CrmStagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sequence];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crm_stages';
  @override
  VerificationContext validateIntegrity(
    Insertable<CrmStage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CrmStage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CrmStage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
    );
  }

  @override
  $CrmStagesTable createAlias(String alias) {
    return $CrmStagesTable(attachedDatabase, alias);
  }
}

class CrmStage extends DataClass implements Insertable<CrmStage> {
  final int id;
  final String name;
  final int sequence;
  const CrmStage({
    required this.id,
    required this.name,
    required this.sequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sequence'] = Variable<int>(sequence);
    return map;
  }

  CrmStagesCompanion toCompanion(bool nullToAbsent) {
    return CrmStagesCompanion(
      id: Value(id),
      name: Value(name),
      sequence: Value(sequence),
    );
  }

  factory CrmStage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CrmStage(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sequence: serializer.fromJson<int>(json['sequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sequence': serializer.toJson<int>(sequence),
    };
  }

  CrmStage copyWith({int? id, String? name, int? sequence}) => CrmStage(
    id: id ?? this.id,
    name: name ?? this.name,
    sequence: sequence ?? this.sequence,
  );
  CrmStage copyWithCompanion(CrmStagesCompanion data) {
    return CrmStage(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CrmStage(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sequence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CrmStage &&
          other.id == this.id &&
          other.name == this.name &&
          other.sequence == this.sequence);
}

class CrmStagesCompanion extends UpdateCompanion<CrmStage> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sequence;
  const CrmStagesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sequence = const Value.absent(),
  });
  CrmStagesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sequence = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CrmStage> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sequence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sequence != null) 'sequence': sequence,
    });
  }

  CrmStagesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sequence,
  }) {
    return CrmStagesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CrmStagesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }
}

class $SaleOrdersTable extends SaleOrders
    with TableInfo<$SaleOrdersTable, SaleOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerNameMeta = const VerificationMeta(
    'partnerName',
  );
  @override
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>(
    'partner_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _amountTotalMeta = const VerificationMeta(
    'amountTotal',
  );
  @override
  late final GeneratedColumn<double> amountTotal = GeneratedColumn<double>(
    'amount_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateOrderMeta = const VerificationMeta(
    'dateOrder',
  );
  @override
  late final GeneratedColumn<DateTime> dateOrder = GeneratedColumn<DateTime>(
    'date_order',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    state,
    partnerName,
    amountTotal,
    dateOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('partner_name')) {
      context.handle(
        _partnerNameMeta,
        partnerName.isAcceptableOrUnknown(
          data['partner_name']!,
          _partnerNameMeta,
        ),
      );
    }
    if (data.containsKey('amount_total')) {
      context.handle(
        _amountTotalMeta,
        amountTotal.isAcceptableOrUnknown(
          data['amount_total']!,
          _amountTotalMeta,
        ),
      );
    }
    if (data.containsKey('date_order')) {
      context.handle(
        _dateOrderMeta,
        dateOrder.isAcceptableOrUnknown(data['date_order']!, _dateOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleOrder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      partnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_name'],
      )!,
      amountTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_total'],
      )!,
      dateOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_order'],
      ),
    );
  }

  @override
  $SaleOrdersTable createAlias(String alias) {
    return $SaleOrdersTable(attachedDatabase, alias);
  }
}

class SaleOrder extends DataClass implements Insertable<SaleOrder> {
  final int id;
  final String name;
  final String state;
  final String partnerName;
  final double amountTotal;
  final DateTime? dateOrder;
  const SaleOrder({
    required this.id,
    required this.name,
    required this.state,
    required this.partnerName,
    required this.amountTotal,
    this.dateOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['state'] = Variable<String>(state);
    map['partner_name'] = Variable<String>(partnerName);
    map['amount_total'] = Variable<double>(amountTotal);
    if (!nullToAbsent || dateOrder != null) {
      map['date_order'] = Variable<DateTime>(dateOrder);
    }
    return map;
  }

  SaleOrdersCompanion toCompanion(bool nullToAbsent) {
    return SaleOrdersCompanion(
      id: Value(id),
      name: Value(name),
      state: Value(state),
      partnerName: Value(partnerName),
      amountTotal: Value(amountTotal),
      dateOrder: dateOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOrder),
    );
  }

  factory SaleOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleOrder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      state: serializer.fromJson<String>(json['state']),
      partnerName: serializer.fromJson<String>(json['partnerName']),
      amountTotal: serializer.fromJson<double>(json['amountTotal']),
      dateOrder: serializer.fromJson<DateTime?>(json['dateOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'state': serializer.toJson<String>(state),
      'partnerName': serializer.toJson<String>(partnerName),
      'amountTotal': serializer.toJson<double>(amountTotal),
      'dateOrder': serializer.toJson<DateTime?>(dateOrder),
    };
  }

  SaleOrder copyWith({
    int? id,
    String? name,
    String? state,
    String? partnerName,
    double? amountTotal,
    Value<DateTime?> dateOrder = const Value.absent(),
  }) => SaleOrder(
    id: id ?? this.id,
    name: name ?? this.name,
    state: state ?? this.state,
    partnerName: partnerName ?? this.partnerName,
    amountTotal: amountTotal ?? this.amountTotal,
    dateOrder: dateOrder.present ? dateOrder.value : this.dateOrder,
  );
  SaleOrder copyWithCompanion(SaleOrdersCompanion data) {
    return SaleOrder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      state: data.state.present ? data.state.value : this.state,
      partnerName: data.partnerName.present
          ? data.partnerName.value
          : this.partnerName,
      amountTotal: data.amountTotal.present
          ? data.amountTotal.value
          : this.amountTotal,
      dateOrder: data.dateOrder.present ? data.dateOrder.value : this.dateOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleOrder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('partnerName: $partnerName, ')
          ..write('amountTotal: $amountTotal, ')
          ..write('dateOrder: $dateOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, state, partnerName, amountTotal, dateOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleOrder &&
          other.id == this.id &&
          other.name == this.name &&
          other.state == this.state &&
          other.partnerName == this.partnerName &&
          other.amountTotal == this.amountTotal &&
          other.dateOrder == this.dateOrder);
}

class SaleOrdersCompanion extends UpdateCompanion<SaleOrder> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> state;
  final Value<String> partnerName;
  final Value<double> amountTotal;
  final Value<DateTime?> dateOrder;
  const SaleOrdersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.state = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.amountTotal = const Value.absent(),
    this.dateOrder = const Value.absent(),
  });
  SaleOrdersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String state,
    this.partnerName = const Value.absent(),
    this.amountTotal = const Value.absent(),
    this.dateOrder = const Value.absent(),
  }) : name = Value(name),
       state = Value(state);
  static Insertable<SaleOrder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? state,
    Expression<String>? partnerName,
    Expression<double>? amountTotal,
    Expression<DateTime>? dateOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (state != null) 'state': state,
      if (partnerName != null) 'partner_name': partnerName,
      if (amountTotal != null) 'amount_total': amountTotal,
      if (dateOrder != null) 'date_order': dateOrder,
    });
  }

  SaleOrdersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? state,
    Value<String>? partnerName,
    Value<double>? amountTotal,
    Value<DateTime?>? dateOrder,
  }) {
    return SaleOrdersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      partnerName: partnerName ?? this.partnerName,
      amountTotal: amountTotal ?? this.amountTotal,
      dateOrder: dateOrder ?? this.dateOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (partnerName.present) {
      map['partner_name'] = Variable<String>(partnerName.value);
    }
    if (amountTotal.present) {
      map['amount_total'] = Variable<double>(amountTotal.value);
    }
    if (dateOrder.present) {
      map['date_order'] = Variable<DateTime>(dateOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleOrdersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('partnerName: $partnerName, ')
          ..write('amountTotal: $amountTotal, ')
          ..write('dateOrder: $dateOrder')
          ..write(')'))
        .toString();
  }
}

class $SaleOrderLinesTable extends SaleOrderLines
    with TableInfo<$SaleOrderLinesTable, SaleOrderLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleOrderLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _priceSubtotalMeta = const VerificationMeta(
    'priceSubtotal',
  );
  @override
  late final GeneratedColumn<double> priceSubtotal = GeneratedColumn<double>(
    'price_subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orderId,
    description,
    quantity,
    priceSubtotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_order_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleOrderLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
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
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('price_subtotal')) {
      context.handle(
        _priceSubtotalMeta,
        priceSubtotal.isAcceptableOrUnknown(
          data['price_subtotal']!,
          _priceSubtotalMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleOrderLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleOrderLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      priceSubtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_subtotal'],
      )!,
    );
  }

  @override
  $SaleOrderLinesTable createAlias(String alias) {
    return $SaleOrderLinesTable(attachedDatabase, alias);
  }
}

class SaleOrderLine extends DataClass implements Insertable<SaleOrderLine> {
  final int id;
  final int orderId;
  final String description;
  final double quantity;
  final double priceSubtotal;
  const SaleOrderLine({
    required this.id,
    required this.orderId,
    required this.description,
    required this.quantity,
    required this.priceSubtotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['description'] = Variable<String>(description);
    map['quantity'] = Variable<double>(quantity);
    map['price_subtotal'] = Variable<double>(priceSubtotal);
    return map;
  }

  SaleOrderLinesCompanion toCompanion(bool nullToAbsent) {
    return SaleOrderLinesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      description: Value(description),
      quantity: Value(quantity),
      priceSubtotal: Value(priceSubtotal),
    );
  }

  factory SaleOrderLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleOrderLine(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      description: serializer.fromJson<String>(json['description']),
      quantity: serializer.fromJson<double>(json['quantity']),
      priceSubtotal: serializer.fromJson<double>(json['priceSubtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'description': serializer.toJson<String>(description),
      'quantity': serializer.toJson<double>(quantity),
      'priceSubtotal': serializer.toJson<double>(priceSubtotal),
    };
  }

  SaleOrderLine copyWith({
    int? id,
    int? orderId,
    String? description,
    double? quantity,
    double? priceSubtotal,
  }) => SaleOrderLine(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    description: description ?? this.description,
    quantity: quantity ?? this.quantity,
    priceSubtotal: priceSubtotal ?? this.priceSubtotal,
  );
  SaleOrderLine copyWithCompanion(SaleOrderLinesCompanion data) {
    return SaleOrderLine(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      description: data.description.present
          ? data.description.value
          : this.description,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      priceSubtotal: data.priceSubtotal.present
          ? data.priceSubtotal.value
          : this.priceSubtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleOrderLine(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('priceSubtotal: $priceSubtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, orderId, description, quantity, priceSubtotal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleOrderLine &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.description == this.description &&
          other.quantity == this.quantity &&
          other.priceSubtotal == this.priceSubtotal);
}

class SaleOrderLinesCompanion extends UpdateCompanion<SaleOrderLine> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<String> description;
  final Value<double> quantity;
  final Value<double> priceSubtotal;
  const SaleOrderLinesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.priceSubtotal = const Value.absent(),
  });
  SaleOrderLinesCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.priceSubtotal = const Value.absent(),
  }) : orderId = Value(orderId);
  static Insertable<SaleOrderLine> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<String>? description,
    Expression<double>? quantity,
    Expression<double>? priceSubtotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (priceSubtotal != null) 'price_subtotal': priceSubtotal,
    });
  }

  SaleOrderLinesCompanion copyWith({
    Value<int>? id,
    Value<int>? orderId,
    Value<String>? description,
    Value<double>? quantity,
    Value<double>? priceSubtotal,
  }) {
    return SaleOrderLinesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      priceSubtotal: priceSubtotal ?? this.priceSubtotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (priceSubtotal.present) {
      map['price_subtotal'] = Variable<double>(priceSubtotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleOrderLinesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('priceSubtotal: $priceSubtotal')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PickingsTable pickings = $PickingsTable(this);
  late final $MoveLinesTable moveLines = $MoveLinesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $OpQueueTable opQueue = $OpQueueTable(this);
  late final $LeadsTable leads = $LeadsTable(this);
  late final $CrmStagesTable crmStages = $CrmStagesTable(this);
  late final $SaleOrdersTable saleOrders = $SaleOrdersTable(this);
  late final $SaleOrderLinesTable saleOrderLines = $SaleOrderLinesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pickings,
    moveLines,
    products,
    opQueue,
    leads,
    crmStages,
    saleOrders,
    saleOrderLines,
  ];
}

typedef $$PickingsTableCreateCompanionBuilder =
    PickingsCompanion Function({
      Value<int> id,
      required String name,
      required String state,
      required String pickingTypeCode,
      Value<String> partnerName,
      Value<DateTime?> scheduledDate,
    });
typedef $$PickingsTableUpdateCompanionBuilder =
    PickingsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> state,
      Value<String> pickingTypeCode,
      Value<String> partnerName,
      Value<DateTime?> scheduledDate,
    });

class $$PickingsTableFilterComposer
    extends Composer<_$AppDatabase, $PickingsTable> {
  $$PickingsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pickingTypeCode => $composableBuilder(
    column: $table.pickingTypeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PickingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PickingsTable> {
  $$PickingsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pickingTypeCode => $composableBuilder(
    column: $table.pickingTypeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PickingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PickingsTable> {
  $$PickingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get pickingTypeCode => $composableBuilder(
    column: $table.pickingTypeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );
}

class $$PickingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PickingsTable,
          Picking,
          $$PickingsTableFilterComposer,
          $$PickingsTableOrderingComposer,
          $$PickingsTableAnnotationComposer,
          $$PickingsTableCreateCompanionBuilder,
          $$PickingsTableUpdateCompanionBuilder,
          (Picking, BaseReferences<_$AppDatabase, $PickingsTable, Picking>),
          Picking,
          PrefetchHooks Function()
        > {
  $$PickingsTableTableManager(_$AppDatabase db, $PickingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PickingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PickingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PickingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> pickingTypeCode = const Value.absent(),
                Value<String> partnerName = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
              }) => PickingsCompanion(
                id: id,
                name: name,
                state: state,
                pickingTypeCode: pickingTypeCode,
                partnerName: partnerName,
                scheduledDate: scheduledDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String state,
                required String pickingTypeCode,
                Value<String> partnerName = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
              }) => PickingsCompanion.insert(
                id: id,
                name: name,
                state: state,
                pickingTypeCode: pickingTypeCode,
                partnerName: partnerName,
                scheduledDate: scheduledDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PickingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PickingsTable,
      Picking,
      $$PickingsTableFilterComposer,
      $$PickingsTableOrderingComposer,
      $$PickingsTableAnnotationComposer,
      $$PickingsTableCreateCompanionBuilder,
      $$PickingsTableUpdateCompanionBuilder,
      (Picking, BaseReferences<_$AppDatabase, $PickingsTable, Picking>),
      Picking,
      PrefetchHooks Function()
    >;
typedef $$MoveLinesTableCreateCompanionBuilder =
    MoveLinesCompanion Function({
      Value<int> id,
      required int pickingId,
      required int productId,
      Value<String> productName,
      Value<double> quantity,
      Value<bool> picked,
    });
typedef $$MoveLinesTableUpdateCompanionBuilder =
    MoveLinesCompanion Function({
      Value<int> id,
      Value<int> pickingId,
      Value<int> productId,
      Value<String> productName,
      Value<double> quantity,
      Value<bool> picked,
    });

class $$MoveLinesTableFilterComposer
    extends Composer<_$AppDatabase, $MoveLinesTable> {
  $$MoveLinesTableFilterComposer({
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

  ColumnFilters<int> get pickingId => $composableBuilder(
    column: $table.pickingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get picked => $composableBuilder(
    column: $table.picked,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoveLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MoveLinesTable> {
  $$MoveLinesTableOrderingComposer({
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

  ColumnOrderings<int> get pickingId => $composableBuilder(
    column: $table.pickingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get picked => $composableBuilder(
    column: $table.picked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoveLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoveLinesTable> {
  $$MoveLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pickingId =>
      $composableBuilder(column: $table.pickingId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<bool> get picked =>
      $composableBuilder(column: $table.picked, builder: (column) => column);
}

class $$MoveLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoveLinesTable,
          MoveLine,
          $$MoveLinesTableFilterComposer,
          $$MoveLinesTableOrderingComposer,
          $$MoveLinesTableAnnotationComposer,
          $$MoveLinesTableCreateCompanionBuilder,
          $$MoveLinesTableUpdateCompanionBuilder,
          (MoveLine, BaseReferences<_$AppDatabase, $MoveLinesTable, MoveLine>),
          MoveLine,
          PrefetchHooks Function()
        > {
  $$MoveLinesTableTableManager(_$AppDatabase db, $MoveLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoveLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoveLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoveLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pickingId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<bool> picked = const Value.absent(),
              }) => MoveLinesCompanion(
                id: id,
                pickingId: pickingId,
                productId: productId,
                productName: productName,
                quantity: quantity,
                picked: picked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pickingId,
                required int productId,
                Value<String> productName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<bool> picked = const Value.absent(),
              }) => MoveLinesCompanion.insert(
                id: id,
                pickingId: pickingId,
                productId: productId,
                productName: productName,
                quantity: quantity,
                picked: picked,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoveLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoveLinesTable,
      MoveLine,
      $$MoveLinesTableFilterComposer,
      $$MoveLinesTableOrderingComposer,
      $$MoveLinesTableAnnotationComposer,
      $$MoveLinesTableCreateCompanionBuilder,
      $$MoveLinesTableUpdateCompanionBuilder,
      (MoveLine, BaseReferences<_$AppDatabase, $MoveLinesTable, MoveLine>),
      MoveLine,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> barcode,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> barcode,
    });

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
          Product,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
              }) => ProductsCompanion(id: id, name: name, barcode: barcode),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> barcode = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                barcode: barcode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
      Product,
      PrefetchHooks Function()
    >;
typedef $$OpQueueTableCreateCompanionBuilder =
    OpQueueCompanion Function({
      Value<int> id,
      required String uuid,
      required String kind,
      required String payload,
      Value<OpStatus> status,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime> createdAt,
    });
typedef $$OpQueueTableUpdateCompanionBuilder =
    OpQueueCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> kind,
      Value<String> payload,
      Value<OpStatus> status,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime> createdAt,
    });

class $$OpQueueTableFilterComposer
    extends Composer<_$AppDatabase, $OpQueueTable> {
  $$OpQueueTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OpStatus, OpStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OpQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $OpQueueTable> {
  $$OpQueueTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OpQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpQueueTable> {
  $$OpQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OpStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OpQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OpQueueTable,
          OpQueueData,
          $$OpQueueTableFilterComposer,
          $$OpQueueTableOrderingComposer,
          $$OpQueueTableAnnotationComposer,
          $$OpQueueTableCreateCompanionBuilder,
          $$OpQueueTableUpdateCompanionBuilder,
          (
            OpQueueData,
            BaseReferences<_$AppDatabase, $OpQueueTable, OpQueueData>,
          ),
          OpQueueData,
          PrefetchHooks Function()
        > {
  $$OpQueueTableTableManager(_$AppDatabase db, $OpQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<OpStatus> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OpQueueCompanion(
                id: id,
                uuid: uuid,
                kind: kind,
                payload: payload,
                status: status,
                attempts: attempts,
                lastError: lastError,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String kind,
                required String payload,
                Value<OpStatus> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OpQueueCompanion.insert(
                id: id,
                uuid: uuid,
                kind: kind,
                payload: payload,
                status: status,
                attempts: attempts,
                lastError: lastError,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OpQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OpQueueTable,
      OpQueueData,
      $$OpQueueTableFilterComposer,
      $$OpQueueTableOrderingComposer,
      $$OpQueueTableAnnotationComposer,
      $$OpQueueTableCreateCompanionBuilder,
      $$OpQueueTableUpdateCompanionBuilder,
      (OpQueueData, BaseReferences<_$AppDatabase, $OpQueueTable, OpQueueData>),
      OpQueueData,
      PrefetchHooks Function()
    >;
typedef $$LeadsTableCreateCompanionBuilder =
    LeadsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> partnerName,
      Value<int?> stageId,
      Value<String> stageName,
      Value<double> expectedRevenue,
      Value<String> phone,
      Value<String> email,
    });
typedef $$LeadsTableUpdateCompanionBuilder =
    LeadsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> partnerName,
      Value<int?> stageId,
      Value<String> stageName,
      Value<double> expectedRevenue,
      Value<String> phone,
      Value<String> email,
    });

class $$LeadsTableFilterComposer extends Composer<_$AppDatabase, $LeadsTable> {
  $$LeadsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageName => $composableBuilder(
    column: $table.stageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expectedRevenue => $composableBuilder(
    column: $table.expectedRevenue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeadsTableOrderingComposer
    extends Composer<_$AppDatabase, $LeadsTable> {
  $$LeadsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageName => $composableBuilder(
    column: $table.stageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expectedRevenue => $composableBuilder(
    column: $table.expectedRevenue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeadsTable> {
  $$LeadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stageId =>
      $composableBuilder(column: $table.stageId, builder: (column) => column);

  GeneratedColumn<String> get stageName =>
      $composableBuilder(column: $table.stageName, builder: (column) => column);

  GeneratedColumn<double> get expectedRevenue => $composableBuilder(
    column: $table.expectedRevenue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);
}

class $$LeadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeadsTable,
          Lead,
          $$LeadsTableFilterComposer,
          $$LeadsTableOrderingComposer,
          $$LeadsTableAnnotationComposer,
          $$LeadsTableCreateCompanionBuilder,
          $$LeadsTableUpdateCompanionBuilder,
          (Lead, BaseReferences<_$AppDatabase, $LeadsTable, Lead>),
          Lead,
          PrefetchHooks Function()
        > {
  $$LeadsTableTableManager(_$AppDatabase db, $LeadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> partnerName = const Value.absent(),
                Value<int?> stageId = const Value.absent(),
                Value<String> stageName = const Value.absent(),
                Value<double> expectedRevenue = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
              }) => LeadsCompanion(
                id: id,
                name: name,
                partnerName: partnerName,
                stageId: stageId,
                stageName: stageName,
                expectedRevenue: expectedRevenue,
                phone: phone,
                email: email,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> partnerName = const Value.absent(),
                Value<int?> stageId = const Value.absent(),
                Value<String> stageName = const Value.absent(),
                Value<double> expectedRevenue = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
              }) => LeadsCompanion.insert(
                id: id,
                name: name,
                partnerName: partnerName,
                stageId: stageId,
                stageName: stageName,
                expectedRevenue: expectedRevenue,
                phone: phone,
                email: email,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeadsTable,
      Lead,
      $$LeadsTableFilterComposer,
      $$LeadsTableOrderingComposer,
      $$LeadsTableAnnotationComposer,
      $$LeadsTableCreateCompanionBuilder,
      $$LeadsTableUpdateCompanionBuilder,
      (Lead, BaseReferences<_$AppDatabase, $LeadsTable, Lead>),
      Lead,
      PrefetchHooks Function()
    >;
typedef $$CrmStagesTableCreateCompanionBuilder =
    CrmStagesCompanion Function({
      Value<int> id,
      required String name,
      Value<int> sequence,
    });
typedef $$CrmStagesTableUpdateCompanionBuilder =
    CrmStagesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> sequence,
    });

class $$CrmStagesTableFilterComposer
    extends Composer<_$AppDatabase, $CrmStagesTable> {
  $$CrmStagesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CrmStagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CrmStagesTable> {
  $$CrmStagesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CrmStagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CrmStagesTable> {
  $$CrmStagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);
}

class $$CrmStagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CrmStagesTable,
          CrmStage,
          $$CrmStagesTableFilterComposer,
          $$CrmStagesTableOrderingComposer,
          $$CrmStagesTableAnnotationComposer,
          $$CrmStagesTableCreateCompanionBuilder,
          $$CrmStagesTableUpdateCompanionBuilder,
          (CrmStage, BaseReferences<_$AppDatabase, $CrmStagesTable, CrmStage>),
          CrmStage,
          PrefetchHooks Function()
        > {
  $$CrmStagesTableTableManager(_$AppDatabase db, $CrmStagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CrmStagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CrmStagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CrmStagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sequence = const Value.absent(),
              }) => CrmStagesCompanion(id: id, name: name, sequence: sequence),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> sequence = const Value.absent(),
              }) => CrmStagesCompanion.insert(
                id: id,
                name: name,
                sequence: sequence,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CrmStagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CrmStagesTable,
      CrmStage,
      $$CrmStagesTableFilterComposer,
      $$CrmStagesTableOrderingComposer,
      $$CrmStagesTableAnnotationComposer,
      $$CrmStagesTableCreateCompanionBuilder,
      $$CrmStagesTableUpdateCompanionBuilder,
      (CrmStage, BaseReferences<_$AppDatabase, $CrmStagesTable, CrmStage>),
      CrmStage,
      PrefetchHooks Function()
    >;
typedef $$SaleOrdersTableCreateCompanionBuilder =
    SaleOrdersCompanion Function({
      Value<int> id,
      required String name,
      required String state,
      Value<String> partnerName,
      Value<double> amountTotal,
      Value<DateTime?> dateOrder,
    });
typedef $$SaleOrdersTableUpdateCompanionBuilder =
    SaleOrdersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> state,
      Value<String> partnerName,
      Value<double> amountTotal,
      Value<DateTime?> dateOrder,
    });

class $$SaleOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $SaleOrdersTable> {
  $$SaleOrdersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountTotal => $composableBuilder(
    column: $table.amountTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOrder => $composableBuilder(
    column: $table.dateOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaleOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleOrdersTable> {
  $$SaleOrdersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountTotal => $composableBuilder(
    column: $table.amountTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOrder => $composableBuilder(
    column: $table.dateOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaleOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleOrdersTable> {
  $$SaleOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountTotal => $composableBuilder(
    column: $table.amountTotal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateOrder =>
      $composableBuilder(column: $table.dateOrder, builder: (column) => column);
}

class $$SaleOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleOrdersTable,
          SaleOrder,
          $$SaleOrdersTableFilterComposer,
          $$SaleOrdersTableOrderingComposer,
          $$SaleOrdersTableAnnotationComposer,
          $$SaleOrdersTableCreateCompanionBuilder,
          $$SaleOrdersTableUpdateCompanionBuilder,
          (
            SaleOrder,
            BaseReferences<_$AppDatabase, $SaleOrdersTable, SaleOrder>,
          ),
          SaleOrder,
          PrefetchHooks Function()
        > {
  $$SaleOrdersTableTableManager(_$AppDatabase db, $SaleOrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> partnerName = const Value.absent(),
                Value<double> amountTotal = const Value.absent(),
                Value<DateTime?> dateOrder = const Value.absent(),
              }) => SaleOrdersCompanion(
                id: id,
                name: name,
                state: state,
                partnerName: partnerName,
                amountTotal: amountTotal,
                dateOrder: dateOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String state,
                Value<String> partnerName = const Value.absent(),
                Value<double> amountTotal = const Value.absent(),
                Value<DateTime?> dateOrder = const Value.absent(),
              }) => SaleOrdersCompanion.insert(
                id: id,
                name: name,
                state: state,
                partnerName: partnerName,
                amountTotal: amountTotal,
                dateOrder: dateOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaleOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleOrdersTable,
      SaleOrder,
      $$SaleOrdersTableFilterComposer,
      $$SaleOrdersTableOrderingComposer,
      $$SaleOrdersTableAnnotationComposer,
      $$SaleOrdersTableCreateCompanionBuilder,
      $$SaleOrdersTableUpdateCompanionBuilder,
      (SaleOrder, BaseReferences<_$AppDatabase, $SaleOrdersTable, SaleOrder>),
      SaleOrder,
      PrefetchHooks Function()
    >;
typedef $$SaleOrderLinesTableCreateCompanionBuilder =
    SaleOrderLinesCompanion Function({
      Value<int> id,
      required int orderId,
      Value<String> description,
      Value<double> quantity,
      Value<double> priceSubtotal,
    });
typedef $$SaleOrderLinesTableUpdateCompanionBuilder =
    SaleOrderLinesCompanion Function({
      Value<int> id,
      Value<int> orderId,
      Value<String> description,
      Value<double> quantity,
      Value<double> priceSubtotal,
    });

class $$SaleOrderLinesTableFilterComposer
    extends Composer<_$AppDatabase, $SaleOrderLinesTable> {
  $$SaleOrderLinesTableFilterComposer({
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

  ColumnFilters<int> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priceSubtotal => $composableBuilder(
    column: $table.priceSubtotal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaleOrderLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleOrderLinesTable> {
  $$SaleOrderLinesTableOrderingComposer({
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

  ColumnOrderings<int> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priceSubtotal => $composableBuilder(
    column: $table.priceSubtotal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaleOrderLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleOrderLinesTable> {
  $$SaleOrderLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get priceSubtotal => $composableBuilder(
    column: $table.priceSubtotal,
    builder: (column) => column,
  );
}

class $$SaleOrderLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleOrderLinesTable,
          SaleOrderLine,
          $$SaleOrderLinesTableFilterComposer,
          $$SaleOrderLinesTableOrderingComposer,
          $$SaleOrderLinesTableAnnotationComposer,
          $$SaleOrderLinesTableCreateCompanionBuilder,
          $$SaleOrderLinesTableUpdateCompanionBuilder,
          (
            SaleOrderLine,
            BaseReferences<_$AppDatabase, $SaleOrderLinesTable, SaleOrderLine>,
          ),
          SaleOrderLine,
          PrefetchHooks Function()
        > {
  $$SaleOrderLinesTableTableManager(
    _$AppDatabase db,
    $SaleOrderLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleOrderLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleOrderLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleOrderLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> orderId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> priceSubtotal = const Value.absent(),
              }) => SaleOrderLinesCompanion(
                id: id,
                orderId: orderId,
                description: description,
                quantity: quantity,
                priceSubtotal: priceSubtotal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int orderId,
                Value<String> description = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> priceSubtotal = const Value.absent(),
              }) => SaleOrderLinesCompanion.insert(
                id: id,
                orderId: orderId,
                description: description,
                quantity: quantity,
                priceSubtotal: priceSubtotal,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaleOrderLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleOrderLinesTable,
      SaleOrderLine,
      $$SaleOrderLinesTableFilterComposer,
      $$SaleOrderLinesTableOrderingComposer,
      $$SaleOrderLinesTableAnnotationComposer,
      $$SaleOrderLinesTableCreateCompanionBuilder,
      $$SaleOrderLinesTableUpdateCompanionBuilder,
      (
        SaleOrderLine,
        BaseReferences<_$AppDatabase, $SaleOrderLinesTable, SaleOrderLine>,
      ),
      SaleOrderLine,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PickingsTableTableManager get pickings =>
      $$PickingsTableTableManager(_db, _db.pickings);
  $$MoveLinesTableTableManager get moveLines =>
      $$MoveLinesTableTableManager(_db, _db.moveLines);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$OpQueueTableTableManager get opQueue =>
      $$OpQueueTableTableManager(_db, _db.opQueue);
  $$LeadsTableTableManager get leads =>
      $$LeadsTableTableManager(_db, _db.leads);
  $$CrmStagesTableTableManager get crmStages =>
      $$CrmStagesTableTableManager(_db, _db.crmStages);
  $$SaleOrdersTableTableManager get saleOrders =>
      $$SaleOrdersTableTableManager(_db, _db.saleOrders);
  $$SaleOrderLinesTableTableManager get saleOrderLines =>
      $$SaleOrderLinesTableTableManager(_db, _db.saleOrderLines);
}
