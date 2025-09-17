import 'package:intl/intl.dart';

class NumberFormatter {
  // Para Costa Rica usa punto como separador de miles
  static final NumberFormat _costaRicaFormat = NumberFormat('#,##0', 'es_CR');
  
  // Alternativa con punto (más común en Costa Rica)
  // ignore: unused_field
  static final NumberFormat _pointFormat = NumberFormat.decimalPattern('es_CR');
  
  /// Formatea un número con separador de miles usando punto
  static String formatCurrency(double amount) {
    return _costaRicaFormat.format(amount.round()).replaceAll(',', '.');
  }
  
  /// Formatea con coma (estilo internacional)
  static String formatCurrencyWithComma(double amount) {
    return _costaRicaFormat.format(amount.round());
  }
  
  /// Formatea con el separador preferido del sistema
  static String formatCurrencyAuto(double amount) {
    return NumberFormat('#,##0').format(amount.round());
  }
}