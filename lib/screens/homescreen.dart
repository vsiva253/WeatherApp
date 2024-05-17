import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:WeatherApp/provider/weather_provider.dart';
import 'package:weather/weather.dart';
// Adjust the import based on your file structure




class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
  body: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF6E58E2),
          Color(0xFF3A1C71),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Column(
      children: [
        const SizedBox(height: 90),
        buildSearchField(context),
        Expanded(
          child: Consumer<WeatherProvider>(
            builder: (context, weatherProvider, child) {
              if (weatherProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (weatherProvider.weather == null || weatherProvider.hourlyForecast == null || weatherProvider.dailyForecast == null) {
                return const Center(child: Text('Enter a location to get weather data'));
              } else {
                return buildWeatherDetails(weatherProvider.weather!, weatherProvider.hourlyForecast!, weatherProvider.dailyForecast!);
              }
            },
          ),
        ),
      ],
    ),
  ),
);

  }

  Widget buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: locationController,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        decoration: InputDecoration(
          hintText: 'Enter a location',
          prefixIcon:const Padding(
            padding:  EdgeInsets.only(left: 5,right: 5),
            child:  Icon(
              Icons.search,
              color: Colors.white,
              size: 30,
            ),
          ),
          hintStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: const Color(0xFF4C35EB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      
         onSubmitted: (value) {
  final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
  weatherProvider.fetchWeatherData(value);
  weatherProvider.fetchHourlyForecast(value); 
  weatherProvider.fetchDailyForecast(value);
  // Add this line
},

        
      ),
    );
  }

  Widget buildWeatherDetails(Weather weather, List<Weather> hourlyWeather, List<Weather> dailyWeather) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildWeatherHeader(weather),
          const SizedBox(height: 20),
          buildTodayWeatherInfo(),
          const SizedBox(height: 20),
          buildHourlyForecast(hourlyWeather),
          const SizedBox(height: 20),
          buildWeeklyForecast(dailyWeather),
          const SizedBox(height: 30),
          buildAirQualityCard(),
              const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget buildWeatherHeader(Weather weather) {
    return Center(
      child: Column(
        children: [
          Image.network(
            'https://openweathermap.org/img/wn/${weather.weatherIcon}@2x.png',
            width: 150,
            height: 150,
            fit: BoxFit.fill ,
          ),
          const SizedBox(height: 10),
          Text(
            '${weather.areaName}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${weather.temperature?.celsius?.toStringAsFixed(0)}°',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "Max: ${weather.tempMax?.celsius?.truncate()}° Min: ${weather.tempMin?.celsius?.truncate()}°",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTodayWeatherInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Today",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildHourlyForecast(List<Weather> hourlyWeather) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (index) {
          return Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4C35EB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _buildForecastCard(
              time: '${(index + 1) * 3}:00',
              icon: 'https://openweathermap.org/img/wn/${hourlyWeather[index].weatherIcon}@2x.png',
              temperature: '${ hourlyWeather[index].temperature?.celsius?.toStringAsFixed(0)}°C',
            ),
          );
        }),
      ),
    );
  }

  Widget buildWeeklyForecast(List<Weather> dailyWeather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "7-Days Forecasts",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(7, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C35EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildForecastCard(
                  time: '${DateTime.now().day + index} ${_getMonthName(DateTime.now().month)}',
                  icon: 'https://openweathermap.org/img/wn/${dailyWeather[index].weatherIcon}@2x.png',
                  temperature: '${dailyWeather[index].temperature?.celsius?.truncate()}°C',
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastCard({
    required String time,
    required String icon,
    required String temperature,
  }) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Image.network(
          icon,
          height: 50,
          width: 50,
        ),
        const SizedBox(height: 10),
        Text(
          temperature,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildAirQualityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4C35EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.trip_origin,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AIR QUALITY",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                "3-Low Health Risk",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
