import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/app_preferences.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final ValueNotifier<List<_ProfileAddress>> _addressesNotifier = ValueNotifier<List<_ProfileAddress>>(<_ProfileAddress>[]);

  late AppPreferences _prefs;
  bool _isLoading = true;
  bool _defaultAddressScheduled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _prefs = await AppPreferences.getInstance();
    _nameController.text =
        _prefs.getString(AppConstants.sharedPrefsProfileNameKey) ?? 'Greenly User';
    _emailController.text =
        _prefs.getString(AppConstants.sharedPrefsProfileEmailKey) ?? 'user@example.com';
    _phoneController.text =
        _prefs.getString(AppConstants.sharedPrefsProfilePhoneKey) ?? '+1234567890';

    final stored = _prefs.getString(AppConstants.sharedPrefsProfileAddressesKey);
    if (stored != null) {
      try {
        final List<dynamic> decoded = jsonDecode(stored) as List<dynamic>;
        final addresses = decoded
            .whereType<Map<String, dynamic>>()
            .map(_ProfileAddress.fromJson)
            .toList();
        if (addresses.isEmpty) {
          _addressesNotifier.value = const <_ProfileAddress>[];
          _scheduleDefaultAddress();
        } else {
          if (!addresses.any((address) => address.isDefault)) {
            addresses[0] = addresses[0].copyWith(isDefault: true);
          }
          _addressesNotifier.value = List<_ProfileAddress>.unmodifiable(addresses);
          await _persistAddresses();
        }
      } catch (_) {
        _addressesNotifier.value = const <_ProfileAddress>[];
        _scheduleDefaultAddress();
      }
    } else {
      _addressesNotifier.value = const <_ProfileAddress>[];
      _scheduleDefaultAddress();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _scheduleDefaultAddress() {
    if (_defaultAddressScheduled) return;
    _defaultAddressScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDefaultAddress());
  }

  Future<void> _ensureDefaultAddress() async {
    if (!mounted) return;
    final current = List<_ProfileAddress>.from(_addressesNotifier.value);
    if (current.isEmpty) {
      final loc = AppLocalizations.of(context);
      current.add(
        _ProfileAddress(
          id: _generateId(),
          label: loc.translate('profileAddressDefaultLabel'),
          details: loc.translate('profileAddressDefaultDetails'),
          isDefault: true,
        ),
      );
    } else {
      current[0] = current[0].copyWith(isDefault: true);
    }
    _addressesNotifier.value = List<_ProfileAddress>.unmodifiable(current);
    await _persistAddresses();
  }

  Future<void> _persistAddresses() async {
    final jsonList = _addressesNotifier.value.map((address) => address.toJson()).toList();
    await _prefs.setString(AppConstants.sharedPrefsProfileAddressesKey, jsonEncode(jsonList));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await _prefs.setString(AppConstants.sharedPrefsProfileNameKey, _nameController.text.trim());
    await _prefs.setString(AppConstants.sharedPrefsProfileEmailKey, _emailController.text.trim());
    await _prefs.setString(AppConstants.sharedPrefsProfilePhoneKey, _phoneController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).translate('profileSavedMessage'))));
  }

  Future<void> _editAddress({_ProfileAddress? address}) async {
    final loc = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final labelController = TextEditingController(text: address?.label ?? '');
    final detailsController = TextEditingController(text: address?.details ?? '');

    final result = await showModalBottomSheet<_ProfileAddress>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate(address == null
                      ? 'profileAddressFormTitleNew'
                      : 'profileAddressFormTitleEdit'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: labelController,
                  decoration:
                      InputDecoration(labelText: loc.translate('profileAddressFormLabel')),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? loc.translate('validationRequired') : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: detailsController,
                  maxLines: 2,
                  decoration:
                      InputDecoration(labelText: loc.translate('profileAddressFormDetails')),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? loc.translate('validationRequired') : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(loc.translate('cancel')),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.of(context).pop(
                          _ProfileAddress(
                            id: address?.id ?? _generateId(),
                            label: labelController.text.trim(),
                            details: detailsController.text.trim(),
                            isDefault: address?.isDefault ?? false,
                          ),
                        );
                      },
                      child: Text(loc.translate('profileAddressFormSave')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;

    final updated = List<_ProfileAddress>.from(_addressesNotifier.value);
    final index = updated.indexWhere((item) => item.id == result.id);
    if (index >= 0) {
      updated[index] = result;
    } else {
      updated.add(result);
    }
    if (!updated.any((element) => element.isDefault)) {
      final first = updated.first;
      updated[0] = first.copyWith(isDefault: true);
    }
    _addressesNotifier.value = List<_ProfileAddress>.unmodifiable(updated);
    await _persistAddresses();
  }

  Future<void> _removeAddress(_ProfileAddress address) async {
    final updated = List<_ProfileAddress>.from(_addressesNotifier.value)
      ..removeWhere((element) => element.id == address.id);
    if (updated.isEmpty) {
      _addressesNotifier.value = const <_ProfileAddress>[];
      _defaultAddressScheduled = false;
      _scheduleDefaultAddress();
      return;
    }
    if (!updated.any((element) => element.isDefault)) {
      updated[0] = updated[0].copyWith(isDefault: true);
    }
    _addressesNotifier.value = List<_ProfileAddress>.unmodifiable(updated);
    await _persistAddresses();
  }

  Future<void> _setDefaultAddress(String id) async {
    final updated = _addressesNotifier.value
        .map((address) => address.copyWith(isDefault: address.id == id))
        .toList(growable: false);
    _addressesNotifier.value = List<_ProfileAddress>.unmodifiable(updated);
    await _persistAddresses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AppScaffold(
      initialIndex: 2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Text(loc.translate('profileTitle'),
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            InputDecoration(labelText: loc.translate('profileNameLabel')),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? loc.translate('validationRequired') : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            InputDecoration(labelText: loc.translate('profileEmailLabel')),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return loc.translate('validationRequired');
                          }
                          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!regex.hasMatch(value.trim())) {
                            return loc.translate('validationEmail');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration:
                            InputDecoration(labelText: loc.translate('profilePhoneLabel')),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return loc.translate('validationRequired');
                          }
                          if (value.trim().length < 9) {
                            return loc.translate('validationPhone');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(loc.translate('profileAddressesSection'),
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<List<_ProfileAddress>>(
                        valueListenable: _addressesNotifier,
                        builder: (context, addresses, _) {
                          if (addresses.isEmpty) {
                            return Text(loc.translate('profileAddressEmpty'));
                          }
                          final defaultId = addresses
                              .firstWhere((address) => address.isDefault,
                                  orElse: () => addresses.first)
                              .id;
                          return Column(
                            children: [
                              for (final address in addresses)
                                _AddressCard(
                                  address: address,
                                  isDefault: address.id == defaultId,
                                  onSelectDefault: () => _setDefaultAddress(address.id),
                                  onEdit: () => _editAddress(address: address),
                                  onDelete: () => _removeAddress(address),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _editAddress(),
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: Text(loc.translate('profileAddressAdd')),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _save,
                        child: Text(loc.translate('profileSaveButton')),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}

class _ProfileAddress {
  const _ProfileAddress({
    required this.id,
    required this.label,
    required this.details,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String details;
  final bool isDefault;

  factory _ProfileAddress.fromJson(Map<String, dynamic> json) {
    return _ProfileAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      details: json['details'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'details': details,
        'isDefault': isDefault,
      };

  _ProfileAddress copyWith({
    bool? isDefault,
    String? label,
    String? details,
  }) {
    return _ProfileAddress(
      id: id,
      label: label ?? this.label,
      details: details ?? this.details,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isDefault,
    required this.onSelectDefault,
    required this.onEdit,
    required this.onDelete,
  });

  final _ProfileAddress address;
  final bool isDefault;
  final VoidCallback onSelectDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(address.label, style: Theme.of(context).textTheme.titleMedium),
                ),
                if (isDefault)
                  Chip(
                    label: Text(loc.translate('profileAddressDefaultBadge')),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(address.details),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isDefault ? null : onSelectDefault,
                    child: Text(loc.translate('profileAddressMakeDefault')),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  tooltip: loc.translate('profileAddressEdit'),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: loc.translate('profileAddressDelete'),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
