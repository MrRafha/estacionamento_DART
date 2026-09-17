import 'enums.dart';

class Cliente {
  String id;
  String nome;
  String documento;
  String telefone;
  PerfilCliente perfil;
  bool mensalidadeEmDia;

  Cliente({required this.id, required this.nome, required this.documento, required this.telefone, required this.perfil, this.mensalidadeEmDia = false});

  Map<String, dynamic> toJson() => {
    'id': id, 'nome': nome, 'documento': documento, 'telefone': telefone,
    'perfil': enumName(perfil), 'mensalidadeEmDia': mensalidadeEmDia,
  };

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    id: json['id'], nome: json['nome'], documento: json['documento'], telefone: json['telefone'],
    perfil: perfilFrom(json['perfil']), mensalidadeEmDia: json['mensalidadeEmDia'] ?? false,
  );
}
