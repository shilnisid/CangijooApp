import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class EditSupplierController extends GetxController {
  //TODO: Implement EditSupplierController
  late TextEditingController newName;
  late TextEditingController newNumber;

  FirebaseFirestore db =FirebaseFirestore.instance;

  Future<void> editSupplier(String supplierId, String newName, String newNumber) async {
    DocumentReference docData = db.collection('supplier').doc(supplierId);
    try {
      await docData.update({
        'supplierName': newName,
        'supplierNumber': newNumber,
      });
      Get.back(); // Close the edit screen (optional)
      Get.snackbar('Success', 'Supplier updated successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update supplier.');
      print(e);
    }
  }

  Future<DocumentSnapshot> getData(String docID) async {
    DocumentReference docRef = db.collection('supplier').doc(docID);
    return await docRef.get();
  }

  @override
  void onInit() {
    newName = TextEditingController();
    newNumber = TextEditingController();
    super.onInit();
  }


  @override
  void onClose() {
    newName.dispose();
    newNumber.dispose();
    super.onClose();
  }
}
