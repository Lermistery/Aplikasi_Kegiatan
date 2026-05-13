import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'admin_form_kegiatan_screen.dart';

class AdminManageKegiatanScreen extends StatefulWidget {
  const AdminManageKegiatanScreen({super.key});

  @override
  State<AdminManageKegiatanScreen> createState() => _AdminManageKegiatanScreenState();
}

class _AdminManageKegiatanScreenState extends State<AdminManageKegiatanScreen> {
  List<dynamic> _kegiatanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKegiatan();
  }

  Future<void> _fetchKegiatan() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getKegiatan();
      if (mounted) {
        setState(() {
          _kegiatanList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnackbar('Gagal memuat data kegiatan', isError: true);
    }
  }

  Future<void> _deleteKegiatan(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kegiatan?'),
        content: const Text('Apakah Anda yakin ingin menghapus kegiatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      final res = await ApiService.deleteKegiatan(id);
      if (res['success'] == true) {
        _showSnackbar('Kegiatan berhasil dihapus');
        _fetchKegiatan();
      } else {
        _showSnackbar(res['error'] ?? 'Gagal menghapus', isError: true);
      }
    } catch (e) {
      _showSnackbar('Terjadi kesalahan', isError: true);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Kegiatan', style: GoogleFonts.poppins()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _kegiatanList.isEmpty
              ? const Center(child: Text('Tidak ada data kegiatan.'))
              : ListView.builder(
                  itemCount: _kegiatanList.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = _kegiatanList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(
                          item['nama_kegiatan'] ?? 'Tanpa Judul',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${item['tanggal']} | Kuota: ${item['kuota']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminFormKegiatanScreen(kegiatan: item),
                                  ),
                                );
                                if (result == true) _fetchKegiatan();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppTheme.dangerColor),
                              onPressed: () => _deleteKegiatan(int.parse(item['id'].toString())),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminFormKegiatanScreen()),
          );
          if (result == true) _fetchKegiatan();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
