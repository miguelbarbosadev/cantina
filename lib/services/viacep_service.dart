// Recurso adicional (RF09): consumo de API REST com o pacote http.
// Fonte: https://viacep.com.br  |  https://pub.dev/packages/http
import 'dart:convert';

import 'package:http/http.dart' as http;

class Endereco {
  final String rua;
  final String bairro;
  final String cidade;
  final String uf;

  const Endereco({
    required this.rua,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) => Endereco(
        rua: json['logradouro'] ?? '',
        bairro: json['bairro'] ?? '',
        cidade: json['localidade'] ?? '',
        uf: json['uf'] ?? '',
      );
}

class ViaCepService {
  /// Retorna o endereço do CEP ou `null` se for inválido/inexistente.
  static Future<Endereco?> buscar(String cep) async {
    final digitos = cep.replaceAll(RegExp(r'\D'), '');
    if (digitos.length != 8) return null;

    final resposta = await http.get(Uri.parse('https://viacep.com.br/ws/$digitos/json/'));
    if (resposta.statusCode != 200) return null;

    final json = jsonDecode(resposta.body) as Map<String, dynamic>;
    if (json.containsKey('erro')) return null; // CEP inexistente

    return Endereco.fromJson(json);
  }
}
