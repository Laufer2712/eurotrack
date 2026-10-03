import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';

class SortBottomSheet extends StatelessWidget {
  final String currentSort;
  final Function(String) onSortSelected;

  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ordenar por",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildSortOption(
            context,
            "default",
            "Relevancia",
            Icons.trending_up,
          ),
          _buildSortOption(
            context,
            "price_asc",
            "Precio: Menor a Mayor",
            Icons.arrow_upward,
          ),
          _buildSortOption(
            context,
            "price_desc",
            "Precio: Mayor a Menor",
            Icons.arrow_downward,
          ),
          _buildSortOption(
            context,
            "name_asc",
            "Nombre: A a Z",
            Icons.sort_by_alpha,
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(
      BuildContext context,
      String value,
      String label,
      IconData icon,
      ) {
    final isSelected = currentSort == value;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.royalBlue.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.royalBlue.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.royalBlue.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? AppColors.royalBlue : Colors.grey.shade500,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.royalBlue : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        trailing: isSelected
            ? Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.royalBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        )
            : null,
        onTap: () {
          onSortSelected(value);
          Navigator.pop(context);
        },
      ),
    );
  }
}