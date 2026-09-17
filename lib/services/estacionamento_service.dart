import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/permanencia.dart';
import '../models/vaga.dart';
import '../models/veiculo.dart';
import 'storage_service.dart';

class EstacionamentoService {
  // Esta classe concentra as regras do estacionamento, mantendo a interface
  // do terminal separada da lógica que precisa ser validada.
  final StorageService storage;
  final List<Vaga> vagas = [];
  final List<Cliente> clientes = [];
  final List<Veiculo> veiculos = [];
  final List<Permanencia> permanencias = [];
  int _sequencia = 1;

  EstacionamentoService(this.storage);

  Future<void> carregar() async {
    // Na inicialização, reconstruo os objetos a partir do arquivo salvo.
    // Assim, fechar o programa não apaga os cadastros feitos anteriormente.
    // O arquivo é a fonte de verdade persistida do terminal.
    final data = await storage.load();
    vagas..clear()..addAll((data['vagas'] as List? ?? []).map((e) => Vaga.fromJson(Map<String, dynamic>.from(e))));
    clientes..clear()..addAll((data['clientes'] as List? ?? []).map((e) => Cliente.fromJson(Map<String, dynamic>.from(e))));
    veiculos..clear()..addAll((data['veiculos'] as List? ?? []).map((e) => Veiculo.fromJson(Map<String, dynamic>.from(e))));
    permanencias..clear()..addAll((data['permanencias'] as List? ?? []).map((e) => Permanencia.fromJson(Map<String, dynamic>.from(e))));
    _recalcularSequencia();
  }

  void _recalcularSequencia() {
    var maiorNumero = 0;

    for (final permanencia in permanencias) {
      final numero = int.tryParse(permanencia.id.replaceFirst(RegExp(r'[^0-9]'), '')) ?? 0;
      if (numero > maiorNumero) {
        maiorNumero = numero;
      }
    }

    _sequencia = maiorNumero + 1;
  }

  Future<void> salvar() async => storage.save({
    // Cada entidade sabe virar JSON por meio de toJson().
    'vagas': vagas.map((e) => e.toJson()).toList(),
    'clientes': clientes.map((e) => e.toJson()).toList(),
    'veiculos': veiculos.map((e) => e.toJson()).toList(),
    'permanencias': permanencias.map((e) => e.toJson()).toList(),
  });

  String novoId(String prefixo) => '$prefixo${_sequencia++}';

  // ---------- VAGAS ----------
  void adicionarVaga(Vaga vaga) {
    vaga.id = vaga.id.trim().toUpperCase();
    if (vagas.any((v) => v.id.toUpperCase() == vaga.id.toUpperCase())) throw Exception('Já existe uma vaga com esse identificador.');
    vagas.add(vaga);
  }

  Vaga vaga(String id) => vagas.firstWhere((v) => v.id.toUpperCase() == id.trim().toUpperCase(), orElse: () => throw Exception('Vaga não encontrada.'));

  void atualizarVaga(String id, TipoVaga tipo, DestinacaoVaga dest, StatusVaga status) {
    final v = vaga(id);
    // Vaga ocupada não pode ser liberada por edição cadastral porque teria permanência aberta.
    if (v.status == StatusVaga.ocupada && status != StatusVaga.ocupada) throw Exception('Uma vaga ocupada não pode ser liberada/interditada pelo cadastro.');
    v.tipo = tipo; v.destinacao = dest; v.status = status;
  }

  void removerVaga(String id) {
    final v = vaga(id);
    if (v.status == StatusVaga.ocupada) throw Exception('Não é possível remover uma vaga ocupada.');
    if (permanencias.any((p) => p.vagaId == v.id && p.aberta)) throw Exception('A vaga possui permanência aberta.');
    vagas.remove(v);
  }

  // ---------- CLIENTES ----------
  void adicionarCliente(Cliente cliente) {
    cliente.id = cliente.id.trim().toUpperCase();
    cliente.documento = cliente.documento.trim();
    if (clientes.any((c) => c.id.toUpperCase() == cliente.id.toUpperCase())) throw Exception('ID de cliente já cadastrado.');
    if (clientes.any((c) => c.documento == cliente.documento)) throw Exception('Documento já cadastrado.');
    // Cliente avulso nunca deve guardar mensalidade em dia para não misturar perfis.
    if (cliente.perfil == PerfilCliente.avulso) cliente.mensalidadeEmDia = false;
    clientes.add(cliente);
  }

  Cliente cliente(String id) => clientes.firstWhere((c) => c.id.toUpperCase() == id.trim().toUpperCase(), orElse: () => throw Exception('Cliente não encontrado.'));

  void atualizarCliente(String id, String nome, String documento, String telefone, PerfilCliente perfil, bool emDia) {
    final c = cliente(id);
    if (clientes.any((x) => x.id != c.id && x.documento == documento)) throw Exception('Documento já cadastrado para outro cliente.');
    c.nome = nome; c.documento = documento; c.telefone = telefone; c.perfil = perfil; c.mensalidadeEmDia = perfil == PerfilCliente.mensalista ? emDia : false;
  }

  void removerCliente(String id) {
    final c = cliente(id);
    if (veiculos.any((v) => v.clienteId == c.id)) throw Exception('Cliente possui veículo vinculado. Remova/edite o vínculo antes.');
    clientes.remove(c);
  }

  // ---------- VEÍCULOS ----------
  void adicionarVeiculo(Veiculo v) {
    v.placa = normalizarPlaca(v.placa);
    v.clienteId = v.clienteId?.trim().toUpperCase();
    if (veiculos.any((x) => x.placa == v.placa)) throw Exception('Placa já cadastrada.');
    if (v.clienteId != null) {
      final c = cliente(v.clienteId!);
      if (c.perfil != PerfilCliente.mensalista) throw Exception('Somente veículo de mensalista pode possuir vínculo fixo.');
    }
    veiculos.add(v);
  }

  Veiculo veiculo(String placa) => veiculos.firstWhere((v) => v.placa == normalizarPlaca(placa), orElse: () => throw Exception('Veículo não encontrado.'));

  void atualizarVeiculo(String placa, String modelo, String marca, TipoVeiculo tipo, String? clienteId) {
    final v = veiculo(placa);
    final vinculo = clienteId?.trim().toUpperCase();
    if (vinculo != null && cliente(vinculo).perfil != PerfilCliente.mensalista) throw Exception('O vínculo deve ser com um mensalista.');
    v.modelo = modelo; v.marca = marca; v.tipo = tipo; v.clienteId = vinculo;
  }

  void removerVeiculo(String placa) {
    final v = veiculo(placa);
    if (permanencias.any((p) => p.placa == v.placa && p.aberta)) throw Exception('Veículo está dentro do estacionamento.');
    veiculos.remove(v);
  }

  // ---------- ENTRADA/SAÍDA ----------
  Vaga? encontrarVagaLivre(TipoVeiculo tipo, {DestinacaoVaga? preferencia}) {
    // A primeira vaga compatível e livre é suficiente para o fluxo do terminal.
    final candidatos = vagas.where((v) => v.status == StatusVaga.livre && v.compativelCom(tipo));
    if (preferencia != null) {
      final preferidas = candidatos.where((v) => v.destinacao == preferencia).toList();
      if (preferidas.isNotEmpty) return preferidas.first;
    }
    return candidatos.isEmpty ? null : candidatos.first;
  }

  Permanencia registrarEntrada({required String placa, required String vagaId, required DateTime entrada, required bool mensalista, bool ticketPerdido = false}) {
    // A entrada é o melhor ponto para validar placa, vaga, compatibilidade
    // e situação da mensalidade antes de alterar o estado do estacionamento.
    final v = veiculo(placa);
    final vagaEscolhida = vaga(vagaId);
    if (permanencias.any((p) => p.placa == v.placa && p.aberta)) throw Exception('Este veículo já está no estacionamento.');
    if (vagaEscolhida.status != StatusVaga.livre) throw Exception('A vaga não está livre.');
    if (!vagaEscolhida.compativelCom(v.tipo)) throw Exception('A vaga é incompatível com o tipo do veículo.');

    final perfil = mensalista ? PerfilCliente.mensalista : PerfilCliente.avulso;
    if (mensalista) {
      if (v.clienteId == null) throw Exception('Veículo não possui mensalista vinculado.');
      final c = cliente(v.clienteId!);
      // Mensalista só entra com a cobrança em dia, mantendo a regra comercial do sistema.
      if (c.perfil != PerfilCliente.mensalista || !c.mensalidadeEmDia) throw Exception('Mensalidade não está em dia.');
    }

    final p = Permanencia(id: novoId('P'), placa: v.placa, vagaId: vagaEscolhida.id, perfil: enumName(perfil), entrada: entrada);
    vagaEscolhida.status = StatusVaga.ocupada;
    permanencias.add(p);
    return p;
  }

  double finalizarSaida(String permanenciaId, DateTime saida, {required bool ticketPerdido}) {
    // Na saída, calculo o valor, encerro a permanência e devolvo a vaga ao estoque.
    final p = permanencias.firstWhere((x) => x.id == permanenciaId, orElse: () => throw Exception('Permanência não encontrada.'));
    if (!p.aberta) throw Exception('Essa permanência já foi encerrada.');
    if (saida.isBefore(p.entrada)) throw Exception('A saída não pode ser anterior à entrada.');
    final v = vaga(p.vagaId);
    final veic = veiculo(p.placa);
    final clienteDoVeiculo = veic.clienteId == null ? null : cliente(veic.clienteId!);

    if (p.perfil == enumName(PerfilCliente.mensalista)) {
      // Mensalista regulariza a saída sem tarifa, desde que o cadastro continue válido.
      if (clienteDoVeiculo == null || !clienteDoVeiculo.mensalidadeEmDia) throw Exception('Mensalidade não está em dia.');
      p.valor = 0;
    } else {
      p.ticketPerdido = ticketPerdido;
      p.valor = calcularValor(p.entrada, saida, v, veic.tipo, ticketPerdido);
    }

    p.saida = saida;
    v.status = StatusVaga.livre;
    return p.valor;
  }

  double calcularValor(DateTime entrada, DateTime saida, Vaga vaga, TipoVeiculo veiculo, bool ticketPerdido) {
    // Primeiro aplico a tolerância; depois calculo horas cheias e consulto
    // a combinação de vaga, veículo e período do dia.
    final minutos = saida.difference(entrada).inMinutes;
    const tolerancia = 15;
    if (minutos <= tolerancia) return ticketPerdido ? 20.0 : 0.0;
    final horas = (minutos / 60).ceil();
    final periodo = entrada.hour >= 6 && entrada.hour < 18 ? PeriodoDia.diurno : PeriodoDia.noturno;

    // A tabela abaixo é a regra tarifária central do projeto e fica concentrada aqui.
    double base = switch ((vaga.tipo, veiculo, periodo)) {
      (TipoVaga.coberta, TipoVeiculo.moto, PeriodoDia.diurno) => 5.0,
      (TipoVaga.coberta, TipoVeiculo.moto, PeriodoDia.noturno) => 6.0,
      (TipoVaga.coberta, TipoVeiculo.carro, PeriodoDia.diurno) => 8.0,
      (TipoVaga.coberta, TipoVeiculo.carro, PeriodoDia.noturno) => 10.0,
      (TipoVaga.coberta, TipoVeiculo.utilitario, PeriodoDia.diurno) => 10.0,
      (TipoVaga.coberta, TipoVeiculo.utilitario, PeriodoDia.noturno) => 12.0,
      (TipoVaga.descoberta, TipoVeiculo.moto, PeriodoDia.diurno) => 4.0,
      (TipoVaga.descoberta, TipoVeiculo.moto, PeriodoDia.noturno) => 5.0,
      (TipoVaga.descoberta, TipoVeiculo.carro, PeriodoDia.diurno) => 6.0,
      (TipoVaga.descoberta, TipoVeiculo.carro, PeriodoDia.noturno) => 8.0,
      (TipoVaga.descoberta, TipoVeiculo.utilitario, PeriodoDia.diurno) => 8.0,
      (TipoVaga.descoberta, TipoVeiculo.utilitario, PeriodoDia.noturno) => 10.0,
    };
    final taxaPerda = ticketPerdido ? 20.0 : 0.0;
    return horas * base + taxaPerda;
  }

  static String normalizarPlaca(String placa) => placa.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}
