import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/shopping_providers.dart';
import 'store_detail_page.dart';
import '../model/store_purchase_models.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjetas de resumen
          _SummaryCards(),
          const SizedBox(height: 24),
          
          // Gastos por tienda
          _SpendingByStoreSection(),
          const SizedBox(height: 24),
          
          // Gastos mensuales
          _MonthlySpendingSection(),
          const SizedBox(height: 24),
          
          // Productos más comprados
          _TopProductsSection(),
        ],
      ),
    );
  }
}

class _SummaryCards extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchasesProvider);
    
    return purchasesAsync.when(
      loading: () => const _LoadingSummaryCards(),
      error: (error, stack) => const _ErrorSummaryCards(),
      data: (purchases) {
        final thisMonthPurchases = purchases.where((p) => 
          p.purchaseDate.month == DateTime.now().month &&
          p.purchaseDate.year == DateTime.now().year
        ).toList();
        
        final thisMonthTotal = thisMonthPurchases.fold(0.0, (sum, p) => sum + p.totalAmount);
        final avgPurchase = purchases.isNotEmpty 
            ? purchases.fold(0.0, (sum, p) => sum + p.totalAmount) / purchases.length
            : 0.0;
        
        return Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Este mes',
                value:'₡${_formatNumberWithSeparator(thisMonthTotal)}',
                subtitle: '${thisMonthPurchases.length} compras',
                icon: Icons.calendar_month,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Promedio',
                value: '₡${_formatNumberWithSeparator(avgPurchase)}',
                subtitle: 'por compra',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  
  // Función helper para formatear números con separador de miles
  String _formatNumberWithSeparator(double number) {
    final intPart = number.round();
    final str = intPart.toString();
    
    if (str.length <= 3) return str;
    
    String result = '';
    int count = 0;
    
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result'; // Usa punto como separador (estilo Costa Rica)
        count = 0;
      }
      result = str[i] + result;
      count++;
    }
    
    return result;
  }
}

class _LoadingSummaryCards extends StatelessWidget {
  const _LoadingSummaryCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SummaryCardSkeleton()),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCardSkeleton()),
      ],
    );
  }
}

class _ErrorSummaryCards extends StatelessWidget {
  const _ErrorSummaryCards();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Error cargando resumen'),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 28,
              width: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingByStoreSection extends ConsumerWidget {

  // Función helper para formatear números con separador de miles
  String _formatNumberWithSeparator(double number) {
    final intPart = number.round();
    final str = intPart.toString();
    
    if (str.length <= 3) return str;
    
    String result = '';
    int count = 0;
    
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result'; // Usa punto como separador (estilo Costa Rica)
        count = 0;
      }
      result = str[i] + result;
      count++;
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spendingAsync = ref.watch(spendingByStoreProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gastos por tienda',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        spendingAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error cargando datos: $error'),
            ),
          ),
          data: (data) {
            final stores = data['stores'] as List? ?? [];
            
            if (stores.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No hay datos de gastos por tienda aún'),
                  ),
                ),
              );
            }
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: stores.take(5).map((store) {
                    return ListTile(
  leading: CircleAvatar(
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    child: const Icon(Icons.store),
  ),
  title: Text(store['store_name'] ?? 'Tienda desconocida'),
  subtitle: Text('${store['purchase_count'] ?? 0} compras'),
  trailing: Text(
    //'₡${(store['total_spent'] as num?)?.toStringAsFixed(0) ?? '0'}',
    '₡${_formatNumberWithSeparator(store['total_spent'])}',
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    ),
  ),
  onTap: () {
    // Encontrar la tienda y navegar
    final storesAsync = ref.read(storesProvider);
    final stores = storesAsync.value ?? [];
    final foundStore = stores.cast<Store?>().firstWhere(
      (s) => s?.name == store['store_name'],
      orElse: () => null,
    );
    
    if (foundStore != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StoreDetailPage(store: foundStore),
        ),
      );
    }
  },
);
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MonthlySpendingSection extends ConsumerWidget {

  // Función helper para formatear números con separador de miles
  String _formatNumberWithSeparator(double number) {
    final intPart = number.round();
    final str = intPart.toString();
    
    if (str.length <= 3) return str;
    
    String result = '';
    int count = 0;
    
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result'; // Usa punto como separador (estilo Costa Rica)
        count = 0;
      }
      result = str[i] + result;
      count++;
    }
    
    return result;
  }

  @override

  
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyAsync = ref.watch(monthlySpendingProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gastos mensuales',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        monthlyAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error cargando datos: $error'),
            ),
          ),
          data: (data) {
            final months = data['months'] as List? ?? [];
            
            if (months.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No hay datos de gastos mensuales aún'),
                  ),
                ),
              );
            }
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: months.take(6).map((month) {
                    final monthDate = DateTime.parse(month['month']);
                    final monthName = _getMonthName(monthDate.month);
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        child: const Icon(Icons.calendar_month),
                      ),
                      title: Text('$monthName ${monthDate.year}'),
                      subtitle: Text('${month['purchase_count'] ?? 0} compras'),
                      trailing: Text(
                        //'₡${(month['total_spent'] as num?)?.toStringAsFixed(0) ?? '0'}',
                        '₡${_formatNumberWithSeparator(month['total_spent'])}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month];
  }
}

class _TopProductsSection extends ConsumerWidget {

  // Función helper para formatear números con separador de miles
  String _formatNumberWithSeparator(double number) {
    final intPart = number.round();
    final str = intPart.toString();
    
    if (str.length <= 3) return str;
    
    String result = '';
    int count = 0;
    
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result'; // Usa punto como separador (estilo Costa Rica)
        count = 0;
      }
      result = str[i] + result;
      count++;
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final averagePricesAsync = ref.watch(averagePricesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos frecuentes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        averagePricesAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error cargando datos: $error'),
            ),
          ),
          data: (data) {
            final items = data['items'] as List? ?? [];
            
            if (items.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No hay datos de productos aún'),
                  ),
                ),
              );
            }
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: items.take(5).map((item) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                        child: const Icon(Icons.shopping_basket),
                      ),
                      title: Text(item['item_name'] ?? 'Producto desconocido'),
                      subtitle: Text('${item['purchase_count'] ?? 0} veces comprado'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            //'₡${(item['avg_price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                            '₡${_formatNumberWithSeparator(item['avg_price'])}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'promedio',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}