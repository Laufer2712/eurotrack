// lib/features/profile/widgets/ValidatedHiddenInfoField.dart
import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/features/profile/presentation/services/ValidationService.dart';

class ValidatedHiddenInfoField extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isEditable;
  final TextEditingController? controller;
  final int userId;
  final String validationType; // 'username' o 'email'
  final bool isRequired;

  const ValidatedHiddenInfoField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isEditable = false,
    this.controller,
    required this.userId,
    required this.validationType,
    this.isRequired = true,
  });

  @override
  State<ValidatedHiddenInfoField> createState() => _ValidatedHiddenInfoFieldState();
}

class _ValidatedHiddenInfoFieldState extends State<ValidatedHiddenInfoField> {
  bool _isVisible = false;
  bool _isValid = true;
  String _errorMessage = '';
  bool _isChecking = false;
  final ValidationService _validationService = ValidationService();
  String _originalValue = '';
  String _lastCheckedValue = '';
  bool _isListenerAttached = false;

  @override
  void initState() {
    super.initState();
    _originalValue = widget.value;
    _lastCheckedValue = widget.value;
    _attachListener();
  }

  void _attachListener() {
    if (widget.controller != null && !_isListenerAttached) {
      widget.controller!.addListener(_onTextChanged);
      _isListenerAttached = true;
    }
  }

  void _onTextChanged() {
    final currentValue = widget.controller?.text ?? '';
    _validateField(currentValue);
  }

  Future<void> _validateField(String value) async {
    if (!widget.isEditable) {
      setState(() {
        _isValid = true;
        _errorMessage = '';
        _isChecking = false;
      });
      return;
    }

    final String trimmedValue = value.trim();
    final String originalTrimmed = _originalValue.trim();

    // ✅ Si el valor es igual al original, es válido (no ha cambiado)
    if (trimmedValue == originalTrimmed) {
      setState(() {
        _isValid = true;
        _errorMessage = '';
        _isChecking = false;
        _lastCheckedValue = trimmedValue;
      });
      return;
    }

    // ✅ Si ya validamos este valor exacto antes y es válido, no repetir
    if (trimmedValue == _lastCheckedValue && _isValid) {
      return;
    }

    // Validar que no esté vacío
    if (widget.isRequired && trimmedValue.isEmpty) {
      setState(() {
        _isValid = false;
        _errorMessage = 'Este campo es requerido';
        _isChecking = false;
        _lastCheckedValue = trimmedValue;
      });
      return;
    }

    // Validar longitud mínima para username
    if (widget.validationType == 'username' && trimmedValue.length < 3) {
      setState(() {
        _isValid = false;
        _errorMessage = 'El usuario debe tener al menos 3 caracteres';
        _isChecking = false;
        _lastCheckedValue = trimmedValue;
      });
      return;
    }

    // Validar que username solo tenga letras, números y guión bajo
    if (widget.validationType == 'username') {
      final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
      if (!usernameRegex.hasMatch(trimmedValue)) {
        setState(() {
          _isValid = false;
          _errorMessage = 'Solo letras, números y guión bajo';
          _isChecking = false;
          _lastCheckedValue = trimmedValue;
        });
        return;
      }
    }

    // Validar formato de email
    if (widget.validationType == 'email' && trimmedValue.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(trimmedValue)) {
        setState(() {
          _isValid = false;
          _errorMessage = 'Ingresa un email válido';
          _isChecking = false;
          _lastCheckedValue = trimmedValue;
        });
        return;
      }
    }

    // ✅ Si el valor es el mismo que el original, no consultar al servidor
    if (trimmedValue == originalTrimmed) {
      setState(() {
        _isValid = true;
        _errorMessage = '';
        _isChecking = false;
        _lastCheckedValue = trimmedValue;
      });
      return;
    }

    // Verificar unicidad en el servidor
    setState(() {
      _isChecking = true;
    });

    try {
      bool isAvailable;
      if (widget.validationType == 'username') {
        isAvailable = await _validationService.isUsernameAvailable(
          trimmedValue,
          widget.userId,
        );
      } else if (widget.validationType == 'email') {
        isAvailable = await _validationService.isEmailAvailable(
          trimmedValue,
          widget.userId,
        );
      } else {
        isAvailable = true;
      }

      if (mounted) {
        setState(() {
          _isValid = isAvailable;
          _isChecking = false;
          _lastCheckedValue = trimmedValue;
          if (!isAvailable) {
            if (widget.validationType == 'username') {
              _errorMessage = '❌ El usuario ya está en uso';
            } else if (widget.validationType == 'email') {
              _errorMessage = '❌ El email ya está registrado';
            }
          } else {
            _errorMessage = '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _isValid = true;
          _errorMessage = '';
          _lastCheckedValue = trimmedValue;
        });
      }
    }
  }

  @override
  void didUpdateWidget(ValidatedHiddenInfoField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Si el controlador cambió, actualizar el listener
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      _isListenerAttached = false;
      _attachListener();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showError = !_isValid && _errorMessage.isNotEmpty;
    final bool isUsername = widget.validationType == 'username';
    final bool isEmail = widget.validationType == 'email';
    final bool hasChanged = widget.controller?.text != _originalValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showError ? Colors.red : (_isVisible ? AppColors.royalBlue : Colors.grey.shade200),
          width: showError ? 2 : (_isVisible ? 1.5 : 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.icon,
                color: showError ? Colors.red : Colors.grey.shade400,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: showError ? Colors.red : Colors.grey.shade600,
                  ),
                ),
              ),
              // Indicador de validación
              if (widget.isEditable && _isChecking)
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.royalBlue,
                  ),
                ),
              if (widget.isEditable && !_isChecking && hasChanged)
                Icon(
                  _isValid ? Icons.check_circle : Icons.error,
                  color: _isValid ? Colors.green : Colors.red,
                  size: 18,
                ),
              const SizedBox(width: 4),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.isEditable && widget.controller != null
                      ? TextField(
                    controller: widget.controller,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.deepNavy,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: (isUsername || isEmail) && widget.controller!.text.isNotEmpty && hasChanged
                          ? Icon(
                        _isValid ? Icons.check_circle : Icons.error,
                        color: _isValid ? Colors.green : Colors.red,
                        size: 20,
                      )
                          : null,
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
                  if (showError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_isValid && hasChanged && widget.isEditable && !_isChecking)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '✅ ${widget.validationType == 'username' ? 'Usuario' : 'Email'} disponible',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
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

  @override
  void dispose() {
    if (widget.controller != null && _isListenerAttached) {
      widget.controller!.removeListener(_onTextChanged);
      _isListenerAttached = false;
    }
    super.dispose();
  }
}