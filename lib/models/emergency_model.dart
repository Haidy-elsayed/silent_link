class EmergencyNumbers {
  final String countryName;
  final String police;
  final String fire;
  final String ambulance;

  EmergencyNumbers({
    required this.countryName,
    required this.police,
    required this.fire,
    required this.ambulance,
  });

 
  static Map<String, EmergencyNumbers> countryData = {
  "Egypt": EmergencyNumbers(countryName: "Egypt", police: "122", fire: "180", ambulance: "123"),
  "Palestine": EmergencyNumbers(countryName: "Palestine", police: "100", fire: "102", ambulance: "101"),
  "Algeria": EmergencyNumbers(countryName: "Algeria", police: "17", fire: "14", ambulance: "14"),
  "Morocco": EmergencyNumbers(countryName: "Morocco", police: "19", fire: "15", ambulance: "15"),
  "Tunisia": EmergencyNumbers(countryName: "Tunisia", police: "197", fire: "198", ambulance: "190"),
  "Libya": EmergencyNumbers(countryName: "Libya", police: "1515", fire: "1515", ambulance: "1515"),
  "Syria": EmergencyNumbers(countryName: "Syria", police: "112", fire: "113", ambulance: "110"),
  "Lebanon": EmergencyNumbers(countryName: "Lebanon", police: "112", fire: "175", ambulance: "140"),
};
}