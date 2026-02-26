import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhan/adhan.dart';
import '../../blocs/prayer/prayer_bloc.dart';
import '../../blocs/prayer/prayer_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../../core/constants/app_typography.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  @override
  Widget build(BuildContext context) {
    context.watch<SettingsCubit>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Arah Kiblat',
            style: AppTypography.titleMedium
                .copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<PrayerBloc, PrayerState>(
        builder: (context, state) {
          if (state is! PrayerLoaded) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.accent));
          }

          // Use location from PrayerBloc
          // Try to decode latitude and longitude if the state.location has them, or if it's dynamic
          // Assuming LocationEntity has latitude and longitude
          final lat = (state.location.latitude as num).toDouble();
          final lng = (state.location.longitude as num).toDouble();
          final qiblaDirection = Qibla(Coordinates(lat, lng)).direction;

          return StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Gagal memuat kompas',
                      style: AppTypography.bodyLarge),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(color: AppColors.accent));
              }

              double? heading = snapshot.data?.heading;

              if (heading == null) {
                return Center(
                  child: Text('Perangkat tidak mendukung kompas',
                      style: AppTypography.bodyLarge),
                );
              }

              // Calculate how much the Qibla needle needs to rotate
              final compassAngle = -heading * (pi / 180);

              return SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${qiblaDirection.toStringAsFixed(1)}°',
                      style: AppTypography.displayLarge
                          .copyWith(color: AppColors.accent),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Arah Kiblat dari lokasimu',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 60),

                    // Modern Compass UI
                    Center(
                      child: Container(
                        height: 280,
                        width: 280,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardDark,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                              color: AppColors.glassBorder, width: 2),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Main Compass dial (North indicator)
                            Transform.rotate(
                              angle: compassAngle,
                              child: _buildCompassDial(),
                            ),
                            // Qibla Indicator
                            Transform.rotate(
                              angle:
                                  compassAngle + (qiblaDirection * (pi / 180)),
                              child: _buildQiblaNeedle(),
                            ),
                            // Center pin
                            Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCompassDial() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(color: AppColors.textMuted.withOpacity(0.3), width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // N S E W Markers
          Positioned(
            top: 10,
            child: Text('U',
                style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ),
          Positioned(
            bottom: 10,
            child: Text('S',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Positioned(
            right: 15,
            child: Text('T',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Positioned(
            left: 15,
            child: Text('B',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          // A subtle needle pointing North
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 35),
              width: 4,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaNeedle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.explore_rounded,
          size: 40,
          color: AppColors.accent,
        ),
        Container(
          width: 6,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
        ),
        const SizedBox(height: 100), // Offset to balance the needle
      ],
    );
  }
}
