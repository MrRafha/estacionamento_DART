import 'enums.dart';

// Representa uma vaga e o estado dela dentro do estacionamento.
class Vaga {
  String id;
  TipoVaga tipo;
  DestinacaoVaga destinacao;
  StatusVaga status;

  Vaga({required this.id, required this.tipo, required this.destinacao, this.status = StatusVaga.livre});

  bool compativelCom(TipoVeiculo veiculo) {
    // Vagas de moto aceitam apenas motos; as demais aceitam outros veículos.
    if (destinacao == DestinacaoVaga.moto) return veiculo == TipoVeiculo.moto;
    return veiculo != TipoVeiculo.moto;
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'tipo': enumName(tipo), 'destinacao': enumName(destinacao), 'status': enumName(status),
  };

  factory Vaga.fromJson(Map<String, dynamic> json) => Vaga(
    id: json['id'], tipo: tipoVagaFrom(json['tipo']), destinacao: destinacaoFrom(json['destinacao']), status: statusVagaFrom(json['status']),
  );
}
