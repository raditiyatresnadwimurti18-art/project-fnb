import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_kasir_provider.dart';
import '../models/user_model.dart';
import '../core/theme/app_theme.dart';

class KasirDashboardView extends StatefulWidget {
  const KasirDashboardView({super.key});

  @override
  State<KasirDashboardView> createState() => _KasirDashboardViewState();
}

class _KasirDashboardViewState extends State<KasirDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminKasirProvider>(context, listen: false).loadKasirs();
    });
  }

  Future<void> _deleteKasir(UserModel kasir) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kasir'),
        content: Text('Anda yakin ingin menghapus akun ${kasir.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final success = await Provider.of<AdminKasirProvider>(context, listen: false).deleteKasir(kasir.id!);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun kasir berhasil dihapus')),
        );
      } else {
        final err = Provider.of<AdminKasirProvider>(context, listen: false).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err ?? 'Gagal menghapus kasir')),
        );
      }
    }
  }

  Future<void> _showKasirFormDialog([UserModel? kasir]) async {
    final isEdit = kasir != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: kasir?.name ?? '');
    final usernameController = TextEditingController(text: kasir?.username ?? '');
    final emailController = TextEditingController(text: kasir?.email ?? '');
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Kasir' : 'Tambah Kasir Baru'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap *'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username *'),
                  autofillHints: const [],
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    if (!v.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: isEdit ? 'Password Baru (Kosongkan jika tidak diubah)' : 'Password *',
                  ),
                  obscureText: true,
                  autofillHints: const [],
                  validator: (v) {
                    if (!isEdit && v!.isEmpty) {
                      return 'Password wajib diisi untuk kasir baru';
                    }
                    if (v!.isNotEmpty && v.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newKasir = UserModel(
                  id: kasir?.id,
                  name: nameController.text,
                  username: usernameController.text,
                  email: emailController.text,
                  role: 'kasir',
                );
                Navigator.pop(context, {
                  'kasir': newKasir,
                  'password': passwordController.text,
                });
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ).then((result) async {
      if (result != null && result is Map) {
        final kasirData = result['kasir'] as UserModel;
        final passData = result['password'] as String;

        if (!mounted) return;
        final provider = Provider.of<AdminKasirProvider>(context, listen: false);
        bool success;
        
        if (isEdit) {
          success = await provider.updateKasir(kasirData, passData.isEmpty ? null : passData);
        } else {
          success = await provider.createKasir(kasirData, passData);
        }

        if (!mounted) return;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil menyimpan data kasir')),
          );
        } else {
          final err = provider.errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err ?? 'Gagal menyimpan data kasir')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminKasirProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.grey.shade50,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Manajemen Kasir',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showKasirFormDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Kasir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                  const SizedBox(height: 16),
                                  Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: provider.loadKasirs,
                                    child: const Text('Coba Lagi'),
                                  )
                                ],
                              ),
                            )
                          : provider.kasirs.isEmpty
                              ? const Center(child: Text('Tidak ada data kasir.'))
                              : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.kasirs.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final kasir = provider.kasirs[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryLight,
                                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                        ),
                                        child: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              kasir.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '@${kasir.username}',
                                              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              kasir.email ?? 'Tidak ada email',
                                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                                            onPressed: () => _showKasirFormDialog(kasir),
                                            tooltip: 'Edit',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                                            onPressed: () => _deleteKasir(kasir),
                                            tooltip: 'Hapus',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
