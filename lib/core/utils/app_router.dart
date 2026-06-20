// lib/core/utils/app_router.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/borrower/presentation/pages/borrower_home_page.dart';
import '../../features/borrower/presentation/pages/borrower_orders_page.dart';
import '../../features/borrower/presentation/pages/booking_page.dart';
import '../../features/borrower/presentation/pages/listing_detail_page.dart';

import '../../features/lender/presentation/pages/lender_dashboard_page.dart';
import '../../features/lender/presentation/pages/add_listing_page.dart';
import '../../features/lender/presentation/pages/listing_schedule_page.dart';
import '../../features/lender/presentation/pages/rating_borrower_page.dart';

import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/chat/presentation/pages/chat_room_page.dart';
import '../../features/lender/presentation/pages/lender_bookings_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      final isLoggedIn = authState.value != null;

      final isAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthPage) {
        return '/login';
      }

      if (isLoggedIn && isAuthPage) {
        final role = authState.value?.role;

        if (role == 'lender') {
          return '/lender';
        }

        return '/borrower';
      }

      return null;
    },

    routes: [
      // =====================
      // AUTH
      // =====================

      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),

      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterPage(),
      ),

      // =====================
      // BORROWER
      // =====================

      GoRoute(
        path: '/borrower',
        builder: (_, __) => const BorrowerHomePage(),
        routes: [
          GoRoute(
            path: 'listing/:id',
            builder: (_, state) => ListingDetailPage(
              listingId: state.pathParameters['id']!,
            ),
          ),

          GoRoute(
            path: 'booking/:listingId',
            builder: (_, state) => BookingPage(
              listingId:
                  state.pathParameters['listingId']!,
            ),
          ),

          GoRoute(
            path: 'orders',
            builder: (_, __) =>
                const BorrowerOrdersPage(),
          ),
        ],
      ),

      // =====================
      // LENDER
      // =====================

      GoRoute(
        path: '/lender',
        builder: (_, __) =>
            const LenderDashboardPage(),
        routes: [
          GoRoute(
  path: 'bookings',
  builder: (_, __) => const LenderBookingsPage(),
),
          GoRoute(
            path: 'add-listing',
            builder: (_, __) =>
                const AddListingPage(),
          ),

          GoRoute(
            path: 'edit-listing/:id',
            builder: (_, state) => AddListingPage(
              listingId:
                  state.pathParameters['id'],
            ),
          ),

          GoRoute(
            path: 'chat',
            builder: (_, __) =>
                const ChatListPage(),
          ),

          GoRoute(
            path: 'schedule/:id',
            builder: (_, state) =>
                ListingSchedulePage(
              listingId:
                  state.pathParameters['id']!,
            ),
          ),

          GoRoute(
  path: 'rating',
  builder: (_, state) => RatingBorrowerPage(
    borrowerId:
        state.uri.queryParameters['borrowerId'] ?? '',
    borrowerName:
        state.uri.queryParameters['borrowerName'] ?? '',
  ),
),
        ],
      ),

      // =====================
      // CHAT
      // =====================

      GoRoute(
        path: '/chats',
        builder: (_, __) =>
            const ChatListPage(),
        routes: [
          GoRoute(
            path: ':roomId',
            builder: (_, state) =>
                ChatRoomPage(
              roomId:
                  state.pathParameters['roomId']!,
            ),
          ),
        ],
      ),
    ],
  );
});