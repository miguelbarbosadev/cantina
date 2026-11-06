import 'package:flutter/material.dart';

/// Tamanho do pedido — enum usado no grupo de Radio (aula 08).
enum Tamanho { pequeno, medio, grande }

extension TamanhoInfo on Tamanho {
  String get label => switch (this) {
        Tamanho.pequeno => 'Pequeno',
        Tamanho.medio => 'Médio',
        Tamanho.grande => 'Grande',
      };

  double get acrescimo => switch (this) {
        Tamanho.pequeno => 0,
        Tamanho.medio => 3,
        Tamanho.grande => 6,
      };

  static Tamanho fromName(String? name) =>
      Tamanho.values.firstWhere((t) => t.name == name, orElse: () => Tamanho.medio);
}

class Adicional {
  final String nome;
  final double preco;
  const Adicional(this.nome, this.preco);
}

class Produto {
  final String nome;
  final String descricao;
  final double preco;
  final String imagemUrl;
  final IconData icone;
  final List<Adicional> adicionais;

  const Produto({
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.imagemUrl,
    required this.icone,
    required this.adicionais,
  });
}

String reais(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

const produtos = <Produto>[
  Produto(
    nome: 'X-Burguer da Casa',
    descricao: 'Pão brioche, hambúrguer 150 g, queijo prato, alface e tomate.',
    preco: 18.90,
    imagemUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80&auto=format',
    icone: Icons.lunch_dining,
    adicionais: [
      Adicional('Bacon', 4.00),
      Adicional('Queijo extra', 3.00),
      Adicional('Ovo', 2.50),
      Adicional('Batata frita', 6.00),
    ],
  ),
  Produto(
    nome: 'Pizza Brotinho',
    descricao: 'Massa fina, molho de tomate artesanal e muçarela.',
    preco: 15.00,
    imagemUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&q=80&auto=format',
    icone: Icons.local_pizza,
    adicionais: [
      Adicional('Calabresa', 3.50),
      Adicional('Borda recheada', 5.00),
      Adicional('Azeitona', 1.50),
    ],
  ),
  Produto(
    nome: 'Salada Bowl',
    descricao: 'Mix de folhas, grão-de-bico, legumes assados e molho da casa.',
    preco: 16.50,
    imagemUrl:
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80&auto=format',
    icone: Icons.eco,
    adicionais: [
      Adicional('Frango grelhado', 5.00),
      Adicional('Ovo cozido', 2.00),
      Adicional('Croutons', 1.50),
    ],
  ),
  Produto(
    nome: 'Café Expresso',
    descricao: 'Grãos 100% arábica, moídos na hora.',
    preco: 6.00,
    imagemUrl:
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600&q=80&auto=format',
    icone: Icons.coffee,
    adicionais: [
      Adicional('Leite vaporizado', 2.00),
      Adicional('Chantilly', 2.50),
      Adicional('Pão de queijo', 4.00),
    ],
  ),
];
