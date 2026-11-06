import 'package:flutter/material.dart';

import '../models/produto.dart';
import '../theme.dart';
import 'pedido_form_page.dart';
import 'pedidos_page.dart';

/// Página 1 — Cardápio (aulas 01 a 05).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _abrirPedidos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PedidosPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cantinaAppBar(
        'Cantina UNIP',
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Pedidos',
            onPressed: () => _abrirPedidos(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Banner(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Cardápio de hoje',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kLaranja),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Toque em um item para montar seu pedido.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 8),
            for (final p in produtos) _ProdutoCard(produto: p),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirPedidos(context),
        backgroundColor: kLaranja,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.delivery_dining),
        label: const Text('Ver pedidos'),
      ),
    );
  }
}

/// Banner com Stack + Positioned (aula 04) e Image.asset (aula 03).
class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/banner.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
          ),
          const Positioned(
            left: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fome entre as aulas?',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Entrega no campus em até 20 min',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProdutoCard extends StatelessWidget {
  final Produto produto;
  const _ProdutoCard({required this.produto});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Navegação com passagem de parâmetro (aula 05)
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PedidoFormPage(produto: produto)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProdutoImagem(produto: produto, width: 110, height: 110),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      produto.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reais(produto.preco),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: kLaranja),
                        ),
                        const Icon(Icons.add_shopping_cart, color: kLaranja),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Image.network com BoxFit.cover e fallback para ícone se a rede falhar.
class ProdutoImagem extends StatelessWidget {
  final Produto produto;
  final double width;
  final double height;
  const ProdutoImagem({super.key, required this.produto, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      produto.imagemUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : SizedBox(
              width: width,
              height: height,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: const Color(0xFFFFE0B2),
        child: Icon(produto.icone, size: width * 0.45, color: kLaranja),
      ),
    );
  }
}
