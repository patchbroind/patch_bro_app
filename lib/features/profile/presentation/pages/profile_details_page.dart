import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/utils/phone_utils.dart';
import 'package:patch_bro/core/validators/validators.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/app_text_field.dart';
import 'package:patch_bro/core/widgets/auth_scaffold.dart';

import 'package:patch_bro/features/auth/presentation/models/otp_verification_args.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

import '../../domain/entities/profile_data.dart';
import '../../domain/entities/profile_location.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_location_section.dart';

class ProfileDetailsPage extends ConsumerStatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  ConsumerState<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends ConsumerState<ProfileDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _stateController = TextEditingController();

  ProfileLocation? _selectedLocation;

  bool _isPhoneLocked = false;
  bool _isEmailLocked = false;
  bool _isInitialized = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    ref.listenManual(authStateProvider, (previous, next) {
      if (next.hasValue) {
        _initializeFromAuthUser();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _initializeFromAuthUser();
    });
  }

  void _initializeFromAuthUser() {
    if (_isInitialized) {
      return;
    }

    final user = ref.read(currentUserProvider);

    if (user == null) {
      return;
    }

    final email = user.email?.trim() ?? '';
    final phone = user.phone?.trim() ?? '';

    if (email.isNotEmpty) {
      _emailController.text = email;
      _isEmailLocked = true;
    }

    if (phone.isNotEmpty) {
      _mobileController.text = phone;
      _isPhoneLocked = true;
    }

    _isInitialized = true;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _pinCodeController.dispose();
    _stateController.dispose();

    super.dispose();
  }

  Future<void> _continue() async {
    if (_isSubmitting || ref.read(authControllerProvider).isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      AppSnackbar.error(context, 'Please select your location.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    FocusScope.of(context).unfocus();

    final config = ref.read(appConfigProvider);

    final phone = _mobileController.text.trim();
    final normalizedPhone = normalizePhone(phone);

    final profileData = ProfileData(
      name: _nameController.text.trim(),
      phone: normalizedPhone,
      address1: _address1Controller.text.trim(),
      address2: _address2Controller.text.trim(),
      pinCode: _pinCodeController.text.trim(),
      state: _stateController.text.trim(),
      location: _selectedLocation!,
      isWorker: config.isWorker,
    );

    try {
      // GOOGLE USER WITHOUT VERIFIED PHONE

      if (!_isPhoneLocked) {
        await ref.read(authControllerProvider.notifier).updatePhone(phone: normalizedPhone);

        if (!mounted) {
          return;
        }

        context.push(
          '/otp',
          extra: OtpVerificationArgs.phoneChange(phone: normalizedPhone, profileData: profileData),
        );

        return;
      }

      // EXISTING VERIFIED PHONE

      await ref
          .read(profileRepositoryProvider)
          .saveProfile(
            name: profileData.name,
            phone: profileData.phone,
            address1: profileData.address1,
            address2: profileData.address2,
            pinCode: profileData.pinCode,
            state: profileData.state,
            latitude: profileData.location.latitude,
            longitude: profileData.location.longitude,
            locationAddress: profileData.location.address,
            isWorker: profileData.isWorker,
          );

      if (!mounted) {
        return;
      }

      context.go(config.isWorker ? '/worker/home' : '/employer/home');
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, 'Failed to continue: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final authIsLoading = ref.watch(authControllerProvider.select((state) => state.isLoading));

    final isLoading = _isSubmitting || authIsLoading;

    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete Profile',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Please provide your details to continue.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 17),
              ),

              const SizedBox(height: 32),

              // NAME
              AppTextField(
                controller: _nameController,
                hintText: 'Name',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: Validators.required,
              ),

              const SizedBox(height: 18),

              // EMAIL
              AppTextField(
                controller: _emailController,
                hintText: 'E-mail',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                isReadOnly: _isEmailLocked,
                validator: Validators.required,
              ),

              const SizedBox(height: 18),

              // MOBILE
              AppTextField(
                controller: _mobileController,
                hintText: 'Mobile Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                isReadOnly: _isPhoneLocked,
                validator: Validators.required,
              ),

              const SizedBox(height: 18),

              // ADDRESS 1
              AppTextField(
                controller: _address1Controller,
                hintText: 'Address 1',
                icon: Icons.location_on_outlined,
                textInputAction: TextInputAction.next,
                validator: Validators.required,
              ),

              const SizedBox(height: 18),

              // ADDRESS 2
              AppTextField(
                controller: _address2Controller,
                hintText: 'Address 2',
                icon: Icons.location_on_outlined,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 18),

              // PIN CODE
              AppTextField(
                controller: _pinCodeController,
                hintText: 'Pin Code',
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: Validators.required,
              ),

              const SizedBox(height: 18),

              // STATE
              AppTextField(
                controller: _stateController,
                hintText: 'State',
                icon: Icons.map_outlined,
                textInputAction: TextInputAction.done,
                validator: Validators.required,
              ),

              const SizedBox(height: 28),

              // LOCATION
              ProfileLocationSection(
                location: _selectedLocation,
                onLocationSelected: (location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                },
              ),

              const SizedBox(height: 30),

              // CONTINUE
              AppPrimaryButton(
                label: 'Continue',
                isLoading: isLoading,
                onPressed: isLoading ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
