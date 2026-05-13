import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'kegiatan_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _userStats = {};
  List<dynamic> _kegiatan = [];
  List<dynamic> _riwayat = [];
  bool _isLoadingStats = true;
  bool _isLoadingKegiatan = true;
  bool _isLoadingRiwayat = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadKegiatan();
    _loadRiwayat();
  }

  Future<void> _loadStats() async {
    try {
      final s = await ApiService.getStats();
      final us = await ApiService.getUserStats(widget.user['id']);
      if (mounted) setState(() { _stats = s; _userStats = us; _isLoadingStats = false; });
    } catch (_) { if (mounted) setState(() => _isLoadingStats = false); }
  }

  Future<void> _loadKegiatan({String? search}) async {
    setState(() => _isLoadingKegiatan = true);
    try {
      final d = await ApiService.getKegiatan(userId: widget.user['id'], search: search);
      if (mounted) setState(() { _kegiatan = d; _isLoadingKegiatan = false; });
    } catch (_) { if (mounted) setState(() => _isLoadingKegiatan = false); }
  }

  Future<void> _loadRiwayat() async {
    try {
      final d = await ApiService.getRiwayat(widget.user['id']);
      if (mounted) setState(() { _riwayat = d; _isLoadingRiwayat = false; });
    } catch (_) { if (mounted) setState(() => _isLoadingRiwayat = false); }
  }

  Future<void> _daftarKegiatan(int id) async {
    try {
      final r = await ApiService.daftarKegiatan(widget.user['id'], id);
      if (r['success'] == true) {
        _snack(r['message'] ?? 'Berhasil!');
        _loadKegiatan(); _loadRiwayat(); _loadStats();
      } else { _snack(r['error'] ?? 'Gagal.', err: true); }
    } catch (_) { _snack('Server error.', err: true); }
  }

  Future<void> _tukarHadiah(String hadiah, int harga) async {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Tukar Poin', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: Text('Tukar $harga poin untuk $hadiah?', style: GoogleFonts.poppins()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.poppins())),
        ElevatedButton(onPressed: () async {
          Navigator.pop(ctx);
          try {
            final r = await ApiService.tukarHadiah(widget.user['id'], hadiah, harga);
            _snack(r['message'] ?? r['error'] ?? 'Gagal', err: r['success'] != true);
            _loadStats();
          } catch (_) { _snack('Server error', err: true); }
        }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: Text('Ya, Tukar', style: GoogleFonts.poppins(color: Colors.white))),
      ],
    ));
  }

  void _snack(String m, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m, style: GoogleFonts.poppins()),
      backgroundColor: err ? AppTheme.dangerColor : AppTheme.successColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KegiatanKu', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 8), child: Row(children: [
            Text(widget.user['nama'] ?? '', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (v) { if (v == 'logout') _logout(); },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              offset: const Offset(0, 50),
              itemBuilder: (_) => [PopupMenuItem(value: 'logout', child: Row(children: [
                const Icon(Icons.logout, color: AppTheme.dangerColor, size: 20),
                const SizedBox(width: 10),
                Text('Logout', style: GoogleFonts.poppins(fontSize: 14)),
              ]))],
              child: CircleAvatar(radius: 18, backgroundColor: AppTheme.primaryColor,
                child: Text((widget.user['nama'] ?? 'U')[0].toUpperCase(),
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700))),
            ),
          ])),
        ],
      ),
      body: [_buildDashboard(), _buildKegiatan(), _buildRiwayat(), _buildProfile()][_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.mutedColor,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.event_rounded), label: 'Kegiatan'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: Text('Yakin ingin keluar?', style: GoogleFonts.poppins()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.poppins())),
        ElevatedButton(
          onPressed: () { Navigator.pop(ctx); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
          child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
        ),
      ],
    ));
  }

  Widget _buildDashboard() {
    return RefreshIndicator(onRefresh: () async { await _loadStats(); await _loadKegiatan(); },
      child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Hero
          Container(width: double.infinity, padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E3A5F), Color(0xFF6A0DAD)]),
              boxShadow: [BoxShadow(color: AppTheme.accentPurple.withAlpha(51), blurRadius: 24, offset: const Offset(0, 12))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hai, ${widget.user['nama']}! 👋', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Bergabunglah dalam Kegiatan Sosial yang Bermakna', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70, height: 1.5)),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: () => setState(() => _currentIndex = 1),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text('Lihat Kegiatan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withAlpha(51), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.white.withAlpha(64))))),
            ])),
          const SizedBox(height: 24),
          Text('Statistik', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          _isLoadingStats ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            : GridView.count(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.6, children: [
                  _statCard('Kegiatan Aktif', '${_stats['kegiatan_aktif'] ?? 0}', Icons.event_available_rounded, AppTheme.primaryColor),
                  _statCard('Total Pendaftar', '${_stats['total_pendaftar'] ?? 0}', Icons.how_to_reg_rounded, AppTheme.accentPurple),
                  _statCard('Pengguna', '${_stats['total_pengguna'] ?? 0}', Icons.people_rounded, const Color(0xFFFF8C00)),
                  _statCard('Selesai', '${_stats['kegiatan_selesai'] ?? 0}', Icons.check_circle_rounded, AppTheme.successColor),
                ]),
        ])));
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: color, size: 26)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.mutedColor)),
      ])),
    ])));
  }

  Widget _buildKegiatan() {
    return RefreshIndicator(onRefresh: () async => _loadKegiatan(search: _searchController.text),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(controller: _searchController,
          onSubmitted: (v) => _loadKegiatan(search: v),
          decoration: InputDecoration(hintText: 'Cari kegiatan...', prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear),
              onPressed: () { _searchController.clear(); _loadKegiatan(); }) : null),
          onChanged: (_) => setState(() {}))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          Text('Dashboard Kegiatan Sosial', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('${_kegiatan.length} kegiatan', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.mutedColor)),
        ])),
        const SizedBox(height: 10),
        Expanded(child: _isLoadingKegiatan ? const Center(child: CircularProgressIndicator())
          : _kegiatan.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.event_busy_rounded, size: 64, color: AppTheme.mutedColor.withAlpha(100)),
              const SizedBox(height: 16),
              Text('Tidak ada kegiatan', style: GoogleFonts.poppins(color: AppTheme.mutedColor)),
            ]))
          : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _kegiatan.length,
              itemBuilder: (_, i) => _kegiatanCard(_kegiatan[i]))),
      ]));
  }

  Widget _kegiatanCard(Map<String, dynamic> item) {
    final isOpen = item['is_open'] == true;
    final status = item['pendaftaran_status'];
    final kuota = item['kuota'] ?? 0;
    final pendaftar = item['jumlah_pendaftar'] ?? 0;
    String waktu = 'Belum ditentukan';
    if (item['waktu_mulai'] != null && item['waktu_mulai'].toString().isNotEmpty) {
      waktu = item['waktu_mulai'].toString().substring(0, 5);
      if (item['waktu_selesai'] != null && item['waktu_selesai'].toString().isNotEmpty) {
        waktu += ' - ${item['waktu_selesai'].toString().substring(0, 5)}';
      }
      waktu += ' WIB';
    }

    return Card(margin: const EdgeInsets.only(bottom: 14), child: InkWell(borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
        KegiatanDetailScreen(kegiatan: item, user: widget.user, onDaftar: () => _daftarKegiatan(item['id'])))),
      child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(item['nama_kegiatan'] ?? '', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600))),
          const SizedBox(width: 10),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: (isOpen ? AppTheme.successColor : AppTheme.dangerColor).withAlpha(26), borderRadius: BorderRadius.circular(20)),
            child: Text(isOpen ? 'Buka' : 'Tutup', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600,
              color: isOpen ? AppTheme.successColor : AppTheme.dangerColor))),
        ]),
        const SizedBox(height: 12),
        _infoRow(Icons.location_on_rounded, item['lokasi'] ?? '-'),
        const SizedBox(height: 6),
        _infoRow(Icons.calendar_today_rounded, item['tanggal'] ?? '-'),
        const SizedBox(height: 6),
        _infoRow(Icons.access_time_rounded, waktu),
        const SizedBox(height: 6),
        _infoRow(Icons.people_rounded, 'Pendaftar: $pendaftar / ${kuota > 0 ? kuota : "-"}'),
        const SizedBox(height: 14),
        _actionBtn(status, isOpen, item['id']),
      ]))));
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 16, color: AppTheme.mutedColor), const SizedBox(width: 8),
      Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.mutedColor))),
    ]);
  }

  Widget _actionBtn(String? status, bool isOpen, int id) {
    Color bg; String label; IconData icon; bool enabled = false;
    switch (status) {
      case 'pending': bg = AppTheme.warningColor; label = 'Menunggu Verifikasi'; icon = Icons.hourglass_top_rounded; break;
      case 'verified': case 'Diterima': bg = AppTheme.successColor; label = 'Terdaftar'; icon = Icons.check_circle_rounded; break;
      case 'rejected': case 'Ditolak': bg = AppTheme.dangerColor; label = 'Ditolak'; icon = Icons.cancel_rounded; break;
      default: bg = AppTheme.primaryColor; label = 'Daftar'; icon = Icons.how_to_reg_rounded; enabled = isOpen;
    }
    return SizedBox(width: double.infinity, child: ElevatedButton.icon(
      onPressed: enabled ? () => _confirmDaftar(id) : null,
      icon: Icon(icon, size: 18), label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(backgroundColor: bg,
        disabledBackgroundColor: bg.withAlpha(180), disabledForegroundColor: Colors.white,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))));
  }

  void _confirmDaftar(int id) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Konfirmasi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: Text('Yakin ingin mendaftar?', style: GoogleFonts.poppins()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.poppins())),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _daftarKegiatan(id); },
          child: Text('Ya, Daftar', style: GoogleFonts.poppins(color: Colors.white))),
      ],
    ));
  }

  Widget _buildRiwayat() {
    return RefreshIndicator(onRefresh: _loadRiwayat,
      child: _isLoadingRiwayat ? const Center(child: CircularProgressIndicator())
        : _riwayat.isEmpty ? ListView(children: [SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(child: Column(children: [
              Icon(Icons.history_rounded, size: 64, color: AppTheme.mutedColor.withAlpha(100)),
              const SizedBox(height: 16),
              Text('Belum ada riwayat kegiatan.', style: GoogleFonts.poppins(color: AppTheme.mutedColor)),
            ]))])
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.all(16),
              child: Text('Riwayat Kegiatan Anda', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600))),
            Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _riwayat.length, itemBuilder: (_, i) => _riwayatCard(_riwayat[i]))),
          ]));
  }

  Widget _riwayatCard(Map<String, dynamic> item) {
    final status = item['status'] ?? '';
    Color c; String label; IconData icon;
    if (status == 'verified' || status == 'Diterima') { c = AppTheme.successColor; label = 'Terdaftar'; icon = Icons.check_circle_rounded; }
    else if (status == 'pending') { c = AppTheme.warningColor; label = 'Menunggu'; icon = Icons.hourglass_top_rounded; }
    else if (status == 'rejected' || status == 'Ditolak') { c = AppTheme.dangerColor; label = 'Ditolak'; icon = Icons.cancel_rounded; }
    else { c = AppTheme.mutedColor; label = status; icon = Icons.info_rounded; }

    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c.withAlpha(26), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: c, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['nama_kegiatan'] ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('📍 ${item['lokasi'] ?? '-'}', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.mutedColor)),
          Text('📅 ${item['tanggal'] ?? '-'}', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.mutedColor)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: c.withAlpha(26), borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: c))),
      ])));
  }

  Widget _buildProfile() {
    return RefreshIndicator(onRefresh: _loadStats,
      child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Profil & Poin Reward', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _isLoadingStats ? const Center(child: CircularProgressIndicator()) : GridView.count(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.1, children: [
            _statCardProfile('Kegiatan\nBulan Ini', '${_userStats['kegiatan_bulan_ini'] ?? 0}', Icons.event_available_rounded, AppTheme.primaryColor),
            _statCardProfile('Total Poin\nGamifikasi', '${_userStats['poin'] ?? 0}', Icons.star_rounded, const Color(0xFFFFB300)),
          ]),
          const SizedBox(height: 10),
          Center(child: Text('Disetujui = +5 Poin, Ditolak = +2 Poin', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.mutedColor))),
          const SizedBox(height: 30),
          Text('Tukar Hadiah', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          _hadiahCard('Coffee Latte', 50, Icons.local_cafe_rounded, Colors.brown),
          _hadiahCard('Ember', 100, Icons.cleaning_services_rounded, Colors.blue),
          _hadiahCard('Baju / Kaos Relawan', 250, Icons.checkroom_rounded, Colors.purple),
        ])));
  }

  Widget _statCardProfile(String label, String value, IconData icon, Color color) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: color, size: 36),
      const SizedBox(height: 8),
      Text(value, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
      Text(label, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.mutedColor)),
    ])));
  }

  Widget _hadiahCard(String nama, int harga, IconData icon, Color color) {
    int currentPoin = _userStats['poin'] ?? 0;
    bool canAfford = currentPoin >= harga;
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 28)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(nama, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('$harga Poin', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFFFB300))),
        ])),
        ElevatedButton(onPressed: canAfford ? () => _tukarHadiah(nama, harga) : null,
          style: ElevatedButton.styleFrom(backgroundColor: color, disabledBackgroundColor: color.withAlpha(100), disabledForegroundColor: Colors.white, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text('Tukar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)))
      ])));
  }
}
