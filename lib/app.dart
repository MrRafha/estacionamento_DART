import 'models/cliente.dart';
import 'models/enums.dart';
import 'models/vaga.dart';
import 'models/veiculo.dart';
import 'services/estacionamento_service.dart';
import 'utils/input.dart';

class App {
  final EstacionamentoService service;
  App(this.service);

  Future<void> iniciar() async {
    // Se a carga falhar, o sistema continua aberto para permitir uso em memória.
    try {
      await service.carregar();
      print('\n SISTEMA DE ESTACIONAMENTO');
      print('Dados carregados com sucesso.');
    } catch (e) {
      print('  Não foi possível carregar os dados: $e');
    }

    var sair = false;
    while (!sair) {
      try {
        imprimirResumo();
        switch (menu('MENU PRINCIPAL', ['Operação do dia', 'Vagas', 'Clientes', 'Veículos', 'Relatórios', 'Sair'])) {
          case 1: await menuOperacao(); break;
          case 2: await menuVagas(); break;
          case 3: await menuClientes(); break;
          case 4: await menuVeiculos(); break;
          case 5: menuRelatorios(); break;
          case 6: sair = true;
        }
      } on EntradaEncerradaException {
        sair = true;
      } catch (e) {
        print('❌ $e');
      }
    }
    print('\nAté logo!');
  }

  Future<void> menuVagas() async {
    switch (menu('CADASTRO DE VAGAS', ['Cadastrar', 'Listar', 'Alterar', 'Interditar/Liberar', 'Excluir', 'Voltar'])) {
      case 1:
        await cadastrarVaga();
        break;
      case 2:
        listarVagas();
        break;
      case 3:
        await alterarVaga();
        break;
      case 4:
        await alternarStatusVaga();
        break;
      case 5:
        await excluirVaga();
        break;
    }
  }

  Future<void> menuClientes() async {
    switch (menu('CADASTRO DE CLIENTES', ['Cadastrar', 'Listar', 'Alterar', 'Excluir', 'Voltar'])) {
      case 1:
        await cadastrarCliente();
        break;
      case 2:
        listarClientes();
        break;
      case 3:
        await alterarCliente();
        break;
      case 4:
        await excluirCliente();
        break;
    }
  }

  Future<void> menuVeiculos() async {
    switch (menu('CADASTRO DE VEÍCULOS', ['Cadastrar', 'Listar', 'Alterar', 'Excluir', 'Voltar'])) {
      case 1:
        await cadastrarVeiculo();
        break;
      case 2:
        listarVeiculos();
        break;
      case 3:
        await alterarVeiculo();
        break;
      case 4:
        await excluirVeiculo();
        break;
    }
  }

  Future<void> menuOperacao() async {
    switch (menu('OPERAÇÃO DO DIA', ['Registrar entrada', 'Registrar saída', 'Veículos estacionados', 'Vagas disponíveis', 'Voltar'])) {
      case 1:
        await registrarEntrada();
        break;
      case 2:
        await registrarSaida();
        break;
      case 3:
        listarVeiculosNoEstacionamento();
        break;
      case 4:
        listarVagasDisponiveis();
        break;
    }
  }

  void imprimirResumo() {
    final ocupadas = service.vagas.where((vaga) => vaga.status == StatusVaga.ocupada).length;
    final livres = service.vagas.where((vaga) => vaga.status == StatusVaga.livre).length;
    final faturamentoHoje = service.permanencias
        .where((permanencia) => permanencia.saida != null && _mesmoDia(permanencia.saida!, DateTime.now()))
        .fold<double>(0, (total, permanencia) => total + permanencia.valor);

    print('\nResumo: $livres vagas livres | $ocupadas ocupadas | ${service.permanencias.where((p) => p.aberta).length} veículo(s) no local | Faturamento hoje: R\$ ${faturamentoHoje.toStringAsFixed(2)}');
  }

  bool _mesmoDia(DateTime primeiro, DateTime segundo) => primeiro.year == segundo.year && primeiro.month == segundo.month && primeiro.day == segundo.day;

  void menuRelatorios() {
    switch (menu('RELATÓRIOS', ['Faturamento por período', 'Movimentações por período', 'Ocupação atual', 'Voltar'])) {
      case 1:
        relatorioFaturamentoPorPeriodo();
        break;
      case 2:
        relatorioMovimentacoesPorPeriodo();
        break;
      case 3:
        relatorioOcupacaoAtual();
        break;
    }
  }

  // ---------- VAGAS ----------

  Future<void> cadastrarVaga() async {
    final id = normalizarCodigo(lerTexto('Identificador da vaga: '));
    final tipo = escolherTipoVaga();
    final destinacao = escolherDestinacao();

    service.adicionarVaga(Vaga(id: id, tipo: tipo, destinacao: destinacao));
    await service.salvar();
    print(' Vaga cadastrada.');
  }

  Future<void> alterarVaga() async {
    final id = normalizarCodigo(lerTexto('ID da vaga: '));
    final tipo = escolherTipoVaga();
    final destinacao = escolherDestinacao();

    service.atualizarVaga(id, tipo, destinacao, service.vaga(id).status);
    await service.salvar();
    print(' Vaga alterada.');
  }

  Future<void> alternarStatusVaga() async {
    final id = normalizarCodigo(lerTexto('ID da vaga: '));
    final vaga = service.vaga(id);

    // Vaga ocupada é protegida para não quebrar a permanência aberta.
    if (vaga.status == StatusVaga.ocupada) {
      throw Exception('Vaga ocupada não pode ser interditada.');
    }

    final novoStatus = vaga.status == StatusVaga.interditada ? StatusVaga.livre : StatusVaga.interditada;
    service.atualizarVaga(id, vaga.tipo, vaga.destinacao, novoStatus);
    await service.salvar();
    print(' Status atualizado.');
  }

  Future<void> excluirVaga() async {
    final id = normalizarCodigo(lerTexto('ID da vaga: '));
    service.removerVaga(id);
    await service.salvar();
    print(' Vaga removida.');
  }

  void listarVagas() {
    if (service.vagas.isEmpty) {
      print('Nenhuma vaga cadastrada.');
      return;
    }

    print('\nID     TIPO          DESTINAÇÃO       STATUS');
    print('─' * 55);
    for (final vaga in service.vagas) {
      print('${vaga.id.padRight(7)}${labelTipoVaga(vaga.tipo).padRight(14)}${labelDestinacao(vaga.destinacao).padRight(17)}${labelStatus(vaga.status)}');
    }
  }

  void listarVagasDisponiveis() {
    final disponiveis = service.vagas.where((vaga) => vaga.status == StatusVaga.livre).toList();
    if (disponiveis.isEmpty) {
      print('Nenhuma vaga disponível no momento.');
      return;
    }

    print('\nVagas disponíveis:');
    for (final vaga in disponiveis) {
      print('${vaga.id} | ${labelTipoVaga(vaga.tipo)} | ${labelDestinacao(vaga.destinacao)}');
    }
  }

  // ---------- CLIENTES ----------

  Future<void> cadastrarCliente() async {
    final id = normalizarCodigo(lerTexto('ID: '));
    final nome = lerTexto('Nome: ');
    final documento = lerTexto('Documento: ');
    final telefone = lerTexto('Telefone: ');
    final perfil = escolherPerfil();
    final mensalidadeEmDia = perfil == PerfilCliente.mensalista ? lerSimNao('Mensalidade em dia?') : false;

    service.adicionarCliente(
      Cliente(id: id, nome: nome, documento: documento, telefone: telefone, perfil: perfil, mensalidadeEmDia: mensalidadeEmDia),
    );
    await service.salvar();
    print(' Cliente cadastrado.');
  }

  void listarClientes() {
    if (service.clientes.isEmpty) {
      print('Nenhum cliente cadastrado.');
      return;
    }

    for (final cliente in service.clientes) {
      print('${cliente.id} | ${cliente.nome} | ${cliente.documento} | ${labelPerfil(cliente.perfil)} | Mensalidade: ${cliente.mensalidadeEmDia ? 'OK' : 'Pendente'}');
    }
  }

  Future<void> alterarCliente() async {
    final id = normalizarCodigo(lerTexto('ID: '));
    final nome = lerTexto('Nome: ');
    final documento = lerTexto('Documento: ');
    final telefone = lerTexto('Telefone: ');
    final perfil = escolherPerfil();
    final mensalidadeEmDia = perfil == PerfilCliente.mensalista ? lerSimNao('Mensalidade em dia?') : false;

    service.atualizarCliente(id, nome, documento, telefone, perfil, mensalidadeEmDia);
    await service.salvar();
    print(' Cliente alterado.');
  }

  Future<void> excluirCliente() async {
    final id = normalizarCodigo(lerTexto('ID: '));
    service.removerCliente(id);
    await service.salvar();
    print(' Cliente removido.');
  }

  // ---------- VEÍCULOS ----------

  Future<void> cadastrarVeiculo({String? placaInicial}) async {
    final placa = placaInicial ?? lerTexto('Placa: ');
    final modelo = lerTexto('Modelo: ');
    final marca = lerTexto('Marca: ');
    final tipo = escolherTipoVeiculo();
    final vinculo = lerTexto('ID do mensalista (ENTER para nenhum): ', obrigatorio: false);
    final clienteId = vinculo.isEmpty ? null : normalizarCodigo(vinculo);

    service.adicionarVeiculo(Veiculo(placa: placa, modelo: modelo, marca: marca, tipo: tipo, clienteId: clienteId));
    await service.salvar();
    print(' Veículo cadastrado.');
  }

  void listarVeiculos() {
    if (service.veiculos.isEmpty) {
      print('Nenhum veículo cadastrado.');
      return;
    }

    for (final veiculo in service.veiculos) {
      print('${veiculo.placa} | ${veiculo.marca} ${veiculo.modelo} | ${labelTipoVeiculo(veiculo.tipo)} | Cliente: ${veiculo.clienteId ?? 'Avulso'}');
    }
  }

  Future<void> alterarVeiculo() async {
    final placa = lerTexto('Placa: ');
    final modelo = lerTexto('Modelo: ');
    final marca = lerTexto('Marca: ');
    final tipo = escolherTipoVeiculo();
    final vinculo = lerTexto('ID do mensalista (ENTER para nenhum): ', obrigatorio: false);
    final clienteId = vinculo.isEmpty ? null : normalizarCodigo(vinculo);

    service.atualizarVeiculo(placa, modelo, marca, tipo, clienteId);
    await service.salvar();
    print(' Veículo alterado.');
  }

  Future<void> excluirVeiculo() async {
    final placa = lerTexto('Placa: ');
    service.removerVeiculo(placa);
    await service.salvar();
    print(' Veículo removido.');
  }

  // ---------- ENTRADA / SAÍDA ----------

  Future<void> registrarEntrada() async {
    final placa = EstacionamentoService.normalizarPlaca(lerTexto('Placa: '));
    Veiculo veiculo;
    try {
      veiculo = service.veiculo(placa);
    } catch (_) {
      print('Veículo não cadastrado.');
      if (!lerSimNao('Deseja cadastrar este veículo agora?')) return;
      await cadastrarVeiculo(placaInicial: placa);
      veiculo = service.veiculo(placa);
    }
    final ehMensalista = veiculo.clienteId != null;
    final entrada = lerDataHora('Data/hora de entrada', padraoAgora: true);

    // A busca já considera tipo de veículo e disponibilidade real da vaga.
    final vaga = service.encontrarVagaLivre(veiculo.tipo);
    if (vaga == null) {
      throw Exception('Não há vaga compatível disponível.');
    }

    print('Vaga sugerida: ${vaga.id} (${labelTipoVaga(vaga.tipo)}, ${labelDestinacao(vaga.destinacao)})');
    final confirmar = lerSimNao('Confirmar esta vaga?');
    if (!confirmar) return;

    service.registrarEntrada(
      placa: placa,
      vagaId: vaga.id,
      entrada: entrada,
      mensalista: ehMensalista,
    );
    await service.salvar();
    print(' Entrada registrada na vaga ${vaga.id}.');
  }

  Future<void> registrarSaida() async {
    final placa = EstacionamentoService.normalizarPlaca(lerTexto('Placa do veículo: '));
    final permanencia = service.permanencias.firstWhere(
      (x) => x.placa == placa && x.aberta,
      orElse: () => throw Exception('Não há permanência aberta para essa placa.'),
    );

    print('Entrada registrada em ${formatarData(permanencia.entrada)} na vaga ${permanencia.vagaId}.');
    final saida = lerDataHora('Data/hora de saída', minimo: permanencia.entrada, padraoAgora: true);
    final ticketPerdido = permanencia.perfil == enumName(PerfilCliente.avulso) ? lerSimNao('Ticket perdido?') : false;

    final valor = service.finalizarSaida(permanencia.id, saida, ticketPerdido: ticketPerdido);
    await service.salvar();
    print(' Saída registrada. Valor: R\$ ${valor.toStringAsFixed(2)}');
  }

  void listarVeiculosNoEstacionamento() {
    final abertas = service.permanencias.where((permanencia) => permanencia.aberta).toList();
    if (abertas.isEmpty) {
      print('Nenhum veiculo no estacionamento.');
      return;
    }

    for (final permanencia in abertas) {
      print('${permanencia.id} | Placa: ${permanencia.placa} | Vaga: ${permanencia.vagaId} | Entrada: ${formatarData(permanencia.entrada)} | ${labelPerfil(perfilFrom(permanencia.perfil))}');
    }
  }

  // ---------- RELATORIOS ----------

  void relatorioFaturamentoPorPeriodo() {
    final inicio = lerDataHora('Inicio');
    final fim = lerDataHora('Fim', minimo: inicio);

    final total = service.permanencias
        .where((permanencia) => permanencia.saida != null && !permanencia.saida!.isBefore(inicio) && !permanencia.saida!.isAfter(fim))
        .fold<double>(0, (acumulado, permanencia) => acumulado + permanencia.valor);

    print(' Faturamento no periodo: R\$ ${total.toStringAsFixed(2)}');
  }

  void relatorioMovimentacoesPorPeriodo() {
    final inicio = lerDataHora('Inicio');
    final fim = lerDataHora('Fim', minimo: inicio);

    final lista = service.permanencias.where((permanencia) => !permanencia.entrada.isBefore(inicio) && !permanencia.entrada.isAfter(fim)).toList();
    print('\n${lista.length} movimentacao(oes):');
    for (final permanencia in lista) {
      print('${permanencia.id} | ${permanencia.placa} | ${formatarData(permanencia.entrada)} | ${permanencia.saida == null ? 'ABERTA' : formatarData(permanencia.saida!)} | R\$ ${permanencia.valor.toStringAsFixed(2)}');
    }
  }

  void relatorioOcupacaoAtual() {
    final ocupadas = service.vagas.where((vaga) => vaga.status == StatusVaga.ocupada).length;
    final livres = service.vagas.where((vaga) => vaga.status == StatusVaga.livre).length;
    final interditadas = service.vagas.where((vaga) => vaga.status == StatusVaga.interditada).length;

    print('Ocupadas: $ocupadas | Livres: $livres | Interditadas: $interditadas | Total: ${service.vagas.length}');
  }

  // ---------- AJUDANTES DE LEITURA ----------

  TipoVaga escolherTipoVaga() {
    final escolha = menu('TIPO DE VAGA', ['Coberta', 'Descoberta']);
    return escolha == 1 ? TipoVaga.coberta : TipoVaga.descoberta;
  }

  DestinacaoVaga escolherDestinacao() {
    final escolha = menu('DESTINAÇÃO', ['Comum', 'Preferencial', 'Moto']);
    return DestinacaoVaga.values[escolha - 1];
  }

  TipoVeiculo escolherTipoVeiculo() {
    final escolha = menu('TIPO DE VEÍCULO', ['Carro', 'Moto', 'Utilitário']);
    return TipoVeiculo.values[escolha - 1];
  }

  PerfilCliente escolherPerfil() {
    final escolha = menu('PERFIL', ['Avulso', 'Mensalista']);
    return escolha == 1 ? PerfilCliente.avulso : PerfilCliente.mensalista;
  }

  String normalizarCodigo(String valor) => valor.trim().toUpperCase();

  String formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
}
