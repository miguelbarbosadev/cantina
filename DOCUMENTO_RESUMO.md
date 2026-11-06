# Trabalho NP2 — Desenvolvimento Mobile

**Aplicativo:** Cantina UNIP
**Tema:** Sugestão A — Cantina da faculdade (delivery)

**Objetivo:** permitir que alunos montem pedidos da cantina pelo celular — escolhendo produto, tamanho e adicionais — com entrega no endereço informado e acompanhamento dos pedidos em tempo real na nuvem.

## Integrantes e papéis

| Integrante | Papel | Partes do código |
|---|---|---|
| _Nome 1_ | Coordenação e integração | `main.dart`, `theme.dart`, integração final |
| _Nome 2_ | Interface e layout (aulas 01–04) | `home_page.dart` (banner com Stack, cards, imagens) |
| _Nome 3_ | Navegação e formulário (aulas 05–08) | `pedido_form_page.dart` (TextFields, Radio, Checkbox, setState) |
| _Nome 4_ | Dados e Firebase (aula 09) | `firebase_options.dart`, `_salvar()`, `pedidos_page.dart` |
| _Nome 5_ | Recurso adicional e qualidade | `viacep_service.dart`, checklist RF01–RF09 |

## Recurso adicional: consumo de API REST (pacote `http` + ViaCEP)

**Justificativa:** o formulário de entrega precisa de endereço; consultar o CEP reduz digitação e erros de preenchimento, e integra o recurso diretamente ao requisito do formulário. Funciona no Chrome sem configuração extra (o ViaCEP libera CORS) e introduz conceitos não vistos em aula: requisição HTTP assíncrona (`async/await`), `Future`, parse de JSON com `dart:convert` e tratamento de erro.

**Como funciona:** ao digitar o 8º dígito no campo CEP (`onChanged`), o app chama `https://viacep.com.br/ws/{cep}/json/`, converte a resposta em um objeto `Endereco` e preenche rua, bairro e cidade pelos `TextEditingController`. Um indicador de carregamento aparece no campo durante a consulta; CEP inexistente (`"erro": true`) exibe mensagem.

**Dificuldades encontradas:** _(preencher — ex.: ViaCEP retorna 200 mesmo para CEP inexistente, sendo preciso checar o campo `erro`; atualizar a tela após o `await` exigiu verificar `mounted`)._

**Fontes:**
- ViaCEP — https://viacep.com.br
- Pacote http — https://pub.dev/packages/http
- Flutter: Fetch data from the internet — https://docs.flutter.dev/cookbook/networking/fetch-data
- dart:convert — https://api.dart.dev/stable/dart-convert/dart-convert-library.html
