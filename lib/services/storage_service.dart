import 'dart:convert';
import 'dart:io';

class StorageService {
  final String path;
  StorageService(this.path);

  Future<Map<String, dynamic>> load() async {
    // Escolhi JSON porque ele é legível durante a apresentação e fácil de converter
    // para Mapas do Dart, sem precisar instalar um banco de dados.
    // O arquivo pode não existir na primeira execução; nesse caso o sistema começa vazio.
    final file = File(path);
    if (!await file.exists()) return {};
    try {
      final text = await file.readAsString();
      if (text.trim().isEmpty) return {};
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('O arquivo de dados está corrompido ou inválido.');
    }
  }

  Future<void> save(Map<String, dynamic> data) async {
    // O serviço de negócio não precisa conhecer os detalhes de arquivos e JSON.
    // Essa separação facilita trocar o arquivo por um banco no futuro.
    // A pasta é criada sob demanda para não depender de preparo manual do ambiente.
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }
}
