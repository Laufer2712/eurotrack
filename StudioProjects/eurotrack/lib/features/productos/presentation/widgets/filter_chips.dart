import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';

class FilterChips extends StatelessWidget {
  final List<Map<String, dynamic>> categorias;
  final int? selectedCategoriaId;
  final Function(int?) onCategoriaSelected;

  const FilterChips({
    super.key,
    required this.categorias,
    required this.selectedCategoriaId,
    required this.onCategoriaSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 4 : 0),
      child: Row(
        children: [
          _buildChip(
            label: "Todos",
            isSelected: selectedCategoriaId == null,
            onSelected: () => onCategoriaSelected(null),
            isDesktop: isDesktop,
          ),
          const SizedBox(width: 8),
          ...categorias.map((categoria) {
            final isSelected = selectedCategoriaId == categoria['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: categoria['nombre'] ?? '',
                isSelected: isSelected,
                onSelected: () => onCategoriaSelected(categoria['id']),
                isDesktop: isDesktop,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required bool isDesktop,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.deepNavy,
          fontSize: isDesktop ? 13 : 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.royalBlue,
      backgroundColor: Colors.white,
      elevation: isSelected ? 2 : 0,
      shadowColor: isSelected ? AppColors.royalBlue.withOpacity(0.3) : Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 12,
        vertical: isDesktop ? 10 : 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isSelected ? AppColors.royalBlue : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      showCheckmark: false, // ✅ ESTO ELIMINA EL CHECKMARK
    );
  }
}