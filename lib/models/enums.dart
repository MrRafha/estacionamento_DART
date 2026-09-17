enum TipoVaga { coberta, descoberta }
enum DestinacaoVaga { comum, preferencial, moto }
enum TipoVeiculo { carro, moto, utilitario }
enum PerfilCliente { avulso, mensalista }
enum StatusVaga { livre, ocupada, interditada }

enum PeriodoDia { diurno, noturno }

String enumName(Object value) => value.toString().split('.').last;

TipoVaga tipoVagaFrom(String value) => TipoVaga.values.firstWhere((e) => enumName(e) == value);
DestinacaoVaga destinacaoFrom(String value) => DestinacaoVaga.values.firstWhere((e) => enumName(e) == value);
TipoVeiculo tipoVeiculoFrom(String value) => TipoVeiculo.values.firstWhere((e) => enumName(e) == value);
PerfilCliente perfilFrom(String value) => PerfilCliente.values.firstWhere((e) => enumName(e) == value);
StatusVaga statusVagaFrom(String value) => StatusVaga.values.firstWhere((e) => enumName(e) == value);

String labelTipoVaga(TipoVaga v) => v == TipoVaga.coberta ? 'Coberta' : 'Descoberta';
String labelDestinacao(DestinacaoVaga v) => switch (v) { DestinacaoVaga.comum => 'Comum', DestinacaoVaga.preferencial => 'Preferencial', DestinacaoVaga.moto => 'Moto' };
String labelTipoVeiculo(TipoVeiculo v) => switch (v) { TipoVeiculo.carro => 'Carro', TipoVeiculo.moto => 'Moto', TipoVeiculo.utilitario => 'Utilitário' };
String labelPerfil(PerfilCliente p) => p == PerfilCliente.avulso ? 'Avulso' : 'Mensalista';
String labelStatus(StatusVaga s) => switch (s) { StatusVaga.livre => 'Livre', StatusVaga.ocupada => 'Ocupada', StatusVaga.interditada => 'Interditada' };
String labelPeriodo(PeriodoDia p) => p == PeriodoDia.diurno ? 'Diurno' : 'Noturno';
