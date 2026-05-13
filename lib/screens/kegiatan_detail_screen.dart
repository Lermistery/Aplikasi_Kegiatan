import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class KegiatanDetailScreen extends StatelessWidget {
  final Map<String, dynamic> kegiatan;
  final Map<String, dynamic> user;
  final VoidCallback onDaftar;

  const KegiatanDetailScreen({
    super.key,
    required this.kegiatan,
    required this.user,
    required this.onDaftar,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = kegiatan['is_open'] == true;
    final status = kegiatan['pendaftaran_status'];
    final kuota = kegiatan['kuota'] ?? 0;
    final pendaftar = kegiatan['jumlah_pendaftar'] ?? 0;

    String waktu = 'Belum ditentukan';
    if (kegiatan['waktu_mulai'] != null && kegiatan['waktu_mulai'].toString().isNotEmpty) {
      waktu = kegiatan['waktu_mulai'].toString().substring(0, 5);
      if (kegiatan['waktu_selesai'] != null && kegiatan['waktu_selesai'].toString().isNotEmpty) {
        waktu += ' - ${kegiatan['waktu_selesai'].toString().substring(0, 5)}';
      }
      waktu += ' WIB';
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                kegiatan['nama_kegiatan'] ?? '',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF6A0DAD), Color(0xFF007BFF)],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.event_rounded, size: 80, color: Colors.white.withAlpha(51)),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isOpen ? AppTheme.successColor : AppTheme.dangerColor).withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOpen ? '🟢 Pendaftaran Buka' : '🔴 Pendaftaran Tutup',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isOpen ? AppTheme.successColor : AppTheme.dangerColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Cards
                  _detailCard(context, Icons.location_on_rounded, 'Lokasi', kegiatan['lokasi'] ?? '-', AppTheme.primaryColor),
                  _detailCard(context, Icons.calendar_today_rounded, 'Tanggal', kegiatan['tanggal'] ?? '-', AppTheme.accentPurple),
                  _detailCard(context, Icons.access_time_rounded, 'Waktu', waktu, const Color(0xFFFF8C00)),
                  _detailCard(context, Icons.people_rounded, 'Kuota', 'Pendaftar: $pendaftar / ${kuota > 0 ? kuota : "Tidak terbatas"}', AppTheme.successColor),

                  if (kegiatan['deskripsi'] != null && kegiatan['deskripsi'].toString().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Deskripsi', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          kegiatan['deskripsi'],
                          style: GoogleFonts.poppins(fontSize: 14, height: 1.6, color: AppTheme.mutedColor),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Action Button
                  _buildButton(context, status, isOpen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard(BuildContext context, IconData icon, String label, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.mutedColor, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String? status, bool isOpen) {
    Color bg; String label; IconData icon; bool enabled = false;
    switch (status) {
      case 'pending': bg = AppTheme.warningColor; label = 'Menunggu Verifikasi'; icon = Icons.hourglass_top_rounded; break;
      case 'verified': case 'Diterima': bg = AppTheme.successColor; label = 'Terdaftar'; icon = Icons.check_circle_rounded; break;
      case 'rejected': case 'Ditolak': bg = AppTheme.dangerColor; label = 'Ditolak'; icon = Icons.cancel_rounded; break;
      default: bg = AppTheme.primaryColor; label = 'Daftar Sekarang'; icon = Icons.how_to_reg_rounded; enabled = isOpen;
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: enabled ? () {
          showDialog(context: context, builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Konfirmasi Pendaftaran', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            content: Text('Yakin ingin mendaftar ke "${kegiatan['nama_kegiatan']}"?', style: GoogleFonts.poppins()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.poppins())),
              ElevatedButton(
                onPressed: () { Navigator.pop(ctx); onDaftar(); Navigator.pop(context); },
                child: Text('Ya, Daftar', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ));
        } : null,
        icon: Icon(icon, size: 20),
        label: Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          disabledBackgroundColor: bg.withAlpha(180),
          disabledForegroundColor: Colors.white,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: bg.withAlpha(100),
        ),
      ),
    );
  }
}
