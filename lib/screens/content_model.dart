import 'dart:ui';

class onboardingContent {
  String image;
  String title;
  String discription;

  onboardingContent(
      {required this.image, required this.title, required this.discription});
}

List<onboardingContent> contents = [
  onboardingContent(
      title: 'Dan Parking System',
      image: 'images/parking-spots.gif',
      discription: "The First Smart Parking System in ETHIOPIA! "),
  onboardingContent(
      title: 'Guided Parking',
      image: 'images/guided-parking.gif',
      discription:
          "computer image recognition system and smartphone application integrated to form a simple assisted guiding system."),
  onboardingContent(
      title: 'Safty',
      image: 'images/cctv.gif',
      discription:
          "Intelligent cameras, which can authenticate the identity of anyone entering a "
          "parking facility and alert security personnel as to whether or not they should be there. "),
];
