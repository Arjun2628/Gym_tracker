import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gym_provider.dart';
import '../models/user_profile.dart';
import '../models/science_context.dart';
import '../theme/gym_theme.dart';
import '../widgets/context_card.dart';

class ProfileBiomarkersScreen extends StatefulWidget {
  const ProfileBiomarkersScreen({super.key});

  @override
  State<ProfileBiomarkersScreen> createState() => _ProfileBiomarkersScreenState();
}

class _ProfileBiomarkersScreenState extends State<ProfileBiomarkersScreen> {
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  late TextEditingController _targetWeightController;
  late TextEditingController _targetWeeksController;

  late Gender _selectedGender;
  late ActivityLevel _selectedActivity;
  late FitnessGoal _selectedGoal;

  @override
  void initState() {
    super.initState();
    final profile = context.read<GymProvider>().profile;
    _nameController = TextEditingController(text: profile.name);
    _weightController = TextEditingController(text: profile.weightKg.toStringAsFixed(1));
    _heightController = TextEditingController(text: profile.heightCm.toStringAsFixed(1));
    _ageController = TextEditingController(text: profile.age.toString());
    _targetWeightController = TextEditingController(text: profile.targetWeightKg.toStringAsFixed(1));
    _targetWeeksController = TextEditingController(text: profile.targetWeeks.toString());

    _selectedGender = profile.gender;
    _selectedActivity = profile.activityLevel;
    _selectedGoal = profile.goal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _targetWeightController.dispose();
    _targetWeeksController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final gym = context.read<GymProvider>();
    final updated = UserProfile(
      name: _nameController.text.trim().isEmpty ? 'Athlete' : _nameController.text.trim(),
      weightKg: double.tryParse(_weightController.text) ?? gym.profile.weightKg,
      heightCm: double.tryParse(_heightController.text) ?? gym.profile.heightCm,
      age: int.tryParse(_ageController.text) ?? gym.profile.age,
      gender: _selectedGender,
      activityLevel: _selectedActivity,
      goal: _selectedGoal,
      targetWeightKg: double.tryParse(_targetWeightController.text) ?? gym.profile.targetWeightKg,
      targetWeeks: int.tryParse(_targetWeeksController.text) ?? gym.profile.targetWeeks,
      customProteinGPerKg: gym.profile.customProteinGPerKg,
    );

    gym.updateProfile(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Biomarkers and Personal Data Updated!'),
        backgroundColor: GymColors.neonGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final profile = gym.profile;
    final (minIdeal, maxIdeal) = profile.idealWeightRange;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GymColors.background,
        elevation: 0,
        title: const Text(
          'BIOMARKERS & METRICS',
          style: TextStyle(
            color: GymColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, color: GymColors.neonGreen, size: 18),
            label: const Text('Save', style: TextStyle(color: GymColors.neonGreen, fontWeight: FontWeight.bold)),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Science & Context Card
          const SectionContextCard(
            item: SectionScienceContext.biomarkersContext,
            initialExpanded: true,
          ),

          // Live Computed Biomarker Grid
          const Text(
            'LIVE CALCULATED BIOMARKERS',
            style: TextStyle(
              color: GymColors.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'BMR',
                  value: profile.bmr.toStringAsFixed(0),
                  unit: 'kcal/day',
                  subtitle: 'Basal Metabolic Rate',
                  color: GymColors.neonCyan,
                  icon: Icons.local_fire_department,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'TDEE',
                  value: profile.tdee.toStringAsFixed(0),
                  unit: 'kcal/day',
                  subtitle: 'Total Daily Burn',
                  color: GymColors.neonGreen,
                  icon: Icons.bolt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'BMI',
                  value: profile.bmi.toStringAsFixed(1),
                  unit: 'kg/m²',
                  subtitle: profile.bmiCategory,
                  color: GymColors.neonAmber,
                  icon: Icons.accessibility_new,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'TARGET PROTEIN',
                  value: '${profile.dailyProteinTargetGrams.toStringAsFixed(0)}g',
                  unit: '${profile.effectiveProteinPerKg.toStringAsFixed(1)}g/kg',
                  subtitle: 'Muscle Synthesis Target',
                  color: GymColors.neonPurple,
                  icon: Icons.fitness_center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ideal Weight Range & Planned Rate Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GymColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: GymColors.surfaceBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Normal BMI Weight Range:', style: TextStyle(color: GymColors.textSecondary, fontSize: 12)),
                    Text(
                      '${minIdeal.toStringAsFixed(1)} kg - ${maxIdeal.toStringAsFixed(1)} kg',
                      style: const TextStyle(color: GymColors.neonGreen, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(color: GymColors.surfaceBorder, height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Planned Growth / Delta Rate:', style: TextStyle(color: GymColors.textSecondary, fontSize: 12)),
                    Text(
                      '${profile.plannedWeeklyGrowthRateKg >= 0 ? '+' : ''}${profile.plannedWeeklyGrowthRateKg.toStringAsFixed(2)} kg/wk',
                      style: const TextStyle(color: GymColors.neonCyan, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Personal Data Input Form
          const Text(
            'PERSONAL PARAMETERS',
            style: TextStyle(
              color: GymColors.neonGreen,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          _buildInputField(label: 'Full Name / Nickname', controller: _nameController, icon: Icons.person),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Current Weight (kg)',
                  controller: _weightController,
                  icon: Icons.monitor_weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: 'Height (cm)',
                  controller: _heightController,
                  icon: Icons.height,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Age (Years)',
                  controller: _ageController,
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: GymColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GymColors.surfaceBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Gender>(
                      value: _selectedGender,
                      isExpanded: true,
                      dropdownColor: GymColors.surface,
                      items: const [
                        DropdownMenuItem(value: Gender.male, child: Text('Male')),
                        DropdownMenuItem(value: Gender.female, child: Text('Female')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedGender = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Activity Level Selector
          const Text('Activity Level Multiplier', style: TextStyle(color: GymColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: GymColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GymColors.surfaceBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ActivityLevel>(
                value: _selectedActivity,
                isExpanded: true,
                dropdownColor: GymColors.surface,
                items: ActivityLevel.values.map((act) {
                  return DropdownMenuItem(
                    value: act,
                    child: Text('${act.label} (×${act.multiplier})', style: const TextStyle(fontSize: 12.5)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedActivity = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fitness Goal Selector
          const Text('Fitness Objective / Phase', style: TextStyle(color: GymColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: GymColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GymColors.surfaceBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<FitnessGoal>(
                value: _selectedGoal,
                isExpanded: true,
                dropdownColor: GymColors.surface,
                items: FitnessGoal.values.map((g) {
                  return DropdownMenuItem(
                    value: g,
                    child: Text(g.label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGoal = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Target Weight & Weeks
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Target Weight (kg)',
                  controller: _targetWeightController,
                  icon: Icons.flag,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: 'Timeframe (Weeks)',
                  controller: _targetWeeksController,
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: GymColors.neonGreen,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: const Icon(Icons.save, size: 20),
            label: const Text('SAVE & RECALCULATE TARGETS'),
            onPressed: _saveProfile,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GymColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GymColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(color: GymColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(color: GymColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: GymColors.textPrimary, fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: GymColors.textSecondary, fontSize: 12),
        prefixIcon: Icon(icon, color: GymColors.neonCyan, size: 18),
      ),
    );
  }
}
