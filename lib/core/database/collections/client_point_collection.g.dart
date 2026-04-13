// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_point_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClientPointCollection on Isar {
  IsarCollection<ClientPoint> get clientPoints => this.collection();
}

const ClientPointSchema = CollectionSchema(
  name: r'ClientPoint',
  id: 5148645506770685355,
  properties: {
    r'clientName': PropertySchema(
      id: 0,
      name: r'clientName',
      type: IsarType.string,
    ),
    r'defaultProducts': PropertySchema(
      id: 1,
      name: r'defaultProducts',
      type: IsarType.stringList,
    ),
    r'deliveryNotes': PropertySchema(
      id: 2,
      name: r'deliveryNotes',
      type: IsarType.string,
    ),
    r'latitude': PropertySchema(
      id: 3,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 4,
      name: r'longitude',
      type: IsarType.double,
    )
  },
  estimateSize: _clientPointEstimateSize,
  serialize: _clientPointSerialize,
  deserialize: _clientPointDeserialize,
  deserializeProp: _clientPointDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _clientPointGetId,
  getLinks: _clientPointGetLinks,
  attach: _clientPointAttach,
  version: '3.1.0+1',
);

int _clientPointEstimateSize(
  ClientPoint object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.clientName.length * 3;
  bytesCount += 3 + object.defaultProducts.length * 3;
  {
    for (var i = 0; i < object.defaultProducts.length; i++) {
      final value = object.defaultProducts[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.deliveryNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _clientPointSerialize(
  ClientPoint object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.clientName);
  writer.writeStringList(offsets[1], object.defaultProducts);
  writer.writeString(offsets[2], object.deliveryNotes);
  writer.writeDouble(offsets[3], object.latitude);
  writer.writeDouble(offsets[4], object.longitude);
}

ClientPoint _clientPointDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClientPoint();
  object.clientName = reader.readString(offsets[0]);
  object.defaultProducts = reader.readStringList(offsets[1]) ?? [];
  object.deliveryNotes = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.latitude = reader.readDouble(offsets[3]);
  object.longitude = reader.readDouble(offsets[4]);
  return object;
}

P _clientPointDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _clientPointGetId(ClientPoint object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _clientPointGetLinks(ClientPoint object) {
  return [];
}

void _clientPointAttach(
    IsarCollection<dynamic> col, Id id, ClientPoint object) {
  object.id = id;
}

extension ClientPointQueryWhereSort
    on QueryBuilder<ClientPoint, ClientPoint, QWhere> {
  QueryBuilder<ClientPoint, ClientPoint, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ClientPointQueryWhere
    on QueryBuilder<ClientPoint, ClientPoint, QWhereClause> {
  QueryBuilder<ClientPoint, ClientPoint, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ClientPointQueryFilter
    on QueryBuilder<ClientPoint, ClientPoint, QFilterCondition> {
  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      clientNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      clientNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      clientNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      clientNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clientName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      clientNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      clientNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      clientNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      clientNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clientName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      clientNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientName',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      clientNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clientName',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultProducts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultProducts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultProducts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultProducts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'defaultProducts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'defaultProducts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'defaultProducts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'defaultProducts',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultProducts',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'defaultProducts',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaultProducts',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaultProducts',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaultProducts',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaultProducts',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaultProducts',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      defaultProductsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaultProducts',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deliveryNotes',
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deliveryNotes',
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deliveryNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deliveryNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deliveryNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deliveryNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deliveryNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deliveryNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deliveryNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deliveryNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deliveryNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      deliveryNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deliveryNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterFilterCondition>
      longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ClientPointQueryObject
    on QueryBuilder<ClientPoint, ClientPoint, QFilterCondition> {}

extension ClientPointQueryLinks
    on QueryBuilder<ClientPoint, ClientPoint, QFilterCondition> {}

extension ClientPointQuerySortBy
    on QueryBuilder<ClientPoint, ClientPoint, QSortBy> {
  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> sortByClientName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientName', Sort.asc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> sortByClientNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientName', Sort.desc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> sortByDeliveryNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryNotes', Sort.asc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy>
      sortByDeliveryNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryNotes', Sort.desc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }
}

extension ClientPointQuerySortThenBy
    on QueryBuilder<ClientPoint, ClientPoint, QSortThenBy> {
  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> thenByClientName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientName', Sort.asc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> thenByClientNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientName', Sort.desc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> thenByDeliveryNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryNotes', Sort.asc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy>
      thenByDeliveryNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryNotes', Sort.desc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }
}

extension ClientPointQueryWhereDistinct
    on QueryBuilder<ClientPoint, ClientPoint, QDistinct> {
  QueryBuilder<ClientPoint, ClientPoint, QDistinct> distinctByClientName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clientName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QDistinct>
      distinctByDefaultProducts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultProducts');
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QDistinct> distinctByDeliveryNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deliveryNotes',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<ClientPoint, ClientPoint, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }
}

extension ClientPointQueryProperty
    on QueryBuilder<ClientPoint, ClientPoint, QQueryProperty> {
  QueryBuilder<ClientPoint, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ClientPoint, String, QQueryOperations> clientNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clientName');
    });
  }

  QueryBuilder<ClientPoint, List<String>, QQueryOperations>
      defaultProductsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultProducts');
    });
  }

  QueryBuilder<ClientPoint, String?, QQueryOperations> deliveryNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deliveryNotes');
    });
  }

  QueryBuilder<ClientPoint, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<ClientPoint, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }
}
