class ScienceGuideItem {
  final String title;
  final String category;
  final String summary;
  final String scientificExplanation;
  final String formulaBreakdown;
  final List<String> practicalActionTips;
  final String icon;

  const ScienceGuideItem({
    required this.title,
    required this.category,
    required this.summary,
    required this.scientificExplanation,
    this.formulaBreakdown = '',
    required this.practicalActionTips,
    required this.icon,
  });
}

class SectionScienceContext {
  // 1. BIOMARKERS & ENERGY BALANCE CONTEXT
  static const ScienceGuideItem biomarkersContext = ScienceGuideItem(
    title: 'Energy Balance & Metabolic Rate Science',
    category: 'Biomarkers & BMR',
    icon: '⚡',
    summary:
        'Your body requires energy just to sustain breathing, organ function, and cellular turnover (BMR). Factoring in physical movement yields your Total Daily Energy Expenditure (TDEE).',
    scientificExplanation:
        'We utilize the Mifflin-St Jeor Equation, clinically validated by the American Dietetic Association as the most accurate non-calorimetric estimate for healthy adults.\n\n'
        '• BMR represents 60-70% of total calorie burn.\n'
        '• NEAT (Non-Exercise Activity Thermogenesis) like walking, fidgeting, and posture accounts for 15-20% and varies heavily by individual.\n'
        '• TEF (Thermic Effect of Food) accounts for ~10%, with protein having the highest thermic cost (20-30% of its energy burned during digestion).\n'
        '• EAT (Exercise Activity) represents the targeted gym output.',
    formulaBreakdown:
        'Mifflin-St Jeor Equation:\n'
        'Men: BMR = (10 × weight_kg) + (6.25 × height_cm) - (5 × age_yrs) + 5\n'
        'Women: BMR = (10 × weight_kg) + (6.25 × height_cm) - (5 × age_yrs) - 161\n\n'
        'TDEE = BMR × Activity Factor (1.2 to 1.9)',
    practicalActionTips: [
      'To gain lean muscle, maintain a moderate caloric surplus (+250 to +350 kcal/day).',
      'For fat loss without losing muscle, aim for a 400-500 kcal deficit, preserving 2.0-2.4g protein/kg.',
      'BMI is a population metric. For muscular lifters, track waist-to-height ratio and body circumferences instead.',
    ],
  );

  // 2. PROTEIN & MACRO NUTRITION CONTEXT
  static const ScienceGuideItem proteinContext = ScienceGuideItem(
    title: 'Muscle Protein Synthesis (MPS) & Nutrient Timing',
    category: 'Protein Engine',
    icon: '🥩',
    summary:
        'Muscle growth requires net positive protein balance: Muscle Protein Synthesis (MPS) must exceed Muscle Protein Breakdown (MPB).',
    scientificExplanation:
        'Peer-reviewed sports nutrition meta-analyses (Morton et al., British Journal of Sports Medicine) confirm that 1.6g to 2.2g of protein per kg of bodyweight optimizes resistance training adaptations.\n\n'
        '• The Leucine Threshold: Each meal requires ~2.5g to 3.0g of the essential amino acid Leucine to trigger the mTOR pathway for MPS.\n'
        '• Protein Distribution: Spreading protein across 3 to 5 meals (0.40 - 0.55g/kg/meal) stimulates MPS pulses repeatedly throughout 24 hours.\n'
        '• Carbohydrates spare muscle proteins by replenishing intramuscular glycogen and fueling high-intensity glycolytic lifting sets.\n'
        '• Healthy Fats maintain lipid membranes and optimize endogenous testosterone and steroid hormone synthesis.',
    formulaBreakdown:
        'Daily Protein Goal (Hypertrophy): Bodyweight (kg) × 2.0g to 2.2g\n'
        'Daily Protein Goal (Cutting Deficit): Bodyweight (kg) × 2.2g to 2.4g\n'
        'Carbs Energy: 4 kcal per gram | Protein Energy: 4 kcal per gram | Fats Energy: 9 kcal per gram',
    practicalActionTips: [
      'Consume 25-40g high-quality complete protein (Whey, Eggs, Chicken, Beef, Soy) within 1-2 hours post-workout.',
      'Drink 35-45ml of water per kg of bodyweight to maintain muscular intracellular hydration and creatine uptake.',
      'On intense lifting days, bias carbohydrates around pre- and post-workout windows for peak performance.',
    ],
  );

  // 3. GROWTH RATE & VELOCITY CONTEXT
  static const ScienceGuideItem growthRateContext = ScienceGuideItem(
    title: 'Hypertrophy Velocity & Weight Trend Smoothing',
    category: 'Growth Analytics',
    icon: '📈',
    summary:
        'Skeletal muscle tissue synthesis has physiological upper limits. Tracking your weekly growth velocity prevents unnecessary body fat accumulation.',
    scientificExplanation:
        'According to the McDonald and Helms Natural Hypertrophy Models:\n'
        '• Beginner lifters can gain ~1.0-1.5% of bodyweight per month in pure muscle.\n'
        '• Intermediate lifters (1-3 yrs lifting) can gain ~0.5-1.0% per month.\n'
        '• Advanced lifters (>3 yrs lifting) gain ~0.25-0.5% per month.\n\n'
        'Daily weight fluctuates 1-3 kg due to sodium intake, glycogen storage (each gram of glycogen holds ~3-4g of water), and bowel contents. We analyze multi-point exponential trendlines to reveal your true physiological growth rate.',
    formulaBreakdown:
        'Weekly Growth Velocity = [(Current Weight - Starting Weight) / Days] × 7\n'
        'Ideal Hypertrophy Pace: +0.25% to +0.50% bodyweight per week (~0.2 - 0.4 kg/week)\n'
        'Ideal Fat Loss Pace: -0.5% to -1.0% bodyweight per week (~0.4 - 0.8 kg/week)',
    practicalActionTips: [
      'Weigh yourself first thing in the morning after using the restroom and before eating/drinking.',
      'If gaining >0.5kg/week for 3 consecutive weeks while waist measurement increases, reduce daily surplus by 150 kcal.',
      'Monitor arm and chest circumference growth against waist size to ensure lean tissue accretion.',
    ],
  );

  // 4. WORKOUT SPLIT & RECOVERY CONTEXT
  static const ScienceGuideItem workoutSplitContext = ScienceGuideItem(
    title: 'Training Split Dynamics & Hypertrophy Windows',
    category: 'Workout Separation',
    icon: '🏋️',
    summary:
        'Splitting workouts balances localized muscular tension, systemic CNS fatigue, and recovery windows for maximum structural hypertrophy.',
    scientificExplanation:
        'Following a resistance workout, Muscle Protein Synthesis remains elevated for approximately 24 to 48 hours before returning to baseline.\n\n'
        '• Push / Pull / Legs (PPL): Hits muscle groups with 2x weekly frequency. Synergistic movements (e.g. chest press + triceps) prevent joint overuse.\n'
        '• Upper / Lower: High neuromuscular recovery with 4 days per week, allowing heavy compound progression.\n'
        '• Bro Split: Delivers high per-session volume (16-20 sets) to single muscle groups. Ideal for lifters who require maximum metabolic pump.\n'
        '• Full Body: High frequency (3x/wk) with low per-session volume. Superb for strength motor learning and busy schedules.',
    formulaBreakdown:
        'Effective Hypertrophy Volume: 10 to 20 hard working sets per muscle group per week.\n'
        'Recovery Window: 48 to 72 hours per muscle before re-stimulation.',
    practicalActionTips: [
      'Choose a split that matches your weekly schedule consistency (Consistency > Split type).',
      'Ensure 10-20 weekly sets per muscle group taken within 1 to 3 Reps in Reserve (RIR).',
      'Allow at least 48 hours before training the same primary muscle group heavy again.',
    ],
  );

  // 5. ACTIVE SESSION & 1RM STRENGTH CONTEXT
  static const ScienceGuideItem activeSessionContext = ScienceGuideItem(
    title: 'RPE, Progressive Overload & 1RM Calculations',
    category: 'Active Workout',
    icon: '⏱️',
    summary:
        'Tracking load, repetitions, and Rate of Perceived Exertion (RPE) ensures progressive overload while auto-regulating fatigue.',
    scientificExplanation:
        'Progressive Overload is the foundational stimulus for muscular adaptation. You must gradually increase mechanical tension over time by adding weight, reps, or improving execution quality.\n\n'
        '• RPE (Borg Scale Modified for Lifting):\n'
        '  - RPE 10: Maximum effort, 0 reps in reserve (RIR 0).\n'
        '  - RPE 9: 1 rep left in the tank (RIR 1).\n'
        '  - RPE 8: 2 reps left in the tank (RIR 2) — ideal working set sweet spot.\n'
        '• Rest Intervals: Compound lifts (Squat, Bench, Deadlift, OHP) require 2.5 to 3.5 minutes to restore phosphocreatine (PCr) and ATP stores for high motor unit recruitment. Isolation movements require 60 to 90 seconds.',
    formulaBreakdown:
        'Epley 1-Rep Max Formula: 1RM = Weight × (1 + Reps / 30)\n'
        'Brzycki 1-Rep Max Formula: 1RM = Weight × (36 / (37 - Reps))\n'
        'Session Volume = Σ (Weight_kg × Reps) across all completed working sets',
    practicalActionTips: [
      'Aim for RPE 7.5 to 9 on most working sets. Reserve RPE 10 (absolute failure) for the last set of isolation movements.',
      'Use the rest timer diligently: short-changing rest on heavy squats lowers motor unit output on subsequent sets.',
      'Log your sets accurately to track lifetime personal records (PRs).',
    ],
  );
}
