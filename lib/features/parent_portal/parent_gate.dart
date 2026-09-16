import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../progress/progress_cubit.dart';
import 'parent_portal_screen.dart';

class ParentGate {
  static Future<void> open(BuildContext context) async {
    final unlocked = await showDialog<bool>(
      context: context,
      builder: (_) => const _HoldOrMathDialog(),
    );
    if (unlocked != true || !context.mounted) return;

    final pin = context.read<ProgressCubit>().state.player.parentPin;
    if (pin == null || pin.isEmpty) {
      final created = await _promptNewPin(context);
      if (created != true || !context.mounted) return;
    } else {
      final ok = await _promptPin(context, pin);
      if (ok != true || !context.mounted) return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ParentPortalScreen()),
    );
  }

  static Future<bool?> _promptNewPin(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create a parent PIN'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(hintText: '4 digits'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () async {
                final value = controller.text.trim();
                if (value.length == 4) {
                  await context.read<ProgressCubit>().setPin(value);
                }
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> _promptPin(BuildContext context, String expected) {
    final controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter parent PIN'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim() == expected);
              },
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );
  }
}

class _HoldOrMathDialog extends StatefulWidget {
  const _HoldOrMathDialog();

  @override
  State<_HoldOrMathDialog> createState() => _HoldOrMathDialogState();
}

class _HoldOrMathDialogState extends State<_HoldOrMathDialog> {
  final _answer = TextEditingController();
  double _hold = 0;
  bool _holding = false;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _holdDown() async {
    _holding = true;
    _hold = 0;
    while (_holding && mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!_holding) return;
      setState(() => _hold = (_hold + 0.05).clamp(0, 1));
      if (_hold >= 1) {
        _holding = false;
        if (mounted) Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Grown-ups only', style: AppTheme.fredoka(size: 22)),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Hold for 3 seconds, or solve 4 + 3.', style: AppTheme.nunito(size: 15)),
            const SizedBox(height: 12),
            GestureDetector(
              onTapDown: (_) => _holdDown(),
              onTapUp: (_) {
                _holding = false;
                setState(() => _hold = 0);
              },
              onTapCancel: () {
                _holding = false;
                setState(() => _hold = 0);
              },
              child: SizedBox(
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FractionallySizedBox(
                          widthFactor: _hold,
                          alignment: Alignment.centerLeft,
                          child: const ColoredBox(color: Color(0x590284C7)),
                        ),
                        const Center(child: Text('Press and hold')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _answer,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'What is 4 + 3?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _answer.text.trim() == '7'),
          child: const Text('Check'),
        ),
      ],
    );
  }
}
