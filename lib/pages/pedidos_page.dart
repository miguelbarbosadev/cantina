import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/produto.dart';
import '../theme.dart';

/// Página 3 — Pedidos em tempo real (aula 09).
/// [clienteDestaque] chega da página do formulário (passagem de parâmetro).
class PedidosPage extends StatelessWidget {
  final String? clienteDestaque;
  const PedidosPage({super.key, this.clienteDestaque});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('pedidos')
        .orderBy('criadoEm', descending: true)
        .snapshots();

    return Scaffold(
      appBar: cantinaAppBar('Pedidos na nuvem'),
      body: Column(
        children: [
          if (clienteDestaque != null)
            Container(
              width: double.infinity,
              color: Colors.green.shade50,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pedido de $clienteDestaque enviado com sucesso!',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.black26),
                        SizedBox(height: 8),
                        Text('Nenhum pedido ainda.'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 8),
                  itemCount: docs.length,
                  itemBuilder: (_, i) => _PedidoTile(
                    dados: docs[i].data(),
                    destaque: docs[i].data()['cliente'] == clienteDestaque,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        backgroundColor: kLaranja,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.restaurant_menu),
        label: const Text('Cardápio'),
      ),
    );
  }
}

class _PedidoTile extends StatelessWidget {
  final Map<String, dynamic> dados;
  final bool destaque;
  const _PedidoTile({required this.dados, required this.destaque});

  @override
  Widget build(BuildContext context) {
    final tamanho = TamanhoInfo.fromName(dados['tamanho'] as String?);
    final adicionais = List<String>.from(dados['adicionais'] ?? const []);
    final total = (dados['total'] as num?)?.toDouble() ?? 0;
    final ts = dados['criadoEm'] as Timestamp?;
    final hora = ts == null
        ? 'agora'
        : '${ts.toDate().hour.toString().padLeft(2, '0')}:${ts.toDate().minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: destaque
          ? RoundedRectangleBorder(
              side: const BorderSide(color: kLaranja, width: 2),
              borderRadius: BorderRadius.circular(12))
          : null,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFE0B2),
          child: Icon(Icons.fastfood, color: kLaranja),
        ),
        title: Text('${dados['produto']} (${tamanho.label})',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${dados['cliente']} • ${dados['rua']}, ${dados['numero']} - ${dados['bairro']}'
          '${adicionais.isEmpty ? '' : '\n+ ${adicionais.join(', ')}'}'
          '${dados['paraViagem'] == true ? '\nPara viagem' : ''}',
        ),
        isThreeLine: adicionais.isNotEmpty || dados['paraViagem'] == true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(reais(total),
                style: const TextStyle(fontWeight: FontWeight.bold, color: kLaranja)),
            Text(hora, style: const TextStyle(fontSize: 12, color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}
