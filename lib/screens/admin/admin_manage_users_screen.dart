import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AdminManageUsersScreen extends StatefulWidget {
  const AdminManageUsersScreen({super.key});

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _userList = [];
  List<dynamic> _registrationList = [];
  bool _isLoadingUsers = true;
  bool _isLoadingRegistrations = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUsers();
    _fetchRegistrations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final list = await ApiService.getUsers();
      if (mounted) {
        setState(() {
          _userList = list;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
      }
      _showSnackbar('Error load users: $e', isError: true);
    }
  }

  Future<void> _fetchRegistrations() async {
    setState(() => _isLoadingRegistrations = true);
    try {
      final list = await ApiService.getPendingRegistrations();
      if (mounted) {
        setState(() {
          _registrationList = list;
          _isLoadingRegistrations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRegistrations = false);
      }
      _showSnackbar('Error load pendaftaran: $e', isError: true);
    }
  }

  Future<void> _deleteUser(int id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Pengguna?'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus pengguna ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.dangerColor,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      final res = await ApiService.deleteUser(id);
      if (res['success'] == true) {
        _showSnackbar('Pengguna berhasil dihapus');
        _fetchUsers();
      } else {
        _showSnackbar(
          res['error'] ?? 'Gagal menghapus pengguna',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    }
  }

  Future<void> _changeRole(int id, String currentRole) async {
    final String newRole = currentRole == 'admin' ? 'user' : 'admin';
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Ubah Role?'),
            content: Text('Ubah role pengguna ini menjadi $newRole?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Ubah'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      final res = await ApiService.updateUserRole(id, newRole);
      if (res['success'] == true) {
        _showSnackbar('Role berhasil diubah');
        _fetchUsers();
      } else {
        _showSnackbar(res['error'] ?? 'Gagal mengubah role', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    }
  }

  Future<void> _verifyRegistration(int id, String status) async {
    try {
      final res = await ApiService.verifyRegistration(id, status);
      if (res['success'] == true) {
        _showSnackbar('Status berhasil diubah menjadi $status');
        _fetchRegistrations(); // Refresh list
      } else {
        _showSnackbar(res['error'] ?? 'Gagal mengubah status', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.dangerColor : AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manajemen & Verifikasi',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppTheme.accentPurple,
          indicatorWeight: 4,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Pengguna'),
            Tab(icon: Icon(Icons.verified_user), text: 'Verifikasi'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [_buildUsersTab(isDark), _buildVerificationTab(isDark)],
        ),
      ),
    );
  }

  Widget _buildUsersTab(bool isDark) {
    if (_isLoadingUsers)
      return const Center(child: CircularProgressIndicator());
    if (_userList.isEmpty)
      return const Center(child: Text('Tidak ada data pengguna.'));

    return ListView.builder(
      itemCount: _userList.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final user = _userList[index];
        final isRoleAdmin = user['role'] == 'admin';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: isRoleAdmin
                      ? AppTheme.accentPurple
                      : AppTheme.primaryColor,
                  child: Text(
                    (user['nama'] ?? 'U')
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['nama'] ?? 'Tanpa Nama',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user['email'] ?? '-',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isRoleAdmin
                                      ? AppTheme.accentPurple
                                      : Colors.blueGrey)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isRoleAdmin
                                ? AppTheme.accentPurple
                                : Colors.blueGrey,
                          ),
                        ),
                        child: Text(
                          (user['role'] ?? 'user').toString().toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isRoleAdmin
                                ? AppTheme.accentPurple
                                : Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        isRoleAdmin
                            ? Icons.admin_panel_settings
                            : Icons.person_outline,
                        color: isRoleAdmin
                            ? AppTheme.accentPurple
                            : Colors.blueGrey,
                      ),
                      tooltip: 'Ubah Role',
                      onPressed: () => _changeRole(
                        int.parse(user['id'].toString()),
                        user['role'] ?? 'user',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.dangerColor,
                      ),
                      tooltip: 'Hapus User',
                      onPressed: () =>
                          _deleteUser(int.parse(user['id'].toString())),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationTab(bool isDark) {
    if (_isLoadingRegistrations)
      return const Center(child: CircularProgressIndicator());
    if (_registrationList.isEmpty)
      return const Center(child: Text('Tidak ada pendaftaran menunggu.'));

    return ListView.builder(
      itemCount: _registrationList.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final reg = _registrationList[index];
        final status = reg['status'] ?? 'pending';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        reg['nama_kegiatan'] ?? 'Kegiatan Tidak Diketahui',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      reg['nama_user'] ?? 'Anonim',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      reg['created_at'] ?? '-',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (status == 'pending') ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _verifyRegistration(
                          int.parse(reg['id'].toString()),
                          'rejected',
                        ),
                        icon: const Icon(
                          Icons.close,
                          color: AppTheme.dangerColor,
                        ),
                        label: Text(
                          'Tolak',
                          style: GoogleFonts.poppins(
                            color: AppTheme.dangerColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.dangerColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _verifyRegistration(
                          int.parse(reg['id'].toString()),
                          'verified',
                        ),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: Text(
                          'Setujui',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'verified':
        color = AppTheme.successColor;
        break;
      case 'rejected':
        color = AppTheme.dangerColor;
        break;
      default:
        color = Colors.orange;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
