import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/InformationUserController.dart';
import 'package:tadakir/View/ShowDialog/ShowDialog.dart';

class Profileinformation extends StatefulWidget {
  const Profileinformation({super.key});

  @override
  State<Profileinformation> createState() => _ProfileinformationState();
}

class _ProfileinformationState extends State<Profileinformation> {
  final Informationusercontroller infoUserController =
      Get.put(Informationusercontroller());

  final sharedPrefs = ControllerSharedPreferences();

  // Form controllers
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateNaissanceController =
      TextEditingController();
  final TextEditingController _cinController = TextEditingController();

  // Civility state
  RxBool isMale = false.obs;
  RxBool isFemale = false.obs;

  // Selected Ville
  String? selectedVille;

  // List of villes
  final List<String> villes = [];
  @override
  void initState() {
    super.initState();
    infoUserController.fetchInfoUser(context).then((_) {
      final userInfo = infoUserController.infoUser;
      if (userInfo.isNotEmpty) {
        _nomController.text = userInfo['nom'] ?? '';
        _prenomController.text = userInfo['prenom'] ?? '';
        _emailController.text = userInfo['email'] ?? '';
        _phoneController.text = userInfo['telephone'] ?? '';
        selectedVille = userInfo['ville'];
        _dateNaissanceController.text = userInfo['birthdate'] ?? '';
        _cinController.text = userInfo['cin'] ?? '';
        isMale.value = userInfo['sex'] == 'homme';
        isFemale.value = userInfo['sex'] == 'femme';
        for (var i = 0; i < infoUserController.villes.length; i++) {
          Map<String, dynamic> object = infoUserController.villes[i];
          villes.add(object['nom']);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Information User",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Civility",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Checkbox(
                    value: isMale.value,
                    onChanged: (value) {
                      isMale.value = value ?? false;
                      isFemale.value = !isMale.value;
                    },
                  ),
                  const Text("Male"),
                  Checkbox(
                    value: isFemale.value,
                    onChanged: (value) {
                      isFemale.value = value ?? false;
                      isMale.value = !isFemale.value;
                    },
                  ),
                  const Text("Female"),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: "Prénom",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedVille,
                items: villes
                    .map((ville) => DropdownMenuItem<String>(
                          value: ville,
                          child: Text(ville),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: "Ville",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedVille = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _dateNaissanceController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date de Naissance",
                  border: const OutlineInputBorder(),
                  hintText: "YYYY-MM-DD",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        String formattedDate =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        _dateNaissanceController.text = formattedDate;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cinController,
                decoration: const InputDecoration(
                  labelText: "CIN",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Retrieve the token asynchronously
                  String? token = await sharedPrefs.getToken();

                  // Check if the token is valid
                  if (token == null || token.isEmpty) {
                    if (context.mounted) {
                      showDialogForResponse(
                          context, "Error", "Token is not available.");
                    }
                    return;
                  }

                  // Retrieve user information safely with null checks
                  final nom = _nomController.text.trim();
                  final prenom = _prenomController.text.trim();
                  final sex =
                      isMale.value ? 'homme' : (isFemale.value ? 'femme' : '');
                  final birthDate = _dateNaissanceController.text.trim();
                  final telephone = _phoneController.text.trim();
                  final cin = _cinController.text.trim();
                  final ville = selectedVille?.trim();
                  final email = _emailController.text.trim();

                  // Call the updateInformation method
                  infoUserController.updateInformation(
                    // ignore: use_build_context_synchronously
                    context,
                    token,
                    nom,
                    prenom,
                    sex,
                    birthDate,
                    telephone,
                    cin,
                    ville!,
                    email,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 211, 49, 58),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                    side: const BorderSide(
                        width: 2,
                        color: const Color.fromARGB(255, 211, 49, 58)),
                  ),
                ),
                child: const Text(
                  "METTRE A JOUR",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
