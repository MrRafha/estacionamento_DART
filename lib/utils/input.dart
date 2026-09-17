import 'dart:io';

String lerTexto(String mensagem, {bool obrigatorio = true}) {
  while (true) {
    stdout.write(mensagem);
    final valor = stdin.readLineSync()?.trim() ?? '';
    if (!obrigatorio || valor.isNotEmpty) return valor;
    print('⚠️  Campo obrigatório.');
  }
}

int lerInt(String mensagem, {int? min, int? max}) {
  while (true) {
    final texto = lerTexto(mensagem);
    final valor = int.tryParse(texto);
    if (valor != null && (min == null || valor >= min) && (max == null || valor <= max)) return valor;
    print('⚠️  Informe um número válido${min != null ? ' a partir de $min' : ''}${max != null ? ' até $max' : ''}.');
  }
}

double lerDouble(String mensagem, {double? min}) {
  while (true) {
    final texto = lerTexto(mensagem).replaceAll(',', '.');
    final valor = double.tryParse(texto);
    if (valor != null && (min == null || valor >= min)) return valor;
    print('⚠️  Informe um valor válido.');
  }
}

bool lerSimNao(String mensagem) {
  while (true) {
    final valor = lerTexto('$mensagem (S/N): ').toUpperCase();
    if (valor == 'S') return true;
    if (valor == 'N') return false;
    print('⚠️  Digite S ou N.');
  }
}

DateTime lerDataHora(String mensagem, {DateTime? minimo}) {
  while (true) {
    final texto = lerTexto('$mensagem (DD/MM/AAAA HH:MM): ');
    final partes = texto.split(RegExp(r'[ T]'));
    if (partes.length == 2) {
      final d = partes[0].split('/');
      final h = partes[1].split(':');
      if (d.length == 3 && h.length >= 2) {
        final dia = int.tryParse(d[0]);
        final mes = int.tryParse(d[1]);
        final ano = int.tryParse(d[2]);
        final hora = int.tryParse(h[0]);
        final minuto = int.tryParse(h[1]);
        if (dia != null && mes != null && ano != null && hora != null && minuto != null) {
          final dt = DateTime(ano, mes, dia, hora, minuto);
          final dataValida = dt.year == ano && dt.month == mes && dt.day == dia && dt.hour == hora && dt.minute == minuto;
          if (dataValida && (minimo == null || !dt.isBefore(minimo))) return dt;
        }
      }
    }
    print('⚠️  Data/hora inválida. Use DD/MM/AAAA HH:MM.');
  }
}

int menu(String titulo, List<String> opcoes) {
  // Menu simples e previsível: sempre numerado de 1 até N.
  print('\n╔══════════════════════════════════════╗');
  print('║ ${titulo.padRight(36)} ║');
  print('╚══════════════════════════════════════╝');
  for (var i = 0; i < opcoes.length; i++) print('${i + 1}. ${opcoes[i]}');
  return lerInt('Escolha: ', min: 1, max: opcoes.length);
}
