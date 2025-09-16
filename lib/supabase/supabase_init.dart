import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Rellena con tus valores reales
const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://bmsljgrpcxtpwauwjyzc.supabase.co');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJtc2xqZ3JwY3h0cHdhdXdqeXpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5OTAyMDEsImV4cCI6MjA3MzU2NjIwMX0.UQRzgtI4ndt8GF5ef8hRPqlCuhDSoGW5FwYRA_m24fA');

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      // Persistencia de sesión por defecto
      autoRefreshToken: true,
      // persistSession se removió en versiones más recientes
      // La persistencia de sesión está habilitada por defecto
    ),
  );
}

final supabase = Supabase.instance.client;