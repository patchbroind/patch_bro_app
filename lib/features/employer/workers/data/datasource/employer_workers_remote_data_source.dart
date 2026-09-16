import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class EmployerWorkersRemoteDataSource {
  EmployerWorkersRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<List<EmployerWorkerEntity>> getWorkers() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));

    return const [
      EmployerWorkerEntity(
        id: 'worker-1',
        name: 'John Mathew',
        profession: 'Plumber',
        rating: 4.8,
        reviewCount: 124,
        distanceKm: 2.4,
        isFavourite: false,
        isAvailableToday: true,
        availableTomorrow: true,
        skills: [
          'Pipe Repair',
          'Bathroom',
          'Water Tank',
        ],
        about:
            'Experienced plumber with more than 6 years of residential and commercial plumbing experience. Specialises in bathroom fittings, pipe repairs, water tank installation and leak repair.',
        experienceYears: 6,
        jobsCompleted: 148,
        responseRate: 96,
        availabilityDays: [
          'Mon',
          'Tue',
          'Thu',
          'Fri',
          'Sat',
        ],
        location: 'Kalikavu, Kerala',
        phone: '+91 90000 00001',
      ),
      EmployerWorkerEntity(
        id: 'worker-2',
        name: 'Rakesh Kumar',
        profession: 'Electrician',
        rating: 4.6,
        reviewCount: 98,
        distanceKm: 3.1,
        isFavourite: false,
        isAvailableToday: true,
        availableTomorrow: true,
        skills: [
          'Wiring',
          'Fan Installation',
          'Switch Repair',
        ],
        about:
            'Professional electrician experienced in residential wiring, lighting, fan installation and electrical maintenance.',
        experienceYears: 5,
        jobsCompleted: 121,
        responseRate: 93,
        availabilityDays: [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
        ],
        location: 'Manjeri, Kerala',
        phone: '+91 90000 00002',
      ),
      EmployerWorkerEntity(
        id: 'worker-3',
        name: 'Shafeeq A',
        profession: 'Carpenter',
        rating: 4.7,
        reviewCount: 76,
        distanceKm: 4.5,
        isFavourite: false,
        isAvailableToday: false,
        availableTomorrow: true,
        skills: [
          'Furniture',
          'Wood Work',
          'Door Repair',
        ],
        about:
            'Skilled carpenter specialising in custom furniture, wood work, doors and interior finishing.',
        experienceYears: 7,
        jobsCompleted: 109,
        responseRate: 91,
        availabilityDays: [
          'Tue',
          'Wed',
          'Thu',
          'Sat',
        ],
        location: 'Nilambur, Kerala',
        phone: '+91 90000 00003',
      ),
      EmployerWorkerEntity(
        id: 'worker-4',
        name: 'Anoop Das',
        profession: 'Painter',
        rating: 4.5,
        reviewCount: 62,
        distanceKm: 5.2,
        isFavourite: false,
        isAvailableToday: true,
        availableTomorrow: true,
        skills: [
          'Interior Painting',
          'Exterior',
          'Wall Finishing',
        ],
        about:
            'Experienced painter for residential and commercial interior and exterior painting projects.',
        experienceYears: 4,
        jobsCompleted: 87,
        responseRate: 89,
        availabilityDays: [
          'Mon',
          'Wed',
          'Fri',
          'Sat',
        ],
        location: 'Wandoor, Kerala',
        phone: '+91 90000 00004',
      ),
      EmployerWorkerEntity(
        id: 'worker-5',
        name: 'Faisal TK',
        profession: 'AC Technician',
        rating: 4.7,
        reviewCount: 89,
        distanceKm: 5.2,
        isFavourite: true,
        isAvailableToday: true,
        availableTomorrow: true,
        skills: [
          'AC Repair',
          'Installation',
          'Service',
        ],
        about:
            'AC technician with experience in split and window AC installation, repair and servicing.',
        experienceYears: 6,
        jobsCompleted: 136,
        responseRate: 95,
        availabilityDays: [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
        ],
        location: 'Perinthalmanna, Kerala',
        phone: '+91 90000 00005',
      ),
      EmployerWorkerEntity(
        id: 'worker-6',
        name: 'Nithin Raj',
        profession: 'Painter',
        rating: 4.5,
        reviewCount: 62,
        distanceKm: 6.8,
        isFavourite: true,
        isAvailableToday: true,
        availableTomorrow: false,
        skills: [
          'Interior Painting',
          'Exterior',
        ],
        about:
            'Painter specialising in home interiors, exterior coating and wall finishing.',
        experienceYears: 5,
        jobsCompleted: 94,
        responseRate: 88,
        availabilityDays: [
          'Mon',
          'Thu',
          'Fri',
          'Sun',
        ],
        location: 'Malappuram, Kerala',
        phone: '+91 90000 00006',
      ),
    ];
  }

  Future<void> toggleFavourite(String workerId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}