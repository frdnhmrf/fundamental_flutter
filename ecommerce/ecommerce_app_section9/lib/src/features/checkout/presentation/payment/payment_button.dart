import 'package:ecommerce_app/src/common_widgets/alert_dialogs.dart';
import 'package:ecommerce_app/src/features/cart/application/cart_service.dart';
import 'package:ecommerce_app/src/features/checkout/presentation/payment/payment_button_controller.dart';
import 'package:ecommerce_app/src/localization/string_hardcoded.dart';
import 'package:ecommerce_app/src/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/src/common_widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Button used to initiate the payment flow.
class PaymentButton extends ConsumerWidget {
  const PaymentButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<double>(cartTotalProvider, (_, cartTotal) {
      if (cartTotal == 0.0) {
        context.goNamed(AppRoute.orders.name);
      }
    });
    final state = ref.watch(paymentButtonControllerProvider);
    return PrimaryButton(
      text: 'Pay'.hardcoded,
      isLoading: state.isLoading,
      onPressed: state.isLoading
          ? null
          : () => ref.read(paymentButtonControllerProvider.notifier).pay(),
    );
  }
}
