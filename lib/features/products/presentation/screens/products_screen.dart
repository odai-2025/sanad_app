import 'package:flutter/material.dart';
import '../../data/services/products_service.dart';
import '../../../recharge/presentation/widgets/quick_recharge_sheet.dart';
import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductsService _productsService = ProductsService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _allServices = [];
  List<Map<String, dynamic>> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _productsService.getServices();

    if (!mounted) return;

    if (result['success'] == true) {
      final rawData = result['data'];
      List<Map<String, dynamic>> servicesList = [];

      if (rawData is List) {
        servicesList = rawData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else if (rawData is Map<String, dynamic> && rawData['data'] is List) {
        servicesList = (rawData['data'] as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      setState(() {
        _allServices = servicesList;
        _filteredServices = servicesList;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage =
            result['message']?.toString() ?? 'Failed to load services';
        _isLoading = false;
      });
    }
  }

  void _filterServices() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredServices = List.from(_allServices);
      } else {
        _filteredServices = _allServices.where((service) {
          final nameAr = (service['name_ar'] ?? '').toString().toLowerCase();
          final nameEn = (service['name_en'] ?? '').toString().toLowerCase();
          final code = (service['code'] ?? '').toString().toLowerCase();

          return nameAr.contains(query) ||
              nameEn.contains(query) ||
              code.contains(query);
        }).toList();
      }
    });
  }

  IconData _resolveIcon(String value) {
    final normalized = value.toLowerCase();

    if (normalized.contains('pubg')) return Icons.sports_esports;
    if (normalized.contains('free fire')) {
      return Icons.local_fire_department_outlined;
    }
    if (normalized.contains('itunes')) return Icons.card_giftcard;
    if (normalized.contains('google play')) return Icons.play_circle_outline;
    if (normalized.contains('yemen')) return Icons.phone_android;
    if (normalized.contains('sabafon')) return Icons.network_cell;
    if (normalized.contains('you')) return Icons.sim_card_outlined;
    if (normalized.contains('game')) return Icons.sports_esports;
    if (normalized.contains('telecom')) return Icons.phone_android;
    if (normalized.contains('gift')) return Icons.card_giftcard;

    return Icons.apps_rounded;
  }

  Future<void> _openQuickRecharge(Map<String, dynamic> item) async {
    final serviceId = item['id'];
    if (serviceId == null) return;

    final s = AppStrings.of(context);
    final title = s.isArabic
        ? (item['name_ar'] ?? item['name_en'] ?? 'Service').toString()
        : (item['name_en'] ?? item['name_ar'] ?? 'Service').toString();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickRechargeSheet(
        serviceId: int.tryParse(serviceId.toString()) ?? 0,
        serviceName: title,
        onSuccess: (result) async {
          await _loadServices();
        },
      ),
    );

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      final message = result['message']?.toString() ??
          (s.isArabic ? 'تم تنفيذ الطلب بنجاح' : 'Order completed successfully');

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: s.products,
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              s.products,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: s.searchProduct,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.close),
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildBody(s),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppStrings s) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.orange,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadServices,
                child: Text(s.isArabic ? 'إعادة المحاولة' : 'Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredServices.isEmpty) {
      return Center(
        child: Text(
          s.isArabic ? 'لا توجد خدمات متاحة' : 'No services available',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadServices,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredServices.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          final item = _filteredServices[index];

          final title = s.isArabic
              ? (item['name_ar'] ?? item['name_en'] ?? 'Service').toString()
              : (item['name_en'] ?? item['name_ar'] ?? 'Service').toString();

          final subtitle =
          (item['service_type'] ?? item['input_type'] ?? '').toString();

          final icon = _resolveIcon(title);

          return InkWell(
            onTap: () => _openQuickRecharge(item),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}