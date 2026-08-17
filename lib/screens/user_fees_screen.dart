import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/gym_provider.dart';
import '../theme/gym_theme.dart';

class UserFeesScreen extends StatelessWidget {
  const UserFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final activeMember = gym.activeMember;

    if (activeMember == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Membership & Fees'),
          backgroundColor: GymColors.surface,
        ),
        body: const Center(
          child: Text('No active member found.', style: TextStyle(color: GymColors.textMuted)),
        ),
      );
    }

    final myFees = gym.feeRecords.where((f) => f.memberId == activeMember.id).toList();
    final currentFee = myFees.isNotEmpty ? myFees.first : null;

    final statusColor = activeMember.status == 'Active'
        ? GymColors.neonGreen
        : (activeMember.status == 'Overdue' ? GymColors.neonRed : GymColors.neonAmber);

    return Scaffold(
      backgroundColor: GymColors.background,
      appBar: AppBar(
        backgroundColor: GymColors.surface,
        title: const Text(
          'MY MEMBERSHIP & FEES',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withAlpha((0.4 * 255).round())),
            ),
            child: Row(
              children: [
                Icon(Icons.verified, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  activeMember.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Membership Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GymColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GymColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeMember.name,
                            style: const TextStyle(
                              color: GymColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Plan: ${activeMember.planType} Membership',
                            style: const TextStyle(color: GymColors.neonCyan, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: GymColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GymColors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            const Text('MONTHLY FEE', style: TextStyle(color: GymColors.textMuted, fontSize: 9)),
                            Text(
                              '\$${activeMember.monthlyFee.toStringAsFixed(0)}',
                              style: const TextStyle(color: GymColors.neonGreen, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: GymColors.cardBorder, height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniInfo('Member ID', activeMember.id),
                      _buildMiniInfo('Due Day', '${activeMember.dueDayOfMonth}th of month'),
                      _buildMiniInfo('Joined', DateFormat('MMM yyyy').format(activeMember.joinDate)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Current Month Status Card
            if (currentFee != null) ...[
              const Text(
                'CURRENT BILLING PERIOD',
                style: TextStyle(color: GymColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GymColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentFee.isPaid
                        ? GymColors.neonGreen.withAlpha((0.3 * 255).round())
                        : (currentFee.isOverdue ? GymColors.neonRed : GymColors.neonAmber),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (currentFee.isPaid ? GymColors.neonGreen : GymColors.neonAmber).withAlpha((0.15 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        currentFee.isPaid ? Icons.check : Icons.access_time,
                        color: currentFee.isPaid ? GymColors.neonGreen : GymColors.neonAmber,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentFee.formattedMonth,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentFee.isPaid
                                ? 'Paid on ${currentFee.formattedPaidDate} via ${currentFee.paymentMethod ?? 'Direct'}'
                                : 'Due by ${currentFee.formattedDueDate}',
                            style: const TextStyle(color: GymColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${currentFee.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: currentFee.isPaid ? GymColors.neonGreen : GymColors.neonAmber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Payment History List
            const Text(
              'PAYMENT & RECEIPT HISTORY',
              style: TextStyle(color: GymColors.neonCyan, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 10),

            if (myFees.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('No fee transaction history found.', style: TextStyle(color: GymColors.textMuted)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myFees.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final fee = myFees[idx];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GymColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GymColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fee.formattedMonth,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              fee.isPaid
                                  ? 'Receipt: ${fee.receiptNumber ?? 'REC-AUTO'} • Method: ${fee.paymentMethod ?? 'N/A'}'
                                  : 'Status: ${fee.status}',
                              style: const TextStyle(color: GymColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${fee.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: fee.isPaid ? GymColors.neonGreen : GymColors.neonAmber,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              fee.status.toUpperCase(),
                              style: TextStyle(
                                color: fee.isPaid ? GymColors.neonGreen : GymColors.neonAmber,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: GymColors.textMuted, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
