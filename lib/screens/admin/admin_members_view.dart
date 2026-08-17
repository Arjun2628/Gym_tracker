import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/gym_provider.dart';
import '../../models/member_model.dart';
import '../../theme/gym_theme.dart';
import 'add_member_dialog.dart';

class AdminMembersView extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const AdminMembersView({super.key, this.onNavigateTab});

  @override
  State<AdminMembersView> createState() => _AdminMembersViewState();
}

class _AdminMembersViewState extends State<AdminMembersView> {
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();

    var filtered = gym.members.where((m) {
      final matchesQuery = _searchQuery.isEmpty ||
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.phone.contains(_searchQuery) ||
          m.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _statusFilter == 'All' || m.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Add Member Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MEMBERS DIRECTORY & PROFILES',
                    style: TextStyle(
                      color: GymColors.neonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All Members (${gym.members.length})',
                    style: const TextStyle(
                      color: GymColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymColors.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('ADD MEMBER', style: TextStyle(fontWeight: FontWeight.w900)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddMemberDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GymColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GymColors.cardBorder),
            ),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by member name, phone number, or email...',
                    hintStyle: const TextStyle(color: GymColors.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: GymColors.neonGreen, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: GymColors.textMuted),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: GymColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Active', 'Pending Fee', 'Overdue', 'Inactive'].map((status) {
                      final isSelected = _statusFilter == status;
                      Color chipColor = GymColors.textSecondary;
                      if (status == 'Active') chipColor = GymColors.neonGreen;
                      if (status == 'Pending Fee') chipColor = GymColors.neonAmber;
                      if (status == 'Overdue') chipColor = GymColors.neonRed;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : GymColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          selected: isSelected,
                          selectedColor: chipColor,
                          backgroundColor: GymColors.surface,
                          side: BorderSide(
                            color: isSelected ? chipColor : GymColors.cardBorder,
                          ),
                          onSelected: (_) => setState(() => _statusFilter = status),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Members List Cards
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: GymColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GymColors.cardBorder),
              ),
              child: const Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: GymColors.textMuted),
                  SizedBox(height: 12),
                  Text(
                    'No members matched your search criteria',
                    style: TextStyle(color: GymColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final m = filtered[idx];
                return _buildMemberCard(context, m, gym);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, MemberModel m, GymProvider gym) {
    final statusColor = m.status == 'Active'
        ? GymColors.neonGreen
        : (m.status == 'Overdue' ? GymColors.neonRed : GymColors.neonAmber);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GymColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GymColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: GymColors.surface,
            child: Text(
              m.name.isNotEmpty ? m.name.substring(0, 1).toUpperCase() : 'M',
              style: const TextStyle(
                color: GymColors.neonGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      m.name,
                      style: const TextStyle(
                        color: GymColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha((0.15 * 255).round()),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor.withAlpha((0.4 * 255).round())),
                      ),
                      child: Text(
                        m.status.toUpperCase(),
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${m.phone} • ${m.email} • Age: ${m.age} • ${m.gender}',
                  style: const TextStyle(color: GymColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: GymColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${m.planType} Plan (\$${m.monthlyFee.toStringAsFixed(0)}/mo)',
                        style: const TextStyle(color: GymColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: GymColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Due Day: ${m.dueDayOfMonth}th',
                        style: const TextStyle(color: GymColors.textMuted, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: GymColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${m.totalWorkoutsCompleted} Workouts • Streak: ${m.attendanceStreak}d',
                        style: const TextStyle(color: GymColors.neonAmber, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              IconButton(
                tooltip: 'Edit Member',
                icon: const Icon(Icons.edit_outlined, color: GymColors.textSecondary, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddMemberDialog(memberToEdit: m),
                  );
                },
              ),
              IconButton(
                tooltip: 'View Member Details',
                icon: const Icon(Icons.visibility_outlined, color: GymColors.neonGreen, size: 20),
                onPressed: () => _showMemberDetailsModal(context, m, gym),
              ),
              IconButton(
                tooltip: 'Delete Member',
                icon: const Icon(Icons.delete_outline, color: GymColors.neonRed, size: 20),
                onPressed: () => _confirmDelete(context, m, gym),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMemberDetailsModal(BuildContext context, MemberModel m, GymProvider gym) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GymColors.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: GymColors.neonGreen.withAlpha((0.2 * 255).round()),
                          child: Text(
                            m.name.substring(0, 1),
                            style: const TextStyle(color: GymColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Joined: ${DateFormat('dd MMM yyyy').format(m.joinDate)}',
                              style: const TextStyle(color: GymColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: GymColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(color: GymColors.cardBorder, height: 28),

                // Metrics Row
                Row(
                  children: [
                    _buildDetailMetric('Weight', '${m.currentWeight.toStringAsFixed(1)} kg', GymColors.neonCyan),
                    const SizedBox(width: 12),
                    _buildDetailMetric('Workouts', '${m.totalWorkoutsCompleted}', GymColors.neonGreen),
                    const SizedBox(width: 12),
                    _buildDetailMetric('Streak', '${m.attendanceStreak} days', GymColors.neonAmber),
                    const SizedBox(width: 12),
                    _buildDetailMetric('Fee / Month', '\$${m.monthlyFee.toStringAsFixed(0)}', GymColors.neonPurple),
                  ],
                ),
                const SizedBox(height: 20),

                // Membership & Payment Info
                const Text(
                  'MEMBERSHIP SPECIFICATIONS',
                  style: TextStyle(color: GymColors.neonGreen, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                _buildInfoRow('Plan Tier', m.planType),
                _buildInfoRow('Monthly Fee', '\$${m.monthlyFee.toStringAsFixed(2)}'),
                _buildInfoRow('Due Day of Month', '${m.dueDayOfMonth}th of every month'),
                _buildInfoRow('Status', m.status),
                _buildInfoRow('Phone', m.phone),
                _buildInfoRow('Email', m.email.isNotEmpty ? m.email : 'N/A'),
                if (m.emergencyContact != null) _buildInfoRow('Emergency Contact', m.emergencyContact!),
                if (m.notes != null) _buildInfoRow('Special Notes', m.notes!),

                const SizedBox(height: 20),
                // Assigned Split and Diet
                const Text(
                  'ASSIGNED PROTOCOLS',
                  style: TextStyle(color: GymColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                _buildInfoRow('Assigned Split ID', m.assignedSplitId ?? 'split_ppl'),
                _buildInfoRow('Assigned Diet ID', m.assignedDietId ?? 'diet_hypertrophy_mass'),

                const SizedBox(height: 24),
                // Switch App Context to This Member button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GymColors.neonCyan,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.switch_account, size: 18),
                  label: Text(
                    'SWITCH USER APP CONTEXT TO ${m.name.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  onPressed: () {
                    gym.setActiveMember(m.id);
                    gym.setRole(AppRole.user);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Switched active member context to ${m.name} in Member App!'),
                        backgroundColor: GymColors.neonCyan,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailMetric(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: GymColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: GymColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: GymColors.textMuted, fontSize: 10)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: GymColors.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: GymColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MemberModel m, GymProvider gym) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: GymColors.cardBg,
          title: const Text('Delete Member?', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to remove ${m.name}? This will also delete their fee history and workout logs.',
            style: const TextStyle(color: GymColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCEL', style: TextStyle(color: GymColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: GymColors.neonRed, foregroundColor: Colors.white),
              onPressed: () {
                gym.deleteMember(m.id);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${m.name} from gym database'),
                    backgroundColor: GymColors.neonRed,
                  ),
                );
              },
              child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
