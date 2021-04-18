import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:write_story/models/group_storage_model.dart';
import 'package:write_story/models/member_model.dart';
import 'package:write_story/models/pending_model.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/services/authentication_service.dart';
import 'package:write_story/services/encrypt_service.dart';

class GroupRemoteService {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference userCollection = _firestore.collection('users');
  static CollectionReference groupsCollection = _firestore.collection("groups");
  static CollectionReference pendingsCollection =
      _firestore.collection("pendings");

  Future<List<GroupStorageModel>?> fetchGroupsList() async {
    final auth = AuthenticationService();
    if (auth.user?.uid == null) return null;
    final String uid = auth.user!.uid;
    CollectionReference ref = userCollection.doc("$uid").collection("groups");
    List<QueryDocumentSnapshot> result =
        await ref.get().then((value) => value.docs);

    final modelsList = result.map((e) {
      final json = e.data();
      print("$json");
      return GroupStorageModel.fromJson(json);
    }).toList();
    return modelsList;
  }

  Future<String?> fetchSelectedGroup() async {
    final auth = AuthenticationService();
    if (auth.user?.uid == null) return null;
    final String uid = auth.user!.uid;
    final data = userCollection.doc(uid).get();
    return data.then((value) => value['selected_group']);
  }

  Future<GroupStorageModel?> fetchGroup(String groupId) async {
    DocumentReference groupDocRef = groupsCollection.doc(groupId);
    DocumentSnapshot snapshot = await groupDocRef.get().then((value) => value);
    final Map<String, dynamic>? data = snapshot.data();
    if (data == null) return null;
    return GroupStorageModel.fromJson(data);
  }

  Stream<List<MemberModel>> fetchMembers(String? groupId) {
    CollectionReference membersCollection =
        groupsCollection.doc(groupId).collection("members");
    final snapshot = membersCollection.orderBy('invite_on').snapshots();
    return snapshot.map((event) {
      return event.docs.map((json) {
        return MemberModel.fromJson(json.data());
      }).toList();
    });
  }

  Future<GroupStorageModel?> createGroup(String groupName) async {
    final auth = AuthenticationService();
    if (auth.user?.email == null) return null;
    final String email = auth.user!.email!;
    final String uid = auth.user!.uid;

    DocumentReference groupDocRef = await groupsCollection.add(
      {'group_name': groupName, 'admin': email, 'group_id': ''},
    );

    await groupDocRef.update({
      'group_id': groupDocRef.id,
    });

    final member = MemberModel(
      email: email,
      db: "",
      photoUrl: auth.user!.photoURL,
      isAdmin: true,
      joinOn: Timestamp.now(),
      inviteOn: Timestamp.now(),
    );

    DocumentReference membersCollection =
        groupsCollection.doc(groupDocRef.id).collection("members").doc(email);
    await membersCollection.set(member.toJson());

    CollectionReference userGroupCollectionRef =
        userCollection.doc(uid).collection("groups");

    await userCollection.doc(uid).update({"selected_group": groupDocRef.id});
    userGroupCollectionRef.doc(groupDocRef.id).set(GroupStorageModel(
          groupId: groupDocRef.id,
          groupName: groupName,
          admin: email,
        ).toJson());

    return GroupStorageModel(
      admin: email,
      groupId: groupDocRef.id,
      groupName: groupName,
    );
  }

  Future<void> addUserToGroup(
    String email,
    String groupId,
    String groupName,
  ) async {
    final auth = AuthenticationService();
    if (auth.user?.email == null) return null;
    final String sendByEmail = auth.user!.email!;
    final pending = PendingModel(
      sendByEmail: sendByEmail,
      sendToEmail: email,
      groupId: groupId,
      groupName: groupName,
    );

    final member = MemberModel(
      email: email,
      db: "",
      photoUrl: "",
      isAdmin: false,
      joinOn: null,
      inviteOn: Timestamp.now(),
    );

    DocumentReference membersCollection =
        groupsCollection.doc(groupId).collection("members").doc(member.email);
    await membersCollection.set(member.toJson());

    DocumentReference pendingsDocsRef = pendingsCollection.doc(email);
    await pendingsDocsRef.set(pending.toJson());
  }

  Future<void> removePendingUserFromGroup({
    required String email,
    required String groupId,
  }) async {
    DocumentReference membersCollection =
        groupsCollection.doc(groupId).collection("members").doc(email);
    await membersCollection.delete();
    DocumentReference pendingsDocsRef = pendingsCollection.doc(email);
    await pendingsDocsRef.delete();
  }

  Stream<PendingModel> hasPending() {
    final auth = AuthenticationService();
    final String? email = auth.user?.email;
    if (email == null) return Stream.value(PendingModel());
    DocumentReference pendingsDocsRef = pendingsCollection.doc(email);
    return pendingsDocsRef.snapshots().map((event) {
      PendingModel? pendingModel;
      var documentSnapshot = event.data();
      final Map<String, dynamic>? data = documentSnapshot;
      if (data != null) {
        pendingModel = PendingModel.fromJson(data);
      }
      return pendingModel ?? PendingModel();
    });
  }

  // has user joined the group
  Future<bool> isUserJoined(String groupId) async {
    final auth = AuthenticationService();
    if (auth.user?.uid == null) return false;
    final String uid = auth.user!.uid;
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    final data = userDocSnapshot.data();
    List<dynamic> groups = data?['groups'];

    if (groups.contains(groupId)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> acceptPending(PendingModel pendingModel) async {
    final auth = AuthenticationService();
    if (auth.user == null) return null;
    final String? photoUrl = auth.user?.photoURL;

    DocumentReference userDocRef = userCollection.doc(auth.user!.uid);
    await userDocRef
        .collection("groups")
        .doc(pendingModel.groupId)
        .set(GroupStorageModel(
          groupId: pendingModel.groupId,
          groupName: pendingModel.groupName,
          admin: pendingModel.sendByEmail,
        ).toJson());

    final map = {
      "email": pendingModel.sendToEmail,
      "photo_url": photoUrl,
      "join_on": Timestamp.now(),
    };

    DocumentReference membersCollection = groupsCollection
        .doc(pendingModel.groupId)
        .collection("members")
        .doc(pendingModel.sendToEmail);

    await membersCollection.update(map);
    await pendingsCollection.doc(pendingModel.sendToEmail).delete();
  }

  Future<void> cancelPending(PendingModel pendingModel) async {
    await pendingsCollection.doc(pendingModel.sendToEmail).delete();
    await groupsCollection
        .doc(pendingModel.groupId)
        .collection("members")
        .doc(pendingModel.sendToEmail)
        .delete();
  }

  Future<void> setSelectedGroup(String? groupId) async {
    final auth = AuthenticationService();
    if (auth.user?.uid == null) return null;
    final String uid = auth.user!.uid;
    DocumentReference userDocRef = userCollection.doc(uid);
    await userDocRef.update({"selected_group": groupId});
  }

  Future<void> exitGroup(String? groupId, String? selectedGroup) async {
    final auth = AuthenticationService();
    if (auth.user?.uid == null) return null;
    if (auth.user?.email == null) return null;

    final String uid = auth.user!.uid;
    final String email = auth.user!.email!;

    DocumentReference userDocRef = userCollection.doc(uid);
    if (selectedGroup == groupId) {
      await userDocRef.update({
        "selected_group": null,
      });
    }

    await userDocRef.collection("groups").doc(groupId).delete();
    await groupsCollection
        .doc(groupId)
        .collection("members")
        .doc(email)
        .delete();
  }

  Future<void> syncEncryptStories(
    String? groupId,
    Map<int, StoryModel>? result,
  ) async {
    if (result == null) return;

    final auth = AuthenticationService();
    if (auth.user?.uid == null) return;
    if (auth.user?.email == null) return;

    final String email = auth.user!.email!;
    final encrypt = EncryptService.storyMapEncrypt(result);

    await groupsCollection
        .doc(groupId)
        .collection("members")
        .doc(email)
        .update({"db": encrypt});
  }
}
