import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/register_model.dart';

class RegisterRepository {
  final SupabaseClient supabase;

  RegisterRepository({SupabaseClient? supabase})
      : supabase = supabase ?? Supabase.instance.client;

  Future<User?> register(RegisterModel data) async {
    final response = await supabase.auth.signUp(
      email: data.email,
      password: data.password,
      data: {
        'name': data.nama,
      },
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Pendaftaran gagal');
    }

    await supabase.from('profiles').insert({
      'id': user.id,
      'name': data.nama,
      'phone': data.whatsapp,
      'email': data.email,
    });

    return user;
  }
}