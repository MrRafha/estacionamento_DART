// Guarda o período em que um veículo ocupa uma vaga.
// A saída nula representa uma permanência ainda aberta.
class Permanencia {
  String id;
  String placa;
  String vagaId;
  String perfil;
  DateTime entrada;
  DateTime? saida;
  bool ticketPerdido;
  double valor;

  Permanencia({required this.id, required this.placa, required this.vagaId, required this.perfil, required this.entrada, this.saida, this.ticketPerdido = false, this.valor = 0});

  bool get aberta => saida == null;

  Map<String, dynamic> toJson() => {
    // No arquivo uso ISO 8601, que evita ambiguidade; na tela mostro o formato brasileiro.
    'id': id, 'placa': placa, 'vagaId': vagaId, 'perfil': perfil, 'entrada': entrada.toIso8601String(),
    'saida': saida?.toIso8601String(), 'ticketPerdido': ticketPerdido, 'valor': valor,
  };

  factory Permanencia.fromJson(Map<String, dynamic> json) => Permanencia(
    id: json['id'], placa: json['placa'], vagaId: json['vagaId'], perfil: json['perfil'],
    entrada: DateTime.parse(json['entrada']), saida: json['saida'] == null ? null : DateTime.parse(json['saida']),
    ticketPerdido: json['ticketPerdido'] ?? false, valor: (json['valor'] as num?)?.toDouble() ?? 0,
  );
}
