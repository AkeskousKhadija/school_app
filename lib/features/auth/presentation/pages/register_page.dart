import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/features/auth/presentation/viewmodels/auth_notifier.dart';
import 'package:school_app/core/errors/failures.dart';
import 'package:school_app/features/shared/domain/entities/user_role.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String role = "teacher"; // "teacher" or "student"
  String? niveau;

  bool loading = false;
  String? error;

  void setRole(String newRole) {
    setState(() {
      role = newRole;
      if (role == "teacher") niveau = null;
    });
  }

  String _formatFailure(Object? err) {
    if (err is Failure) return err.message;
    if (err is Exception) return err.toString();
    return '$err';
  }

  Future<void> register() async {
    setState(() {
      error = null;
    });

    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final email = _emailController.text.trim();
    final fullName = '${nomController.text.trim()} ${prenomController.text.trim()}'.trim();

    if (password != confirm) {
      setState(() {
        error = 'Les mots de passe ne correspondent pas';
      });
      return;
    }

    if (role == 'student' && (niveau == null || niveau!.isEmpty)) {
      setState(() {
        error = 'Veuillez sélectionner un niveau';
      });
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final userRole = role == 'teacher' ? UserRole.professor : UserRole.student;

      await ref.read(authNotifierProvider.notifier).signUp(
            email: email,
            password: password,
            fullName: fullName.isEmpty ? email : fullName,
            role: userRole,
            department: userRole == UserRole.professor ? null : null,
            specialization: userRole == UserRole.professor ? null : null,
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          );

      final authState = ref.read(authNotifierProvider);

      if (authState.hasError) {
        setState(() {
          error = _formatFailure(authState.error);
        });
      } else if (authState.valueOrNull != null) {
        if (!mounted) return;
        context.go('/login');
      } else {
        // fallback
        if (!mounted) return;
        context.go('/login');
      }
    } catch (e) {
      setState(() {
        error = 'Erreur lors de l\'inscription';
      });
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2EFEA),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2E78),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Fais partie de QAMAR !',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    if (authState.hasError || error != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          authState.hasError ? _formatFailure(authState.error) : (error ?? ''),
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),

                    // Toggle Role
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EDE4),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setRole('teacher'),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: role == 'teacher' ? const Color(0xFF3A98C7) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(child: Text('Enseignant')),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setRole('student'),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: role == 'student' ? const Color(0xFF3A98C7) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(child: Text('Etudiant')),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Nom + Prenom
                    Row(
                      children: [
                        Expanded(child: _input('Nom', nomController)),
                        const SizedBox(width: 10),
                        Expanded(child: _input('Prénom', prenomController)),
                      ],
                    ),

                    _input('Email', _emailController),
                    _input('Téléphone', _phoneController),

                    if (role == 'student')
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: niveau,
                            hint: const Text('Sélectionner niveau'),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'primaire', child: Text('Primaire')),
                              DropdownMenuItem(value: 'college', child: Text('Collège')),
                              DropdownMenuItem(value: 'lycee', child: Text('Lycée')),
                            ],
                            onChanged: (val) => setState(() => niveau = val),
                          ),
                        ),
                      ),

                    _input('Mot de passe', _passwordController, obscure: true),
                    _input('Confirmer mot de passe', _confirmPasswordController, obscure: true),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading || authState.isLoading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A98C7),
                          padding: const EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        child: (loading || authState.isLoading)
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("S'inscrire", style: TextStyle(fontSize: 18)),
                      ),
                    ),

                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('← Retour', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(String hint, TextEditingController controller, {bool obscure = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
