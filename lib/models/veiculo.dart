import 'enums.dart';

class Veiculo {
  String placa;
  String modelo;
  String marca;
  TipoVeiculo tipo;
  String? clienteId;

  Veiculo({required this.placa, required this.modelo, required this.marca, required this.tipo, this.clienteId});

  Map<String, dynamic> toJson() => {
    'placa': placa, 'modelo': modelo, 'marca': marca, 'tipo': enumName(tipo), 'clienteId': clienteId,
  };

  factory Veiculo.fromJson(Map<String, dynamic> json) => Veiculo(
    placa: json['placa'], modelo: json['modelo'], marca: json['marca'], tipo: tipoVeiculoFrom(json['tipo']), clienteId: json['clienteId'],
  );
}
