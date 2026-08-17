import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member_model.dart';
import '../../providers/gym_provider.dart';
import '../../theme/gym_theme.dart';

class AddMemberDialog extends StatefulWidget {
  final MemberModel? memberToEdit;

  const AddMemberDialog({super.key, this.memberToEdit});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _feeController;
  late TextEditingController _dueDayController;
  late TextEditingController _weightController;
  late TextEditingController _emergencyController;
  late TextEditingController _notesController;

  String _gender = 'Male';
  String _planType = 'Monthly';
  String? _assignedDietId = 'diet_hypertrophy_mass';
  String? _assignedSplitId = 'split_ppl';

  @override
  void initState() {
    super.initState();
    final m = widget.memberToEdit;
    _nameController = TextEditingController(text: m?.name ?? '');
    _emailController = TextEditingController(text: m?.email ?? '');
    _phoneController = TextEditingController(text: m?.phone ?? '');
    _ageController = TextEditingController(text: (m?.age ?? 25).toString());
    _feeController = TextEditingController(text: (m?.monthlyFee ?? 50.0).toStringAsFixed(0));
    _dueDayController = TextEditingController(text: (m?.dueDayOfMonth ?? 5).toString());
    _weightController = TextEditingController(text: (m?.currentWeight ?? 75.0).toStringAsFixed(1));
    _emergencyController = TextEditingController(text: m?.emergencyContact ?? '');
    _notesController = TextEditingController(text: m?.notes ?? '');

    if (m != null) {
      _gender = m.gender;
      _planType = m.planType;
      _assignedDietId = m.assignedDietId ?? 'diet_hypertrophy_mass';
      _assignedSplitId = m.assignedSplitId ?? 'split_ppl';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _feeController.dispose();
    _dueDayController.dispose();
    _weightController.dispose();
    _emergencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveMember() {
    if (!_formKey.currentState!.validate()) return;

    final gym = context.read<GymProvider>();
    final isEditing = widget.memberToEdit != null;

    final member = MemberModel(
      id: widget.memberToEdit?.id ?? 'mem_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _gender,
      age: int.tryParse(_ageController.text) ?? 25,
      planType: _planType,
      monthlyFee: double.tryParse(_feeController.text) ?? 50.0,
      dueDayOfMonth: (int.tryParse(_dueDayController.text) ?? 5).clamp(1, 28),
      currentWeight: double.tryParse(_weightController.text) ?? 75.0,
      assignedDietId: _assignedDietId,
      assignedSplitId: _assignedSplitId,
      emergencyContact: _emergencyController.text.trim().isNotEmpty ? _emergencyController.text.trim() : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      status: widget.memberToEdit?.status ?? 'Active',
      attendanceStreak: widget.memberToEdit?.attendanceStreak ?? 0,
      totalWorkoutsCompleted: widget.memberToEdit?.totalWorkoutsCompleted ?? 0,
      joinDate: widget.memberToEdit?.joinDate ?? DateTime.now(),
    );

    if (isEditing) {
      gym.updateMember(member);
    } else {
      gym.addMember(member);
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Member updated successfully!' : 'New member registered successfully!'),
        backgroundColor: GymColors.neonGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final isEditing = widget.memberToEdit != null;

    return Dialog(
      backgroundColor: GymColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: GymColors.cardBorder),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GymColors.neonGreen.withAlpha((0.15 * 255).round()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit_note : Icons.person_add_alt_1,
                          color: GymColors.neonGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Member Profile' : 'Onboard New Member',
                            style: const TextStyle(
                              color: GymColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Assign plan, monthly fees, diet and workout protocols',
                            style: TextStyle(color: GymColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: GymColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: GymColors.cardBorder, height: 28),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Section
                      const Text(
                        'PERSONAL DETAILS',
                        style: TextStyle(color: GymColors.neonCyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Full Name *', Icons.person_outline),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter member name' : null,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration('Phone Number *', Icons.phone_outlined),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Phone is required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputDecoration('Email Address', Icons.email_outlined),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _gender,
                              dropdownColor: GymColors.surface,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration('Gender', Icons.wc_outlined),
                              items: ['Male', 'Female', 'Other'].map((g) {
                                return DropdownMenuItem(value: g, child: Text(g));
                              }).toList(),
                              onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('Age (yrs)', Icons.cake_outlined),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _inputDecoration('Weight (kg)', Icons.monitor_weight_outlined),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'MEMBERSHIP & FEES SECTION',
                        style: TextStyle(color: GymColors.neonGreen, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _planType,
                              dropdownColor: GymColors.surface,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration('Membership Tier', Icons.card_membership),
                              items: ['Monthly', 'Quarterly', 'Half-Yearly', 'Annual'].map((p) {
                                return DropdownMenuItem(value: p, child: Text(p));
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _planType = v;
                                    if (v == 'Monthly') _feeController.text = '50';
                                    if (v == 'Quarterly') _feeController.text = '45';
                                    if (v == 'Annual') _feeController.text = '38';
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _feeController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _inputDecoration('Monthly Fee (\$)', Icons.attach_money),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Enter fee amount' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _dueDayController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('Due Day of Month', Icons.calendar_today_outlined),
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n < 1 || n > 28) return '1-28 only';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'ASSIGNED WORKOUT & DIET PROTOCOL',
                        style: TextStyle(color: GymColors.neonAmber, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _assignedSplitId,
                              dropdownColor: GymColors.surface,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration('Assigned Split', Icons.fitness_center),
                              items: gym.splits.map((s) {
                                return DropdownMenuItem(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis));
                              }).toList(),
                              onChanged: (v) => setState(() => _assignedSplitId = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _assignedDietId,
                              dropdownColor: GymColors.surface,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration('Assigned Diet', Icons.restaurant_menu),
                              items: gym.allDietPlans.map((d) {
                                return DropdownMenuItem(value: d.id, child: Text(d.title, overflow: TextOverflow.ellipsis));
                              }).toList(),
                              onChanged: (v) => setState(() => _assignedDietId = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _emergencyController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Emergency Contact & Relation', Icons.contact_emergency_outlined),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Special Notes (Injuries, Medical, Targets)', Icons.note_alt_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: GymColors.cardBorder, height: 28),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CANCEL', style: TextStyle(color: GymColors.textMuted)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GymColors.neonGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(
                      isEditing ? 'UPDATE MEMBER' : 'REGISTER MEMBER',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    onPressed: _saveMember,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: GymColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: GymColors.textMuted, size: 18),
      filled: true,
      fillColor: GymColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: GymColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: GymColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: GymColors.neonGreen),
      ),
    );
  }
}
