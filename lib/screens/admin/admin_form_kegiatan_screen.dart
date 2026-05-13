import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AdminFormKegiatanScreen extends StatefulWidget {
  final Map<String, dynamic>? kegiatan;

  const AdminFormKegiatanScreen({super.key, this.kegiatan});

  @override
  State<AdminFormKegiatanScreen> createState() =>
      _AdminFormKegiatanScreenState();
}

class _AdminFormKegiatanScreenState extends State<AdminFormKegiatanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _namaKegiatanController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _kuotaController = TextEditingController();
  final _waktuMulaiController = TextEditingController();
  final _waktuSelesaiController = TextEditingController();
  
  String _status = 'Buka';
  final List<String> _statusOptions = ['Buka', 'aktif', 'selesai'];

  bool get _isEdit => widget.kegiatan != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _namaKegiatanController.text = widget.kegiatan!['nama_kegiatan'] ?? '';
      _deskripsiController.text = widget.kegiatan!['deskripsi'] ?? '';
      _tanggalController.text = widget.kegiatan!['tanggal'] ?? '';
      _lokasiController.text = widget.kegiatan!['lokasi'] ?? '';
      _kuotaController.text = widget.kegiatan!['kuota']?.toString() ?? '';
      _waktuMulaiController.text = widget.kegiatan!['waktu_mulai']?.toString() ?? '';
      _waktuSelesaiController.text = widget.kegiatan!['waktu_selesai']?.toString() ?? '';
      
      String currentStatus = widget.kegiatan!['status']?.toString() ?? 'Buka';
      if (_statusOptions.contains(currentStatus)) {
        _status = currentStatus;
      }
    }
  }

  @override
  void dispose() {
    _namaKegiatanController.dispose();
    _deskripsiController.dispose();
    _tanggalController.dispose();
    _lokasiController.dispose();
    _kuotaController.dispose();
    _waktuMulaiController.dispose();
    _waktuSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        controller.text = DateFormat('HH:mm:ss').format(dt);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'nama_kegiatan': _namaKegiatanController.text,
      'judul': _namaKegiatanController.text, // Backup compatibility
      'deskripsi': _deskripsiController.text,
      'tanggal': _tanggalController.text,
      'lokasi': _lokasiController.text,
      'kuota': _kuotaController.text,
      'status': _status,
      'waktu_mulai': _waktuMulaiController.text,
      'waktu_selesai': _waktuSelesaiController.text,
    };

    try {
      Map<String, dynamic> response;
      if (_isEdit) {
        data['id'] = widget.kegiatan!['id'];
        response = await ApiService.updateKegiatan(data);
      } else {
        response = await ApiService.addKegiatan(data);
      }

      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context, true); // kembali dan beri sinyal refresh
      } else {
        _showSnackbar(response['error'] ?? 'Gagal menyimpan data', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: Text(
          _isEdit ? 'Edit Kegiatan' : 'Tambah Kegiatan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF0F172A) 
            : const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Informasi Dasar'),
                _buildTextField('Nama Kegiatan', _namaKegiatanController, icon: Icons.event),
                _buildTextField('Deskripsi', _deskripsiController, maxLines: 4, icon: Icons.description),
                
                _buildSectionTitle('Waktu & Tempat'),
                _buildDateField('Tanggal Kegiatan', _tanggalController),
                Row(
                  children: [
                    Expanded(child: _buildTimeField('Waktu Mulai', _waktuMulaiController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimeField('Waktu Selesai', _waktuSelesaiController)),
                  ],
                ),
                _buildTextField('Lokasi', _lokasiController, icon: Icons.location_on),
                
                _buildSectionTitle('Detail Pendaftaran'),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildTextField('Kuota', _kuotaController, isNumber: true, icon: Icons.group),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildDropdownField('Status', _status, _statusOptions, (val) {
                        setState(() => _status = val!);
                      }),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Simpan Data',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
    bool isOptional = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: isOptional
            ? null
            : (value) => value == null || value.isEmpty ? '$label wajib diisi' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryColor) : null,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: _selectDate,
        validator: (value) => value == null || value.isEmpty ? '$label wajib diisi' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectTime(controller),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: const Icon(Icons.access_time, color: AppTheme.primaryColor),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: const Icon(Icons.check_circle_outline, color: AppTheme.primaryColor),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: GoogleFonts.poppins()),
          );
        }).toList(),
      ),
    );
  }
}
