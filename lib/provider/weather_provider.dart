import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:WeatherApp/widgets/location_permission_widget.dart';
import 'package:weather/weather.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherFactory weatherFactory = WeatherFactory(
    'efaa1c9d82ce3d8a48fbefd9ab372d88', // Replace with your OpenWeather API key
  );

  Weather? weather;
  List<Weather>? hourlyForecast;
  List<Weather>? dailyForecast;
  bool isLoading = false;
  double latitude = 0.0;
  double longitude = 0.0;
  Future<Weather?>? weatherFuture;

  WeatherProvider() {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    isLoading = true; // Set loading to true when fetching location
    notifyListeners();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Handle permission denied case
      latitude = 17.4503321; // Default location
      longitude = 78.3624171;
      weatherFuture = fetchWeatherDataByCoordinates(latitude, longitude);
      await fetchHourlyForecastByCoordinates(latitude, longitude);
      await fetchDailyForecastByCoordinates(latitude, longitude);
      isLoading = false; // Set loading to false when data is fetched
      notifyListeners();
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastPromptTime = prefs.containsKey('lastLocationPrompt')
        ? DateTime.parse(prefs.getString('lastLocationPrompt')!)
        : DateTime.fromMillisecondsSinceEpoch(0); // Very old date

    if (!serviceEnabled &&
        DateTime.now().difference(lastPromptTime) > const Duration(hours: 24)) {
      await prefs.setString('lastLocationPrompt', DateTime.now().toIso8601String());
      // Prompt the user to enable location services
      locationPermissionAlertDialogu();

      // Add code to handle user response
    } else if (serviceEnabled) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;
      weatherFuture = fetchWeatherDataByCoordinates(latitude, longitude);
      await fetchHourlyForecastByCoordinates(latitude, longitude);
      await fetchDailyForecastByCoordinates(latitude, longitude);
      isLoading = false; // Set loading to false when data is fetched
      notifyListeners();
    }
  }

  Future<Weather?> fetchWeatherDataByCoordinates(
      double latitude, double longitude) async {
    isLoading = true;
    notifyListeners();
    Weather? fetchedWeather;
    try {
      fetchedWeather =
          await weatherFactory.currentWeatherByLocation(latitude, longitude);

      weather = fetchedWeather;
    } catch (e) {
      print('Error fetching weather data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return fetchedWeather;
  }

  Future<List<Weather?>> fetchHourlyForecastByCoordinates(
      double latitude, double longitude) async {
    isLoading = true;
    notifyListeners();
    try {
      hourlyForecast =
          await weatherFactory.fiveDayForecastByLocation(latitude, longitude);
    } catch (e) {
      print('Error fetching hourly forecast: $e');
    } finally {
      isLoading = false;
      notifyListeners();
      return hourlyForecast!;
    }
  }

  Future<List<Weather?>> fetchDailyForecastByCoordinates(
      double latitude, double longitude) async {
    isLoading = true;
    notifyListeners();
    try {
      dailyForecast =
          await weatherFactory.fiveDayForecastByLocation(latitude, longitude);
    } catch (e) {
      print('Error fetching daily forecast: $e');
    } finally {
      isLoading = false;
      notifyListeners();
      return dailyForecast!;
    }
  }

  Future<Weather?> fetchWeatherData(String city) async {
    isLoading = true;
    notifyListeners();
    Weather? fetchedWeather;
    try {
      fetchedWeather = await weatherFactory.currentWeatherByCityName(city);
      weather = fetchedWeather;
    } catch (e) {
      print('Error fetching weather data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return fetchedWeather;
  }

  Future<void> fetchHourlyForecast(String city) async {
    isLoading = true;
    notifyListeners();
    try {
      hourlyForecast = await weatherFactory.fiveDayForecastByCityName(city);
    } catch (e) {
      print('Error fetching hourly forecast: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailyForecast(String city) async {
    isLoading = true;
    notifyListeners();
    try {
      dailyForecast = await weatherFactory.fiveDayForecastByCityName(city);
    } catch (e) {
      print('Error fetching daily forecast: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
