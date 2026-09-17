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

##para apresentação

Este projeto é um sistema de estacionamento feito em Dart para funcionar no terminal. A ideia principal foi organizar o cadastro das vagas, clientes e veículos e, a partir desses cadastros, controlar o momento em que um veículo entra e sai do estacionamento.

O fluxo mais importante é a permanência. Na entrada, o sistema identifica o veículo, procura uma vaga livre compatível e valida se ele já não está estacionado. Na saída, a busca pode ser feita pela placa, o horário atual pode ser usado automaticamente e o sistema calcula o valor, libera a vaga e registra a movimentação. Isso deixa o uso mais próximo da rotina de um estacionamento real.

Também foram aplicadas algumas regras de negócio: mensalistas precisam estar com a mensalidade em dia, motos só ocupam vagas destinadas a motos, a cobrança considera tolerância de 15 minutos e o valor varia conforme o tipo de vaga, o veículo e o período do dia. Essas validações ficam concentradas no serviço principal, evitando que cada tela tenha que repetir as mesmas regras.

Uma decisão importante foi separar o programa em partes. Os modelos representam as entidades, o App cuida da interação com o usuário, o `EstacionamentoService` concentra as regras e o `StorageService` salva os dados em JSON. Assim, os dados continuam disponíveis depois que o programa é fechado, sem depender de um banco de dados externo. Para a apresentação, posso demonstrar o cadastro de uma vaga e de um veículo, registrar uma entrada, consultar a ocupação e finalizar a saída mostrando o cálculo da tarifa.

## Observação sobre as tarifas
Como o enunciado não fornece valores, o projeto adota valores demonstrativos. Eles ficam centralizados no método `calcularValor()` de `lib/services/estacionamento_service.dart`, facilitando a alteração para os valores definidos pelo professor.

## Entidades
1. Vaga
2. Cliente
3. Veículo
4. Permanência

Relacionamentos principais: Cliente → Veículo → Permanência → Vaga.
