import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/gym_provider.dart';
import '../../models/fee_model.dart';
import '../../theme/gym_theme.dart';

class AdminFeesView extends StatefulWidget {
  const AdminFeesView({super.key});

  @override
  State<AdminFeesView> createState() => _AdminFeesViewState();
}

class _AdminFeesViewState extends State<AdminFeesView> {
  String _selectedMonthFilter = 'All';
  String _statusFilter = 'All'; // 'All', 'Pending', 'Overdue', 'Paid'

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final summaries = gym.getMonthlyFeeSummaries();

    final allMonths = ['All', ...summaries.map((s) => s.monthYear)];

    // Filtered records
    var allRecords = gym.feeRecords;
    if (_selectedMonthFilter != 'All') {
      allRecords = allRecords.where((f) => f.monthYear == _selectedMonthFilter).toList();
    }
    if (_statusFilter != 'All') {
      if (_statusFilter == 'Paid') {
        allRecords = allRecords.where((f) => f.isPaid).toList();
      } else if (_statusFilter == 'Pending') {
        allRecords = allRecords.where((f) => f.isPending).toList();
      } else if (_statusFilter == 'Overdue') {
        allRecords = allRecords.where((f) => f.isOverdue).toList();
      }
    }

    final totalCollected = gym.totalRevenueAllTime;
    final totalPending = gym.totalPendingDuesAllTime;
    final totalDefaulters = gym.totalDefaultersCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FINANCIAL OPERATIONS & DUES TRACKER',
                    style: TextStyle(
                      color: GymColors.neonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fees & Monthly Pending Breakdown',
                    style: TextStyle(
                      color: GymColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overview KPI Ribbon
          Row(
            children: [
              _buildMetricCard(
                title: 'TOTAL COLLECTED REVENUE',
                value: '\$${totalCollected.toStringAsFixed(0)}',
                color: GymColors.neonGreen,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                title: 'TOTAL PENDING DUES',
                value: '\$${totalPending.toStringAsFixed(0)}',
                color: GymColors.neonAmber,
                icon: Icons.pending_actions,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                title: 'OVERDUE MEMBERS',
                value: '$totalDefaulters',
                color: GymColors.neonRed,
                icon: Icons.error_outline,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Section 1: MONTH-BY-MONTH PENDING MATRIX
          const Text(
            'MONTHLY PENDING & COLLECTION SUMMARY',
            style: TextStyle(
              color: GymColors.neonCyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: summaries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, idx) {
              final summary = summaries[idx];
              return _buildMonthSummaryCard(context, summary, gym);
            },
          ),

          const SizedBox(height: 32),

          // Section 2: DETAILED TRANSACTIONS & DUES TABLE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'INDIVIDUAL FEE RECORDS & LEDGER',
                style: TextStyle(
                  color: GymColors.neonGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              // Filter options
              Row(
                children: [
                  // Month filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: GymColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GymColors.cardBorder),
                    ),
                    child: DropdownButton<String>(
                      value: allMonths.contains(_selectedMonthFilter) ? _selectedMonthFilter : 'All',
                      dropdownColor: GymColors.surface,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      items: allMonths.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m == 'All' ? 'All Months' : _formatMonthKey(m)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedMonthFilter = v ?? 'All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: GymColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GymColors.cardBorder),
                    ),
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      dropdownColor: GymColors.surface,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      items: ['All', 'Paid', 'Pending', 'Overdue'].map((s) {
                        return DropdownMenuItem(value: s, child: Text('Status: $s'));
                      }).toList(),
                      onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fee Records List
          if (allRecords.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: GymColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GymColors.cardBorder),
              ),
              child: const Text(
                'No fee records found for the selected filters.',
                style: TextStyle(color: GymColors.textMuted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allRecords.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final fee = allRecords[idx];
                return _buildFeeRecordCard(context, fee, gym);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: GymColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GymColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: GymColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSummaryCard(BuildContext context, MonthlyFeeSummary s, GymProvider gym) {
    final pendingRecords = s.records.where((r) => !r.isPaid).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GymColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GymColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: GymColors.neonGreen.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: GymColors.neonGreen.withAlpha((0.3 * 255).round())),
                    ),
                    child: Text(
                      s.monthLabel.toUpperCase(),
                      style: const TextStyle(color: GymColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Collected: \$${s.totalCollected.toStringAsFixed(0)} / \$${s.totalExpected.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: s.totalPending > 0
                      ? GymColors.neonAmber.withAlpha((0.15 * 255).round())
                      : GymColors.neonGreen.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.totalPending > 0
                      ? '${s.pendingCount} PENDING DUES (\$${s.totalPending.toStringAsFixed(0)})'
                      : 'ALL DUES SETTLED',
                  style: TextStyle(
                    color: s.totalPending > 0 ? GymColors.neonAmber : GymColors.neonGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: s.totalExpected > 0 ? s.totalCollected / s.totalExpected : 0.0,
              backgroundColor: GymColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                s.totalPending > 0 ? GymColors.neonGreen : GymColors.neonCyan,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),

          // Pending members list for this month if any
          if (pendingRecords.isNotEmpty) ...[
            const Text(
              'PENDING / OVERDUE MEMBERS FOR THIS MONTH:',
              style: TextStyle(color: GymColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pendingRecords.map((r) {
                return InkWell(
                  onTap: () => _openRecordPaymentModal(context, r, gym),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: GymColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: r.isOverdue ? GymColors.neonRed.withAlpha((0.5 * 255).round()) : GymColors.cardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          r.memberName,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${r.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: r.isOverdue ? GymColors.neonRed : GymColors.neonAmber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: GymColors.neonGreen.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'MARK PAID',
                            style: TextStyle(color: GymColors.neonGreen, fontSize: 9, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeeRecordCard(BuildContext context, FeeRecord fee, GymProvider gym) {
    final statusColor = fee.isPaid
        ? GymColors.neonGreen
        : (fee.isOverdue ? GymColors.neonRed : GymColors.neonAmber);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GymColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GymColors.cardBorder),
      ),
      child: Row(
        children: [
          // Month badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: GymColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              fee.formattedMonth,
              style: const TextStyle(color: GymColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 14),

          // Member info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fee.memberName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  fee.isPaid
                      ? 'Paid on ${fee.formattedPaidDate} via ${fee.paymentMethod ?? 'Standard'} • Ref: ${fee.receiptNumber ?? 'N/A'}'
                      : 'Due by ${fee.formattedDueDate} • Status: ${fee.status}',
                  style: TextStyle(
                    color: fee.isPaid ? GymColors.textSecondary : GymColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '\$${fee.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 14),

          // Status Badge / Action
          if (fee.isPaid)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: GymColors.neonGreen.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: GymColors.neonGreen.withAlpha((0.4 * 255).round())),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, size: 14, color: GymColors.neonGreen),
                  SizedBox(width: 4),
                  Text('PAID', style: TextStyle(color: GymColors.neonGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GymColors.neonGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                minimumSize: Size.zero,
              ),
              onPressed: () => _openRecordPaymentModal(context, fee, gym),
              child: const Text('SETTLE FEE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
            ),
        ],
      ),
    );
  }

  void _openRecordPaymentModal(BuildContext context, FeeRecord fee, GymProvider gym) {
    String paymentMethod = 'UPI / GPay';
    final notesController = TextEditingController();
    final receiptController = TextEditingController(
      text: 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: GymColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: GymColors.cardBorder),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              child: const Icon(Icons.receipt_long, color: GymColors.neonGreen),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Record Fee Payment',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: GymColors.textMuted),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const Divider(color: GymColors.cardBorder, height: 24),

                    // Payment summary block
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: GymColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Member Name:', style: TextStyle(color: GymColors.textSecondary, fontSize: 12)),
                              Text(fee.memberName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Billing Period:', style: TextStyle(color: GymColors.textSecondary, fontSize: 12)),
                              Text(fee.formattedMonth, style: const TextStyle(color: GymColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Fee Amount:', style: TextStyle(color: GymColors.textSecondary, fontSize: 12)),
                              Text('\$${fee.amount.toStringAsFixed(2)}', style: const TextStyle(color: GymColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'PAYMENT METHOD',
                      style: TextStyle(color: GymColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: paymentMethod,
                      dropdownColor: GymColors.surface,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: GymColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: GymColors.cardBorder),
                        ),
                      ),
                      items: ['UPI / GPay', 'Cash', 'Credit/Debit Card', 'Bank Transfer'].map((m) {
                        return DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (v) => setModalState(() => paymentMethod = v ?? 'Cash'),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: receiptController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Receipt / Transaction Ref',
                        labelStyle: const TextStyle(color: GymColors.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: GymColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: GymColors.cardBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: notesController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Payment Notes (Optional)',
                        labelStyle: const TextStyle(color: GymColors.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: GymColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: GymColors.cardBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
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
                          label: const Text('CONFIRM PAYMENT', style: TextStyle(fontWeight: FontWeight.w900)),
                          onPressed: () {
                            gym.recordFeePayment(
                              feeId: fee.id,
                              paymentMethod: paymentMethod,
                              receiptNumber: receiptController.text.trim(),
                              notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                            );
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Payment of \$${fee.amount.toStringAsFixed(0)} recorded for ${fee.memberName}!'),
                                backgroundColor: GymColors.neonGreen,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatMonthKey(String my) {
    try {
      final parts = my.split('-');
      if (parts.length == 2) {
        final d = DateTime(int.parse(parts[0]), int.parse(parts[1]));
        return DateFormat('MMMM yyyy').format(d);
      }
    } catch (_) {}
    return my;
  }
}
