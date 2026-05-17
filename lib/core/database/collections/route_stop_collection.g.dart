// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_stop_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRouteStopCollection on Isar {
  IsarCollection<RouteStop> get routeStops => this.collection();
}

const RouteStopSchema = CollectionSchema(
  name: r'RouteStop',
  id: -288160078318827968,
  properties: {
    r'isDelivered': PropertySchema(
      id: 0,
      name: r'isDelivered',
      type: IsarType.bool,
    ),
    r'latitude': PropertySchema(
      id: 1,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'localImagePath': PropertySchema(
      id: 2,
      name: r'localImagePath',
      type: IsarType.string,
    ),
    r'locationCaptureMethod': PropertySchema(
      id: 3,
      name: r'locationCaptureMethod',
      type: IsarType.string,
    ),
    r'longitude': PropertySchema(
      id: 4,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'notes': PropertySchema(
      id: 5,
      name: r'notes',
      type: IsarType.string,
    ),
    r'orderName': PropertySchema(
      id: 6,
      name: r'orderName',
      type: IsarType.string,
    ),
    r'productsToDeliver': PropertySchema(
      id: 7,
      name: r'productsToDeliver',
      type: IsarType.stringList,
    ),
    r'stopOrder': PropertySchema(
      id: 8,
      name: r'stopOrder',
      type: IsarType.long,
    )
  },
  estimateSize: _routeStopEstimateSize,
  serialize: _routeStopSerialize,
  deserialize: _routeStopDeserialize,
  deserializeProp: _routeStopDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'route': LinkSchema(
      id: -7557119656063090451,
      name: r'route',
      target: r'DeliveryRoute',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _routeStopGetId,
  getLinks: _routeStopGetLinks,
  attach: _routeStopAttach,
  version: '3.1.0+1',
);

int _routeStopEstimateSize(
  RouteStop object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.localImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.locationCaptureMethod;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.orderName.length * 3;
  bytesCount += 3 + object.productsToDeliver.length * 3;
  {
    for (var i = 0; i < object.productsToDeliver.length; i++) {
      final value = object.productsToDeliver[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _routeStopSerialize(
  RouteStop object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isDelivered);
  writer.writeDouble(offsets[1], object.latitude);
  writer.writeString(offsets[2], object.localImagePath);
  writer.writeString(offsets[3], object.locationCaptureMethod);
  writer.writeDouble(offsets[4], object.longitude);
  writer.writeString(offsets[5], object.notes);
  writer.writeString(offsets[6], object.orderName);
  writer.writeStringList(offsets[7], object.productsToDeliver);
  writer.writeLong(offsets[8], object.stopOrder);
}

RouteStop _routeStopDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RouteStop();
  object.id = id;
  object.isDelivered = reader.readBool(offsets[0]);
  object.latitude = reader.readDouble(offsets[1]);
  object.localImagePath = reader.readStringOrNull(offsets[2]);
  object.locationCaptureMethod = reader.readStringOrNull(offsets[3]);
  object.longitude = reader.readDouble(offsets[4]);
  object.notes = reader.readStringOrNull(offsets[5]);
  object.orderName = reader.readString(offsets[6]);
  object.productsToDeliver = reader.readStringList(offsets[7]) ?? [];
  object.stopOrder = reader.readLong(offsets[8]);
  return object;
}

P _routeStopDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _routeStopGetId(RouteStop object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _routeStopGetLinks(RouteStop object) {
  return [object.route];
}

void _routeStopAttach(IsarCollection<dynamic> col, Id id, RouteStop object) {
  object.id = id;
  object.route.attach(col, col.isar.collection<DeliveryRoute>(), r'route', id);
}

extension RouteStopQueryWhereSort
    on QueryBuilder<RouteStop, RouteStop, QWhere> {
  QueryBuilder<RouteStop, RouteStop, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RouteStopQueryWhere
    on QueryBuilder<RouteStop, RouteStop, QWhereClause> {
  QueryBuilder<RouteStop, RouteStop, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<RouteStop, RouteStop, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterWhereClause> idBetween(
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

extension RouteStopQueryFilter
    on QueryBuilder<RouteStop, RouteStop, QFilterCondition> {
  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> isDeliveredEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDelivered',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> latitudeEqualTo(
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> latitudeGreaterThan(
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> latitudeLessThan(
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> latitudeBetween(
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localImagePath',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localImagePath',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      localImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationCaptureMethod',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationCaptureMethod',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationCaptureMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationCaptureMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationCaptureMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationCaptureMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locationCaptureMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locationCaptureMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locationCaptureMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locationCaptureMethod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationCaptureMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      locationCaptureMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locationCaptureMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> longitudeEqualTo(
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> longitudeLessThan(
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> longitudeBetween(
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> orderNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      orderNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> orderNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> orderNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> orderNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'orderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> orderNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'orderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> orderNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'orderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> orderNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'orderName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> orderNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      orderNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'orderName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productsToDeliver',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productsToDeliver',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productsToDeliver',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productsToDeliver',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productsToDeliver',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productsToDeliver',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productsToDeliver',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productsToDeliver',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productsToDeliver',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productsToDeliver',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productsToDeliver',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productsToDeliver',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productsToDeliver',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productsToDeliver',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productsToDeliver',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      productsToDeliverLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productsToDeliver',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> stopOrderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stopOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      stopOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stopOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> stopOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stopOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> stopOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stopOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RouteStopQueryObject
    on QueryBuilder<RouteStop, RouteStop, QFilterCondition> {}

extension RouteStopQueryLinks
    on QueryBuilder<RouteStop, RouteStop, QFilterCondition> {
  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> route(
      FilterQuery<DeliveryRoute> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'route');
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> routeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'route', 0, true, 0, true);
    });
  }
}

extension RouteStopQuerySortBy on QueryBuilder<RouteStop, RouteStop, QSortBy> {
  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByIsDelivered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDelivered', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByIsDeliveredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDelivered', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByLocalImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localImagePath', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByLocalImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localImagePath', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy>
      sortByLocationCaptureMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationCaptureMethod', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy>
      sortByLocationCaptureMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationCaptureMethod', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByOrderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderName', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByOrderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderName', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByStopOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOrder', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> sortByStopOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOrder', Sort.desc);
    });
  }
}

extension RouteStopQuerySortThenBy
    on QueryBuilder<RouteStop, RouteStop, QSortThenBy> {
  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByIsDelivered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDelivered', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByIsDeliveredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDelivered', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByLocalImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localImagePath', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByLocalImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localImagePath', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy>
      thenByLocationCaptureMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationCaptureMethod', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy>
      thenByLocationCaptureMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationCaptureMethod', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByOrderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderName', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByOrderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderName', Sort.desc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByStopOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOrder', Sort.asc);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterSortBy> thenByStopOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOrder', Sort.desc);
    });
  }
}

extension RouteStopQueryWhereDistinct
    on QueryBuilder<RouteStop, RouteStop, QDistinct> {
  QueryBuilder<RouteStop, RouteStop, QDistinct> distinctByIsDelivered() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDelivered');
    });
  }

  QueryBuilder<RouteStop, RouteStop, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<RouteStop, RouteStop, QDistinct> distinctByLocalImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QDistinct> distinctByLocationCaptureMethod(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationCaptureMethod',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<RouteStop, RouteStop, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QDistinct> distinctByOrderName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteStop, RouteStop, QDistinct> distinctByProductsToDeliver() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productsToDeliver');
    });
  }

  QueryBuilder<RouteStop, RouteStop, QDistinct> distinctByStopOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stopOrder');
    });
  }
}

extension RouteStopQueryProperty
    on QueryBuilder<RouteStop, RouteStop, QQueryProperty> {
  QueryBuilder<RouteStop, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RouteStop, bool, QQueryOperations> isDeliveredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDelivered');
    });
  }

  QueryBuilder<RouteStop, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<RouteStop, String?, QQueryOperations> localImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localImagePath');
    });
  }

  QueryBuilder<RouteStop, String?, QQueryOperations>
      locationCaptureMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationCaptureMethod');
    });
  }

  QueryBuilder<RouteStop, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<RouteStop, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<RouteStop, String, QQueryOperations> orderNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderName');
    });
  }

  QueryBuilder<RouteStop, List<String>, QQueryOperations>
      productsToDeliverProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productsToDeliver');
    });
  }

  QueryBuilder<RouteStop, int, QQueryOperations> stopOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stopOrder');
    });
  }
}
