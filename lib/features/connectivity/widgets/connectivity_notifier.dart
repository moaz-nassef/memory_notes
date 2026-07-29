import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:memory_notes/features/connectivity/cubit/connectivity_state.dart';

/// Listens to connectivity changes app-wide and shows a single,
/// non-repeating notification each time the status flips.
///
/// The initial state on app start never triggers a notification —
/// you only hear about it when something actually changed.
class ConnectivityNotifier extends StatelessWidget {
  const ConnectivityNotifier({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      // Fire only on a real online ⇄ offline transition —
      // never for the initial "checking" phase on startup.
      listenWhen:
          (previous, current) =>
              previous.runtimeType != current.runtimeType &&
              previous is! ConnectivityChecking &&
              current is! ConnectivityChecking,
      listener: (context, state) {
        final isOnline = state is ConnectivityOnline;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Row(
                children: [
                  Icon(
                    isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    color: isOnline ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isOnline
                          ? 'Back online'
                          : 'You\'re offline — notes keep working',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
      },
      child: child,
    );
  }
}
