import 'package:supabase/supabase.dart';

/// Script de seed : insère 5 utilisateurs dans la table "user" de Supabase.
///
/// Pour exécuter :
///   dart run test/seed/insert_5_users.dart
///
/// IMPORTANT :
/// - Utilise la clé ANON (pas la service_role).
/// - Si l'insertion échoue à cause de RLS, désactive temporairement
///   les politiques Row Level Security sur la table "user" dans Supabase,
///   ou utilise la clé service_role (à ne jamais committer).
/// - Le nom de table "user" est un mot réservé Postgres → on l'entoure de guillemets.

void main() async {
  const supabaseUrl = 'https://pbksrckspuschimrvlyk.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBia3NyY2tzcHVzY2hpbXJ2bHlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3MDE4ODAsImV4cCI6MjA5NTI3Nzg4MH0.wqM8vwjNlLFBWpV5xp6cZgi_mDxBsyORWcCj1GwQpD0';

  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  final now = DateTime.now().toIso8601String();

  final usersToInsert = [
    {
      'id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
      'email': 'admin@betif.school',
      'full_name': 'Jean Dupont',
      'role': 'admin',
      'created_at': now,
    },
    {
      'id': 'b2c3d4e5-f6a7-8901-bcde-f23456789012',
      'email': 'prof.math@betif.school',
      'full_name': 'Marie Curie',
      'role': 'professor',
      'department': 'Mathématiques',
      'specialization': 'Algèbre',
      'phone': '+33612345678',
      'created_at': now,
    },
    {
      'id': 'c3d4e5f6-a7b8-9012-cdef-345678901234',
      'email': 'prof.physics@betif.school',
      'full_name': 'Albert Einstein',
      'role': 'professor',
      'department': 'Physique',
      'specialization': 'Mécanique Quantique',
      'phone': '+33698765432',
      'created_at': now,
    },
    {
      'id': 'd4e5f6a7-b8c9-0123-def0-456789012345',
      'email': 'etudiant1@betif.school',
      'full_name': 'Lucas Martin',
      'role': 'student',
      'created_at': now,
    },
    {
      'id': 'e5f6a7b8-c9d0-1234-ef01-567890123456',
      'email': 'etudiant2@betif.school',
      'full_name': 'Sophie Laurent',
      'role': 'student',
      'created_at': now,
    },
  ];

  print('🚀 Insertion de 5 utilisateurs dans la table "user"...');

  try {
    for (final user in usersToInsert) {
      await client.from('"user"').upsert(user);
      print('✅ Inséré : ${user['email']} (${user['role']})');
    }
    print('\n🎉 5 utilisateurs insérés avec succès dans la table "user" !');
  } catch (e) {
    print('\n❌ Erreur lors de l\'insertion : $e');
    print('Vérifie :');
    print('  - Que la table "user" existe dans Supabase');
    print('  - Que les politiques RLS autorisent les inserts (ou désactive-les temporairement)');
    print('  - Que les colonnes correspondent exactement à celles de ta table');
  }

  // Fermeture propre
  await Future.delayed(const Duration(milliseconds: 300));
}
