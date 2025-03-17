import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phsyio_up/screens/clinic_admin/cubit/clinic_cubit.dart';

class RegisterTherapistScreen extends StatefulWidget {
  const RegisterTherapistScreen({super.key});

  @override
  State<RegisterTherapistScreen> createState() => _RegisterTherapistScreenState();
}

class _RegisterTherapistScreenState extends State<RegisterTherapistScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClinicCubit(),
      child: BlocBuilder<ClinicCubit, ClinicState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF2F5F9),
            body: LayoutBuilder(
              builder: (context, constraints) {
                bool isWideScreen = constraints.maxWidth > 600;
                return Row(
                  children: [
                    if (isWideScreen)
                      Container(
                        width: constraints.maxWidth * 0.4,
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/Logo_Dark.png",
                                height: 80,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Add Therapist",
                                style: GoogleFonts.montserrat(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  const Icon(Icons.security,
                                      color: Colors.white70, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Secure Staff Registration",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Register New Therapist",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Create a new account for your staff member",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                buildTextField(
                                  "Username",
                                  Icons.person_outline,
                                  ClinicCubit.get(context).usernameController,
                                ),
                                const SizedBox(height: 24),
                                buildPasswordField(ClinicCubit.get(context)),
                                const SizedBox(height: 32),
                                buildRegisterButton(ClinicCubit.get(context), context),
                                const SizedBox(height: 24),
                                // Add back button
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Back to Dashboard",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildTextField(
      String label, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: 'Enter therapist $label',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField(ClinicCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: cubit.passwordController,
            obscureText: !cubit.isPasswordVisible,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: 'Enter therapist password',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
              suffixIcon: IconButton(
                icon: Icon(
                  cubit.isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () => cubit.togglePasswordVisibility(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRegisterButton(ClinicCubit cubit, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          cubit.registerTherapist(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          "Register Therapist",
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}