import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:write_story/models/group_storage_model.dart';
import 'package:write_story/models/member_model.dart';
import 'package:write_story/models/pending_model.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/services/authentication_service.dart';
import 'package:write_story/services/encrypt_service.dart';

class GroupRemoteService {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference userCollection = _firestore.collection('users');
  CollectionReference groupsCollection = _firestore.collection("groups");
  CollectionReference pendingsCollection = _firestore.collection("pendings");
  AuthenticationService auth = AuthenticationService();

  GroupRemoteService() {
    setUserDocs(currentUid!);
  }

  String? get currentUid {
    if (auth.user?.uid == null) return null;
    return auth.user!.uid;
  }

  String? get currentEmail {
    if (auth.user?.email == null) return null;
    return auth.user!.email;
  }

  Future<List<GroupStorageModel>?> fetchGroupsList() async {
    if (currentEmail == null || currentUid == null) return null;
    DocumentReference doc = userCollection.doc("$currentUid");
    CollectionReference ref = doc.collection("groups");
    QuerySnapshot? snapshot;
    try {
      snapshot = await ref.get().timeout(Duration(seconds: 30), onTimeout: () {
        throw "request creating timeout";
      });
    } catch (e) {
      print("GroupRemoteService#fetchGroupsList $e");
      return null;
    }
    List<QueryDocumentSnapshot> result = snapshot.docs;
    final modelsList = result.map((e) {
      final json = e.data();
      return GroupStorageModel.fromJson(json);
    }).toList();
    return modelsList;
  }

  Future<String?> fetchSelectedGroup() async {
    if (currentEmail == null || currentUid == null) return null;
    DocumentSnapshot? data;
    DocumentReference doc = userCollection.doc(currentUid);
    try {
      final ref = doc.get(GetOptions(source: Source.server));
      data = await ref.timeout(Duration(seconds: 30), onTimeout: () {
        throw "request creating timeout";
      });
    } catch (e) {
      print("GroupRemoteService#fetchSelectedGroup $e");
      return null;
    }
    Map<String, dynamic>? map = data.data();
    if (map?.containsKey('selected_group') == true) {
      return map?['selected_group'];
    } else {
      return null;
    }
  }

  Future<GroupStorageModel?> fetchGroup(String groupId) async {
    DocumentReference groupDocRef = groupsCollection.doc(groupId);
    DocumentSnapshot? snapshot;
    try {
      final get = groupDocRef.get();
      snapshot = await get.timeout(Duration(seconds: 30), onTimeout: () {
        throw "request creating timeout";
      });
    } catch (e) {
      print("GroupRemoteService#fetchGroup $e");
      return null;
    }

    final Map<String, dynamic>? data = snapshot.data();
    if (data == null) return null;
    return GroupStorageModel.fromJson(data);
  }

  Stream<List<MemberModel>> fetchMembers(String? groupId) {
    DocumentReference doc = groupsCollection.doc(groupId);
    CollectionReference membersCollection = doc.collection("members");
    final snapshot = membersCollection.orderBy('invite_on').snapshots();
    return snapshot.map((event) {
      return event.docs.map((json) {
        return MemberModel.fromJson(json.data());
      }).toList();
    });
  }

  Future<bool> setUserDocs(String docID) async {
    bool exists = false;
    try {
      await userCollection.doc(docID).get().then((doc) {
        if (doc.exists) {
          exists = true;
        } else {
          exists = false;
          userCollection.doc(docID).set({'selected_group': null});
        }
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  Future<GroupStorageModel?> createGroup(String groupName) async {
    DocumentReference? groupDocRef;
    final map = {
      'group_name': groupName,
      'admin': currentEmail,
      'group_id': ''
    };
    try {
      final add = groupsCollection.add(map);
      groupDocRef = await add.timeout(Duration(seconds: 30), onTimeout: () {
        throw "request creating timeout";
      });
    } catch (e) {
      print("GroupRemoteService#createGroup $e");
      return null;
    }

    await groupDocRef.update({'group_id': groupDocRef.id});
    final member = MemberModel(
      email: currentEmail,
      db: "",
      photoUrl: auth.user!.photoURL,
      isAdmin: true,
      joinOn: Timestamp.now(),
      inviteOn: Timestamp.now(),
    );

    await userCollection
        .doc(currentUid)
        .update({"selected_group": groupDocRef.id});
    final path = groupDocRef.id + "/members/" + currentEmail!;
    DocumentReference membersCollection = groupsCollection.doc(path);
    await membersCollection.set(member.toJson());

    CollectionReference userGroupCollectionRef =
        userCollection.doc(currentUid).collection("groups");

    Map<String, dynamic> groupMap = GroupStorageModel(
      groupId: groupDocRef.id,
      groupName: groupName,
      admin: currentEmail,
    ).toJson();

    await userGroupCollectionRef.doc(groupDocRef.id).set(groupMap);
    return GroupStorageModel(
      admin: currentEmail,
      groupId: groupDocRef.id,
      groupName: groupName,
    );
  }

  Future<void> addUserToGroup(
    String email,
    String groupId,
    String groupName,
  ) async {
    final member = MemberModel(
      email: email,
      db: "",
      photoUrl: "",
      isAdmin: false,
      joinOn: null,
      inviteOn: Timestamp.now(),
    );

    String path = groupId + "/members/" + member.email!;
    DocumentReference membersCollection = groupsCollection.doc(path);

    DocumentSnapshot? value;
    try {
      final get = membersCollection.get();
      value = await get.timeout(timeLimit, onTimeout: () {
        throw "add user to group timeout";
      });
    } catch (e) {
      print("GroupRemoteService#addUserToGroup $e");
      return;
    }
    if (value.data() != null) return;
    Map<String, dynamic> memberMap = member.toJson();
    await membersCollection.set(memberMap);
    PendingModel pending = PendingModel(
      sendByEmail: currentEmail,
      sendToEmail: email,
      groupId: groupId,
      groupName: groupName,
    );
    DocumentReference pendingsDocsRef = pendingsCollection.doc(email);
    Map<String, dynamic> pendingMap = pending.toJson();
    await pendingsDocsRef.set(pendingMap);
  }

  Future<void> removePendingUserFromGroup({
    required String email,
    required String groupId,
  }) async {
    String path = groupId + "/members/" + email;
    DocumentReference membersCollection = groupsCollection.doc(path);
    try {
      final delete = membersCollection.delete();
      await delete.timeout(timeLimit, onTimeout: () {
        throw "remove pending user from group timeout";
      });
    } catch (e) {
      print("GroupRemoteService#removePendingUserFromGroup $e");
      return;
    }
    DocumentReference pendingsDocsRef = pendingsCollection.doc(email);
    await pendingsDocsRef.delete();
  }

  Stream<PendingModel?> hasPending() {
    if (currentEmail == null || currentUid == null) {
      return Stream.value(null);
    }

    DocumentReference pendingsDocsRef = pendingsCollection.doc(currentEmail);
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

  static const Duration timeLimit = Duration(seconds: 30);

  Future<void> acceptPending(PendingModel pendingModel) async {
    if (currentEmail == null || currentUid == null) return null;
    if (pendingModel.groupId == null) return null;
    if (pendingModel.sendToEmail == null) return null;
    final String? photoUrl = auth.user?.photoURL;

    DocumentReference userDocRef = userCollection.doc(auth.user!.uid);
    final group = GroupStorageModel(
      groupId: pendingModel.groupId,
      groupName: pendingModel.groupName,
      admin: pendingModel.sendByEmail,
    ).toJson();

    try {
      final doc = userDocRef.collection("groups").doc(pendingModel.groupId);
      await doc.set(group).timeout(timeLimit, onTimeout: () {
        throw "accept pending timemout";
      });
    } catch (e) {
      print("GroupRemoteService#acceptPending $e");
      return;
    }

    final map = {
      "email": pendingModel.sendToEmail,
      "photo_url": photoUrl,
      "join_on": Timestamp.now(),
    };

    final path =
        pendingModel.groupId! + "/members/" + pendingModel.sendToEmail!;
    DocumentReference membersCollection = groupsCollection.doc(path);
    await membersCollection.update(map);
    await pendingsCollection.doc(pendingModel.sendToEmail).delete();
  }

  Future<void> cancelPending(PendingModel pendingModel) async {
    if (currentEmail == null || currentUid == null) return null;
    if (pendingModel.groupId == null) return null;
    if (pendingModel.sendToEmail == null) return null;
    DocumentReference docRef = pendingsCollection.doc(pendingModel.sendToEmail);
    try {
      await docRef.delete().timeout(timeLimit, onTimeout: () {
        throw "cancel pending timeout";
      });
    } catch (e) {
      print("GroupRemoteService#cancelPending $e");
      return;
    }
    final path =
        pendingModel.groupId! + "/members/" + pendingModel.sendToEmail!;
    final doc = groupsCollection.doc(path);
    await doc.delete();
  }

  Future<void> setSelectedGroup(String? groupId) async {
    if (currentEmail == null || currentUid == null) return null;
    DocumentReference userDocRef = userCollection.doc(currentUid);
    try {
      final updateFuture = userDocRef.update({"selected_group": groupId});
      updateFuture.timeout(timeLimit, onTimeout: () {
        throw "set selected group timeout";
      });
    } catch (e) {
      print("GroupRemoteService#setSelectedGroup $e");
      return;
    }
  }

  Future<void> exitGroup(String? groupId, String? selectedGroup) async {
    if (currentEmail == null || currentUid == null) return null;
    DocumentReference userDocRef = userCollection.doc(currentUid);
    if (selectedGroup == groupId) {
      final updateFuture = userDocRef.update({"selected_group": null});
      try {
        await updateFuture.timeout(timeLimit, onTimeout: () {
          throw "set selected group to null timeout";
        });
      } catch (e) {
        print("GroupRemoteService#exitGroup $e");
        return;
      }
    }

    final groupRef = userDocRef.collection("groups").doc(groupId);
    try {
      await groupRef.delete().timeout(timeLimit, onTimeout: () {
        throw "exit group timeout";
      });
    } catch (e) {
      print("GroupRemoteService#exitGroup $e");
      return;
    }

    DocumentReference docRef = groupsCollection.doc(groupId);
    CollectionReference membersCollectionsRef = docRef.collection("members");
    await membersCollectionsRef.doc(currentEmail).delete();

    QuerySnapshot snapshot = await membersCollectionsRef.get();
    if (snapshot.docs.length == 0) {
      await groupsCollection.doc(groupId).delete();
    }
  }

  Future<void> syncEncryptStories(
    String? groupId,
    Map<int, StoryModel>? result,
  ) async {
    if (currentEmail == null || currentUid == null) return null;
    if (result == null) return;

    DocumentReference group = groupsCollection.doc(groupId);
    DocumentSnapshot? snapshot;
    try {
      snapshot = await group.get().timeout(timeLimit, onTimeout: () {
        throw "sync encrypt stories timeout";
      });
      if (snapshot.data() == null) return;
    } catch (e) {
      print("GroupRemoteService#syncEncryptStories $e");
      return;
    }

    String? encrypt = EncryptService.storyMapEncrypt(result);
    DocumentReference docRef = groupsCollection.doc(groupId);
    CollectionReference membersRef = docRef.collection("members");
    DocumentReference memberRef = membersRef.doc(currentEmail);
    await memberRef.update({"db": encrypt});
  }
}
