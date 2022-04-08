 convert_Metros_Km(double valor, int divisor) {
    String distanciaString = '';
    double distanciaKm = 0.0;
    double distanciaConvertida = 0.0;
    valor = valor / divisor;
    if (valor >= 1) {
      distanciaKm = valor;
      distanciaConvertida = double.parse(distanciaKm.toStringAsFixed(2));
      distanciaString = ' ${distanciaConvertida.toDouble()} KM';
    } else {
      valor = valor * 1000;
      num distanciaConvertida = num.parse(valor.toStringAsPrecision(2));
      distanciaString = '${valor.toInt()} Metros';
    }

    return distanciaString;
  }