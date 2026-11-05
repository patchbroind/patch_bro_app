import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_dialog.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_empty_state.dart';
import 'package:patch_bro/core/widgets/app_error_view.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';

import '../../domain/entities/employer_address_entity.dart';
import '../controllers/employer_addresses_state.dart';
import '../providers/employer_addresses_providers.dart';
import '../widgets/employer_address_card.dart';

class EmployerAddressesPage extends ConsumerStatefulWidget {
  const EmployerAddressesPage({super.key});

  @override
  ConsumerState<EmployerAddressesPage> createState() =>
      _EmployerAddressesPageState();
}

class _EmployerAddressesPageState extends ConsumerState<EmployerAddressesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(employerAddressesControllerProvider.notifier).loadAddresses();
      }
    });
  }

  Future<void> _refresh() async {
    try {
      await ref
          .read(employerAddressesControllerProvider.notifier)
          .refreshAddresses();
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'Unable to refresh addresses. Please try again.',
        );
      }
    }
  }

  void _retry() {
    ref.read(employerAddressesControllerProvider.notifier).loadAddresses();
  }

  void _addAddress() {
    AppSnackbar.info(
      context,
      'Additional saved addresses are not available yet.',
    );
  }

  Future<void> _showAddressActions(EmployerAddressEntity address) async {
    await AppDialog.alert(
      context,
      title: 'Address actions unavailable',
      message:
          'Editing, deleting, and default-address management are not supported by the current backend.',
      buttonLabel: 'OK',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employerAddressesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Addresses')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EmployerAddressesState state) {
    if (state.isLoading && !state.hasAddresses) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.employerPrimary),
      );
    }

    if (state.isFailure && !state.hasAddresses) {
      return AppErrorView(
        title: 'Unable to load Addresses',
        message:
            state.errorMessage ?? 'Please check your connection and try again.',
        icon: Icons.cloud_off_outlined,
        onRetry: _retry,
      );
    }

    return RefreshIndicator(
      color: AppColors.employerPrimary,
      onRefresh: _refresh,
      child: _AddressesContent(
        addresses: state.addresses,
        onAddAddress: _addAddress,
        onMenuTap: _showAddressActions,
      ),
    );
  }
}

class _AddressesContent extends StatelessWidget {
  const _AddressesContent({
    required this.addresses,
    required this.onAddAddress,
    required this.onMenuTap,
  });

  final List<EmployerAddressEntity> addresses;
  final VoidCallback onAddAddress;
  final ValueChanged<EmployerAddressEntity> onMenuTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            12,
            horizontalPadding,
            28,
          ),
          itemCount: addresses.isEmpty ? 2 : addresses.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return AppPrimaryButton(
                label: 'Add New Address',
                onPressed: onAddAddress,
              );
            }

            if (index == 1 && addresses.isEmpty) {
              return const AppEmptyState(
                title: 'No addresses yet',
                message:
                    'Add an address to make posting and managing jobs easier.',
                icon: Icons.location_off_outlined,
                iconColor: AppColors.imagePlaceholderIcon,
                iconSize: 44,
                padding: EdgeInsets.symmetric(vertical: 72),
                messageColor: null,
              );
            }

            final address = addresses[index - 1];
            return EmployerAddressCard(
              key: ValueKey(address.id),
              address: address,
              onMenuTap: () => onMenuTap(address),
            );
          },
        );
      },
    );
  }
}
