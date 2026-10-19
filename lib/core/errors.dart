/// Hierarquia de falhas trataveis da aplicacao.
sealed class AppFailure {
  const AppFailure(this.message);
  final String message;

  String get userMessage => message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
  @override
  String get userMessage =>
      'Falha de conexao. Verifique sua internet e tente novamente.';
}

class PlaylistParseFailure extends AppFailure {
  const PlaylistParseFailure(super.message);
  @override
  String get userMessage =>
      'Nao foi possivel ler a playlist. Verifique se o endereco ou arquivo e valido.';
}

class PlaylistEmptyFailure extends AppFailure {
  const PlaylistEmptyFailure()
      : super('A playlist foi importada mas nao contem itens validos.');
}

class PlaybackFailure extends AppFailure {
  const PlaybackFailure(super.message);
  @override
  String get userMessage =>
      'Nao foi possivel reproduzir este conteudo. A transmissao pode estar indisponivel ou em formato nao suportado.';
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([String message = 'Erro inesperado.']) : super(message);
}
