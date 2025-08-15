import 'package:blackrock_go/models/event_model.dart';
import 'package:blackrock_go/models/user_model.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class EventController extends GetxController {
  final List<EventModel> events = [];

  Future<void> getEvents() async {
    // await FirebaseUtils.events.get().then((querySnapshot) async {
    //   for (var doc in querySnapshot.docs) {
    //     Map<String, dynamic> data = doc.data();
    //     List<String> hostIds = List<String>.from(data['hostId']);
    //     final EventModel event = EventModel.fromMap(data);
    //     event.hosts = await getEventHosts(hostIds);
    //     events.add(event);
    //   }
    // });
    // log(events.length.toString());

    events.add(EventModel(
        imageUrl: '',
        eventName: 'New Event',
        description: 'Event Description',
        location: LatLng(40.786984204692935, -119.20309919712876),
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(days: 1)),
        hosts: [],
        cost: 1,
        locationName: 'Blackrock'));
  }

  Future<void> addEvent(EventModel event) async {
    // await FirebaseUtils.events.add(event.toMap());
    // events.add(event);
  }

  Future<List<User>> getEventHosts(List<String> hostIds) async {
    return List<User>.empty();
    // List<WalletUser> hosts = [];
    // for (var host in hostIds) {
    //   await FirebaseUtils.users.doc(host).get().then((doc) {
    //     hosts.add(WalletUser.fromMap(doc.data() as Map<String, dynamic>));
    //   });
    // }
    // return hosts;
  }
}
