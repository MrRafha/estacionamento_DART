import 'package:sistema_estacionamento/app.dart';
import 'package:sistema_estacionamento/services/estacionamento_service.dart';
import 'package:sistema_estacionamento/services/storage_service.dart';

Future<void> main() async {
  // Este é o ponto de entrada: conecto o serviço de arquivos ao serviço de negócio.
  // A partir daqui, o App fica responsável por conversar com a pessoa no terminal.
  final service = EstacionamentoService(StorageService('data/estacionamento.txt'));
  await App(service).iniciar();
}
