import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mwf_mobile/core/auth/auth_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late AuthRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    repository = AuthRepository(mockClient);
  });

  test('signOut calls Supabase auth signOut', () async {
    when(() => mockAuth.signOut()).thenAnswer((_) async {});

    await repository.signOut();

    verify(() => mockAuth.signOut()).called(1);
  });

  test('currentUser returns null when not authenticated', () {
    when(() => mockAuth.currentUser).thenReturn(null);

    expect(repository.currentUser, isNull);
  });

  test('onAuthStateChange returns stream from Supabase', () {
    final controller = Stream<AuthState>.empty();
    when(() => mockAuth.onAuthStateChange).thenAnswer((_) => controller);

    expect(repository.onAuthStateChange, isA<Stream<AuthState>>());
  });
}
