import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/screens/profile/widgets/avatar_selector.dart';
import 'package:procode/widgets/common/custom_text_field.dart';
import 'package:procode/widgets/common/country_selector.dart';
import 'package:procode/widgets/common/custom_button.dart';
import 'package:procode/widgets/common/loading_widget.dart';
import 'package:procode/utils/validators.dart';
import 'package:procode/config/constants.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  String? _selectedCountry;
  String? _selectedLearningGoal;

  String? _selectedAvatarPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Don't initialize here, wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _displayNameController.text = user.displayName;
      _bioController.text = user.bio ?? '';
      setState(() {
        _selectedCountry = user.country;
        _selectedLearningGoal = user.learningGoal;
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();

      // Handle avatar upload
      XFile? imageFile;
      if (_selectedAvatarPath != null &&
          !_selectedAvatarPath!.startsWith('assets/')) {
        // It's a file path from camera/gallery
        imageFile = XFile(_selectedAvatarPath!);
      }

      await userProvider.updateProfile(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        country: _selectedCountry,
        learningGoal: _selectedLearningGoal,
        imageFile: imageFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Section
                    Center(
                      child: AvatarSelector(
                        currentAvatarUrl: user?.avatarUrl,
                        onAvatarSelected: (String path) {
                          setState(() => _selectedAvatarPath = path);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Display Name
                    CustomTextField(
                      controller: _displayNameController,
                      label: 'Display Name',
                      hint: 'How should we call you?',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: Validators.required,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    CustomTextField(
                      controller: _bioController,
                      label: 'Bio',
                      hint: 'Tell us about yourself',
                      prefixIcon: const Icon(Icons.info_outline),
                      maxLines: 3,
                      maxLength: 150,
                      validator: (value) {
                        if (value != null && value.length > 150) {
                          return 'Bio must be less than 150 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Country Selector
                    CountrySelector(
                      label: 'Country',
                      hint: 'Where are you from?',
                      selectedCountry: _selectedCountry,
                      onCountrySelected: (country) {
                        setState(() => _selectedCountry = country);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Learning Goal
                    Text(
                      'Learning Goal',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLearningGoal,
                      decoration: InputDecoration(
                        hintText: 'Select your primary goal',
                        prefixIcon: const Icon(Icons.flag_outlined),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      items: AppConstants.learningGoals
                          .map((goal) => DropdownMenuItem(
                                value: goal,
                                child: Text(goal),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedLearningGoal = value);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Privacy Settings Note
                    Card(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.privacy_tip_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Privacy Settings',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Control what others can see in Settings',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: _saveProfile,
                      isLoading: _isLoading,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
