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
    r'productsToDeliver': PropertySchema(
      id: 1,
      name: r'productsToDeliver',
      type: IsarType.stringList,
    ),
    r'stopOrder': PropertySchema(
      id: 2,
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
    ),
    r'clientPoint': LinkSchema(
      id: 4660155805860744518,
      name: r'clientPoint',
      target: r'ClientPoint',
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
  writer.writeStringList(offsets[1], object.productsToDeliver);
  writer.writeLong(offsets[2], object.stopOrder);
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
  object.productsToDeliver = reader.readStringList(offsets[1]) ?? [];
  object.stopOrder = reader.readLong(offsets[2]);
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
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _routeStopGetId(RouteStop object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _routeStopGetLinks(RouteStop object) {
  return [object.route, object.clientPoint];
}

void _routeStopAttach(IsarCollection<dynamic> col, Id id, RouteStop object) {
  object.id = id;
  object.route.attach(col, col.isar.collection<DeliveryRoute>(), r'route', id);
  object.clientPoint
      .attach(col, col.isar.collection<ClientPoint>(), r'clientPoint', id);
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

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition> clientPoint(
      FilterQuery<ClientPoint> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'clientPoint');
    });
  }

  QueryBuilder<RouteStop, RouteStop, QAfterFilterCondition>
      clientPointIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'clientPoint', 0, true, 0, true);
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
