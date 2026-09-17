# Sistema de Estacionamento — Dart

Projeto de terminal, sem dependências externas.

## Requisitos atendidos
- Menu principal em laço de repetição.
- CRUD de Vagas, Clientes e Veículos.
- Permanências/entradas e saídas como quarta entidade relacionada.
- Mensalistas e avulsos.
- Compatibilidade entre vaga e tipo de veículo.
- Vagas livres, ocupadas e interditadas.
- Cobrança por hora cheia/fração, tolerância de 15 minutos e taxa de R$ 20 por ticket perdido.
- Tarifas diferentes por tipo de vaga, veículo e período diurno/noturno.
- Verificação de mensalidade em dia.
- Manipulação de `DateTime`.
- Relatórios com filtro por período.
- Persistência em `data/estacionamento.txt` usando JSON dentro de arquivo `.txt`.
- Tratamento de exceções e validações de entrada.

## Executar
```bash
dart pub get
dart run bin/main.dart
```

As datas e horas informadas no terminal usam o formato brasileiro `DD/MM/AAAA HH:MM`.

## Observação sobre as tarifas
Como o enunciado não fornece valores, o projeto adota valores demonstrativos. Eles ficam centralizados no método `calcularValor()` de `lib/services/estacionamento_service.dart`, facilitando a alteração para os valores definidos pelo professor.

## Entidades
1. Vaga
2. Cliente
3. Veículo
4. Permanência

Relacionamentos principais: Cliente → Veículo → Permanência → Vaga.
