// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $IdentityTable extends Identity
    with TableInfo<$IdentityTable, IdentityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false);
  static const VerificationMeta _peerIdMeta = const VerificationMeta('peerId');
  @override
  late final GeneratedColumn<String> peerId = GeneratedColumn<String>(
      'peer_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _pubKeyMeta = const VerificationMeta('pubKey');
  @override
  late final GeneratedColumn<String> pubKey = GeneratedColumn<String>(
      'pub_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _signPubKeyMeta =
      const VerificationMeta('signPubKey');
  @override
  late final GeneratedColumn<String> signPubKey = GeneratedColumn<String>(
      'sign_pub_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Anonymous'));
  static const VerificationMeta _avatarUriMeta =
      const VerificationMeta('avatarUri');
  @override
  late final GeneratedColumn<String> avatarUri = GeneratedColumn<String>(
      'avatar_uri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, peerId, pubKey, signPubKey, displayName, avatarUri, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identity';
  @override
  VerificationContext validateIntegrity(Insertable<IdentityData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('peer_id')) {
      context.handle(_peerIdMeta,
          peerId.isAcceptableOrUnknown(data['peer_id']!, _peerIdMeta));
    } else if (isInserting) {
      context.missing(_peerIdMeta);
    }
    if (data.containsKey('pub_key')) {
      context.handle(_pubKeyMeta,
          pubKey.isAcceptableOrUnknown(data['pub_key']!, _pubKeyMeta));
    } else if (isInserting) {
      context.missing(_pubKeyMeta);
    }
    if (data.containsKey('sign_pub_key')) {
      context.handle(
          _signPubKeyMeta,
          signPubKey.isAcceptableOrUnknown(
              data['sign_pub_key']!, _signPubKeyMeta));
    } else if (isInserting) {
      context.missing(_signPubKeyMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('avatar_uri')) {
      context.handle(_avatarUriMeta,
          avatarUri.isAcceptableOrUnknown(data['avatar_uri']!, _avatarUriMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IdentityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdentityData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      peerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}peer_id'])!,
      pubKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pub_key'])!,
      signPubKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sign_pub_key'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      avatarUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_uri']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $IdentityTable createAlias(String alias) {
    return $IdentityTable(attachedDatabase, alias);
  }
}

class IdentityData extends DataClass implements Insertable<IdentityData> {
  final int id;
  final String peerId;
  final String pubKey;
  final String signPubKey;
  final String displayName;
  final String? avatarUri;
  final int createdAt;
  const IdentityData(
      {required this.id,
      required this.peerId,
      required this.pubKey,
      required this.signPubKey,
      required this.displayName,
      this.avatarUri,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['peer_id'] = Variable<String>(peerId);
    map['pub_key'] = Variable<String>(pubKey);
    map['sign_pub_key'] = Variable<String>(signPubKey);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarUri != null) {
      map['avatar_uri'] = Variable<String>(avatarUri);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  IdentityCompanion toCompanion(bool nullToAbsent) {
    return IdentityCompanion(
      id: Value(id),
      peerId: Value(peerId),
      pubKey: Value(pubKey),
      signPubKey: Value(signPubKey),
      displayName: Value(displayName),
      avatarUri: avatarUri == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUri),
      createdAt: Value(createdAt),
    );
  }

  factory IdentityData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdentityData(
      id: serializer.fromJson<int>(json['id']),
      peerId: serializer.fromJson<String>(json['peerId']),
      pubKey: serializer.fromJson<String>(json['pubKey']),
      signPubKey: serializer.fromJson<String>(json['signPubKey']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarUri: serializer.fromJson<String?>(json['avatarUri']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'peerId': serializer.toJson<String>(peerId),
      'pubKey': serializer.toJson<String>(pubKey),
      'signPubKey': serializer.toJson<String>(signPubKey),
      'displayName': serializer.toJson<String>(displayName),
      'avatarUri': serializer.toJson<String?>(avatarUri),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  IdentityData copyWith(
          {int? id,
          String? peerId,
          String? pubKey,
          String? signPubKey,
          String? displayName,
          Value<String?> avatarUri = const Value.absent(),
          int? createdAt}) =>
      IdentityData(
        id: id ?? this.id,
        peerId: peerId ?? this.peerId,
        pubKey: pubKey ?? this.pubKey,
        signPubKey: signPubKey ?? this.signPubKey,
        displayName: displayName ?? this.displayName,
        avatarUri: avatarUri.present ? avatarUri.value : this.avatarUri,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('IdentityData(')
          ..write('id: $id, ')
          ..write('peerId: $peerId, ')
          ..write('pubKey: $pubKey, ')
          ..write('signPubKey: $signPubKey, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUri: $avatarUri, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, peerId, pubKey, signPubKey, displayName, avatarUri, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdentityData &&
          other.id == this.id &&
          other.peerId == this.peerId &&
          other.pubKey == this.pubKey &&
          other.signPubKey == this.signPubKey &&
          other.displayName == this.displayName &&
          other.avatarUri == this.avatarUri &&
          other.createdAt == this.createdAt);
}

class IdentityCompanion extends UpdateCompanion<IdentityData> {
  final Value<int> id;
  final Value<String> peerId;
  final Value<String> pubKey;
  final Value<String> signPubKey;
  final Value<String> displayName;
  final Value<String?> avatarUri;
  final Value<int> createdAt;
  const IdentityCompanion({
    this.id = const Value.absent(),
    this.peerId = const Value.absent(),
    this.pubKey = const Value.absent(),
    this.signPubKey = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUri = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  IdentityCompanion.insert({
    this.id = const Value.absent(),
    required String peerId,
    required String pubKey,
    required String signPubKey,
    this.displayName = const Value.absent(),
    this.avatarUri = const Value.absent(),
    required int createdAt,
  })  : peerId = Value(peerId),
        pubKey = Value(pubKey),
        signPubKey = Value(signPubKey),
        createdAt = Value(createdAt);
  static Insertable<IdentityData> custom({
    Expression<int>? id,
    Expression<String>? peerId,
    Expression<String>? pubKey,
    Expression<String>? signPubKey,
    Expression<String>? displayName,
    Expression<String>? avatarUri,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (peerId != null) 'peer_id': peerId,
      if (pubKey != null) 'pub_key': pubKey,
      if (signPubKey != null) 'sign_pub_key': signPubKey,
      if (displayName != null) 'display_name': displayName,
      if (avatarUri != null) 'avatar_uri': avatarUri,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  IdentityCompanion copyWith(
      {Value<int>? id,
      Value<String>? peerId,
      Value<String>? pubKey,
      Value<String>? signPubKey,
      Value<String>? displayName,
      Value<String?>? avatarUri,
      Value<int>? createdAt}) {
    return IdentityCompanion(
      id: id ?? this.id,
      peerId: peerId ?? this.peerId,
      pubKey: pubKey ?? this.pubKey,
      signPubKey: signPubKey ?? this.signPubKey,
      displayName: displayName ?? this.displayName,
      avatarUri: avatarUri ?? this.avatarUri,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (peerId.present) {
      map['peer_id'] = Variable<String>(peerId.value);
    }
    if (pubKey.present) {
      map['pub_key'] = Variable<String>(pubKey.value);
    }
    if (signPubKey.present) {
      map['sign_pub_key'] = Variable<String>(signPubKey.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUri.present) {
      map['avatar_uri'] = Variable<String>(avatarUri.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentityCompanion(')
          ..write('id: $id, ')
          ..write('peerId: $peerId, ')
          ..write('pubKey: $pubKey, ')
          ..write('signPubKey: $signPubKey, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUri: $avatarUri, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _peerIdMeta = const VerificationMeta('peerId');
  @override
  late final GeneratedColumn<String> peerId = GeneratedColumn<String>(
      'peer_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pubKeyMeta = const VerificationMeta('pubKey');
  @override
  late final GeneratedColumn<String> pubKey = GeneratedColumn<String>(
      'pub_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _signPubKeyMeta =
      const VerificationMeta('signPubKey');
  @override
  late final GeneratedColumn<String> signPubKey = GeneratedColumn<String>(
      'sign_pub_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _multiaddrsMeta =
      const VerificationMeta('multiaddrs');
  @override
  late final GeneratedColumn<String> multiaddrs = GeneratedColumn<String>(
      'multiaddrs', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarUriMeta =
      const VerificationMeta('avatarUri');
  @override
  late final GeneratedColumn<String> avatarUri = GeneratedColumn<String>(
      'avatar_uri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('offline'));
  static const VerificationMeta _lastSeenMeta =
      const VerificationMeta('lastSeen');
  @override
  late final GeneratedColumn<int> lastSeen = GeneratedColumn<int>(
      'last_seen', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _verifiedMeta =
      const VerificationMeta('verified');
  @override
  late final GeneratedColumn<int> verified = GeneratedColumn<int>(
      'verified', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _blockedMeta =
      const VerificationMeta('blocked');
  @override
  late final GeneratedColumn<int> blocked = GeneratedColumn<int>(
      'blocked', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        peerId,
        displayName,
        pubKey,
        signPubKey,
        multiaddrs,
        avatarUri,
        status,
        lastSeen,
        verified,
        blocked,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<Contact> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('peer_id')) {
      context.handle(_peerIdMeta,
          peerId.isAcceptableOrUnknown(data['peer_id']!, _peerIdMeta));
    } else if (isInserting) {
      context.missing(_peerIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('pub_key')) {
      context.handle(_pubKeyMeta,
          pubKey.isAcceptableOrUnknown(data['pub_key']!, _pubKeyMeta));
    } else if (isInserting) {
      context.missing(_pubKeyMeta);
    }
    if (data.containsKey('sign_pub_key')) {
      context.handle(
          _signPubKeyMeta,
          signPubKey.isAcceptableOrUnknown(
              data['sign_pub_key']!, _signPubKeyMeta));
    } else if (isInserting) {
      context.missing(_signPubKeyMeta);
    }
    if (data.containsKey('multiaddrs')) {
      context.handle(
          _multiaddrsMeta,
          multiaddrs.isAcceptableOrUnknown(
              data['multiaddrs']!, _multiaddrsMeta));
    } else if (isInserting) {
      context.missing(_multiaddrsMeta);
    }
    if (data.containsKey('avatar_uri')) {
      context.handle(_avatarUriMeta,
          avatarUri.isAcceptableOrUnknown(data['avatar_uri']!, _avatarUriMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('last_seen')) {
      context.handle(_lastSeenMeta,
          lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta));
    }
    if (data.containsKey('verified')) {
      context.handle(_verifiedMeta,
          verified.isAcceptableOrUnknown(data['verified']!, _verifiedMeta));
    }
    if (data.containsKey('blocked')) {
      context.handle(_blockedMeta,
          blocked.isAcceptableOrUnknown(data['blocked']!, _blockedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      peerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}peer_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      pubKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pub_key'])!,
      signPubKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sign_pub_key'])!,
      multiaddrs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}multiaddrs'])!,
      avatarUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_uri']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      lastSeen: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_seen']),
      verified: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}verified'])!,
      blocked: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}blocked'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final int id;
  final String peerId;
  final String displayName;
  final String pubKey;
  final String signPubKey;
  final String multiaddrs;
  final String? avatarUri;
  final String status;
  final int? lastSeen;
  final int verified;
  final int blocked;
  final int createdAt;
  final int updatedAt;
  const Contact(
      {required this.id,
      required this.peerId,
      required this.displayName,
      required this.pubKey,
      required this.signPubKey,
      required this.multiaddrs,
      this.avatarUri,
      required this.status,
      this.lastSeen,
      required this.verified,
      required this.blocked,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['peer_id'] = Variable<String>(peerId);
    map['display_name'] = Variable<String>(displayName);
    map['pub_key'] = Variable<String>(pubKey);
    map['sign_pub_key'] = Variable<String>(signPubKey);
    map['multiaddrs'] = Variable<String>(multiaddrs);
    if (!nullToAbsent || avatarUri != null) {
      map['avatar_uri'] = Variable<String>(avatarUri);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<int>(lastSeen);
    }
    map['verified'] = Variable<int>(verified);
    map['blocked'] = Variable<int>(blocked);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      peerId: Value(peerId),
      displayName: Value(displayName),
      pubKey: Value(pubKey),
      signPubKey: Value(signPubKey),
      multiaddrs: Value(multiaddrs),
      avatarUri: avatarUri == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUri),
      status: Value(status),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
      verified: Value(verified),
      blocked: Value(blocked),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<int>(json['id']),
      peerId: serializer.fromJson<String>(json['peerId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      pubKey: serializer.fromJson<String>(json['pubKey']),
      signPubKey: serializer.fromJson<String>(json['signPubKey']),
      multiaddrs: serializer.fromJson<String>(json['multiaddrs']),
      avatarUri: serializer.fromJson<String?>(json['avatarUri']),
      status: serializer.fromJson<String>(json['status']),
      lastSeen: serializer.fromJson<int?>(json['lastSeen']),
      verified: serializer.fromJson<int>(json['verified']),
      blocked: serializer.fromJson<int>(json['blocked']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'peerId': serializer.toJson<String>(peerId),
      'displayName': serializer.toJson<String>(displayName),
      'pubKey': serializer.toJson<String>(pubKey),
      'signPubKey': serializer.toJson<String>(signPubKey),
      'multiaddrs': serializer.toJson<String>(multiaddrs),
      'avatarUri': serializer.toJson<String?>(avatarUri),
      'status': serializer.toJson<String>(status),
      'lastSeen': serializer.toJson<int?>(lastSeen),
      'verified': serializer.toJson<int>(verified),
      'blocked': serializer.toJson<int>(blocked),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Contact copyWith(
          {int? id,
          String? peerId,
          String? displayName,
          String? pubKey,
          String? signPubKey,
          String? multiaddrs,
          Value<String?> avatarUri = const Value.absent(),
          String? status,
          Value<int?> lastSeen = const Value.absent(),
          int? verified,
          int? blocked,
          int? createdAt,
          int? updatedAt}) =>
      Contact(
        id: id ?? this.id,
        peerId: peerId ?? this.peerId,
        displayName: displayName ?? this.displayName,
        pubKey: pubKey ?? this.pubKey,
        signPubKey: signPubKey ?? this.signPubKey,
        multiaddrs: multiaddrs ?? this.multiaddrs,
        avatarUri: avatarUri.present ? avatarUri.value : this.avatarUri,
        status: status ?? this.status,
        lastSeen: lastSeen.present ? lastSeen.value : this.lastSeen,
        verified: verified ?? this.verified,
        blocked: blocked ?? this.blocked,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('peerId: $peerId, ')
          ..write('displayName: $displayName, ')
          ..write('pubKey: $pubKey, ')
          ..write('signPubKey: $signPubKey, ')
          ..write('multiaddrs: $multiaddrs, ')
          ..write('avatarUri: $avatarUri, ')
          ..write('status: $status, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('verified: $verified, ')
          ..write('blocked: $blocked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      peerId,
      displayName,
      pubKey,
      signPubKey,
      multiaddrs,
      avatarUri,
      status,
      lastSeen,
      verified,
      blocked,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.peerId == this.peerId &&
          other.displayName == this.displayName &&
          other.pubKey == this.pubKey &&
          other.signPubKey == this.signPubKey &&
          other.multiaddrs == this.multiaddrs &&
          other.avatarUri == this.avatarUri &&
          other.status == this.status &&
          other.lastSeen == this.lastSeen &&
          other.verified == this.verified &&
          other.blocked == this.blocked &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<int> id;
  final Value<String> peerId;
  final Value<String> displayName;
  final Value<String> pubKey;
  final Value<String> signPubKey;
  final Value<String> multiaddrs;
  final Value<String?> avatarUri;
  final Value<String> status;
  final Value<int?> lastSeen;
  final Value<int> verified;
  final Value<int> blocked;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.peerId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.pubKey = const Value.absent(),
    this.signPubKey = const Value.absent(),
    this.multiaddrs = const Value.absent(),
    this.avatarUri = const Value.absent(),
    this.status = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.verified = const Value.absent(),
    this.blocked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.id = const Value.absent(),
    required String peerId,
    required String displayName,
    required String pubKey,
    required String signPubKey,
    required String multiaddrs,
    this.avatarUri = const Value.absent(),
    this.status = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.verified = const Value.absent(),
    this.blocked = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  })  : peerId = Value(peerId),
        displayName = Value(displayName),
        pubKey = Value(pubKey),
        signPubKey = Value(signPubKey),
        multiaddrs = Value(multiaddrs),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Contact> custom({
    Expression<int>? id,
    Expression<String>? peerId,
    Expression<String>? displayName,
    Expression<String>? pubKey,
    Expression<String>? signPubKey,
    Expression<String>? multiaddrs,
    Expression<String>? avatarUri,
    Expression<String>? status,
    Expression<int>? lastSeen,
    Expression<int>? verified,
    Expression<int>? blocked,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (peerId != null) 'peer_id': peerId,
      if (displayName != null) 'display_name': displayName,
      if (pubKey != null) 'pub_key': pubKey,
      if (signPubKey != null) 'sign_pub_key': signPubKey,
      if (multiaddrs != null) 'multiaddrs': multiaddrs,
      if (avatarUri != null) 'avatar_uri': avatarUri,
      if (status != null) 'status': status,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (verified != null) 'verified': verified,
      if (blocked != null) 'blocked': blocked,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ContactsCompanion copyWith(
      {Value<int>? id,
      Value<String>? peerId,
      Value<String>? displayName,
      Value<String>? pubKey,
      Value<String>? signPubKey,
      Value<String>? multiaddrs,
      Value<String?>? avatarUri,
      Value<String>? status,
      Value<int?>? lastSeen,
      Value<int>? verified,
      Value<int>? blocked,
      Value<int>? createdAt,
      Value<int>? updatedAt}) {
    return ContactsCompanion(
      id: id ?? this.id,
      peerId: peerId ?? this.peerId,
      displayName: displayName ?? this.displayName,
      pubKey: pubKey ?? this.pubKey,
      signPubKey: signPubKey ?? this.signPubKey,
      multiaddrs: multiaddrs ?? this.multiaddrs,
      avatarUri: avatarUri ?? this.avatarUri,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      verified: verified ?? this.verified,
      blocked: blocked ?? this.blocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (peerId.present) {
      map['peer_id'] = Variable<String>(peerId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (pubKey.present) {
      map['pub_key'] = Variable<String>(pubKey.value);
    }
    if (signPubKey.present) {
      map['sign_pub_key'] = Variable<String>(signPubKey.value);
    }
    if (multiaddrs.present) {
      map['multiaddrs'] = Variable<String>(multiaddrs.value);
    }
    if (avatarUri.present) {
      map['avatar_uri'] = Variable<String>(avatarUri.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<int>(lastSeen.value);
    }
    if (verified.present) {
      map['verified'] = Variable<int>(verified.value);
    }
    if (blocked.present) {
      map['blocked'] = Variable<int>(blocked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('peerId: $peerId, ')
          ..write('displayName: $displayName, ')
          ..write('pubKey: $pubKey, ')
          ..write('signPubKey: $signPubKey, ')
          ..write('multiaddrs: $multiaddrs, ')
          ..write('avatarUri: $avatarUri, ')
          ..write('status: $status, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('verified: $verified, ')
          ..write('blocked: $blocked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastMessageMeta =
      const VerificationMeta('lastMessage');
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
      'last_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageAtMeta =
      const VerificationMeta('lastMessageAt');
  @override
  late final GeneratedColumn<int> lastMessageAt = GeneratedColumn<int>(
      'last_message_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<int> muted = GeneratedColumn<int>(
      'muted', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _archivedMeta =
      const VerificationMeta('archived');
  @override
  late final GeneratedColumn<int> archived = GeneratedColumn<int>(
      'archived', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        topic,
        targetId,
        displayName,
        lastMessage,
        lastMessageAt,
        unreadCount,
        muted,
        archived,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(Insertable<Conversation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('last_message')) {
      context.handle(
          _lastMessageMeta,
          lastMessage.isAcceptableOrUnknown(
              data['last_message']!, _lastMessageMeta));
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
          _lastMessageAtMeta,
          lastMessageAt.isAcceptableOrUnknown(
              data['last_message_at']!, _lastMessageAtMeta));
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    if (data.containsKey('muted')) {
      context.handle(
          _mutedMeta, muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta,
          archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic'])!,
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      lastMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_message']),
      lastMessageAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_message_at']),
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
      muted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}muted'])!,
      archived: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final int id;
  final String type;
  final String topic;
  final String targetId;
  final String displayName;
  final String? lastMessage;
  final int? lastMessageAt;
  final int unreadCount;
  final int muted;
  final int archived;
  final int createdAt;
  const Conversation(
      {required this.id,
      required this.type,
      required this.topic,
      required this.targetId,
      required this.displayName,
      this.lastMessage,
      this.lastMessageAt,
      required this.unreadCount,
      required this.muted,
      required this.archived,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['topic'] = Variable<String>(topic);
    map['target_id'] = Variable<String>(targetId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<int>(lastMessageAt);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['muted'] = Variable<int>(muted);
    map['archived'] = Variable<int>(archived);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      type: Value(type),
      topic: Value(topic),
      targetId: Value(targetId),
      displayName: Value(displayName),
      lastMessage: lastMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessage),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      unreadCount: Value(unreadCount),
      muted: Value(muted),
      archived: Value(archived),
      createdAt: Value(createdAt),
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      topic: serializer.fromJson<String>(json['topic']),
      targetId: serializer.fromJson<String>(json['targetId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      lastMessageAt: serializer.fromJson<int?>(json['lastMessageAt']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      muted: serializer.fromJson<int>(json['muted']),
      archived: serializer.fromJson<int>(json['archived']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'topic': serializer.toJson<String>(topic),
      'targetId': serializer.toJson<String>(targetId),
      'displayName': serializer.toJson<String>(displayName),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'lastMessageAt': serializer.toJson<int?>(lastMessageAt),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'muted': serializer.toJson<int>(muted),
      'archived': serializer.toJson<int>(archived),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Conversation copyWith(
          {int? id,
          String? type,
          String? topic,
          String? targetId,
          String? displayName,
          Value<String?> lastMessage = const Value.absent(),
          Value<int?> lastMessageAt = const Value.absent(),
          int? unreadCount,
          int? muted,
          int? archived,
          int? createdAt}) =>
      Conversation(
        id: id ?? this.id,
        type: type ?? this.type,
        topic: topic ?? this.topic,
        targetId: targetId ?? this.targetId,
        displayName: displayName ?? this.displayName,
        lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
        lastMessageAt:
            lastMessageAt.present ? lastMessageAt.value : this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        muted: muted ?? this.muted,
        archived: archived ?? this.archived,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('topic: $topic, ')
          ..write('targetId: $targetId, ')
          ..write('displayName: $displayName, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('muted: $muted, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, topic, targetId, displayName,
      lastMessage, lastMessageAt, unreadCount, muted, archived, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.type == this.type &&
          other.topic == this.topic &&
          other.targetId == this.targetId &&
          other.displayName == this.displayName &&
          other.lastMessage == this.lastMessage &&
          other.lastMessageAt == this.lastMessageAt &&
          other.unreadCount == this.unreadCount &&
          other.muted == this.muted &&
          other.archived == this.archived &&
          other.createdAt == this.createdAt);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> topic;
  final Value<String> targetId;
  final Value<String> displayName;
  final Value<String?> lastMessage;
  final Value<int?> lastMessageAt;
  final Value<int> unreadCount;
  final Value<int> muted;
  final Value<int> archived;
  final Value<int> createdAt;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.topic = const Value.absent(),
    this.targetId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.muted = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ConversationsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String topic,
    required String targetId,
    required String displayName,
    this.lastMessage = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.muted = const Value.absent(),
    this.archived = const Value.absent(),
    required int createdAt,
  })  : type = Value(type),
        topic = Value(topic),
        targetId = Value(targetId),
        displayName = Value(displayName),
        createdAt = Value(createdAt);
  static Insertable<Conversation> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? topic,
    Expression<String>? targetId,
    Expression<String>? displayName,
    Expression<String>? lastMessage,
    Expression<int>? lastMessageAt,
    Expression<int>? unreadCount,
    Expression<int>? muted,
    Expression<int>? archived,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (topic != null) 'topic': topic,
      if (targetId != null) 'target_id': targetId,
      if (displayName != null) 'display_name': displayName,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (muted != null) 'muted': muted,
      if (archived != null) 'archived': archived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ConversationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<String>? topic,
      Value<String>? targetId,
      Value<String>? displayName,
      Value<String?>? lastMessage,
      Value<int?>? lastMessageAt,
      Value<int>? unreadCount,
      Value<int>? muted,
      Value<int>? archived,
      Value<int>? createdAt}) {
    return ConversationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      topic: topic ?? this.topic,
      targetId: targetId ?? this.targetId,
      displayName: displayName ?? this.displayName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      muted: muted ?? this.muted,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<int>(lastMessageAt.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (muted.present) {
      map['muted'] = Variable<int>(muted.value);
    }
    if (archived.present) {
      map['archived'] = Variable<int>(archived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('topic: $topic, ')
          ..write('targetId: $targetId, ')
          ..write('displayName: $displayName, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('muted: $muted, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES conversations (id)'));
  static const VerificationMeta _senderPeerIdMeta =
      const VerificationMeta('senderPeerId');
  @override
  late final GeneratedColumn<String> senderPeerId = GeneratedColumn<String>(
      'sender_peer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentTypeMeta =
      const VerificationMeta('contentType');
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
      'content_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('text'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('sent'));
  static const VerificationMeta _isMineMeta = const VerificationMeta('isMine');
  @override
  late final GeneratedColumn<int> isMine = GeneratedColumn<int>(
      'is_mine', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _replyToIdMeta =
      const VerificationMeta('replyToId');
  @override
  late final GeneratedColumn<String> replyToId = GeneratedColumn<String>(
      'reply_to_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _disappearsAtMeta =
      const VerificationMeta('disappearsAt');
  @override
  late final GeneratedColumn<int> disappearsAt = GeneratedColumn<int>(
      'disappears_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        conversationId,
        senderPeerId,
        content,
        contentType,
        status,
        isMine,
        replyToId,
        metadata,
        disappearsAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_peer_id')) {
      context.handle(
          _senderPeerIdMeta,
          senderPeerId.isAcceptableOrUnknown(
              data['sender_peer_id']!, _senderPeerIdMeta));
    } else if (isInserting) {
      context.missing(_senderPeerIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
          _contentTypeMeta,
          contentType.isAcceptableOrUnknown(
              data['content_type']!, _contentTypeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('is_mine')) {
      context.handle(_isMineMeta,
          isMine.isAcceptableOrUnknown(data['is_mine']!, _isMineMeta));
    } else if (isInserting) {
      context.missing(_isMineMeta);
    }
    if (data.containsKey('reply_to_id')) {
      context.handle(
          _replyToIdMeta,
          replyToId.isAcceptableOrUnknown(
              data['reply_to_id']!, _replyToIdMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    if (data.containsKey('disappears_at')) {
      context.handle(
          _disappearsAtMeta,
          disappearsAt.isAcceptableOrUnknown(
              data['disappears_at']!, _disappearsAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id'])!,
      senderPeerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_peer_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      contentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isMine: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_mine'])!,
      replyToId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply_to_id']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
      disappearsAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}disappears_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final int conversationId;
  final String senderPeerId;
  final String content;
  final String contentType;
  final String status;
  final int isMine;
  final String? replyToId;
  final String? metadata;
  final int? disappearsAt;
  final int createdAt;
  final int updatedAt;
  const Message(
      {required this.id,
      required this.conversationId,
      required this.senderPeerId,
      required this.content,
      required this.contentType,
      required this.status,
      required this.isMine,
      this.replyToId,
      this.metadata,
      this.disappearsAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['sender_peer_id'] = Variable<String>(senderPeerId);
    map['content'] = Variable<String>(content);
    map['content_type'] = Variable<String>(contentType);
    map['status'] = Variable<String>(status);
    map['is_mine'] = Variable<int>(isMine);
    if (!nullToAbsent || replyToId != null) {
      map['reply_to_id'] = Variable<String>(replyToId);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    if (!nullToAbsent || disappearsAt != null) {
      map['disappears_at'] = Variable<int>(disappearsAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      senderPeerId: Value(senderPeerId),
      content: Value(content),
      contentType: Value(contentType),
      status: Value(status),
      isMine: Value(isMine),
      replyToId: replyToId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToId),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      disappearsAt: disappearsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(disappearsAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      senderPeerId: serializer.fromJson<String>(json['senderPeerId']),
      content: serializer.fromJson<String>(json['content']),
      contentType: serializer.fromJson<String>(json['contentType']),
      status: serializer.fromJson<String>(json['status']),
      isMine: serializer.fromJson<int>(json['isMine']),
      replyToId: serializer.fromJson<String?>(json['replyToId']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      disappearsAt: serializer.fromJson<int?>(json['disappearsAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'senderPeerId': serializer.toJson<String>(senderPeerId),
      'content': serializer.toJson<String>(content),
      'contentType': serializer.toJson<String>(contentType),
      'status': serializer.toJson<String>(status),
      'isMine': serializer.toJson<int>(isMine),
      'replyToId': serializer.toJson<String?>(replyToId),
      'metadata': serializer.toJson<String?>(metadata),
      'disappearsAt': serializer.toJson<int?>(disappearsAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Message copyWith(
          {String? id,
          int? conversationId,
          String? senderPeerId,
          String? content,
          String? contentType,
          String? status,
          int? isMine,
          Value<String?> replyToId = const Value.absent(),
          Value<String?> metadata = const Value.absent(),
          Value<int?> disappearsAt = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      Message(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        senderPeerId: senderPeerId ?? this.senderPeerId,
        content: content ?? this.content,
        contentType: contentType ?? this.contentType,
        status: status ?? this.status,
        isMine: isMine ?? this.isMine,
        replyToId: replyToId.present ? replyToId.value : this.replyToId,
        metadata: metadata.present ? metadata.value : this.metadata,
        disappearsAt:
            disappearsAt.present ? disappearsAt.value : this.disappearsAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderPeerId: $senderPeerId, ')
          ..write('content: $content, ')
          ..write('contentType: $contentType, ')
          ..write('status: $status, ')
          ..write('isMine: $isMine, ')
          ..write('replyToId: $replyToId, ')
          ..write('metadata: $metadata, ')
          ..write('disappearsAt: $disappearsAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      conversationId,
      senderPeerId,
      content,
      contentType,
      status,
      isMine,
      replyToId,
      metadata,
      disappearsAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.senderPeerId == this.senderPeerId &&
          other.content == this.content &&
          other.contentType == this.contentType &&
          other.status == this.status &&
          other.isMine == this.isMine &&
          other.replyToId == this.replyToId &&
          other.metadata == this.metadata &&
          other.disappearsAt == this.disappearsAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<int> conversationId;
  final Value<String> senderPeerId;
  final Value<String> content;
  final Value<String> contentType;
  final Value<String> status;
  final Value<int> isMine;
  final Value<String?> replyToId;
  final Value<String?> metadata;
  final Value<int?> disappearsAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderPeerId = const Value.absent(),
    this.content = const Value.absent(),
    this.contentType = const Value.absent(),
    this.status = const Value.absent(),
    this.isMine = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.disappearsAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required int conversationId,
    required String senderPeerId,
    required String content,
    this.contentType = const Value.absent(),
    this.status = const Value.absent(),
    required int isMine,
    this.replyToId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.disappearsAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        conversationId = Value(conversationId),
        senderPeerId = Value(senderPeerId),
        content = Value(content),
        isMine = Value(isMine),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<int>? conversationId,
    Expression<String>? senderPeerId,
    Expression<String>? content,
    Expression<String>? contentType,
    Expression<String>? status,
    Expression<int>? isMine,
    Expression<String>? replyToId,
    Expression<String>? metadata,
    Expression<int>? disappearsAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderPeerId != null) 'sender_peer_id': senderPeerId,
      if (content != null) 'content': content,
      if (contentType != null) 'content_type': contentType,
      if (status != null) 'status': status,
      if (isMine != null) 'is_mine': isMine,
      if (replyToId != null) 'reply_to_id': replyToId,
      if (metadata != null) 'metadata': metadata,
      if (disappearsAt != null) 'disappears_at': disappearsAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? id,
      Value<int>? conversationId,
      Value<String>? senderPeerId,
      Value<String>? content,
      Value<String>? contentType,
      Value<String>? status,
      Value<int>? isMine,
      Value<String?>? replyToId,
      Value<String?>? metadata,
      Value<int?>? disappearsAt,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderPeerId: senderPeerId ?? this.senderPeerId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      status: status ?? this.status,
      isMine: isMine ?? this.isMine,
      replyToId: replyToId ?? this.replyToId,
      metadata: metadata ?? this.metadata,
      disappearsAt: disappearsAt ?? this.disappearsAt,
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
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (senderPeerId.present) {
      map['sender_peer_id'] = Variable<String>(senderPeerId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isMine.present) {
      map['is_mine'] = Variable<int>(isMine.value);
    }
    if (replyToId.present) {
      map['reply_to_id'] = Variable<String>(replyToId.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (disappearsAt.present) {
      map['disappears_at'] = Variable<int>(disappearsAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderPeerId: $senderPeerId, ')
          ..write('content: $content, ')
          ..write('contentType: $contentType, ')
          ..write('status: $status, ')
          ..write('isMine: $isMine, ')
          ..write('replyToId: $replyToId, ')
          ..write('metadata: $metadata, ')
          ..write('disappearsAt: $disappearsAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _groupKeyIdMeta =
      const VerificationMeta('groupKeyId');
  @override
  late final GeneratedColumn<String> groupKeyId = GeneratedColumn<String>(
      'group_key_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _adminPeerIdMeta =
      const VerificationMeta('adminPeerId');
  @override
  late final GeneratedColumn<String> adminPeerId = GeneratedColumn<String>(
      'admin_peer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarUriMeta =
      const VerificationMeta('avatarUri');
  @override
  late final GeneratedColumn<String> avatarUri = GeneratedColumn<String>(
      'avatar_uri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _memberCountMeta =
      const VerificationMeta('memberCount');
  @override
  late final GeneratedColumn<int> memberCount = GeneratedColumn<int>(
      'member_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        topic,
        groupKeyId,
        adminPeerId,
        avatarUri,
        memberCount,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<Group> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('group_key_id')) {
      context.handle(
          _groupKeyIdMeta,
          groupKeyId.isAcceptableOrUnknown(
              data['group_key_id']!, _groupKeyIdMeta));
    } else if (isInserting) {
      context.missing(_groupKeyIdMeta);
    }
    if (data.containsKey('admin_peer_id')) {
      context.handle(
          _adminPeerIdMeta,
          adminPeerId.isAcceptableOrUnknown(
              data['admin_peer_id']!, _adminPeerIdMeta));
    } else if (isInserting) {
      context.missing(_adminPeerIdMeta);
    }
    if (data.containsKey('avatar_uri')) {
      context.handle(_avatarUriMeta,
          avatarUri.isAcceptableOrUnknown(data['avatar_uri']!, _avatarUriMeta));
    }
    if (data.containsKey('member_count')) {
      context.handle(
          _memberCountMeta,
          memberCount.isAcceptableOrUnknown(
              data['member_count']!, _memberCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic'])!,
      groupKeyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_key_id'])!,
      adminPeerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}admin_peer_id'])!,
      avatarUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_uri']),
      memberCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}member_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final String id;
  final String name;
  final String? description;
  final String topic;
  final String groupKeyId;
  final String adminPeerId;
  final String? avatarUri;
  final int memberCount;
  final int createdAt;
  final int updatedAt;
  const Group(
      {required this.id,
      required this.name,
      this.description,
      required this.topic,
      required this.groupKeyId,
      required this.adminPeerId,
      this.avatarUri,
      required this.memberCount,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['topic'] = Variable<String>(topic);
    map['group_key_id'] = Variable<String>(groupKeyId);
    map['admin_peer_id'] = Variable<String>(adminPeerId);
    if (!nullToAbsent || avatarUri != null) {
      map['avatar_uri'] = Variable<String>(avatarUri);
    }
    map['member_count'] = Variable<int>(memberCount);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      topic: Value(topic),
      groupKeyId: Value(groupKeyId),
      adminPeerId: Value(adminPeerId),
      avatarUri: avatarUri == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUri),
      memberCount: Value(memberCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      topic: serializer.fromJson<String>(json['topic']),
      groupKeyId: serializer.fromJson<String>(json['groupKeyId']),
      adminPeerId: serializer.fromJson<String>(json['adminPeerId']),
      avatarUri: serializer.fromJson<String?>(json['avatarUri']),
      memberCount: serializer.fromJson<int>(json['memberCount']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'topic': serializer.toJson<String>(topic),
      'groupKeyId': serializer.toJson<String>(groupKeyId),
      'adminPeerId': serializer.toJson<String>(adminPeerId),
      'avatarUri': serializer.toJson<String?>(avatarUri),
      'memberCount': serializer.toJson<int>(memberCount),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Group copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? topic,
          String? groupKeyId,
          String? adminPeerId,
          Value<String?> avatarUri = const Value.absent(),
          int? memberCount,
          int? createdAt,
          int? updatedAt}) =>
      Group(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        topic: topic ?? this.topic,
        groupKeyId: groupKeyId ?? this.groupKeyId,
        adminPeerId: adminPeerId ?? this.adminPeerId,
        avatarUri: avatarUri.present ? avatarUri.value : this.avatarUri,
        memberCount: memberCount ?? this.memberCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('topic: $topic, ')
          ..write('groupKeyId: $groupKeyId, ')
          ..write('adminPeerId: $adminPeerId, ')
          ..write('avatarUri: $avatarUri, ')
          ..write('memberCount: $memberCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, topic, groupKeyId,
      adminPeerId, avatarUri, memberCount, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.topic == this.topic &&
          other.groupKeyId == this.groupKeyId &&
          other.adminPeerId == this.adminPeerId &&
          other.avatarUri == this.avatarUri &&
          other.memberCount == this.memberCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> topic;
  final Value<String> groupKeyId;
  final Value<String> adminPeerId;
  final Value<String?> avatarUri;
  final Value<int> memberCount;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.topic = const Value.absent(),
    this.groupKeyId = const Value.absent(),
    this.adminPeerId = const Value.absent(),
    this.avatarUri = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String topic,
    required String groupKeyId,
    required String adminPeerId,
    this.avatarUri = const Value.absent(),
    this.memberCount = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        topic = Value(topic),
        groupKeyId = Value(groupKeyId),
        adminPeerId = Value(adminPeerId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Group> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? topic,
    Expression<String>? groupKeyId,
    Expression<String>? adminPeerId,
    Expression<String>? avatarUri,
    Expression<int>? memberCount,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (topic != null) 'topic': topic,
      if (groupKeyId != null) 'group_key_id': groupKeyId,
      if (adminPeerId != null) 'admin_peer_id': adminPeerId,
      if (avatarUri != null) 'avatar_uri': avatarUri,
      if (memberCount != null) 'member_count': memberCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? topic,
      Value<String>? groupKeyId,
      Value<String>? adminPeerId,
      Value<String?>? avatarUri,
      Value<int>? memberCount,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      topic: topic ?? this.topic,
      groupKeyId: groupKeyId ?? this.groupKeyId,
      adminPeerId: adminPeerId ?? this.adminPeerId,
      avatarUri: avatarUri ?? this.avatarUri,
      memberCount: memberCount ?? this.memberCount,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (groupKeyId.present) {
      map['group_key_id'] = Variable<String>(groupKeyId.value);
    }
    if (adminPeerId.present) {
      map['admin_peer_id'] = Variable<String>(adminPeerId.value);
    }
    if (avatarUri.present) {
      map['avatar_uri'] = Variable<String>(avatarUri.value);
    }
    if (memberCount.present) {
      map['member_count'] = Variable<int>(memberCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('topic: $topic, ')
          ..write('groupKeyId: $groupKeyId, ')
          ..write('adminPeerId: $adminPeerId, ')
          ..write('avatarUri: $avatarUri, ')
          ..write('memberCount: $memberCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersTable extends GroupMembers
    with TableInfo<$GroupMembersTable, GroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  static const VerificationMeta _peerIdMeta = const VerificationMeta('peerId');
  @override
  late final GeneratedColumn<String> peerId = GeneratedColumn<String>(
      'peer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('member'));
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<int> joinedAt = GeneratedColumn<int>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, groupId, peerId, role, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members';
  @override
  VerificationContext validateIntegrity(Insertable<GroupMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('peer_id')) {
      context.handle(_peerIdMeta,
          peerId.isAcceptableOrUnknown(data['peer_id']!, _peerIdMeta));
    } else if (isInserting) {
      context.missing(_peerIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {groupId, peerId},
      ];
  @override
  GroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMember(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      peerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}peer_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}joined_at'])!,
    );
  }

  @override
  $GroupMembersTable createAlias(String alias) {
    return $GroupMembersTable(attachedDatabase, alias);
  }
}

class GroupMember extends DataClass implements Insertable<GroupMember> {
  final int id;
  final String groupId;
  final String peerId;
  final String role;
  final int joinedAt;
  const GroupMember(
      {required this.id,
      required this.groupId,
      required this.peerId,
      required this.role,
      required this.joinedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_id'] = Variable<String>(groupId);
    map['peer_id'] = Variable<String>(peerId);
    map['role'] = Variable<String>(role);
    map['joined_at'] = Variable<int>(joinedAt);
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      id: Value(id),
      groupId: Value(groupId),
      peerId: Value(peerId),
      role: Value(role),
      joinedAt: Value(joinedAt),
    );
  }

  factory GroupMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      id: serializer.fromJson<int>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      peerId: serializer.fromJson<String>(json['peerId']),
      role: serializer.fromJson<String>(json['role']),
      joinedAt: serializer.fromJson<int>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupId': serializer.toJson<String>(groupId),
      'peerId': serializer.toJson<String>(peerId),
      'role': serializer.toJson<String>(role),
      'joinedAt': serializer.toJson<int>(joinedAt),
    };
  }

  GroupMember copyWith(
          {int? id,
          String? groupId,
          String? peerId,
          String? role,
          int? joinedAt}) =>
      GroupMember(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        peerId: peerId ?? this.peerId,
        role: role ?? this.role,
        joinedAt: joinedAt ?? this.joinedAt,
      );
  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('peerId: $peerId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, peerId, role, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.peerId == this.peerId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt);
}

class GroupMembersCompanion extends UpdateCompanion<GroupMember> {
  final Value<int> id;
  final Value<String> groupId;
  final Value<String> peerId;
  final Value<String> role;
  final Value<int> joinedAt;
  const GroupMembersCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.peerId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
  });
  GroupMembersCompanion.insert({
    this.id = const Value.absent(),
    required String groupId,
    required String peerId,
    this.role = const Value.absent(),
    required int joinedAt,
  })  : groupId = Value(groupId),
        peerId = Value(peerId),
        joinedAt = Value(joinedAt);
  static Insertable<GroupMember> custom({
    Expression<int>? id,
    Expression<String>? groupId,
    Expression<String>? peerId,
    Expression<String>? role,
    Expression<int>? joinedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (peerId != null) 'peer_id': peerId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
    });
  }

  GroupMembersCompanion copyWith(
      {Value<int>? id,
      Value<String>? groupId,
      Value<String>? peerId,
      Value<String>? role,
      Value<int>? joinedAt}) {
    return GroupMembersCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      peerId: peerId ?? this.peerId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (peerId.present) {
      map['peer_id'] = Variable<String>(peerId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<int>(joinedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('peerId: $peerId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }
}

class $MessageQueueTable extends MessageQueue
    with TableInfo<$MessageQueueTable, MessageQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
      'message_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxRetriesMeta =
      const VerificationMeta('maxRetries');
  @override
  late final GeneratedColumn<int> maxRetries = GeneratedColumn<int>(
      'max_retries', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _nextRetryAtMeta =
      const VerificationMeta('nextRetryAt');
  @override
  late final GeneratedColumn<int> nextRetryAt = GeneratedColumn<int>(
      'next_retry_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        messageId,
        topic,
        payload,
        retryCount,
        maxRetries,
        nextRetryAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_queue';
  @override
  VerificationContext validateIntegrity(Insertable<MessageQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('max_retries')) {
      context.handle(
          _maxRetriesMeta,
          maxRetries.isAcceptableOrUnknown(
              data['max_retries']!, _maxRetriesMeta));
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
          _nextRetryAtMeta,
          nextRetryAt.isAcceptableOrUnknown(
              data['next_retry_at']!, _nextRetryAtMeta));
    } else if (isInserting) {
      context.missing(_nextRetryAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id'])!,
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      maxRetries: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_retries'])!,
      nextRetryAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}next_retry_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MessageQueueTable createAlias(String alias) {
    return $MessageQueueTable(attachedDatabase, alias);
  }
}

class MessageQueueData extends DataClass
    implements Insertable<MessageQueueData> {
  final int id;
  final String messageId;
  final String topic;
  final String payload;
  final int retryCount;
  final int maxRetries;
  final int nextRetryAt;
  final int createdAt;
  const MessageQueueData(
      {required this.id,
      required this.messageId,
      required this.topic,
      required this.payload,
      required this.retryCount,
      required this.maxRetries,
      required this.nextRetryAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['topic'] = Variable<String>(topic);
    map['payload'] = Variable<String>(payload);
    map['retry_count'] = Variable<int>(retryCount);
    map['max_retries'] = Variable<int>(maxRetries);
    map['next_retry_at'] = Variable<int>(nextRetryAt);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  MessageQueueCompanion toCompanion(bool nullToAbsent) {
    return MessageQueueCompanion(
      id: Value(id),
      messageId: Value(messageId),
      topic: Value(topic),
      payload: Value(payload),
      retryCount: Value(retryCount),
      maxRetries: Value(maxRetries),
      nextRetryAt: Value(nextRetryAt),
      createdAt: Value(createdAt),
    );
  }

  factory MessageQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageQueueData(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      topic: serializer.fromJson<String>(json['topic']),
      payload: serializer.fromJson<String>(json['payload']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      maxRetries: serializer.fromJson<int>(json['maxRetries']),
      nextRetryAt: serializer.fromJson<int>(json['nextRetryAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'topic': serializer.toJson<String>(topic),
      'payload': serializer.toJson<String>(payload),
      'retryCount': serializer.toJson<int>(retryCount),
      'maxRetries': serializer.toJson<int>(maxRetries),
      'nextRetryAt': serializer.toJson<int>(nextRetryAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  MessageQueueData copyWith(
          {int? id,
          String? messageId,
          String? topic,
          String? payload,
          int? retryCount,
          int? maxRetries,
          int? nextRetryAt,
          int? createdAt}) =>
      MessageQueueData(
        id: id ?? this.id,
        messageId: messageId ?? this.messageId,
        topic: topic ?? this.topic,
        payload: payload ?? this.payload,
        retryCount: retryCount ?? this.retryCount,
        maxRetries: maxRetries ?? this.maxRetries,
        nextRetryAt: nextRetryAt ?? this.nextRetryAt,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('MessageQueueData(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('topic: $topic, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, messageId, topic, payload, retryCount,
      maxRetries, nextRetryAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageQueueData &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.topic == this.topic &&
          other.payload == this.payload &&
          other.retryCount == this.retryCount &&
          other.maxRetries == this.maxRetries &&
          other.nextRetryAt == this.nextRetryAt &&
          other.createdAt == this.createdAt);
}

class MessageQueueCompanion extends UpdateCompanion<MessageQueueData> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<String> topic;
  final Value<String> payload;
  final Value<int> retryCount;
  final Value<int> maxRetries;
  final Value<int> nextRetryAt;
  final Value<int> createdAt;
  const MessageQueueCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.topic = const Value.absent(),
    this.payload = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MessageQueueCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    required String topic,
    required String payload,
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    required int nextRetryAt,
    required int createdAt,
  })  : messageId = Value(messageId),
        topic = Value(topic),
        payload = Value(payload),
        nextRetryAt = Value(nextRetryAt),
        createdAt = Value(createdAt);
  static Insertable<MessageQueueData> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? topic,
    Expression<String>? payload,
    Expression<int>? retryCount,
    Expression<int>? maxRetries,
    Expression<int>? nextRetryAt,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (topic != null) 'topic': topic,
      if (payload != null) 'payload': payload,
      if (retryCount != null) 'retry_count': retryCount,
      if (maxRetries != null) 'max_retries': maxRetries,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MessageQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? messageId,
      Value<String>? topic,
      Value<String>? payload,
      Value<int>? retryCount,
      Value<int>? maxRetries,
      Value<int>? nextRetryAt,
      Value<int>? createdAt}) {
    return MessageQueueCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      topic: topic ?? this.topic,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (maxRetries.present) {
      map['max_retries'] = Variable<int>(maxRetries.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<int>(nextRetryAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageQueueCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('topic: $topic, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $IdentityTable identity = $IdentityTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $MessageQueueTable messageQueue = $MessageQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        identity,
        contacts,
        conversations,
        messages,
        groups,
        groupMembers,
        messageQueue
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('group_members', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}
