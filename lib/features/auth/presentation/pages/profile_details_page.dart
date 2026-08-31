import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/auth_scaffold.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class ProfileDetailsPage extends ConsumerStatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  ConsumerState<ProfileDetailsPage> createState() =>
      _ProfileDetailsPageState();
}

class _ProfileDetailsPageState
    extends ConsumerState<ProfileDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _stateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _pinCodeController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final config = ref.read(appConfigProvider);

    if (config.isWorker) {
      context.go('/worker/home');
    } else {
      context.go('/employer/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Please provide your details to continue.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 32),

              AuthTextField(
                controller: _nameController,
                hintText: 'Name',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 18),

              AuthTextField(
                controller: _mobileController,
                hintText: 'Mobile Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 18),

              AuthTextField(
                controller: _address1Controller,
                hintText: 'Address 1',
                icon: Icons.location_on_outlined,
                textInputAction: TextInputAction.next,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 18),

              AuthTextField(
                controller: _address2Controller,
                hintText: 'Address 2',
                icon: Icons.location_on_outlined,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 18),

              AuthTextField(
                controller: _pinCodeController,
                hintText: 'Pin Code',
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 18),

              AuthTextField(
                controller: _stateController,
                hintText: 'State',
                icon: Icons.map_outlined,
                textInputAction: TextInputAction.done,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 30),

              AuthPrimaryButton(
                label: 'Continue',
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }
}