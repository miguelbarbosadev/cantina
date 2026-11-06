import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/produto.dart';
import '../services/viacep_service.dart';
import '../theme.dart';
import 'home_page.dart' show ProdutoImagem;
import 'pedidos_page.dart';

/// Página 2 — Formulário do pedido (aulas 05 a 09 + ViaCEP).
/// Recebe o [produto] escolhido na HomePage (passagem de parâmetro).
class PedidoFormPage extends StatefulWidget {
  final Produto produto;
  const PedidoFormPage({super.key, required this.produto});

  @override
  State<PedidoFormPage> createState() => _PedidoFormPageState();
}

class _PedidoFormPageState extends State<PedidoFormPage> {
  // TextFields controlados (aula 07). Valores iniciais agilizam a demonstração.
  final _nomeCtrl = TextEditingController(text: 'Aluno Teste');
  final _cepCtrl = TextEditingController();
  final _ruaCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController(text: '100');
  final _bairroCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  // Estado do formulário (aulas 06 e 08)
  Tamanho _tamanho = Tamanho.medio;
  final Set<Adicional> _adicionais = {};
  bool _paraViagem = false;
  String _nomeAoVivo = 'Aluno Teste';

  bool _buscandoCep = false;
  String? _cepMensagem;
  bool _salvando = false;

  double get _total =>
      widget.produto.preco +
      _tamanho.acrescimo +
      _adicionais.fold<double>(0, (soma, a) => soma + a.preco);

  @override
  void dispose() {
    for (final c in [
      _nomeCtrl,
      _cepCtrl,
      _ruaCtrl,
      _numeroCtrl,
      _bairroCtrl,
      _cidadeCtrl,
      _obsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- ViaCEP (recurso adicional) ----------
  void _onCepChanged(String valor) {
    final digitos = valor.replaceAll(RegExp(r'\D'), '');
    if (digitos.length == 8) _buscarCep(digitos);
  }

  Future<void> _buscarCep(String cep) async {
    setState(() {
      _buscandoCep = true;
      _cepMensagem = null;
    });
    try {
      final end = await ViaCepService.buscar(cep);
      if (!mounted) return;
      setState(() {
        if (end == null) {
          _cepMensagem = 'CEP não encontrado';
        } else {
          _ruaCtrl.text = end.rua;
          _bairroCtrl.text = end.bairro;
          _cidadeCtrl.text = '${end.cidade}/${end.uf}';
          _cepMensagem = 'Endereço preenchido pelo ViaCEP';
        }
      });
    } catch (_) {
      if (mounted) setState(() => _cepMensagem = 'Falha ao consultar o ViaCEP');
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  // ---------- Firestore (aula 09) ----------
  Future<void> _salvar() async {
    final nome = _nomeCtrl.text.trim();
    if (nome.isEmpty ||
        _cepCtrl.text.trim().isEmpty ||
        _ruaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome, CEP e rua.')),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .add({
            'cliente': nome,
            'produto': widget.produto.nome,
            'tamanho': _tamanho.name,
            'adicionais': _adicionais.map((a) => a.nome).toList(),
            'paraViagem': _paraViagem,
            'cep': _cepCtrl.text.trim(),
            'rua': _ruaCtrl.text.trim(),
            'numero': _numeroCtrl.text.trim(),
            'bairro': _bairroCtrl.text.trim(),
            'cidade': _cidadeCtrl.text.trim(),
            'observacao': _obsCtrl.text.trim(),
            'total': _total,
            'criadoEm': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      // Passa o nome do cliente para a próxima página (aula 05)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PedidosPage(clienteDestaque: nome)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  InputDecoration _dec(
    String label,
    String hint,
    IconData icon, {
    Widget? suffix,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon),
    suffixIcon: suffix,
    border: const OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    final p = widget.produto;

    return Scaffold(
      appBar: cantinaAppBar('Montar pedido'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com o produto recebido por parâmetro
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ProdutoImagem(produto: p, width: 80, height: 80),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pedido de $_nomeAoVivo', // atualizado via onChanged + setState
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _Secao('Seus dados', Icons.person),
            TextField(
              controller: _nomeCtrl,
              decoration: _dec('Nome', 'Como devemos te chamar?', Icons.badge),
              onChanged: (v) =>
                  setState(() => _nomeAoVivo = v.isEmpty ? '...' : v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cepCtrl,
              keyboardType: TextInputType.number,
              decoration: _dec(
                'CEP',
                'Ex.: 01310-100',
                Icons.location_on,
                suffix: _buscandoCep
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _buscarCep(_cepCtrl.text),
                      ),
              ),
              onChanged: _onCepChanged,
            ),
            if (_cepMensagem != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  _cepMensagem!,
                  style: TextStyle(
                    fontSize: 12,
                    color: _cepMensagem!.startsWith('Endereço')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ruaCtrl,
                    decoration: _dec('Rua', 'Logradouro', Icons.signpost),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _numeroCtrl,
                    decoration: _dec('Nº', '100', Icons.numbers),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bairroCtrl,
                    decoration: _dec('Bairro', '', Icons.map),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cidadeCtrl,
                    decoration: _dec('Cidade', '', Icons.location_city),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Radio com enum + RadioGroup (aula 08)
            _Secao('Tamanho', Icons.straighten),
            RadioGroup<Tamanho>(
              groupValue: _tamanho,
              onChanged: (v) => setState(() => _tamanho = v ?? _tamanho),
              child: Column(
                children: [
                  for (final t in Tamanho.values)
                    RadioListTile<Tamanho>(
                      value: t,
                      title: Text(t.label),
                      secondary: Text(
                        t.acrescimo == 0 ? '—' : '+ ${reais(t.acrescimo)}',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Checkbox (aula 08)
            _Secao('Adicionais', Icons.add_circle_outline),
            for (final a in p.adicionais)
              CheckboxListTile(
                value: _adicionais.contains(a),
                title: Text(a.nome),
                secondary: Text('+ ${reais(a.preco)}'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (marcado) => setState(() {
                  marcado == true ? _adicionais.add(a) : _adicionais.remove(a);
                }),
              ),
            Row(
              children: [
                Checkbox(
                  value: _paraViagem,
                  onChanged: (v) => setState(() => _paraViagem = v ?? false),
                ),
                const Text('Embalar para viagem'),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _obsCtrl,
              maxLines: 2,
              decoration: _dec(
                'Observação',
                'Ex.: sem cebola',
                Icons.edit_note,
              ),
            ),
            const SizedBox(height: 20),

            // Total recalculado com setState (aula 06)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 18)),
                  Text(
                    reais(_total),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kLaranja,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _salvando ? null : _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: kLaranja,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: const Text(
                'Enviar pedido',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar ao cardápio'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  final IconData icone;
  const _Secao(this.titulo, this.icone);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icone, color: kLaranja),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kLaranja,
            ),
          ),
        ],
      ),
    );
  }
}
