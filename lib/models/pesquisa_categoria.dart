class registro_categoria {
  final String nome_categoria;
  final String cor_categoria;
  final String icone_categoria;

  registro_categoria(
      this.nome_categoria, this.cor_categoria, this.icone_categoria);

  bool operator ==(o) =>
      o is registro_categoria && o.nome_categoria == nome_categoria;
  int get hashCode => nome_categoria.hashCode;
}

class registro_categoria_Nome {
  final String nome_categoria;
  registro_categoria_Nome(
      this.nome_categoria);

  bool operator ==(o) =>
      o is registro_categoria_Nome && o.nome_categoria == nome_categoria;
  int get hashCode => nome_categoria.hashCode;
}
