import 'package:flutter/material.dart';

import '../services/register_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterService registerService = RegisterService();

  // =========================================================
  // CONTROLLERS
  // =========================================================

  final TextEditingController fullNameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  final TextEditingController companyNameController =
  TextEditingController();

  final TextEditingController contactPersonController =
  TextEditingController();

  final TextEditingController countryController =
  TextEditingController();

  final TextEditingController addressController =
  TextEditingController();

  final TextEditingController registrationNumberController =
  TextEditingController();

  final TextEditingController descriptionController =
  TextEditingController();

  // =========================================================
  // STATE
  // =========================================================

  bool isEmployer = false;

  bool obscurePassword = true;

  bool obscureConfirmPassword = true;

  bool loading = false;

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    companyNameController.dispose();
    contactPersonController.dispose();
    countryController.dispose();
    addressController.dispose();
    registrationNumberController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // =========================================================
  // REGISTER
  // =========================================================

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    // ---------------------------------------------------------
    // COMMON VALIDATION
    // ---------------------------------------------------------

    if (usernameController.text.trim().isEmpty) {
      _showMessage('Please enter a username');
      return;
    }

    if (passwordController.text.isEmpty) {
      _showMessage('Please enter a password');
      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {
      _showMessage('Passwords do not match');
      return;
    }

    // ---------------------------------------------------------
    // EMPLOYER VALIDATION
    // ---------------------------------------------------------

    if (isEmployer) {
      if (companyNameController.text.trim().isEmpty) {
        _showMessage('Please enter company name');
        return;
      }

      if (contactPersonController.text.trim().isEmpty) {
        _showMessage('Please enter contact person');
        return;
      }

      if (emailController.text.trim().isEmpty) {
        _showMessage('Please enter email');
        return;
      }

      if (phoneController.text.trim().isEmpty) {
        _showMessage('Please enter phone number');
        return;
      }

      if (countryController.text.trim().isEmpty) {
        _showMessage('Please enter country');
        return;
      }

      if (addressController.text.trim().isEmpty) {
        _showMessage('Please enter address');
        return;
      }
    }

    // ---------------------------------------------------------
    // APPLICANT VALIDATION
    // ---------------------------------------------------------

    if (!isEmployer) {
      if (fullNameController.text.trim().isEmpty) {
        _showMessage('Please enter your full name');
        return;
      }

      if (emailController.text.trim().isEmpty) {
        _showMessage('Please enter email');
        return;
      }

      if (phoneController.text.trim().isEmpty) {
        _showMessage('Please enter phone number');
        return;
      }
    }

    setState(() {
      loading = true;
    });

    try {
      String? error;

      // =======================================================
      // EMPLOYER REGISTRATION
      // =======================================================

      if (isEmployer) {
        error = await registerService.registerEmployer(
          username: usernameController.text.trim(),
          password: passwordController.text,
          companyName: companyNameController.text.trim(),
          contactPerson: contactPersonController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          country: countryController.text.trim(),
          address: addressController.text.trim(),
          registrationNumber:
          registrationNumberController.text.trim(),
          description:
          descriptionController.text.trim(),
        );
      }

      // =======================================================
      // APPLICANT REGISTRATION
      // =======================================================

      else {
        error = await registerService.register(
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          username: usernameController.text.trim(),
          password: passwordController.text,
        );
      }

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      // =======================================================
      // SUCCESS
      // =======================================================

      if (error == null) {
        _showSuccessDialog();
      }

      // =======================================================
      // ERROR
      // =======================================================

      else {
        _showMessage(error);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Registration failed: $e',
      );
    }
  }

  // =========================================================
  // SUCCESS DIALOG
  // =========================================================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Registration Successful',
          ),
          content: Text(
            isEmployer
                ? 'Your employer account has been created and is waiting for admin approval.'
                : 'Your applicant account has been created successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // =================================================
              // TITLE
              // =================================================

              const SizedBox(height: 10),

              const Text(
                'Join AKTech Overseas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isEmployer
                    ? 'Create an employer account'
                    : 'Create your applicant account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // ACCOUNT TYPE
              // =================================================

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text(
                        'Account Type',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text(
                                'Applicant',
                              ),
                              value: false,
                              groupValue: isEmployer,
                              onChanged: loading
                                  ? null
                                  : (value) {
                                setState(() {
                                  isEmployer =
                                  false;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text(
                                'Employer',
                              ),
                              value: true,
                              groupValue: isEmployer,
                              onChanged: loading
                                  ? null
                                  : (value) {
                                setState(() {
                                  isEmployer =
                                  true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // APPLICANT FIELDS
              // =================================================

              if (!isEmployer) ...[
                _buildTextField(
                  controller:
                  fullNameController,
                  label: 'Full Name',
                  icon: Icons.person,
                ),

                const SizedBox(height: 14),

                _buildTextField(
                  controller:
                  emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType:
                  TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                _buildTextField(
                  controller:
                  phoneController,
                  label: 'Phone',
                  icon: Icons.phone,
                  keyboardType:
                  TextInputType.phone,
                ),

                const SizedBox(height: 14),
              ],

              // =================================================
              // EMPLOYER FIELDS
              // =================================================

              if (isEmployer) ...[
                _buildTextField(
                  controller:
                  companyNameController,
                  label: 'Company Name',
                  icon: Icons.business,
                ),

                const SizedBox(height: 14),

                _buildTextField(
                  controller:
                  contactPersonController,
                  label: 'Contact Person',
                  icon: Icons.person,
                ),

                const SizedBox(height: 14),

                _buildTextField(
                  controller:
                  emailController,
                  label: 'Company Email',
                  icon: Icons.email,
                  keyboardType:
                  TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                _buildTextField(
                  controller:
                  phoneController,
                  label: 'Phone',
                  icon: Icons.phone,
                  keyboardType:
                  TextInputType.phone,
                ),

                const SizedBox(height: 14),

                _buildTextField(
                  controller:
                  countryController,
                  label: 'Country',
                  icon: Icons.public,
                ),

                const SizedBox(height: 14),

                _buildTextField(
                  controller:
                  addressController,
                  label: 'Address',
                  icon: Icons.location_on,
                ),

                const SizedBox(height: 14),

                _buildTextField(
                  controller:
                  registrationNumberController,
                  label:
                  'Registration Number (Optional)',
                  icon: Icons.badge,
                ),

                const SizedBox(height: 14),

                _buildTextField(
                  controller:
                  descriptionController,
                  label:
                  'Company Description (Optional)',
                  icon: Icons.description,
                  maxLines: 3,
                ),

                const SizedBox(height: 14),
              ],

              // =================================================
              // USERNAME
              // =================================================

              _buildTextField(
                controller:
                usernameController,
                label: 'Username',
                icon: Icons.account_circle,
              ),

              const SizedBox(height: 14),

              // =================================================
              // PASSWORD
              // =================================================

              _buildPasswordField(
                controller:
                passwordController,
                label: 'Password',
                obscureText:
                obscurePassword,
                onToggle: () {
                  setState(() {
                    obscurePassword =
                    !obscurePassword;
                  });
                },
              ),

              const SizedBox(height: 14),

              // =================================================
              // CONFIRM PASSWORD
              // =================================================

              _buildPasswordField(
                controller:
                confirmPasswordController,
                label: 'Confirm Password',
                obscureText:
                obscureConfirmPassword,
                onToggle: () {
                  setState(() {
                    obscureConfirmPassword =
                    !obscureConfirmPassword;
                  });
                },
              ),

              const SizedBox(height: 25),

              // =================================================
              // REGISTER BUTTON
              // =================================================

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                  loading ? null : register,
                  child: loading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    isEmployer
                        ? 'Register as Employer'
                        : 'Create Account',
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // LOGIN
              // =================================================

              TextButton(
                onPressed: loading
                    ? null
                    : () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Already have an account? Login',
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TEXT FIELD
  // =========================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  // =========================================================
  // PASSWORD FIELD
  // =========================================================

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(
          Icons.lock,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility
                : Icons.visibility_off,
          ),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}