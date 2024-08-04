import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos e Condições'),
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '''Bem-vindo ao AutoResc. Ao usar nosso aplicativo, você concorda em cumprir e estar sujeito aos seguintes termos e condições. Por favor, leia-os cuidadosamente.

## Aceitação dos Termos
Ao acessar ou usar o AutoResc, você concorda em obedecer a estes Termos e Condições e a todas as leis e regulamentos aplicáveis. Se você não concordar com algum destes termos, não use nosso App.

## Modificações aos Termos
Reservamo-nos o direito de revisar e alterar estes Termos e Condições a qualquer momento. Quaisquer mudanças serão publicadas nesta página, e o uso contínuo do App após tais alterações constitui aceitação dos novos termos.

## Cadastro e Contas
Para usar as funcionalidades do App, você será  solicitado a registrar uma conta. Você deve fornecer informações precisas e completas e manter essas informações atualizadas. Você é responsável por manter a confidencialidade de sua conta e senha.

## Privacidade
Sua privacidade é importante para nós. Por favor, reveja nossa Política de Privacidade para entender como coletamos, usamos e compartilhamos suas informações.

## Uso Aceitável
Você concorda em usar o App apenas para fins legais e de acordo com estes Termos e Condições. Você concorda em não usar o App de qualquer maneira que possa danificar, desativar, sobrecarregar ou prejudicar o App ou interferir no uso de qualquer outra parte.

## Limitação de Responsabilidade
Na máxima extensão permitida pela lei aplicável, em nenhuma circunstância o AutoResc será responsável por quaisquer danos indiretos, incidentais, especiais, consequenciais ou punitivos, ou quaisquer perdas de lucros ou receitas.

## Indenização
Você concorda em indenizar e isentar o AutoResc, seus diretores, funcionários e agentes de qualquer reclamação, dano, obrigação, perda, responsabilidade, custo ou dívida, e despesas decorrentes de seu uso do App ou violação destes Termos.

## Rescisão
Podemos rescindir ou suspender seu acesso ao App imediatamente, sem aviso prévio ou responsabilidade, se você violar estes Termos e Condições.

## Lei Aplicável
Estes Termos e Condições serão regidos e interpretados de acordo com as leis do Brasil, sem considerar suas disposições sobre conflitos de leis.

## Contate-nos
Se você tiver alguma dúvida sobre estes Termos e Condições, entre em contato conosco em autoresc@gmail.com.
''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
