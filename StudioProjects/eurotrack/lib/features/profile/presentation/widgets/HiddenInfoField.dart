// lib/features/profile/widgets/hidden_info_field.dart
import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';

class HiddenInfoField extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isEditable;
  final TextEditingController? controller;

  const HiddenInfoField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isEditable = false,
    this.controller,
  });

  @override
  State<HiddenInfoField> createState() => _HiddenInfoFieldState();
}

class _HiddenInfoFieldState extends State<HiddenInfoField> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isVisible ? AppColors.royalBlue : Colors.grey.shade200,
          width: _isVisible ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: Colors.grey.shade400, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                },
                icon: Icon(
                  _isVisible ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: _isVisible ? Colors.grey.shade600 : AppColors.royalBlue,
                ),
                label: Text(
                  _isVisible ? 'Ocultar' : 'Ver',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isVisible ? Colors.grey.shade600 : AppColors.royalBlue,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isVisible
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: widget.isEditable && widget.controller != null
                  ? TextField(
                controller: widget.controller,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.deepNavy,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              )
                  : Text(
                widget.value.isEmpty ? 'No especificado' : widget.value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: widget.value.isEmpty ? Colors.grey : AppColors.deepNavy,
                ),
              ),
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '●●●●●●●●',
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 4,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Oculto',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}