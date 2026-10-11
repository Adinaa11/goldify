import 'package:supabase_flutter/supabase_flutter.dart';

class LoginRepository {
  final SupabaseClient supabase;

  LoginRepository({
    SupabaseClient? supabase,
  }) : supabase =
            supabase ?? Supabase.instance.client;

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final response =
        await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response.user;
  }
}