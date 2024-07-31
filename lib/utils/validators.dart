//validar a senha
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Senha é obrigatória';
  }

  // Checar comprimento
  if (value.length < 8) {
    return 'A senha deve ter no mínimo 8 caracteres';
  }

  // Checar letra maiúscula
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'A senha deve conter pelo menos uma letra maiúscula';
  }

  // Checar número
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'A senha deve conter pelo menos um número';
  }

  // Checar símbolo
  if (!RegExp(r'[$*&@#]').hasMatch(value)) {
    return 'A senha deve conter pelo menos um símbolo (\$*&@#)';
  }

  // Checar sequências iguais
  if (RegExp(r'(.)\1{1,}').hasMatch(value)) {
    return 'A senha não pode conter sequências iguais';
  }

  return null; // Senha válida
}

//validar o email
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email é obrigatório';
  }

  // Verificar se o email possui espaços
  if (value.contains(' ')) {
    return 'O email não pode conter espaços';
  }

  // Expressão regular para validar o formato do email
  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  if (!emailRegex.hasMatch(value)) {
    return 'Email inválido';
  }

  return null; // Email válido
}