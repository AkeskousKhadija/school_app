import 'dart:io';
import 'package:supabase/supabase.dart';

/// Script de test qui insère 5 utilisateurs dans la table "users" via Supabase.
/// Exécution :
///   (PowerShell) $env:SUPABASE_SERVICE_ROLE_KEY="<SERVICE_ROLE_KEY>"; flutter test test/widget_test.dart -r expanded
///   (Linux/macOS) SUPABASE_SERVICE_ROLE_KEY="<SERVICE_ROLE_KEY>" flutter test test/widget_test.dart -r expanded
///
/// IMPORTANT :
/// - Ne jamais commiter la service_role key.

Future<void> main() async {
  const supabaseUrl = 'https://pbksrckspuschimrvlyk.supabase.co';

  final supabaseKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ?? Platform.environment['SUPABASE_ANON_KEY'];
  if (supabaseKey == null || supabaseKey.isEmpty) {
    print('❌ SUPABASE_SERVICE_ROLE_KEY not found in environment. Set it before running the test.');
    return;
  }

  final client = SupabaseClient(supabaseUrl, supabaseKey);

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
'created_at': now,
    },
    {
      'id': 'c3d4e5f6-a7b8-9012-cdef-345678901234',
      'email': 'prof.physics@betif.school',
      'full_name': 'Albert Einstein',
      'role': 'professor',
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

  print('Insertion de 5 utilisateurs dans la table "user"...');

  var success = 0;

  try {
    final response = await client.from('users').insert(usersToInsert);
    print('Insert response: $response');
    success = usersToInsert.length;
  } catch (e) {
    for (final user in usersToInsert) {
      print('Exception pour ${user['email']}: $e');
    }
  }

  print('\nRésultat: $success/5 insérés.');
}
