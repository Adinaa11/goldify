import 'package:flutter/material.dart';

import '../../repositories/profile_repository.dart';
import '../../viewmodels/profile_viewmodel.dart';

import 'personal_info_page.dart';
import 'security_page.dart';
import 'app_version_page.dart';
import 'terms_page.dart';
import 'privacy_policy_page.dart';

import '../splash_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState()
      => _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {

  late ProfileViewModel viewModel;

  @override
  void initState(){

    super.initState();

    viewModel =
        ProfileViewModel(
          ProfileRepository(),
        );
    viewModel.loadProfile();
  }

  @override
  Widget build(BuildContext context){

    return AnimatedBuilder(
      animation: viewModel,
      builder:(context, child){

        if(viewModel.isLoading){
          return const Scaffold(

            body:
            Center(
              child:
              CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(

          backgroundColor:
          const Color(0xFFF5F6F8),

          appBar:
          AppBar(
            title:
            const Text(
              "Profil",
            ),
            backgroundColor:
            Colors.white,
            foregroundColor:
            Colors.black,
            elevation:1,
          ),

          body:
          _buildBody(),
        );
      },
    );
  }

  Widget _buildBody(){

    final profile =
        viewModel.profile;

    final name =
        profile?.name ??
        "Tidak ada nama";

    final email =
        profile?.email ??
        "Tidak ada email";

    final String? avatarUrl =
        profile?.avatarUrl;

    return SingleChildScrollView(
      child:
      Column(
        children: [

          Container(
            margin:
            const EdgeInsets.symmetric(
              horizontal:16,
              vertical:12,
            ),

            padding:
            const EdgeInsets.all(16),

            decoration:
            BoxDecoration(
              color:
              Colors.white,

              borderRadius:
              BorderRadius.circular(16),
            ),

            child:
            Row(
              children: [
                CircleAvatar(
                  radius:28,
                  backgroundColor:
                  Colors.grey[200],

                  backgroundImage:
                  (avatarUrl != null &&
                   avatarUrl.isNotEmpty) ?
                  NetworkImage(
                    avatarUrl,
                  ):
                  const AssetImage(
                    'assets/images/profile.png',
                  )
                  as ImageProvider,
                ),

                const SizedBox(
                  width:12,
                ),

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,
                      style:
                      const TextStyle(

                        fontSize:16,

                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height:4,
                    ),

                    Text(
                      email,
                      style:
                      const TextStyle(

                        color:
                        Colors.grey,

                        fontSize:
                        13,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          _sectionTitle("AKUN"),

          _menuItem(
            icon:
            Icons.person,
            title:
            "Informasi Pribadi",
            onTap:
            _goToPersonalInfo,
          ),

          _menuItem(
            icon:
            Icons.shield_outlined,
            title:
            "Keamanan",
            onTap:(){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:(_) =>
                  const SecurityPage(),
                ),
              );
            },
          ),

          const SizedBox(
            height:10,
          ),

          _sectionTitle(
            "INFO APLIKASI",
          ),

          _menuItem(
            icon:
            Icons.info_outline,
            title:
            "Tentang Aplikasi",
            onTap:(){
              Navigator.push(
                context,
                MaterialPageRoute(

                  builder:(_) =>
                  AppVersionPage(),
                ),
              );
            },
          ),

          _menuItem(
            icon:
            Icons.description_outlined,

            title:
            "Syarat & Ketentuan",

            onTap:(){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:(_) =>
                  const TermsPage(),
                ),
              );
            },
          ),

          _menuItem(
            icon:
            Icons.privacy_tip_outlined,

            title:
            "Kebijakan Privasi",

            onTap:(){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:(_) =>
                  const PrivacyPolicyPage(),
                ),
              );
            },
          ),

          const SizedBox(
            height:20,
          ),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal:16,
            ),

            child:
            SizedBox(
              width:
              double.infinity,
              child:
              OutlinedButton.icon(

                onPressed:() async {

                  await viewModel.logout();

                  Navigator.pushAndRemoveUntil(
                    context,

                    MaterialPageRoute(
                      builder:(_) =>
                      const SplashScreen(),
                    ),
                    (route)=>false,
                  );
                },

                icon:
                const Icon(
                  Icons.logout,
                  color:
                  Colors.red,
                ),

                label:
                const Text(
                  "Keluar",
                  style:
                  TextStyle(

                    color:
                    Colors.red,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            height:20,
          ),
        ],
      ),
    );
  }

  Future<void> _goToPersonalInfo() async {

    final result =
    await Navigator.push(

      context,

      MaterialPageRoute(
        builder:(_)
        =>
        const PersonalInfoPage(),
      ),
    );

    if(result == true && mounted){
      await viewModel.loadProfile();
    }
  }

  Widget _sectionTitle(String title){

    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.symmetric(
        horizontal:16,
        vertical:10,
      ),

      child:
      Text(
        title,
        style:
        const TextStyle(

          fontSize:11,

          color:
          Colors.grey,

          fontWeight:
          FontWeight.w500,
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }){

    return Material(
      color:
      Colors.white,

      child:
      InkWell(

        onTap:onTap,

        child:
        Column(
          children:[
            ListTile(
              leading:
              Icon(
                icon,
                color:
                Colors.black87,
              ),

              title:
              Text(title),
              trailing:
              trailing != null?

              Row(
                mainAxisSize:
                MainAxisSize.min,

                children:[
                  Text(
                    trailing,
                    style:
                    const TextStyle(
                      color:
                      Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    width:6,
                  ),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size:14,
                  ),
                ],
              ):
              const Icon(
                Icons.arrow_forward_ios,
                size:14,
              ),
            ),

            const Divider(
              height:0,
              indent:56,
            )
          ],
        ),
      ),
    );
  }
}