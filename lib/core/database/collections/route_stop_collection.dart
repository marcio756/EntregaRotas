import 'package:isar/isar.dart';
import 'route_collection.dart';

part 'route_stop_collection.g.dart';

/// Representa um Pedido específico dentro de uma Rota.
/// Fundimos a localização, imagem e produtos numa única entidade 
/// para simplificar a arquitetura de uso único (Domingos).
@collection
class RouteStop {
  Id id = Isar.autoIncrement;

  /// Ligação à Rota a que este pedido pertence (ex: Domingo)
  final route = IsarLink<DeliveryRoute>();

  /// Nome ou identificador rápido do pedido (ex: "Casa Amarela", "Sr. João")
  late String orderName;

  /// Descrição ou notas de entrega
  String? notes;

  /// Coordenadas exatas do pedido
  late double latitude;
  late double longitude;
  
  /// Como foi obtida a localização ('GPS' ou 'MAP')
  String? locationCaptureMethod;

  /// Caminho para a fotografia tirada ao local guardada no dispositivo
  String? localImagePath;

  /// Ordem de entrega na rota
  late int stopOrder;

  /// Resumo dos produtos e quantidades para este pedido
  late List<String> productsToDeliver;
  
  /// Estado da entrega
  bool isDelivered = false;
}