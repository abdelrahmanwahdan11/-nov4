import '../../domain/models/car.dart';

const List<Car> dummyCars = <Car>[
  Car(
    id: 'car-1',
    brand: 'EcoMotion',
    model: 'Leafline',
    year: 2024,
    imageUrl:
        'https://images.unsplash.com/photo-1549923746-c502d488b3ea?auto=format&fit=crop&w=1200&q=80',
    asset3D: 'assets/models/eco_compact.obj',
    specs: <String, String>{
      'range': '420 km',
      'battery': '72 kWh',
      'acceleration': '0-100 km/h in 7.1s',
      'drive': 'FWD',
      'charging': '120 kW fast',
    },
  ),
  Car(
    id: 'car-2',
    brand: 'EcoMotion',
    model: 'Leafline Plus',
    year: 2025,
    imageUrl:
        'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=1200&q=80',
    asset3D: 'assets/models/eco_compact.obj',
    specs: <String, String>{
      'range': '480 km',
      'battery': '82 kWh',
      'acceleration': '0-100 km/h in 6.2s',
      'drive': 'AWD',
      'charging': '150 kW fast',
    },
  ),
  Car(
    id: 'car-3',
    brand: 'SunDrive',
    model: 'Aurora',
    year: 2023,
    imageUrl:
        'https://images.unsplash.com/photo-1511396275271-2c148cd1f5eb?auto=format&fit=crop&w=1200&q=80',
    asset3D: 'assets/models/eco_compact.obj',
    specs: <String, String>{
      'range': '510 km',
      'battery': '88 kWh',
      'acceleration': '0-100 km/h in 6.0s',
      'drive': 'RWD',
      'charging': '180 kW fast',
    },
  ),
  Car(
    id: 'car-4',
    brand: 'SunDrive',
    model: 'Aurora Touring',
    year: 2024,
    imageUrl:
        'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1200&q=80',
    asset3D: 'assets/models/eco_compact.obj',
    specs: <String, String>{
      'range': '540 km',
      'battery': '94 kWh',
      'acceleration': '0-100 km/h in 5.6s',
      'drive': 'AWD',
      'charging': '200 kW fast',
    },
  ),
  Car(
    id: 'car-5',
    brand: 'UrbanPulse',
    model: 'Metro E',
    year: 2022,
    imageUrl:
        'https://images.unsplash.com/photo-1462396881884-de2c07cb95ed?auto=format&fit=crop&w=1200&q=80',
    asset3D: 'assets/models/eco_compact.obj',
    specs: <String, String>{
      'range': '360 km',
      'battery': '64 kWh',
      'acceleration': '0-100 km/h in 8.4s',
      'drive': 'FWD',
      'charging': '110 kW fast',
    },
  ),
  Car(
    id: 'car-6',
    brand: 'UrbanPulse',
    model: 'Metro E Max',
    year: 2024,
    imageUrl:
        'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?auto=format&fit=crop&w=1200&q=80',
    asset3D: 'assets/models/eco_compact.obj',
    specs: <String, String>{
      'range': '410 km',
      'battery': '76 kWh',
      'acceleration': '0-100 km/h in 7.4s',
      'drive': 'AWD',
      'charging': '140 kW fast',
    },
  ),
  Car(
    id: 'car-7',
    brand: 'Glide',
    model: 'Whisper',
    year: 2023,
    imageUrl:
        'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?auto=format&fit=crop&w=1200&q=80',
    asset3D: 'assets/models/eco_compact.obj',
    specs: <String, String>{
      'range': '450 km',
      'battery': '78 kWh',
      'acceleration': '0-100 km/h in 6.8s',
      'drive': 'RWD',
      'charging': '160 kW fast',
    },
  ),
  Car(
    id: 'car-8',
    brand: 'Glide',
    model: 'Whisper Touring',
    year: 2025,
    imageUrl:
        'https://images.unsplash.com/photo-1525609004556-c46c7d6cf023?auto=format&fit=crop&w=1200&q=80',
    asset3D: 'assets/models/eco_compact.obj',
    specs: <String, String>{
      'range': '520 km',
      'battery': '90 kWh',
      'acceleration': '0-100 km/h in 5.9s',
      'drive': 'AWD',
      'charging': '210 kW fast',
    },
  ),
];
